import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/home.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/image_helpers.dart';
import '../SignIn/sign_in_screen.dart';
import 'models/dialog.dart';

/// Profile tab: identity card, appearance switch, account and support menus.
class UserProfileScreen extends ConsumerStatefulWidget {
  static String routeName = 'UserProfileScreen';

  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
        children: [
          Text('My Account', style: TLText.screenTitle(t.text)),
          const SizedBox(height: 16),
          _IdentityCard(
            name: student?.name ?? '',
            contact: student?.contact ?? '',
            imagePath: student?.userImage ?? '',
            onEditImage: _showImageOptions,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(TLTokens.rLg),
            ),
            child: Row(
              children: [
                Icon(Icons.dark_mode_outlined, size: 19, color: t.text),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Dark mode',
                    style: TLText.body(t.text)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: isDark,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setDark(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Account', style: TLText.cardTitle(t.text)),
          const SizedBox(height: 12),
          TLMenuGroup(
            children: [
              TLMenuRow(
                label: 'Edit name',
                leading: Icons.badge_outlined,
                onTap: () => _editField(isName: true),
              ),
              TLMenuRow(
                label: 'Edit contact',
                leading: Icons.phone_outlined,
                onTap: () => _editField(isName: false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TLMenuGroup(
            children: [
              TLMenuRow(
                label: 'Notification settings',
                leading: Icons.notifications_none_rounded,
                onTap: () => _notImplemented('Notification settings'),
              ),
              TLMenuRow(
                label: 'Privacy and policy',
                leading: Icons.shield_outlined,
                onTap: () => _notImplemented('Privacy and policy'),
              ),
              TLMenuRow(
                label: 'Help center',
                leading: Icons.help_outline_rounded,
                onTap: () => helpCenterDialog(context),
              ),
              TLMenuRow(
                label: 'About us',
                leading: Icons.info_outline_rounded,
                onTap: () => aboutUs(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Material(
              color: TLTokens.danger,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _logout,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 150,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'Logout',
                    style: TLText.cardTitle(Colors.white).copyWith(fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, SignInScreen.routeName, (route) => false);
  }

  void _notImplemented(String what) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$what is coming soon')));
  }

  /// Camera-or-gallery picker, then crop, then store the local path.
  Future<void> _showImageOptions() async {
    final source = await showTLSheet<ImageSource>(
      context: context,
      builder: (context) {
        final t = context.tl;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Profile photo', style: TLText.cardTitle(t.text)),
            const SizedBox(height: 10),
            TLMenuGroup(
              children: [
                TLMenuRow(
                  label: 'Take a photo',
                  leading: Icons.photo_camera_outlined,
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                TLMenuRow(
                  label: 'Choose from gallery',
                  leading: Icons.photo_library_outlined,
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    final cropped = await ImageCropper()
        .cropImage(sourcePath: picked.path, maxHeight: 1080, maxWidth: 1080);
    if (cropped != null) {
      ref.read(authProvider.notifier).updateImage(cropped.path);
    }
  }

  /// Updates either the display name or the contact number.
  Future<void> _editField({required bool isName}) async {
    final controller = TextEditingController(
      text: isName
          ? ref.read(authProvider)?.name ?? ''
          : ref.read(authProvider)?.contact ?? '',
    );

    final saved = await showDialog<String>(
      context: context,
      builder: (context) {
        final t = context.tl;
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isName ? 'Update your name' : 'Update your contact',
                style: TLText.cardTitle(t.text).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 14),
              TLField(
                hint: isName ? 'Your name' : 'Your contact number',
                controller: controller,
                keyboardType: isName ? TextInputType.name : TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TLButton(
                      label: 'Save',
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
    if (saved == null || saved.isEmpty) return;

    if (isName) {
      ref.read(authProvider.notifier).updateName(saved);
    } else {
      ref.read(authProvider.notifier).updateContact(saved);
    }
  }
}

/// Avatar, name and contact, with a camera badge over the photo.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.contact,
    required this.imagePath,
    required this.onEditImage,
  });

  final String name;
  final String contact;
  final String imagePath;
  final VoidCallback onEditImage;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLCard(
      padding: const EdgeInsets.all(16),
      radius: TLTokens.rXl,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              TLAvatar(imagePath: imagePath, size: 64),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onEditImage,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: TLTokens.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.card, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Your name' : name,
                  style: TLText.cardTitle(t.text).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.isEmpty ? 'Add a contact number' : contact,
                  style: TLText.meta(t.textSub).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular avatar that falls back to the bundled placeholder illustration.
class TLAvatar extends StatelessWidget {
  const TLAvatar({Key? key, required this.imagePath, this.size = 48})
      : super(key: key);

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imagePath.isEmpty
            ? ColoredBox(
                color: t.cardAlt,
                child: SvgPicture.asset(
                  TLAssets.avatar,
                  fit: BoxFit.cover,
                  semanticsLabel: 'No profile photo',
                ),
              )
            : Image(image: appImageProvider(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}
