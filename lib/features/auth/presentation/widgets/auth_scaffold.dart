import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_background.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final List<Widget>? actions;

  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = false,
    this.bottom,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: title != null,
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              leading: showBackButton
                  ? leading ??
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        )
                  : null,
              bottom: bottom,
              actions: actions,
            )
          : null,
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth <= 360;
              final isLargeScreen = constraints.maxWidth >= 600;
              final horizontalPadding = isSmallScreen
                  ? AppSizes.s24
                  : AppSizes.s32;
              final maxWidth = isLargeScreen ? 500.0 : 440.0;

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSizes.s24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
