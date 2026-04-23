import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/presentation/widgets/common/follow_button.dart';
import 'package:vibi/features/questions/presentation/widgets/send_question_dialog.dart';

class PublicProfileActionsRow extends StatelessWidget {
  final PublicProfile profile;

  const PublicProfileActionsRow({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: FollowButton(profile: profile)),
        SizedBox(width: AppSizes.s12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: StadiumBorder(),
              minimumSize: Size.fromHeight(52),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.12),
              ),
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
                  ? 'Ask or Recommend'
                  : 'Questions Off',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
