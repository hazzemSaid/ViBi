import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/providers/social_links_provider.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_dialog.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

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

          if (socialLinksAsync.status == ViewStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.s12),
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (socialLinksAsync.status == ViewStatus.failure) {
            return const SizedBox.shrink();
          }

          final activeLinks = links.where((link) => link.isActive).toList();

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.s12,
            runSpacing: AppSizes.s8,
            children: [
              ...activeLinks.map(
                (link) => InkResponse(
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
                  radius: 18,
                  child: Icon(
                    socialPlatformIcon(link.platform),
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              InkResponse(
                onTap: () => SocialLinkDialog.show(
                  context,
                  widget.userId,
                  nextOrder: _getNextOrder(links),
                  onSaved: () => _socialLinksCubit.refresh(),
                ),
                radius: 18,
                child: Icon(
                  links.isEmpty ? Icons.add_circle_outline : Icons.add,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
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
