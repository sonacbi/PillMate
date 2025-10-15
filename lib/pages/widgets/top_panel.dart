// lib/pages/widgets/top_panel.dart
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
  final VoidCallback onBluetoothPressed;


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
    required this.onBluetoothPressed, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE94844),
          borderRadius: BorderRadius.vertical(top: Radius.circular(200)),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 Row: 뒤로, 상태, 블루투스 버튼
            Row(
              children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("뒤로", style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "연결상태: ${status.toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: connecting ? null : onBluetoothPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: connecting ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(connecting ? "연결 중..." : "블루투스"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 사용자 관리 영역
            Row(
              children: [
                Expanded(
                  child: usernameEditing
                      ? TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            hintText: "새 사용자 이름 입력",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: selectedUser.isNotEmpty ? selectedUser : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          hint: const Text("사용자 선택"),
                          items: [
                            ...users.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                            const DropdownMenuItem(value: "__add__", child: Text("+ 사용자 추가")),
                          ],
                          onChanged: (value) {
                            if (value == "__add__") {
                              startEditing();
                              usernameController.clear();
                            } else if (value != null) {
                              onUserSelected(value);
                            }
                          },
                        ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: usernameEditing
                      ? () {
                          final name = usernameController.text.trim();
                          if (selectedUser.isNotEmpty && users.contains(selectedUser)) {
                            updateUser(selectedUser, name);
                          } else if (name.isNotEmpty) {
                            addUser(name);
                          }
                        }
                      : startEditing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: usernameEditing ? Colors.green : Colors.blue,
                  ),
                  child: Text(usernameEditing ? "확인" : "수정"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: usernameEditing ? cancelEditing : deleteUser,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(usernameEditing ? "취소" : "삭제"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
