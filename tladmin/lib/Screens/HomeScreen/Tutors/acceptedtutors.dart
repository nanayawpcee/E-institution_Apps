import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_widgets.dart';
import '../../../utils/passwordgen.dart';
import '../Shell/admin_form.dart';
import '../Shell/admin_nav.dart';

/// Route wrapper kept for the named-route table.
class AddAcceptedTutorScreen extends StatelessWidget {
  static String routeName = 'AddAcceptedTutors';

  const AddAcceptedTutorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const AddTutorBody();
}

class AddTutorBody extends ConsumerStatefulWidget {
  const AddTutorBody({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTutorBody> createState() => _AddTutorBodyState();
}

class _AddTutorBodyState extends ConsumerState<AddTutorBody> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _courseName;
  String _imageName = '';
  Uint8List? _imageBytes;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(adminDataProvider).courses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TLPageHeader(
          title: 'Add Tutor',
          subtitle: 'Onboard an accepted tutor with login access',
        ),
        TLFormCard(
          columns: [
            // Left column — who the tutor is.
            [
              const TLFormLabel('Tutor name'),
              TLField(hint: 'Full name', controller: _nameController),
              const TLFormLabel('Email'),
              TLField(
                hint: 'Email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const TLFormLabel('Bio'),
              TLField(
                hint: 'Short teaching bio',
                controller: _bioController,
                maxLines: 5,
              ),
            ],
            // Right column — access, assignment and the form's actions.
            [
              const TLFormLabel('Password'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TLField(
                      hint: 'Temporary password',
                      controller: _passwordController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TLSecondaryButton(
                    label: 'Generate',
                    onPressed: () => setState(() {
                      _passwordController.text = generateRandomPassword();
                    }),
                  ),
                ],
              ),
              const TLFormLabel('Contact'),
              TLField(
                hint: 'Phone number',
                controller: _contactController,
                keyboardType: TextInputType.phone,
              ),
              const TLFormLabel('Assign course'),
              TLFormDropdown(
                value: _courseName,
                hint: 'Select a course',
                items: courses.map((c) => c.name).toList(),
                onChanged: (v) => setState(() => _courseName = v),
              ),
              const TLFormLabel('Photo'),
              TLUploadRow(
                icon: Icons.person_outline_rounded,
                label: _imageName.isEmpty ? 'Click to upload a photo' : _imageName,
                onTap: _submitting ? null : _pickImage,
                leading: _imageBytes == null
                    ? null
                    : ClipOval(
                        child: Image.memory(
                          _imageBytes!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TLPrimaryButton(
                      label: 'Add Tutor',
                      busy: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TLSecondaryButton(
                    label: 'Clear form',
                    onPressed: _submitting ? null : _clear,
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
      dialogTitle: 'Select Tutor Image',
    );
    if (!mounted) return;

    if (result == null || result.files.isEmpty) {
      _toast('No image selected');
      return;
    }
    setState(() {
      _imageName = result.files.first.name;
      _imageBytes = result.files.single.bytes;
    });
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _toast('Please enter the tutor\'s name');
      return;
    }
    if (_courseName == null) {
      _toast('Please assign a course');
      return;
    }
    if (_imageBytes == null) {
      _toast('Please select an image');
      return;
    }

    setState(() => _submitting = true);
    try {
      // No Storage upload to point a URL at — keep the picked bytes as a data
      // URI so tutor lists can still render the image.
      final imageUrl = 'data:image/png;base64,${base64Encode(_imageBytes!)}';

      final tutor = ref.read(adminDataProvider.notifier).addTutor(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            imageUrl: imageUrl,
            contact: _contactController.text.trim(),
            courseName: _courseName!,
          );

      if (tutor == null) {
        _toast('No matching course found.');
        return;
      }

      _clear();
      _toast('Tutor added');
      ref.read(adminNavProvider.notifier).go(AdminPageKey.tutors);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _clear() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _bioController.clear();
      _contactController.clear();
      _passwordController.clear();
      _courseName = null;
      _imageName = '';
      _imageBytes = null;
    });
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
