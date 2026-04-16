import 'package:flutter/material.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/core/theme/theme_cubit.dart';

class ProfileEditorPalette {
  static Color get canvas => _scheme.surface;
  static Color get accent => _scheme.primary;
  static Color get accentSoft => _scheme.primary.withValues(alpha: 0.08);
  static Color get primaryText => _scheme.onSurface;
  static Color get secondaryText => _scheme.onSurfaceVariant;
  static Color get mutedText => _scheme.onSurfaceVariant.withValues(alpha: 0.82);
  static Color get placeholder =>
      _scheme.onSurfaceVariant.withValues(alpha: 0.6);
  static Color get outline => _scheme.outlineVariant;
  static Color get outlineStrong => _scheme.outline;
  static Color get fieldFill => _scheme.surfaceContainerLowest;
  static Color get tabActive => _scheme.surfaceContainerLow;

  static ColorScheme get _scheme {
    if (!getIt.isRegistered<ThemeCubit>()) {
      return AppColors.lightColorScheme;
    }

    final themeMode = getIt<ThemeCubit>().state;
    final brightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };

    return brightness == Brightness.dark
        ? AppColors.darkColorScheme
        : AppColors.lightColorScheme;
  }
}
