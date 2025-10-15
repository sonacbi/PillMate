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
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                "사용자 관리",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (usernameEditing)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: "새 사용자 이름 입력",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    addUser(usernameController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("추가"),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: cancelEditing,
                  child: const Text("취소"),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUser.isNotEmpty ? selectedUser : null,
                    hint: const Text("사용자 선택"),
                    items: users
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onUserSelected(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: startEditing,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("+ 추가", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: selectedUser.isNotEmpty ? deleteUser : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("삭제", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
