import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/services/instagram_share_service.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';

class ProfileAnswerCard extends StatelessWidget {
  final AnsweredQuestion answer;

  const ProfileAnswerCard({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final bodyFontSize = isTablet ? 17.0 : 15.0;
    final questionFontSize = isTablet ? 20.0 : 18.0;
    final displayName = answer.isAnonymous
        ? 'Anonymous User'
        : (answer.senderUsername ?? 'Someone');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnswerAuthorRow(answer: answer),
          const SizedBox(height: 12),
          _QuestionCard(
            answer: answer,
            displayName: displayName,
            questionFontSize: questionFontSize,
          ),
          const SizedBox(height: 16),
          Text(
            answer.answerText,
            style: TextStyle(color: Colors.white, fontSize: bodyFontSize),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          _ActionRow(
            answer: answer,
            onShareTap: () => InstagramShareService.showShareSheet(
              context,
              questionText: answer.questionText,
              answerText: answer.answerText,
              username: answer.answererUsername ?? 'me',
              isAnonymous: answer.isAnonymous,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerAuthorRow extends StatelessWidget {
  final AnsweredQuestion answer;

  const _AnswerAuthorRow({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: answer.answererAvatarUrl != null
              ? NetworkImage(answer.answererAvatarUrl!)
              : null,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          child: answer.answererAvatarUrl == null
              ? const Icon(Icons.person, color: Colors.white24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answer.answererUsername ?? 'You',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Answered',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white54),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final AnsweredQuestion answer;
  final String displayName;
  final double questionFontSize;

  const _QuestionCard({
    required this.answer,
    required this.displayName,
    required this.questionFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C212A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SenderRow(answer: answer, displayName: displayName),
          const SizedBox(height: 12),
          const Text(
            'TELL',
            style: TextStyle(
              color: Color(0xFF6B8AFF),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer.questionText,
            style: TextStyle(
              color: Colors.white,
              fontSize: questionFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SenderRow extends StatelessWidget {
  final AnsweredQuestion answer;
  final String displayName;

  const _SenderRow({required this.answer, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: answer.senderAvatarUrl != null
              ? NetworkImage(answer.senderAvatarUrl!)
              : null,
          backgroundColor: answer.isAnonymous
              ? const Color(0xFF5A4FCF).withValues(alpha: 0.3)
              : Colors.grey,
          child: answer.senderAvatarUrl == null
              ? Icon(
                  Icons.person,
                  color: answer.isAnonymous
                      ? const Color(0xFF5A4FCF)
                      : Colors.white24,
                  size: 16,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (answer.isAnonymous)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A4FCF).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Anon',
                          style: TextStyle(
                            color: Color(0xFF5A4FCF),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Text(
                'Asked',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final AnsweredQuestion answer;
  final VoidCallback? onShareTap;

  const _ActionRow({required this.answer, this.onShareTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth < 360 ? 12.0 : 20.0;

    return Row(
      children: [
        const Icon(Icons.favorite_border, color: Color(0xFF5A4FCF), size: 22),
        const SizedBox(width: 6),
        Text(
          '${answer.likesCount}',
          style: const TextStyle(
            color: Color(0xFF5A4FCF),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: spacing),
        const Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
        const SizedBox(width: 6),
        Text(
          '${answer.commentsCount} Reply',
          style: const TextStyle(color: Colors.white54),
        ),
        SizedBox(width: spacing),
        GestureDetector(
          onTap: onShareTap,
          child: const Icon(
            Icons.share_outlined,
            color: Colors.white54,
            size: 20,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C212A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Send Tell',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
