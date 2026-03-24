import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/providers/social_links_provider.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_dialog.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

class ProfileSocialLinksSection extends StatelessWidget {
  final String userId;

  const ProfileSocialLinksSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SocialLinksCubit(userId: userId, dataSource: socialLinksDataSource),
      child: BlocBuilder<SocialLinksCubit, ViewState<List<SocialLink>>>(
        builder: (context, socialLinksAsync) {
          final links = socialLinksAsync.data ?? const <SocialLink>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Social Media',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SocialLinkDialog.show(
                      context,
                      userId,
                      nextOrder: _getNextOrder(links),
                      onSaved: () => context.read<SocialLinksCubit>().refresh(),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Add social link',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              if (socialLinksAsync.status == ViewStatus.loading)
                const Padding(
                  padding: EdgeInsets.all(AppSizes.s12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (socialLinksAsync.status == ViewStatus.failure)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.s12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Text(
                    'Failed to load social links: ${socialLinksAsync.errorMessage}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              else if (links.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.s16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Text(
                    'No social links yet. Tap + to add Instagram, X, YouTube, Website, and more.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                Column(
                  children: links
                      .map(
                        (link) => _SocialMediaCard(
                          link: link,
                          onTap: () => SocialLinkDialog.show(
                            context,
                            userId,
                            existingLink: link,
                            nextOrder: link.displayOrder,
                            onSaved: () =>
                                context.read<SocialLinksCubit>().refresh(),
                          ),
                          onLongPress: () async {
                            try {
                              final urlString = link.url.trim();
                              final webUrl = urlString.startsWith('https')
                                  ? urlString
                                  : 'https://$urlString';
                              final webUri = Uri.parse(webUrl);

                              if (await canLaunchUrl(webUri)) {
                                await launchUrl(
                                  webUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                debugPrint('Could not launch $webUrl');
                              }
                            } catch (e) {
                              debugPrint('Error launching URL: $e');
                            }
                          },
                          onDelete: () {
                            context.read<SocialLinksCubit>().deleteLink(
                              link.id,
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  int _getNextOrder(List<SocialLink>? links) {
    if (links == null || links.isEmpty) return 0;
    return links.fold<int>(
          0,
          (max, link) => link.displayOrder > max ? link.displayOrder : max,
        ) +
        1;
  }
}

class _SocialMediaCard extends StatelessWidget {
  const _SocialMediaCard({
    required this.link,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  final SocialLink link;
  final VoidCallback onTap;
  final Future<void> Function() onLongPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: link.isActive ? 0.06 : 0.03),
        borderRadius: BorderRadius.circular(AppSizes.r14),
        border: Border.all(
          color: link.isActive ? Colors.white24 : Colors.white10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => onLongPress(),
          borderRadius: BorderRadius.circular(AppSizes.r14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.r14,
              vertical: AppSizes.s12,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Icon(
                    socialPlatformIcon(link.platform),
                    color: link.isActive
                        ? AppColors.textPrimary
                        : Colors.white54,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        link.displayLabel?.trim().isNotEmpty == true
                            ? link.displayLabel!
                            : (link.title?.trim().isNotEmpty == true
                                  ? link.title!
                                  : socialPlatformLabel(link.platform)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: link.isActive
                              ? AppColors.textPrimary
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.s8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    color: Colors.redAccent.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
