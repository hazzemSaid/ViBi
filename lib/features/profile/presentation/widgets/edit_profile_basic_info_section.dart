import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile_section_card.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_form_field.dart';

class EditProfileBasicInfoSection extends StatelessWidget {
  const EditProfileBasicInfoSection({
    super.key,
    required this.nameController,
    required this.usernameController,
    required this.bioController,
    required this.isPrivate,
    required this.onPrivateChanged,
  });

  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final bool isPrivate;
  final ValueChanged<bool> onPrivateChanged;

  @override
  Widget build(BuildContext context) {
    return EditProfileSectionCard(
      title: 'Profile Details',
      subtitle: 'Your public identity and account visibility settings.',
      child: Column(
        children: [
          ProfileFormField(
            label: 'Name',
            controller: nameController,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSizes.s20),
          ProfileFormField(
            label: 'Username',
            controller: usernameController,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Required';
              if (val.length < 3) return 'Too short';
              return null;
            },
          ),
          const SizedBox(height: AppSizes.s20),
          ProfileFormField(
            label: 'Bio',
            controller: bioController,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.s8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Private account',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'Require follow approval for private content.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            value: isPrivate,
            onChanged: onPrivateChanged,
          ),
        ],
      ),
    );
  }
}
