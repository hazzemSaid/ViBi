import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

class EditProfileTabBar extends StatelessWidget {
  final EditorTab activeTab;
  final ValueChanged<EditorTab> onTabChanged;

  const EditProfileTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border(bottom: BorderSide(color: ProfileEditorPalette.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: EditorTabButton(
              label: 'Links',
              icon: Icons.dashboard_outlined,
              selected: activeTab == EditorTab.links,
              onTap: () => onTabChanged(EditorTab.links),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: EditorTabButton(
              label: 'Appearance',
              icon: Icons.auto_awesome_outlined,
              selected: activeTab == EditorTab.appearance,
              onTap: () => onTabChanged(EditorTab.appearance),
            ),
          ),
        ],
      ),
    );
  }
}
