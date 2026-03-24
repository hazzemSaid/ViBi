import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/providers/social_links_provider.dart';
import 'package:vibi/features/profile/presentation/widgets/public_profile_social_links_section/public_social_media_card.dart';

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
                    .map((link) => PublicSocialMediaCard(link: link))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
