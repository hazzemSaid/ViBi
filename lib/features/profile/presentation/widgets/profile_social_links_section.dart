import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/providers/social_links_provider.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_social_links_section/social_media_card.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_dialog.dart';

class ProfileSocialLinksSection extends StatefulWidget {
  final String userId;

  const ProfileSocialLinksSection({super.key, required this.userId});

  @override
  State<ProfileSocialLinksSection> createState() =>
      _ProfileSocialLinksSectionState();
}

class _ProfileSocialLinksSectionState extends State<ProfileSocialLinksSection> {
  late final SocialLinksCubit _socialLinksCubit;

  @override
  void initState() {
    super.initState();
    _socialLinksCubit = getIt<SocialLinksCubit>(param1: widget.userId);
  }

  @override
  void dispose() {
    _socialLinksCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SocialLinksCubit>.value(
      value: _socialLinksCubit,
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
                      widget.userId,
                      nextOrder: _getNextOrder(links),
                      onSaved: () => _socialLinksCubit.refresh(),
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
                        (link) => SocialMediaCard(
                          link: link,
                          onTap: () => SocialLinkDialog.show(
                            context,
                            widget.userId,
                            existingLink: link,
                            nextOrder: link.displayOrder,
                            onSaved: () => _socialLinksCubit.refresh(),
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
                            _socialLinksCubit.deleteLink(link.id);
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
