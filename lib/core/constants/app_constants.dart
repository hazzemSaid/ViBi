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

  static const List<String> publicFontFamilyOptions = [
    'inter',
    'google_sans',
    'serif',
    'mono',
    'system',
  ];

  static const Map<String, String> publicFontFamilyLabels = {
    'inter': 'Modern Chic',
    'google_sans': 'Smooth & Round',
    'serif': 'Fancy Vintage',
    'mono': 'Cyber Geek',
    'system': 'Friendly Native',
  };

  static String normalizeFontFamily(String? key) {
    final valid = publicFontFamilyOptions;
    return (key != null && valid.contains(key)) ? key : 'inter';
  }
}
