import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

class SocialLinkDialog {
  static Future<void> show(
    BuildContext context,
    String userId, {
    SocialLink? existingLink,
    required int nextOrder,
    Future<void> Function()? onSaved,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(
      text: existingLink?.title ?? '',
    );
    final displayLabelController = TextEditingController(
      text: existingLink?.displayLabel ?? '',
    );
    final urlController = TextEditingController(text: existingLink?.url ?? '');
    var platform = existingLink?.platform ?? 'instagram';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF171A25),
              title: Text(
                existingLink == null ? 'Add Social Link' : 'Edit Social Link',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: platform,
                        dropdownColor: const Color(0xFF171A25),
                        decoration: const InputDecoration(
                          labelText: 'Platform',
                        ),
                        items: kSocialPlatforms
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p,
                                child: Text(
                                  socialPlatformLabel(p),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => platform = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.s12),
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Custom title (optional)',
                        ),
                      ),
                      const SizedBox(height: AppSizes.s12),
                      TextFormField(
                        controller: displayLabelController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Button label (optional)',
                          hintText: 'e.g. Follow me on Instagram',
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.length > 120) {
                            return 'Label must be 120 characters or less';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.s12),
                      TextFormField(
                        controller: urlController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'URL',
                          hintText: 'https://example.com/your-profile',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'URL is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    var normalizedUrl = urlController.text.trim();
                    if (!normalizedUrl.startsWith('http://') &&
                        !normalizedUrl.startsWith('https://')) {
                      normalizedUrl = 'https://$normalizedUrl';
                    }

                    try {
                      final client = Supabase.instance.client;
                      final resolvedDisplayLabel =
                          displayLabelController.text.trim().isEmpty
                          ? socialPlatformDefaultDisplayLabel(platform)
                          : displayLabelController.text.trim();
                      final payload = {
                        'user_id': userId,
                        'platform': platform,
                        'url': normalizedUrl,
                        'title': titleController.text.trim().isEmpty
                            ? null
                            : titleController.text.trim(),
                        'display_label': resolvedDisplayLabel,
                        'display_order':
                            existingLink?.displayOrder ?? nextOrder,
                      };

                      if (existingLink == null) {
                        await client.from('social_links').insert(payload);
                      } else {
                        await client
                            .from('social_links')
                            .update(payload)
                            .eq('id', existingLink.id);
                      }

                      if (onSaved != null) {
                        await onSaved();
                      }
                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existingLink == null
                                  ? 'Social link added'
                                  : 'Social link updated',
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save link: $error'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(existingLink == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
