enum ShareCardTemplate { neonPulse, editorial, sunsetGlow, polaroid }

extension ShareCardTemplateX on ShareCardTemplate {
  String get title {
    switch (this) {
      case ShareCardTemplate.neonPulse:
        return 'Neon Pulse';
      case ShareCardTemplate.editorial:
        return 'Editorial';
      case ShareCardTemplate.sunsetGlow:
        return 'Sunset Glow';
      case ShareCardTemplate.polaroid:
        return 'Polaroid';
    }
  }

  String get subtitle {
    switch (this) {
      case ShareCardTemplate.neonPulse:
        return 'Bold and vibrant';
      case ShareCardTemplate.editorial:
        return 'Minimal and sharp';
      case ShareCardTemplate.sunsetGlow:
        return 'Warm and dreamy';
      case ShareCardTemplate.polaroid:
        return 'Playful scrapbook';
    }
  }
}

class ShareCardLayout {
  static const double storyWidth = 324;
  static const double storyHeight = 576; // 9:16 Instagram Story ratio

  const ShareCardLayout._();
}

class ShareCardBackgrounds {
  static const String neonPulse = 'assets/images/background1.jpg';
  static const String editorial = 'assets/images/background3.jpg';
  static const String sunsetGlow = 'assets/images/background2.jpg';
  static const String polaroid = 'assets/images/background4.jpg';

  const ShareCardBackgrounds._();
}
