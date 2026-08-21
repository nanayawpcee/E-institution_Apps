import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../theme/app_assets.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';

/// Support contact for the platform.
const String supportContact = '+233504930005';

Future<void> _callSupport() =>
    launchUrlString('tel://$supportContact');

Future<void> _whatsappSupport() => launchUrlString(
    'https://wa.me/$supportContact?text=I have a problem');

/// Contact options for the platform's support team.
Future<void> helpCenterDialog(BuildContext context) {
  return showTLSheet<void>(
    context: context,
    builder: (context) {
      final t = context.tl;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Help center', style: TLText.cardTitle(t.text)),
          const SizedBox(height: 4),
          Text(
            'Reach the TutorLink team on $supportContact.',
            style: TLText.sub(t.textSub),
          ),
          const SizedBox(height: 16),
          TLMenuGroup(
            children: [
              TLMenuRow(
                label: 'WhatsApp us',
                leading: Icons.chat_rounded,
                onTap: () {
                  Navigator.pop(context);
                  _whatsappSupport();
                },
              ),
              TLMenuRow(
                label: 'Call us',
                leading: Icons.call_rounded,
                onTap: () {
                  Navigator.pop(context);
                  _callSupport();
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

/// App identity and version.
Future<void> aboutUs(BuildContext context) {
  return showTLSheet<void>(
    context: context,
    builder: (context) {
      final t = context.tl;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            TLAssets.logo,
            width: 170,
            fit: BoxFit.contain,
            semanticLabel: 'TutorLink',
          ),
          const SizedBox(height: 14),
          Text(
            'TutorLink connects students with tutors for live, one-to-one '
            'classes and shared course material.',
            textAlign: TextAlign.center,
            style: TLText.sub(t.textSub).copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          Text('Version 1.0.1', style: TLText.meta(t.textSub)),
        ],
      );
    },
  );
}
