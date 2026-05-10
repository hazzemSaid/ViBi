import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vibi/core/constants/app_sizes.dart';

import '../cubit/drawing_cubit.dart';

/**
 * A toolbar for the drawing canvas that provides controls for color selection,
 * brush width adjustments, and canvas actions (undo/clear).
 */
class DrawingToolbar extends StatefulWidget {
  final DrawingState state;
  final DrawingCubit cubit;
  final Color backgroundColor;

  const DrawingToolbar({
    super.key,
    required this.state,
    required this.cubit,
    required this.backgroundColor,
  });

  @override
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {
  bool _isOpen = true;

  static const _colors = [
    Colors.black,
    Colors.white,
    Color(0xFFE53935), // red
    Color(0xFF1E88E5), // blue
    Color(0xFF43A047), // green
    Color(0xFFFDD835), // yellow
    Color(0xFFFF7043), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFF00ACC1), // cyan
    Color(0xFFEC407A), // pink
  ];

  static const _widths = [2.0, 4.0, 8.0, 14.0];

  Future<void> _openColorPicker() async {
    var tempColor = widget.state.selectedColor;
    final picked = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
              enableAlpha: false,
              displayThumbColor: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(tempColor),
              child: const Text('Use color'),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      widget.cubit.setColor(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = widget.cubit;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.s12,
        vertical: AppSizes.s8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Drawing tools',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _isOpen = !_isOpen),
                tooltip: _isOpen ? 'Collapse toolbar' : 'Expand toolbar',
                iconSize: AppSizes.iconNormal,
              ),
            ],
          ),
          if (_isOpen) ...[
            // Color palette
            SizedBox(
              height: AppSizes.s40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length + 1,
                separatorBuilder: (_, __) => AppSizes.gapW8,
                itemBuilder: (_, i) {
                  if (i == _colors.length) {
                    return GestureDetector(
                      onTap: _openColorPicker,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: AppSizes.s32,
                        height: AppSizes.s32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.color_lens,
                          size: AppSizes.iconSmall,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  final color = _colors[i];
                  final selected = state.selectedColor == color;
                  return GestureDetector(
                    onTap: () => cubit.setColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: AppSizes.s32,
                      height: AppSizes.s32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          width: selected ? 3 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            AppSizes.gapH8,
            // Width selector + actions
            Row(
              children: [
                // Width options
                ..._widths.map((w) {
                  final selected = state.selectedWidth == w;
                  return GestureDetector(
                    onTap: () => cubit.setWidth(w),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(right: AppSizes.s6),
                      width: AppSizes.s32 + 4,
                      height: AppSizes.s32 + 4,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: w * 1.5 + 4,
                          height: w * 1.5 + 4,
                          decoration: BoxDecoration(
                            color: state.selectedColor == Colors.white
                                ? Colors.grey
                                : state.selectedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // Eraser
                IconButton(
                  icon: const Icon(Icons.cleaning_services),
                  onPressed: () => cubit.toggleEraser(widget.backgroundColor),
                  tooltip: 'Eraser',
                  iconSize: AppSizes.iconNormal,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  color: state.isEraser
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                // Undo
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: state.strokes.isEmpty ? null : cubit.undo,
                  tooltip: 'Undo',
                  iconSize: AppSizes.iconNormal,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                // Redo
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: state.canRedo ? cubit.redo : null,
                  tooltip: 'Redo',
                  iconSize: AppSizes.iconNormal,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                // Clear
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: state.isEmpty ? null : cubit.clear,
                  tooltip: 'Clear',
                  iconSize: AppSizes.iconNormal,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
