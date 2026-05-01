import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/cubit/social_links_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/social_media_state.dart';
import 'package:vibi/features/profile/presentation/widgets/common/social_link_platform.dart';

/// Read-only social links section for public profiles
class PublicProfileSocialLinksSection extends StatefulWidget {
  final String userId;

  const PublicProfileSocialLinksSection({super.key, required this.userId});

  @override
  State<PublicProfileSocialLinksSection> createState() =>
      _PublicProfileSocialLinksSectionState();
}

class _PublicProfileSocialLinksSectionState
    extends State<PublicProfileSocialLinksSection> {
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
          if (activeLinks.isEmpty) {
            return const SizedBox.shrink();
          }

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.s12,
            runSpacing: AppSizes.s8,
            children: activeLinks
                .map(
                  (link) => InkResponse(
                    onTap: () => _launchUrl(link.url),
                    radius: 18,
                    child: socialPlatformVisual(
                      link.platform,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final url = urlString.trim();
      final webUrl = url.startsWith('https') ? url : 'https://$url';
      final webUri = Uri.parse(webUrl);

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $webUrl');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
