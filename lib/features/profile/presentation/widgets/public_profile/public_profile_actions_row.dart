import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/common/widgets/send_question_dialog.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/presentation/widgets/common/follow_button.dart';
import 'package:vibi/features/recommendation/presentation/screens/recommend_search_screen.dart';
import 'package:vibi/features/sendQuestion/presentation/pages/drawing_page.dart';

const _defaultShareBaseUrl = 'https://vibi.social';

class PublicProfileActionsRow extends StatelessWidget {
  final PublicProfile profile;

  const PublicProfileActionsRow({super.key, required this.profile});

  void _showAskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AskOptionsBottomSheet(profile: profile);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = profile.username?.trim() ?? '';
    final canShare = username.isNotEmpty;
    return Row(
      children: [
        // Follow Button
        Expanded(child: FollowButton(profile: profile)),
        SizedBox(width: AppSizes.s12),
        // Ask Button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: const StadiumBorder(),
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
            ),
            onPressed: profile.allowAnonymousQuestions
                ? () => _showAskBottomSheet(context)
                : null,
            icon: Icon(
              Icons.send_outlined,
              size: 20,
              color: profile.allowAnonymousQuestions
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            label: Text(
              profile.allowAnonymousQuestions ? 'Ask' : 'Questions Off',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox(width: AppSizes.s12),
        // Share Button
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.ios_share, size: 22),
            color: canShare
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
            onPressed: canShare
                ? () {
                    final shareBaseUrl =
                        dotenv.env['SHARE_BASE_URL'] ?? _defaultShareBaseUrl;
                    final profileUrl = '$shareBaseUrl/u/$username';
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Check out $username\'s profile on Vibi\n$profileUrl',
                        subject: '$username\'s Vibi profile',
                      ),
                    );
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

class _AskOptionsBottomSheet extends StatefulWidget {
  final PublicProfile profile;

  const _AskOptionsBottomSheet({required this.profile});

  @override
  State<_AskOptionsBottomSheet> createState() => _AskOptionsBottomSheetState();
}

class _AskOptionsBottomSheetState extends State<_AskOptionsBottomSheet> {
  bool _sendAnonymously = true;

  PublicProfile get profile => widget.profile;

  Future<void> _openTextQuestion(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await showDialog(
      context: navigator.context,
      builder: (_) => SendQuestionDialog(
        recipientId: profile.id,
        recipientUsername: profile.username ?? 'user',
        initialAnonymous: _sendAnonymously,
        showAnonymousSwitch: false,
      ),
    );
  }

  Future<void> _openDrawing(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => DrawingPage(
          recipientId: profile.id,
          senderId: Supabase.instance.client.auth.currentUser?.id,
          initialAnonymous: _sendAnonymously,
          askBeforeSend: false,
        ),
      ),
    );
  }

  Future<void> _openRecommendation(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => RecommendSearchScreen(
          recipientId: profile.id,
          initialAnonymous: _sendAnonymously,
          showAnonymousSwitch: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Send to ${profile.username ?? 'user'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              'Pick how you want to send, then choose what to create.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                fontSize: 13,
                height: 1.25,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildIdentityToggle(context),
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildMenuItem(
                  context: context,
                  onTap: () => _openTextQuestion(context),
                  icon: Icons.chat_bubble_outline,
                  iconColor: const Color(0xFFE57373),
                  iconBgColor: const Color(0xFF4A2525),
                  title: 'Ask Question',
                  subtitle: _sendAnonymously
                      ? 'Send a text question anonymously'
                      : 'Send a text question with your profile',
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context: context,
                  onTap: () => _openDrawing(context),
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFFBA68C8),
                  iconBgColor: const Color(0xFF381F4A),
                  title: 'Share Drawing',
                  subtitle: _sendAnonymously
                      ? 'Send a drawing anonymously'
                      : 'Send a drawing with your profile',
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context: context,
                  onTap: () => _openRecommendation(context),
                  icon: Icons.movie_filter_outlined,
                  iconColor: const Color(0xFF64B5F6),
                  iconBgColor: const Color(0xFF1B314B),
                  title: 'Recommend Film',
                  subtitle: _sendAnonymously
                      ? 'Share a movie recommendation anonymously'
                      : 'Share a movie recommendation with your profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityToggle(BuildContext context) {
    final theme = Theme.of(context);
    final title = _sendAnonymously ? 'Sending anonymously' : 'Sending as you';
    final subtitle = _sendAnonymously
        ? 'Your name will stay hidden for any option below.'
        : 'Your profile will be attached to any option below.';

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() {
            _sendAnonymously = !_sendAnonymously;
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _sendAnonymously
                        ? Icons.visibility_off_rounded
                        : Icons.person_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.62,
                          ),
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _sendAnonymously,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (value) => setState(() {
                    _sendAnonymously = value;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
