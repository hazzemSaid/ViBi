enum EditorTab { links, appearance }

enum UnsavedExitAction { save, discard, stay }

class ProfileConstants {
  static const List<String> favColorOptions = [
    '#E94E91', // Pink (Default)
    '#FF5722', // Deep Orange
    '#FFC107', // Amber
    '#4CAF50', // Green
    '#00BCD4', // Cyan
    '#2196F3', // Blue
    '#673AB7', // Deep Purple
    '#9C27B0', // Purple
    '#F44336', // Red
    '#FFFFFF', // White
  ];

  static const List<String> publicThemeOptions = [
    'tellonym_dark',
    'minimal_dark',
    'clean_light',
    'noir_dark',
    'ocean_dark',
    'forest_dark',
    'sunset_dark',
    'violet_dark',
    'amber_dark',
  ];

  static const Map<String, String> publicThemeLabels = {
    'tellonym_dark': 'Tellonym Dark',
    'minimal_dark': 'Minimal Dark',
    'clean_light': 'Clean Light',
    'noir_dark': 'Noir',
    'ocean_dark': 'Ocean',
    'forest_dark': 'Forest',
    'sunset_dark': 'Sunset',
    'violet_dark': 'Violet',
    'amber_dark': 'Amber',
  };

  static const Map<String, String> publicThemeDescriptions = {
    'tellonym_dark':
        'High-contrast dark theme inspired by Tellonym-style public pages.',
    'minimal_dark': 'A cleaner dark variant with minimal visual noise.',
    'clean_light': 'A bright, simple layout with clear readability.',
    'noir_dark': 'Deep black background with crisp neutral contrast.',
    'ocean_dark': 'Cold blue gradients with a cinematic dark surface.',
    'forest_dark': 'Muted green-black palette with a grounded mood.',
    'sunset_dark': 'Warm ember tones layered over dark backgrounds.',
    'violet_dark': 'Electric violet accents with a bold night feel.',
    'amber_dark': 'Burnt orange and bronze tones with dark contrast.',
  };

  static const List<String> linkButtonStyleOptions = [
    'filled',
    'pill',
    'outline',
    'outline_pill',
    'shadow',
    'hard_shadow',
  ];

  static const Map<String, String> linkButtonStyleLabels = {
    'filled': 'Filled',
    'pill': 'Pill',
    'outline': 'Outline',
    'outline_pill': 'Outline Pill',
    'shadow': 'Shadow',
    'hard_shadow': 'Hard Shadow',
  };

  static const List<String> publicFontFamilyOptions = [
    'inter',
    'system',
    'serif',
    'mono',
  ];

  static const Map<String, String> publicFontFamilyLabels = {
    'inter': 'Inter',
    'system': 'System',
    'serif': 'Serif',
    'mono': 'Mono',
  };

  static String normalizeThemeKey(String? key) {
    final valid = publicThemeOptions;
    return (key != null && valid.contains(key)) ? key : 'tellonym_dark';
  }

  static String normalizeButtonStyle(String? key) {
    final valid = linkButtonStyleOptions;
    return (key != null && valid.contains(key)) ? key : 'pill';
  }

  static String normalizeFontFamily(String? key) {
    final valid = publicFontFamilyOptions;
    return (key != null && valid.contains(key)) ? key : 'inter';
  }
}
