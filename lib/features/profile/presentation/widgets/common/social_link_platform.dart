import 'package:flutter/material.dart';

const List<String> kSocialPlatforms = [
  'instagram',
  'twitter',
  'threads',
  'telegram',
  'snapchat',
  'facebook',
  'youtube',
  'twitch',
  'tiktok',
  'linkedin',
  'github',
  'email',
  'website',
  'custom',
];

const List<String> kDatabaseSocialPlatforms = [
  'instagram',
  'twitter',
  'facebook',
  'youtube',
  'tiktok',
  'linkedin',
  'github',
  'website',
  'custom',
];

IconData socialPlatformIcon(String platform) {
  switch (platform) {
    case 'instagram':
      return Icons.camera_alt_outlined;
    case 'twitter':
      return Icons.alternate_email;
    case 'facebook':
      return Icons.facebook;
    case 'threads':
      return Icons.forum_outlined;
    case 'telegram':
      return Icons.send_outlined;
    case 'snapchat':
      return Icons.chat_bubble_outline;
    case 'youtube':
      return Icons.smart_display_outlined;
    case 'twitch':
      return Icons.live_tv_outlined;
    case 'tiktok':
      return Icons.music_note;
    case 'linkedin':
      return Icons.business_center_outlined;
    case 'github':
      return Icons.code;
    case 'email':
      return Icons.mail_outline;
    case 'website':
      return Icons.language;
    default:
      return Icons.link;
  }
}

String socialPlatformLabel(String platform) {
  switch (platform) {
    case 'instagram':
      return 'Instagram';
    case 'twitter':
      return 'Twitter / X';
    case 'facebook':
      return 'Facebook';
    case 'threads':
      return 'Threads';
    case 'telegram':
      return 'Telegram';
    case 'snapchat':
      return 'Snapchat';
    case 'youtube':
      return 'YouTube';
    case 'twitch':
      return 'Twitch';
    case 'tiktok':
      return 'TikTok';
    case 'linkedin':
      return 'LinkedIn';
    case 'github':
      return 'GitHub';
    case 'email':
      return 'Email';
    case 'website':
      return 'Website';
    default:
      return 'Custom';
  }
}

String socialPlatformDefaultDisplayLabel(String platform) {
  switch (platform) {
    case 'instagram':
      return 'Follow me on Instagram';
    case 'twitter':
      return 'Follow me on X';
    case 'facebook':
      return 'Follow me on Facebook';
    case 'threads':
      return 'Follow me on Threads';
    case 'telegram':
      return 'Message me on Telegram';
    case 'snapchat':
      return 'Add me on Snapchat';
    case 'youtube':
      return 'Subscribe on YouTube';
    case 'twitch':
      return 'Watch on Twitch';
    case 'tiktok':
      return 'Follow me on TikTok';
    case 'linkedin':
      return 'Connect on LinkedIn';
    case 'github':
      return 'View my GitHub';
    case 'email':
      return 'Email Me';
    case 'website':
      return 'Visit My Website';
    default:
      return 'Open my link';
  }
}

bool usesUsernameTemplate(String platform) {
  switch (platform) {
    case 'instagram':
    case 'twitter':
    case 'threads':
    case 'tiktok':
    case 'snapchat':
    case 'telegram':
    case 'facebook':
    case 'youtube':
    case 'twitch':
    case 'linkedin':
    case 'github':
      return true;
    default:
      return false;
  }
}

String socialUsernameLabel(String platform) {
  switch (platform) {
    case 'instagram':
      return 'Instagram username';
    case 'twitter':
      return 'X username';
    case 'threads':
      return 'Threads username';
    case 'telegram':
      return 'Telegram username';
    case 'snapchat':
      return 'Snapchat username';
    case 'facebook':
      return 'Facebook username';
    case 'youtube':
      return 'YouTube handle';
    case 'twitch':
      return 'Twitch username';
    case 'tiktok':
      return 'TikTok username';
    case 'linkedin':
      return 'LinkedIn username';
    case 'github':
      return 'GitHub username';
    case 'email':
      return 'Email address';
    default:
      return 'Username';
  }
}

String socialUrlPrefix(String platform) {
  switch (platform) {
    case 'instagram':
      return 'https://www.instagram.com/';
    case 'twitter':
      return 'https://x.com/';
    case 'threads':
      return 'https://www.threads.net/@';
    case 'telegram':
      return 'https://t.me/';
    case 'snapchat':
      return 'https://www.snapchat.com/add/';
    case 'facebook':
      return 'https://www.facebook.com/';
    case 'youtube':
      return 'https://www.youtube.com/@';
    case 'twitch':
      return 'https://www.twitch.tv/';
    case 'tiktok':
      return 'https://www.tiktok.com/@';
    case 'linkedin':
      return 'https://www.linkedin.com/in/';
    case 'github':
      return 'https://github.com/';
    default:
      return '';
  }
}

String buildSocialUrl(String platform, String input) {
  final trimmed = input.trim();
  if (!usesUsernameTemplate(platform)) {
    if (platform == 'email') {
      return trimmed.startsWith('mailto:') ? trimmed : 'mailto:$trimmed';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  final normalized = normalizeSocialUsername(trimmed);
  return '${socialUrlPrefix(platform)}$normalized';
}

String normalizeSocialUsername(String raw) {
  var input = raw.trim();
  if (input.isEmpty) return '';

  input = input.split('?').first.split('#').first.trim();

  final uri = Uri.tryParse(input);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    final segments = uri.pathSegments
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (segments.isNotEmpty) {
      return segments.last.replaceFirst('@', '').trim();
    }
    return '';
  }

  if (input.contains('/')) {
    final segments = input
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (segments.isNotEmpty) {
      return segments.last.replaceFirst('@', '').trim();
    }
  }

  return input.replaceFirst('@', '').trim();
}

String usernameFromSocialUrl(String platform, String url) {
  if (!usesUsernameTemplate(platform)) return url;

  final prefix = socialUrlPrefix(platform);
  if (url.startsWith(prefix)) {
    return normalizeSocialUsername(url.substring(prefix.length));
  }

  return normalizeSocialUsername(url);
}
