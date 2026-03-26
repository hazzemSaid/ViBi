import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

class PublicSocialMediaCard extends StatelessWidget {
  final SocialLink link;

  const PublicSocialMediaCard({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: link.isActive ? 0.06 : 0.03),
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(
          color: link.isActive ? Colors.white24 : Colors.white10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(link.url),
          borderRadius: BorderRadius.circular(AppSizes.r24),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s16,
              vertical: AppSizes.s12,
            ),
            child: Row(
              children: [
                _SocialPlatformImage(link: link),
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

class _SocialPlatformImage extends StatelessWidget {
  const _SocialPlatformImage({required this.link});

  final SocialLink link;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _faviconFromUrl(link.url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white12),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _fallbackIcon();
          },
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Icon(
      socialPlatformIcon(link.platform),
      color: link.isActive ? AppColors.textPrimary : Colors.white54,
      size: 22,
    );
  }

  String _faviconFromUrl(String rawUrl) {
    try {
      final input = rawUrl.trim();
      final withScheme = input.startsWith('http') ? input : 'https://$input';
      final host = Uri.parse(withScheme).host;
      if (host.isEmpty) {
        return 'https://www.google.com/s2/favicons?sz=128&domain=vibi.social';
      }
      return 'https://www.google.com/s2/favicons?sz=128&domain=$host';
    } catch (_) {
      return 'https://www.google.com/s2/favicons?sz=128&domain=vibi.social';
    }
  }
}

extension StringExtension on String {
  String get capitalizeFirst =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
