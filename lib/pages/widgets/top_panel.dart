// widgets/top_panel.dart
import 'package:flutter/material.dart';

class TopPanel extends StatelessWidget {
  final String status;
  final bool connecting;
  final VoidCallback onBackPressed;
  final bool usernameEditing;
  final TextEditingController usernameController;
  final String selectedUser;
  final List<String> users;
  final Function(String) onUserSelected;
  final VoidCallback startEditing;
  final VoidCallback cancelEditing;
  final Function(String) addUser;
  final VoidCallback deleteUser;
  final Function(String, String) updateUser;

  const TopPanel({
    super.key,
    required this.status,
    required this.connecting,
    required this.onBackPressed,
    required this.usernameEditing,
    required this.usernameController,
    required this.selectedUser,
    required this.users,
    required this.onUserSelected,
    required this.startEditing,
    required this.cancelEditing,
    required this.addUser,
    required this.deleteUser,
    required this.updateUser,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedUser.isNotEmpty ? selectedUser : null,
      hint: const Text("사용자 선택"),
      items: users.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
      onChanged: (value) {
        if (value != null) onUserSelect(value);
      },
    );
  }
}
