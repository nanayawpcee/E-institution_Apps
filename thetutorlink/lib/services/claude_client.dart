import 'dart:convert';

import 'package:http/http.dart' as http;

/// Where the assistant sends its requests, and with what credential.
///
/// Both values are compile-time constants supplied with `--dart-define`, so
/// nothing secret is checked into the repo.
///
/// **Ship with [proxyUrl], not [apiKey].** A key compiled into a mobile binary
/// can be extracted from the app package by anyone who downloads it, and it
/// would be billable to this account. [apiKey] exists so the feature can be
/// exercised on a local build; production traffic should go through a backend
/// that holds the key and forwards to the Messages API.
class AiConfig {
  const AiConfig._();

  /// A backend endpoint that accepts this app's JSON body, attaches the
  /// Anthropic credential server-side, and returns the API's response
  /// unchanged. The production path.
  static const String proxyUrl =
      String.fromEnvironment('TUTORLINK_AI_PROXY_URL');

  /// Direct Anthropic credential. Local development only — see the class note.
  static const String apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  static bool get isConfigured => proxyUrl.isNotEmpty || apiKey.isNotEmpty;

  /// True when calls go straight to Anthropic with an embedded key.
  static bool get isDirectMode => proxyUrl.isEmpty && apiKey.isNotEmpty;
}

/// One turn in the conversation sent to the model.
class AiTurn {
  const AiTurn({required this.role, required this.text});

  /// `user` or `assistant`.
  final String role;
  final String text;
}

/// Raised when the assistant cannot produce a reply. [retryable] distinguishes
/// transient failures (rate limits, overload, network) from ones that will
/// fail again identically (bad request, bad credential).
class AiException implements Exception {
  const AiException(this.message, {this.retryable = false});

  final String message;
  final bool retryable;

  @override
  String toString() => 'AiException: $message';
}

/// Minimal Claude Messages API client.
///
/// Dart has no official Anthropic SDK, so this talks to the REST endpoint
/// directly. It is deliberately small: one non-streaming call, because the
/// assistant's answers are short and the UI shows a "Thinking…" placeholder
/// rather than streaming tokens.
class ClaudeClient {
  ClaudeClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const String _endpoint = 'https://api.anthropic.com/v1/messages';
  static const String _apiVersion = '2023-06-01';

  /// Opus 5. Effort is held low because every answer is a short, conversational
  /// reply — that keeps the round trip fast enough for a chat UI without
  /// giving up adaptive thinking on the turns that need it.
  static const String _model = 'claude-opus-5';

  /// Headroom for a sub-90-word reply plus any adaptive thinking.
  static const int _maxTokens = 2048;

  Future<String> complete({
    required String system,
    required List<AiTurn> history,
  }) async {
    if (!AiConfig.isConfigured) {
      throw const AiException(
        'The assistant is not configured for this build.',
      );
    }

    final body = jsonEncode({
      'model': _model,
      'max_tokens': _maxTokens,
      'system': system,
      'thinking': {'type': 'adaptive'},
      'output_config': {'effort': 'low'},
      // Route around a safety refusal automatically rather than surfacing an
      // empty turn to the student.
      'betas': ['server-side-fallback-2026-07-01'],
      'fallbacks': 'default',
      'messages': [
        for (final turn in history)
          {'role': turn.role, 'content': turn.text},
      ],
    });

    final http.Response response;
    try {
      response = await _http
          .post(Uri.parse(_target), headers: _headers, body: body)
          .timeout(const Duration(seconds: 60));
    } catch (e) {
      throw AiException('Could not reach the assistant: $e', retryable: true);
    }

    if (response.statusCode != 200) {
      throw _errorFor(response);
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const AiException('The assistant returned an unexpected response.');
    }

    // A refusal comes back as HTTP 200 with no usable text, so check the stop
    // reason before reading content.
    if (decoded['stop_reason'] == 'refusal') {
      throw const AiException(
        "I can't help with that one. Try asking about your coursework.",
      );
    }

    final text = _textFrom(decoded['content']);
    if (text.isEmpty) {
      throw const AiException('The assistant returned an empty reply.');
    }
    return text;
  }

  String get _target =>
      AiConfig.proxyUrl.isNotEmpty ? AiConfig.proxyUrl : _endpoint;

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        if (AiConfig.proxyUrl.isEmpty) ...{
          'x-api-key': AiConfig.apiKey,
          'anthropic-version': _apiVersion,
        },
      };

  /// The response's `content` is a list of blocks; the reply is every `text`
  /// block joined, ignoring any thinking blocks.
  static String _textFrom(Object? content) {
    if (content is! List) return '';
    final buffer = StringBuffer();
    for (final block in content) {
      if (block is Map && block['type'] == 'text' && block['text'] is String) {
        buffer.write(block['text'] as String);
      }
    }
    return buffer.toString().trim();
  }

  static AiException _errorFor(http.Response response) {
    String detail = '';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        detail = (decoded['error']['message'] ?? '').toString();
      }
    } catch (_) {
      // Non-JSON error body — the status code alone drives the message.
    }

    switch (response.statusCode) {
      case 401:
      case 403:
        return AiException(
          'The assistant is not authorised for this build.'
          '${detail.isEmpty ? '' : ' ($detail)'}',
        );
      case 429:
        return const AiException(
          'The assistant is busy right now. Try again in a moment.',
          retryable: true,
        );
      case 500:
      case 502:
      case 503:
      case 529:
        return const AiException(
          'The assistant is temporarily unavailable.',
          retryable: true,
        );
      default:
        return AiException(
          'The assistant failed (${response.statusCode}).'
          '${detail.isEmpty ? '' : ' $detail'}',
        );
    }
  }

  void dispose() => _http.close();
}
