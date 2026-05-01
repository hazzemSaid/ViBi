// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vibi/core/constants/app_sizes.dart';
// import 'package:vibi/features/profile/domain/entities/social_link.dart';
// import 'package:vibi/features/profile/presentation/view/social_media_view/social_links_cubit.dart';
// import 'package:vibi/features/profile/presentation/widgets/common/social_link_platform.dart';

// class SocialLinkDialog {
//   static Future<void> show(
//     BuildContext context,
//     String userId, {
//     SocialLink? existingLink,
//     String? initialPlatform,
//     required int nextOrder,
//     Future<void> Function()? onSaved,
//   }) async {
//     final formKey = GlobalKey<FormState>();
//     final titleController = TextEditingController(
//       text: existingLink?.title ?? '',
//     );
//     final displayLabelController = TextEditingController(
//       text: existingLink?.displayLabel ?? '',
//     );
//     var platform = existingLink?.platform ?? initialPlatform ?? 'instagram';
//     final urlController = TextEditingController(
//       text: existingLink == null
//           ? ''
//           : usernameFromSocialUrl(platform, existingLink.url),
//     );

//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               backgroundColor: Theme.of(context).colorScheme.surface,
//               title: Text(
//                 existingLink == null ? 'Add Social Link' : 'Edit Social Link',
//                 style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//               ),
//               content: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       DropdownButtonFormField<String>(
//                         initialValue: platform,
//                         dropdownColor: Theme.of(context).colorScheme.surface,
//                         decoration: const InputDecoration(
//                           labelText: 'Platform',
//                         ),
//                         items: kDatabaseSocialPlatforms
//                             .map(
//                               (p) => DropdownMenuItem<String>(
//                                 value: p,
//                                 child: Text(
//                                   socialPlatformLabel(p),
//                                   style: TextStyle(
//                                     color: Theme.of(context).colorScheme.onSurface,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             setDialogState(() {
//                               platform = value;
//                               if (existingLink != null) {
//                                 urlController.text = usernameFromSocialUrl(
//                                   platform,
//                                   existingLink.url,
//                                 );
//                               }
//                             });
//                           }
//                         },
//                       ),
// SizedBox(height: AppSizes.s12),
//                       TextFormField(
//                         controller: titleController,
//                         style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         decoration: const InputDecoration(
//                           labelText: 'Custom title (optional)',
//                         ),
//                       ),
// SizedBox(height: AppSizes.s12),
//                       TextFormField(
//                         controller: displayLabelController,
//                         style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         decoration: const InputDecoration(
//                           labelText: 'Button label (optional)',
//                           hintText: 'e.g. Follow me on Instagram',
//                         ),
//                         validator: (value) {
//                           final trimmed = value?.trim() ?? '';
//                           if (trimmed.length > 120) {
//                             return 'Label must be 120 characters or less';
//                           }
//                           return null;
//                         },
//                       ),
// SizedBox(height: AppSizes.s12),
//                       TextFormField(
//                         controller: urlController,
//                         onChanged: (_) => setDialogState(() {}),
//                         style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         decoration: InputDecoration(
//                           labelText: usesUsernameTemplate(platform)
//                               ? socialUsernameLabel(platform)
//                               : 'URL',
//                           hintText: usesUsernameTemplate(platform)
//                               ? 'username'
//                               : 'https://example.com/your-profile',
//                           prefixText: usesUsernameTemplate(platform)
//                               ? socialUrlPrefix(platform)
//                               : null,
//                           prefixStyle: TextStyle(
//                             color: Theme.of(context).colorScheme.onSurfaceVariant,
//                           ),
//                         ),
//                         validator: (value) {
//                           final input = value?.trim() ?? '';
//                           if (input.isEmpty) {
//                             return usesUsernameTemplate(platform)
//                                 ? 'Username is required'
//                                 : 'URL is required';
//                           }

//                           if (usesUsernameTemplate(platform)) {
//                             final normalized = normalizeSocialUsername(input);
//                             if (!RegExp(
//                               r'^[a-zA-Z0-9_.-]+$',
//                             ).hasMatch(normalized)) {
//                               return 'Invalid username format';
//                             }
//                           }

//                           return null;
//                         },
//                       ),
//                       if (usesUsernameTemplate(platform)) ...[
//                         const SizedBox(height: AppSizes.s8),
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Preview: ${buildSocialUrl(platform, urlController.text)}',
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSurfaceVariant,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(dialogContext).pop(),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     if (!formKey.currentState!.validate()) return;

//                     final normalizedUrl = buildSocialUrl(
//                       platform,
//                       urlController.text,
//                     );

//                     try {
//                       final cubit = context.read<SocialLinksCubit>();
//                       final resolvedDisplayLabel =
//                           displayLabelController.text.trim().isEmpty
//                           ? socialPlatformDefaultDisplayLabel(platform)
//                           : displayLabelController.text.trim();
//                       final resolvedTitle = titleController.text.trim().isEmpty
//                           ? null
//                           : titleController.text.trim();

//                       if (existingLink == null) {
//                         await cubit.addLink(
//                           platform: platform,
//                           url: normalizedUrl,
//                           title: resolvedTitle,
//                           displayLabel: resolvedDisplayLabel,
//                           displayOrder: nextOrder,
//                         );
//                       } else {
//                         await cubit.updateLink(
//                           linkId: existingLink.id,
//                           platform: platform,
//                           url: normalizedUrl,
//                           title: resolvedTitle,
//                           displayLabel: resolvedDisplayLabel,
//                           displayOrder: existingLink.displayOrder,
//                           isActive: existingLink.isActive,
//                         );
//                       }

//                       if (onSaved != null) {
//                         await onSaved();
//                       }
//                       if (context.mounted) {
//                         Navigator.of(dialogContext).pop();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               existingLink == null
//                                   ? 'Social link added'
//                                   : 'Social link updated',
//                             ),
//                           ),
//                         );
//                       }
//                     } catch (error) {
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Failed to save link: $error'),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                   child: Text(existingLink == null ? 'Add' : 'Save'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
