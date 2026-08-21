import 'package:flutter/material.dart';

import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/check_permission.dart';

/// Class settings: the permissions the classroom needs to download material.
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _permissions = CheckPermission();
  bool? _storageGranted;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final granted = await _permissions.isStoragePermission();
    if (mounted) setState(() => _storageGranted = granted);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text('Permissions', style: TLText.cardTitle(t.text)),
        const SizedBox(height: 12),
        TLMenuGroup(
          children: [
            TLMenuRow(
              label: 'Storage access',
              leading: Icons.sd_storage_outlined,
              onTap: _refresh,
              trailing: Text(
                _storageGranted == null
                    ? 'Checking…'
                    : _storageGranted!
                        ? 'Granted'
                        : 'Not granted',
                style: TLText.sub(
                  _storageGranted == true ? TLTokens.success : t.textSub,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Storage access lets you download resources and assignments to your '
          'device. Tap the row to re-check after changing it in system settings.',
          style: TLText.meta(t.textSub).copyWith(height: 1.5),
        ),
      ],
    );
  }
}
