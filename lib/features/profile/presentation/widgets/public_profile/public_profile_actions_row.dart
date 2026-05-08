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
              ).colorScheme.onSurface.withOpacity(0.08),
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
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.ios_share, size: 22),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              final username = profile.username?.trim() ?? '';
              final shareBaseUrl =
                  dotenv.env['SHARE_BASE_URL'] ?? 'https://vibi.social';
              final profileUrl = username.isEmpty
                  ? shareBaseUrl
                  : '$shareBaseUrl/u/$username';
              Share.share(
                'Check out ${profile.username ?? "this user"}\'s profile on ViBi!\n$profileUrl',
                subject: '${profile.username ?? "user"}\'s ViBi profile',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AskOptionsBottomSheet extends StatelessWidget {
  final PublicProfile profile;

  const _AskOptionsBottomSheet({required this.profile});

  Future<void> _openTextQuestion(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await showDialog(
      context: navigator.context,
      builder: (_) => SendQuestionDialog(
        recipientId: profile.id,
        recipientUsername: profile.username ?? 'user',
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
        ),
      ),
    );
  }

  Future<void> _openRecommendation(BuildContext context) async {
    final theme = Theme.of(context);
    final anonymous = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        var isAnon = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Send anonymously?',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: SwitchListTile(
              title: Text(
                'Send anonymously',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              value: isAnon,
              activeThumbColor: theme.colorScheme.primary,
              onChanged: (v) => setState(() => isAnon = v),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(isAnon),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );

    if (anonymous == null) return;

    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => RecommendSearchScreen(
          recipientId: profile.id,
          initialAnonymous: anonymous,
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
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                  subtitle: 'Send a text question',
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context: context,
                  onTap: () => _openDrawing(context),
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFFBA68C8),
                  iconBgColor: const Color(0xFF381F4A),
                  title: 'Share Drawing',
                  subtitle: 'Send a drawing or sketch',
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context: context,
                  onTap: () => _openRecommendation(context),
                  icon: Icons.movie_filter_outlined,
                  iconColor: const Color(0xFF64B5F6),
                  iconBgColor: const Color(0xFF1B314B),
                  title: 'Recommend Film',
                  subtitle: 'Share a movie recommendation',
                ),
              ],
            ),
          ),
        ],
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
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
