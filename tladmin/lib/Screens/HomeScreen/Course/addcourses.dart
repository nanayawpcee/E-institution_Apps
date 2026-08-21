import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../Shell/admin_form.dart';
import '../Shell/admin_nav.dart';

/// Route wrapper kept for the named-route table.
class AddCourse extends StatelessWidget {
  static String routeName = 'AddCourse';

  const AddCourse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const AddCourseBody();
}

class AddCourseBody extends ConsumerStatefulWidget {
  const AddCourseBody({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCourseBody> createState() => _AddCourseBodyState();
}

class _AddCourseBodyState extends ConsumerState<AddCourseBody> {
  static const List<String> _departments = [
    '3D Design',
    'Programming Languages',
    'Biology',
    'Physics',
    'Mathematics',
    'Chemistry',
    'Computer Science',
    'Acturial Science',
    'Biochemistry',
    'Information Technology',
    'Arts and Design',
    'Geography',
    'Languages',
    'Social sciences',
  ];

  final _nameController = TextEditingController();
  final _infoController = TextEditingController();

  String? _department;
  double _durationInHours = 1;

  String _imageName = '';
  Uint8List? _imageBytes;

  String _videoName = '';
  bool _pickingVideo = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TLPageHeader(
          title: 'Add Course',
          subtitle: 'Publish a new course to the catalog',
        ),
        TLFormCard(
          columns: [
            // Left column — the course's written record.
            [
              const TLFormLabel('Course name'),
              TLField(
                hint: 'e.g. Programming Languages',
                controller: _nameController,
              ),
              const TLFormLabel('Department'),
              TLFormDropdown(
                value: _department,
                hint: 'Select a department',
                items: _departments,
                onChanged: (v) => setState(() => _department = v),
              ),
              TLFormLabel('Duration: ${_durationInHours.toStringAsFixed(0)} hrs'),
              Slider(
                value: _durationInHours,
                min: 1,
                max: 40,
                divisions: 39,
                activeColor: TLTokens.primary,
                inactiveColor: t.border,
                label: '${_durationInHours.toStringAsFixed(0)} hrs',
                onChanged: (v) => setState(() => _durationInHours = v),
              ),
              const TLFormLabel('Course info'),
              TLField(
                hint: 'Describe what this course covers',
                controller: _infoController,
                maxLines: 5,
              ),
            ],
            // Right column — media and the form's actions.
            [
              const TLFormLabel('Course icon'),
              TLUploadZone(
                onTap: _submitting ? null : _pickIcon,
                child: _imageBytes == null
                    ? null
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _imagePreview(),
                      ),
                emptyIcon: Icons.image_outlined,
                emptyLabel: 'Click to upload image',
              ),
              const TLFormLabel('Course overview video'),
              TLUploadRow(
                icon: Icons.videocam_outlined,
                label: _pickingVideo
                    ? 'Reading video…'
                    : _videoName.isEmpty
                        ? 'Click to upload an .mp4'
                        : _videoName,
                onTap: _submitting || _pickingVideo ? null : _pickVideo,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TLPrimaryButton(
                      label: 'Add Course',
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

  Widget _imagePreview() {
    if (_imageName.toLowerCase().endsWith('.svg')) {
      return SvgPicture.memory(_imageBytes!, fit: BoxFit.cover);
    }
    return Image.memory(_imageBytes!, fit: BoxFit.cover);
  }

  Future<void> _pickIcon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'svg'],
      dialogTitle: 'Select Course Icon',
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

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp4'],
      dialogTitle: 'Select Course video',
    );
    if (!mounted) return;

    if (result == null || result.files.isEmpty) {
      _toast('No video selected');
      return;
    }
    setState(() {
      _pickingVideo = true;
      _videoName = result.files.single.name;
    });
    // Nothing uploads the bytes anywhere yet, so the file name stands in for
    // the eventual URL — same placeholder the previous screen used.
    setState(() => _pickingVideo = false);
    _toast('Course overview video attached');
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _toast('Please enter a course name');
      return;
    }
    if (_department == null) {
      _toast('Please pick a department');
      return;
    }
    if (_imageBytes == null) {
      _toast('Please select an image');
      return;
    }

    setState(() => _submitting = true);
    try {
      // No Storage upload to point a URL at — keep the picked bytes as a data
      // URI so the course list can still render the image.
      final mimeType = _imageName.toLowerCase().endsWith('.svg')
          ? 'image/svg+xml'
          : 'image/png';
      final imageUrl = 'data:$mimeType;base64,${base64Encode(_imageBytes!)}';

      ref.read(adminDataProvider.notifier).addCourse(
            name: _nameController.text.trim(),
            department: _department!,
            info: _infoController.text.trim(),
            imageUrl: imageUrl,
            duration: _durationInHours,
            videoUrl: _videoName.isEmpty ? null : _videoName,
          );

      _clear();
      _toast('Course added');
      ref.read(adminNavProvider.notifier).go(AdminPageKey.courses);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _clear() {
    setState(() {
      _nameController.clear();
      _infoController.clear();
      _department = null;
      _durationInHours = 1;
      _imageName = '';
      _imageBytes = null;
      _videoName = '';
    });
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
