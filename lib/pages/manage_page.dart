// pages/manage_page.dart

import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  final VoidCallback onBack;

  const ManagePage({super.key, required this.onBack});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class Pill {
  final int id;
  String name;
  int count;
  TextEditingController nameController;
  TextEditingController countController;

  Pill({required this.id, this.name = "", this.count = 0})
      : nameController = TextEditingController(text: name),
        countController = TextEditingController(text: count.toString());
}


class Mapping {
  String user;
  List<Pill> pills;
  bool breakfast;
  bool lunch;
  bool dinner;

  Mapping({
    required this.user,
    required this.pills,
    this.breakfast = false,
    this.lunch = false,
    this.dinner = false,
  });

  // meals getter 추가
  Map<String, bool> get meals => {
        "breakfast": breakfast,
        "lunch": lunch,
        "dinner": dinner,
      };

  // meals toggle용 setter
  void toggleMeal(String meal) {
    switch (meal) {
      case "breakfast":
        breakfast = !breakfast;
        break;
      case "lunch":
        lunch = !lunch;
        break;
      case "dinner":
        dinner = !dinner;
        break;
    }
  }
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
  late TextEditingController _usernameController;
  Map<int, TextEditingController> pillNameControllers = {};
  Map<int, TextEditingController> pillCountControllers = {};

  bool showBackModal = false;  // 뒤로가기 경고 모달
  bool showResetModal = false; // 초기화 모달

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // 저장되지 않은 변경 사항 있는지 체크
  bool hasUnsavedChanges() {
    return usernameEditing ||                     // 사용자 수정 모드
          _usernameController.text.isNotEmpty || // 입력값 존재
          username.isNotEmpty ||                 // username 변수 체크
          selectedUser.isNotEmpty ||             // 선택된 사용자 존재
          selectedMapping.pills.any((p) => p.name.isNotEmpty || p.count > 0); // 약 슬롯 체크
  }

  // 뒤로가기 버튼 눌렀을 때
  void onBackPressed() {
    if (hasUnsavedChanges()) {
      setState(() => showBackModal = true); // 경고 모달 띄우기
    } else {
      widget.onBack(); // 바로 뒤로가기
    }
  }

  // 선택된 매핑 getter
  Mapping get selectedMapping => snapshot.mapping.firstWhere(
        (m) => m.user == selectedUser,
        orElse: () => Mapping(user: "", pills: []),
      );

  // 사용자 추가
  void addUser(String name) {
    if (name.isEmpty) return;

    setState(() {
      snapshot.users.add(name);
      snapshot.mapping.add(Mapping(user: name, pills: []));
      selectedUser = name; // 새로 추가된 사용자 자동 선택
      usernameEditing = false;
      username = "";
      _usernameController.clear();
    });
  }

  // 사용자 삭제
  void deleteUser() {
    setState(() {
      snapshot.users.remove(selectedUser);
      snapshot.mapping.removeWhere((m) => m.user == selectedUser);
      selectedUser = snapshot.users.isNotEmpty ? snapshot.users.last : "";
      usernameEditing = false;
      username = "";
      _usernameController.clear();
    });
  }

  // 사용자 이름 수정
  void updateUser(String oldName, String newName) {
    if (newName.isEmpty) return;

    setState(() {
      snapshot.users = snapshot.users.map((u) => u == oldName ? newName : u).toList();
      snapshot.mapping = snapshot.mapping
          .map((m) => m.user == oldName
              ? Mapping(
                  user: newName,
                  pills: m.pills,
                  breakfast: m.breakfast,
                  lunch: m.lunch,
                  dinner: m.dinner)
              : m)
          .toList();
      selectedUser = newName; // 수정 후 선택 상태 유지
      usernameEditing = false;
      username = "";
      _usernameController.clear();
    });
  }

  // 식사 토글
  void toggleMeal(String meal) {
    setState(() {
      for (var m in snapshot.mapping) {
        if (m.user == selectedUser) {
          m.toggleMeal(meal); // Mapping 클래스 메서드 사용
        }
      }
    });
  }

  // 약 슬롯 추가/삭제/수정
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

