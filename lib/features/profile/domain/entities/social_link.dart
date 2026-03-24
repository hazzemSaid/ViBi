class SocialLink {
  final String id;
  final String platform;
  final String url;
  final String? title;
  final String? displayLabel;
  final int displayOrder;
  final bool isActive;

  const SocialLink({
    required this.id,
    required this.platform,
    required this.url,
    required this.title,
    this.displayLabel,
    required this.displayOrder,
    required this.isActive,
  });

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      id: map['id'] as String,
      platform: map['platform'] as String? ?? 'custom',
      url: map['url'] as String? ?? '',
      title: map['title'] as String?,
      displayLabel: map['display_label'] as String?,
      displayOrder: map['display_order'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
