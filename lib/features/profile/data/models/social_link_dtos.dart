class AddSocialLinkDto {
  final String userId;
  final String platform;
  final String url;
  final String? title;
  final String? displayLabel;
  final int displayOrder;

  const AddSocialLinkDto({
    required this.userId,
    required this.platform,
    required this.url,
    this.title,
    this.displayLabel,
    required this.displayOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'platform': platform,
      'url': url,
      'title': title,
      'displayLabel': displayLabel,
      'displayOrder': displayOrder,
    };
  }
}

class UpdateSocialLinkDto {
  final String linkId;
  final String platform;
  final String url;
  final String? title;
  final String? displayLabel;
  final int displayOrder;
  final bool isActive;

  const UpdateSocialLinkDto({
    required this.linkId,
    required this.platform,
    required this.url,
    this.title,
    this.displayLabel,
    required this.displayOrder,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': linkId,
      'platform': platform,
      'url': url,
      'title': title,
      'displayLabel': displayLabel,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }
}