  // 저장 / 초기화
  void saveAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('아두이노에 저장 요청을 보냈습니다. (모의)')),
    );
  }

  void resetAll() {
    setState(() {
      if (selectedUser.isNotEmpty) {
        // 선택된 유저의 매핑 초기화
        snapshot.mapping.removeWhere((m) => m.user == selectedUser);
        snapshot.mapping.add(Mapping(
          user: selectedUser,
          pills: [],       // 약 슬롯 초기화
          breakfast: false, 
          lunch: false, 
          dinner: false,   // 식사 선택 초기화
        ));
      }

      // 입력창 상태 초기화
      usernameEditing = false;
      username = "";
      _usernameController.clear();
    });
  }

  // 사용자 수정 모드 진입
  void startEditingUser() {
    setState(() {
      usernameEditing = true;
      username = selectedUser;
      _usernameController.text = selectedUser;
    });
  }

  // 사용자 입력 취소
  void cancelEditingUser() {
    setState(() {
      usernameEditing = false;
      username = "";
      _usernameController.clear();
    });
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
                                  onPressed: onBackPressed,
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
                                Expanded(
                                  child: usernameEditing
                                      ? TextField(
                                          controller: _usernameController,
                                          decoration: const InputDecoration(
                                            hintText: "사용자 이름",
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (v) => setState(() => username = v),
                                        )
                                      : DropdownButtonFormField<String>(
                                          value: selectedUser.isNotEmpty ? selectedUser : null,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          items: [
                                            ...snapshot.users.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                                            const DropdownMenuItem(
                                              value: "__add__",
                                              child: Text("+ 사용자 추가"),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value == "__add__") {
                                              setState(() {
                                                usernameEditing = true;
                                                selectedUser = ""; // 추가 모드
                                                username = "";
                                                _usernameController.clear();
                                              });
                                            } else {
                                              setState(() {
                                                selectedUser = value ?? "";
                                              });
                                            }
                                          },
                                        ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: usernameEditing
                                      ? () {
                                          if (selectedUser.isNotEmpty && snapshot.users.contains(selectedUser)) {
                                            updateUser(selectedUser, _usernameController.text);
                                          } else {
                                            addUser(_usernameController.text);
                                          }
                                        }
                                      : startEditingUser,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: usernameEditing ? Colors.green : Colors.blue),
                                  child: Text(usernameEditing ? "확인" : "수정"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: usernameEditing ? cancelEditingUser : deleteUser,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text(usernameEditing ? "취소" : "삭제"),
                                ),
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
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(200)),
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            // 아침/점심/저녁 버튼
                            if (selectedUser.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: ["breakfast", "lunch", "dinner"].map((meal) {
                                  bool isSelected = selectedMapping.meals[meal] ?? false;
                                  Color bgColor;
                                  switch (meal) {
                                    case "breakfast":
                                      bgColor = isSelected ? const Color(0xFFFFD54F) : Colors.grey.shade400;
                                      break;
                                    case "lunch":
                                      bgColor = isSelected ? const Color(0xFFFF9700) : Colors.grey.shade400;
                                      break;
                                    default:
                                      bgColor = isSelected ? const Color(0xFF42A5F6) : Colors.grey.shade400;
                                  }
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: ElevatedButton(
                                        onPressed: () => toggleMeal(meal),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: bgColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        child: Text(
                                          meal == "breakfast" ? "아침" : meal == "lunch" ? "점심" : "저녁",
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // 2️⃣ 약 슬롯 리스트 (이름, 개수, 삭제, 추가)
                            Expanded(
                              child: ListView.builder(
                                itemCount: selectedMapping.pills.length + 1,
                                itemBuilder: (context, index) {
                                  if (index < selectedMapping.pills.length) {
                                    final pill = selectedMapping.pills[index];

                                    // 기존 컨트롤러 재사용
                                    final nameController = pillNameControllers.putIfAbsent(
                                      pill.id,
                                      () => TextEditingController(text: pill.name),
                                    );
                                    final countController = pillCountControllers.putIfAbsent(
                                      pill.id,
                                      () => TextEditingController(text: pill.count.toString()),
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              "${index + 1}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: TextField(
                                              controller: nameController,
                                              onChanged: (v) => updatePillName(selectedUser, pill.id, v),
                                              decoration: const InputDecoration(
                                                hintText: "약 이름",
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 60,
                                            child: TextField(
                                              controller: countController,
                                              onChanged: (v) => updatePillCount(selectedUser, pill.id, int.tryParse(v) ?? 0),
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              removePillSlot(selectedUser, pill.id);
                                              pillNameControllers.remove(pill.id);
                                              pillCountControllers.remove(pill.id);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            ),
                                            child: const Text("X", style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // 추가 슬롯
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: ElevatedButton(
                                        onPressed: () => addPillSlot(selectedUser),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          minimumSize: const Size.fromHeight(45),
                                        ),
                                        child: const Text(
                                          "+ 추가하기",
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                            // 3️⃣ 저장 / 초기화 버튼
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: saveAll,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text("저장", style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => setState(() => showResetModal = true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text("초기화", style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40), // 하단 여백
                          ],
                        ),
                      ),
                    ),
                  )
                  
                ],
              ),
              

        // 🔴 뒤로가기 경고 모달
        if (showBackModal)
          Positioned.fill(
            child: Container(
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
                      const Text(
                        "저장하지 않은 내용이 있습니다.\n뒤로 가시겠습니까?",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => showBackModal = false),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                              child: const Text("취소", style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                widget.onBack(); // 확인 시 뒤로가기
                                setState(() => showBackModal = false);
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
          ),


          // 🔴 초기화 모달 (기존 showResetModal)
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
