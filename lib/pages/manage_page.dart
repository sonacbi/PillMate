// pages/manage_page.dart

import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  final VoidCallback onBack;

  const ManagePage({super.key, required this.onBack});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class Pill {
  int id;
  String name;
  int count;

  Pill({required this.id, required this.name, required this.count});
}

class Mapping {
  String user;
  bool breakfast;
  bool lunch;
  bool dinner;
  List<Pill> pills;

  Mapping({
    required this.user,
    this.breakfast = false,
    this.lunch = false,
    this.dinner = false,
    required this.pills,
  });
}

class Snapshot {
  List<String> users;
  List<Mapping> mapping;

  Snapshot({required this.users, required this.mapping});
}

class _ManagePageState extends State<ManagePage> {
  String status = "on call";
  bool connecting = false;
  Snapshot snapshot = Snapshot(users: [], mapping: []);
  String selectedUser = "";
  String username = "";
  bool usernameEditing = false;
  bool showResetModal = false;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: username);
  }


  void addUser(String name) {
    if (name.isEmpty) return;
    setState(() {
      snapshot.users.add(name);
      snapshot.mapping.add(Mapping(user: name, pills: []));
      selectedUser = name;
    });
  }

  void deleteUser() {
    setState(() {
      snapshot.users.remove(selectedUser);
      snapshot.mapping.removeWhere((m) => m.user == selectedUser);
      selectedUser = "";
    });
  }

  void updateUser(String oldName, String newName) {
    setState(() {
      snapshot.users = snapshot.users.map((u) => u == oldName ? newName : u).toList();
      snapshot.mapping = snapshot.mapping
          .map((m) => m.user == oldName ? Mapping(user: newName, pills: m.pills) : m)
          .toList();
      selectedUser = newName;
    });
  }

  void addPillSlot(String user) {
    setState(() {
      for (var m in snapshot.mapping) {
        if (m.user == user) {
          m.pills.add(Pill(id: DateTime.now().millisecondsSinceEpoch, name: "", count: 0));
        }
      }
    });
  }

  void removePillSlot(String user, int id) {
    setState(() {
      for (var m in snapshot.mapping) {
        if (m.user == user) {
          m.pills.removeWhere((p) => p.id == id);
        }
      }
    });
  }

  void updatePillName(String user, int id, String name) {
    setState(() {
      for (var m in snapshot.mapping) {
        if (m.user == user) {
          for (var p in m.pills) {
            if (p.id == id) p.name = name;
          }
        }
      }
    });
  }

  void updatePillCount(String user, int id, int count) {
    setState(() {
      for (var m in snapshot.mapping) {
        if (m.user == user) {
          for (var p in m.pills) {
            if (p.id == id) p.count = count;
          }
        }
      }
    });
  }

  void saveAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('아두이노에 저장 요청을 보냈습니다. (모의)')),
    );
  }

  void resetAll() {
    setState(() {
      snapshot = Snapshot(users: [], mapping: []);
      selectedUser = "";
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMapping =
        snapshot.mapping.firstWhere((m) => m.user == selectedUser, orElse: () => Mapping(user: "", pills: []));

    return Scaffold(
      body: Center(
        child: Container(
          constraints : const BoxConstraints(
            maxWidth: 420,
            minWidth: 360,
            maxHeight: 844,
            minHeight: 700,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // 상단 패널
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE94844),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(200)),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: connecting
                                      ? null
                                      : () => setState(() => status = "ACCESS"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(connecting ? "연결 중..." : "블루투스"),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "연결상태: ${status.toUpperCase()}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: widget.onBack,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("뒤로", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 사용자 관리 영역
                            Row(
                              children: [
                                if (snapshot.users.isNotEmpty && !usernameEditing) ...[
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Text(selectedUser.isNotEmpty
                                          ? selectedUser
                                          : snapshot.users.first),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        username = selectedUser;
                                        usernameEditing = true;
                                      });
                                    },
                                    child: const Text("수정"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: deleteUser,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text("삭제"),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: TextField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                        hintText: "사용자 이름",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) => setState(() => username = v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (selectedUser.isNotEmpty &&
                                          snapshot.users.contains(selectedUser)) {
                                        updateUser(selectedUser, _usernameController.text);
                                      } else {
                                        addUser(_usernameController.text);
                                      }
                                      setState(() {
                                        usernameEditing = false;
                                        username = "";
                                        _usernameController.clear(); // 입력 필드 초기화
                                      });
                                    },
                                    child: Text(selectedUser.isNotEmpty ? "저장" : "추가"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => setState(() {
                                      username = "";
                                      usernameEditing = false;
                                      _usernameController.clear();
                                    }),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                    child: const Text("취소"),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 하단 패널
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.vertical(bottom: Radius.circular(200)),
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (var pill in selectedMapping.pills)
                                        Row(
                                          children: [
                                            const SizedBox(width: 30, child: Text("#")),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                decoration: const InputDecoration(
                                                  hintText: "약 이름",
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (v) =>
                                                    updatePillName(selectedUser, pill.id, v),
                                                controller: TextEditingController(text: pill.name),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 60,
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (v) => updatePillCount(
                                                    selectedUser, pill.id, int.tryParse(v) ?? 0),
                                                controller: TextEditingController(
                                                    text: pill.count.toString()),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  removePillSlot(selectedUser, pill.id),
                                              style:
                                                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text("X"),
                                            ),
                                          ],
                                        ),
                                      if (selectedUser.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 12),
                                          child: ElevatedButton(
                                            onPressed: () => addPillSlot(selectedUser),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              minimumSize: const Size.fromHeight(45),
                                            ),
                                            child: const Text("+ 추가하기",
                                                style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: saveAll,
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text("저장"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => setState(() => showResetModal = true),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text("초기화"),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 80), // StartPage 하단 여백과 동일
                            ],
                          ),
                        ),
                      ),
                    ),

                  
                ],
              ),
              
              // 초기화 모달
              if (showResetModal)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("초기화하시겠습니까?"),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => showResetModal = false),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                                  child: const Text("취소", style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    resetAll();
                                    setState(() => showResetModal = false);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text("확인", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

            ]
          )
        )
      )
    );
  }
}
