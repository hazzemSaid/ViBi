import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_links_cubit.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_media_cubit_state.dart';
import 'package:vibi/features/profile/presentation/widgets/common/social_link_platform.dart';

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
      child: BlocBuilder<SocialLinksCubit, SocialLinksState>(
        builder: (context, socialLinksState) {
          final links = switch (socialLinksState) {
            SocialLinksLoaded loaded => loaded.links,
            SocialLinksLoading loading => loading.previousLinks,
            SocialLinksFailure failure => failure.previousLinks,
            _ => const <SocialLink>[],
          };

          if (socialLinksState is SocialLinksLoading && links.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.s12),
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (socialLinksState is SocialLinksFailure && links.isEmpty) {
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
                  onTap: () async {
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
                  child: socialPlatformVisual(
                    link.platform,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 18,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
