import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/presentation/widgets/follow_button.dart';
import 'package:vibi/features/questions/presentation/widgets/send_question_dialog.dart';

class PublicProfileActionsRow extends StatelessWidget {
  final PublicProfile profile;

  const PublicProfileActionsRow({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: FollowButton(profile: profile)),
        const SizedBox(width: AppSizes.s12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: AppColors.textPrimary,
              shape: const StadiumBorder(),
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            onPressed: profile.allowAnonymousQuestions
                ? () {
                    showDialog(
                      context: context,
                      builder: (_) => SendQuestionDialog(
                        recipientId: profile.id,
                        recipientUsername: profile.username ?? 'user',
                      ),
                    );
                  }
                : null,
            child: Text(
              profile.allowAnonymousQuestions
                  ? 'Ask Question'
                  : 'Questions Off',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
