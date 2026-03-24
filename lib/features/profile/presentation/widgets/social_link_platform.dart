import 'package:flutter/material.dart';

const List<String> kSocialPlatforms = [
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
    case 'youtube':
      return Icons.smart_display_outlined;
    case 'tiktok':
      return Icons.music_note;
    case 'linkedin':
      return Icons.business_center_outlined;
    case 'github':
      return Icons.code;
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
    case 'youtube':
      return 'YouTube';
    case 'tiktok':
      return 'TikTok';
    case 'linkedin':
      return 'LinkedIn';
    case 'github':
      return 'GitHub';
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
    case 'youtube':
      return 'Subscribe on YouTube';
    case 'tiktok':
      return 'Follow me on TikTok';
    case 'linkedin':
      return 'Connect on LinkedIn';
    case 'github':
      return 'View my GitHub';
    case 'website':
      return 'Visit My Website';
    default:
      return 'Open my link';
  }
}
