import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/providers/social_links_provider.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

/// Read-only social links section for public profiles
class PublicProfileSocialLinksSection extends StatelessWidget {
  final String userId;

  const PublicProfileSocialLinksSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SocialLinksCubit(userId: userId, dataSource: socialLinksDataSource),
      child: BlocBuilder<SocialLinksCubit, ViewState<List<SocialLink>>>(
        builder: (context, socialLinksAsync) {
          if (socialLinksAsync.status == ViewStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.s12),
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (socialLinksAsync.status == ViewStatus.failure) {
            return const SizedBox.shrink();
          }

          final links = socialLinksAsync.data ?? const <SocialLink>[];
          if (links.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Social Media',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.s12),
              Column(
                children: links
                    .map((link) => _PublicSocialMediaCard(link: link))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PublicSocialMediaCard extends StatelessWidget {
  final SocialLink link;

  const _PublicSocialMediaCard({required this.link});

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
          onTap: () => _launchUrl(link.url),
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
                        link.platform.capitalizeFirst,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (link.displayLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            link.displayLabel!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_outward,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
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

extension StringExtension on String {
  String get capitalizeFirst =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
