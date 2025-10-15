// lib/pages/manage_page.dart
import 'package:flutter/material.dart';
import 'widgets/top_panel.dart';
import 'widgets/meal_buttons.dart';
import 'widgets/pill_list.dart';
import 'widgets/modals.dart';
import '../utils/storage_helper.dart';
import '../models/mapping.dart';
import '../models/pill.dart';
import '../models/snapshot.dart';

class ManagePage extends StatefulWidget {
  final VoidCallback onBack;
  const ManagePage({super.key, required this.onBack});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> with TickerProviderStateMixin {
  String status = "on call";
  bool connecting = false;
  Snapshot snapshot = Snapshot(users: [], mapping: []);
  String selectedUser = "";
  bool usernameEditing = false;
  late TextEditingController _usernameController;

  bool showBackModal = false;
  bool showResetModal = false;

  // 컨트롤러 맵 (pill id -> controller)
  final Map<int, TextEditingController> pillNameControllers = {};
  final Map<int, TextEditingController> pillCountControllers = {};

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();

    // 예: 저장된 snapshot 불러오기 (StorageHelper 구현에 따라)
    StorageHelper.loadSnapshot().then((loaded) {
      setState(() {
        snapshot = loaded;
        // 선택 유저가 없으면 첫 유저 자동 선택 (있을 때만)
        if (snapshot.users.isNotEmpty && selectedUser.isEmpty) {
          selectedUser = snapshot.users.first;
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    for (var c in pillNameControllers.values) c.dispose();
    for (var c in pillCountControllers.values) c.dispose();
    super.dispose();
  }

  Mapping get selectedMapping => snapshot.mapping.firstWhere(
        (m) => m.user == selectedUser,
        orElse: () => Mapping(user: "", pills: []),
      );

  bool hasUnsavedChanges() {
    // 간단 체크: 편집모드 or 입력값 존재 or 선택된 매핑에 실제 데이터 존재하면 경고
    return usernameEditing ||
        _usernameController.text.isNotEmpty ||
        selectedMapping.pills.any((p) => p.name.isNotEmpty || p.count > 0);
  }

  void onBackPressed() {
    if (hasUnsavedChanges()) {
      setState(() => showBackModal = true);
    } else {
      widget.onBack();
    }
  }

  void addUser(String name) {
    if (name.isEmpty) return;
    setState(() {
      snapshot.users.add(name);
      snapshot.mapping.add(Mapping(user: name, pills: []));
      selectedUser = name;
      usernameEditing = false;
      _usernameController.clear();
      StorageHelper.saveSnapshot(snapshot); // 저장
    });
  }

  void deleteUser() {
    if (selectedUser.isEmpty) return;
    setState(() {
      snapshot.users.remove(selectedUser);
      snapshot.mapping.removeWhere((m) => m.user == selectedUser);
      selectedUser = snapshot.users.isNotEmpty ? snapshot.users.last : "";
      usernameEditing = false;
      _usernameController.clear();
      StorageHelper.saveSnapshot(snapshot); // 저장
    });
  }

  void updateUser(String oldName, String newName) {
    if (newName.isEmpty) return;
    setState(() {
      snapshot.users = snapshot.users.map((u) => u == oldName ? newName : u).toList();
      snapshot.mapping = snapshot.mapping.map((m) {
        return m.user == oldName
            ? Mapping(user: newName, pills: m.pills, breakfast: m.breakfast, lunch: m.lunch, dinner: m.dinner)
            : m;
      }).toList();
      selectedUser = newName;
      usernameEditing = false;
      _usernameController.clear();
      StorageHelper.saveSnapshot(snapshot); // 저장
    });
  }

  void toggleMeal(String meal) {
    setState(() {
      selectedMapping.toggleMeal(meal);
      StorageHelper.saveSnapshot(snapshot); // 저장
    });
  }

  void addPillSlot() {
    if (selectedUser.isEmpty) return;
    setState(() {
      final newPill = Pill(id: DateTime.now().millisecondsSinceEpoch, name: "", count: 0);
      selectedMapping.pills.add(newPill);
      // 컨트롤러 초기화
      pillNameControllers[newPill.id] = TextEditingController(text: newPill.name);
      pillCountControllers[newPill.id] = TextEditingController(text: newPill.count.toString());
    });
  }

  void removePillSlot(int id) {
    setState(() {
      selectedMapping.pills.removeWhere((p) => p.id == id);
      // 컨트롤러 정리
      pillNameControllers[id]?.dispose();
      pillCountControllers[id]?.dispose();
      pillNameControllers.remove(id);
      pillCountControllers.remove(id);
    });
  }

  void updatePillName(int id, String name) {
    for (var p in selectedMapping.pills) {
      if (p.id == id) p.name = name;
    }
    StorageHelper.saveSnapshot(snapshot); // 저장
  }

  void updatePillCount(int id, int count) {
    for (var p in selectedMapping.pills) {
      if (p.id == id) p.count = count;
    }
  }

  void resetAll() async {
    // 선택된 사용자만 초기화 (요청하신 대로)
    if (selectedUser.isNotEmpty) {
      snapshot.mapping.removeWhere((m) => m.user == selectedUser);
      snapshot.mapping.add(Mapping(user: selectedUser, pills: [], breakfast: false, lunch: false, dinner: false));
      // 기존 컨트롤러 정리
      for (var id in pillNameControllers.keys.toList()) {
        pillNameControllers[id]?.dispose();
      }
      for (var id in pillCountControllers.keys.toList()) {
        pillCountControllers[id]?.dispose();
      }
      pillNameControllers.clear();
      pillCountControllers.clear();
    } else {
      // 혹시 전체 초기화 원하면 (여기선 사용자가 비어있으면 전체 초기화)
      snapshot = Snapshot(users: [], mapping: []);
    }
    // (옵션) 로컬 저장소 초기화 호출이 필요하면 여기에 StorageHelper.clearAll();
    setState(() {});
  }

  Future<void> saveAll() async {
    await StorageHelper.saveSnapshot(snapshot);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
    }
  }

  // 사용자 편집 시작
  void startEditingUser() {
    setState(() {
      usernameEditing = true;
      _usernameController.text = selectedUser;
    });
  }

  // 사용자 편집 취소
  void cancelEditingUser() {
    setState(() {
      usernameEditing = false;
      _usernameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // selectedMapping 지역 변수 (빌드 내부에서 사용)
    final mappingForBuild = selectedMapping;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 420,
            minWidth: 360,
            maxHeight: 844,
            minHeight: 700,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // 상단 패널 (원래 UI와 동일하게)
                  TopPanel(
                    status: status,
                    connecting: connecting,
                    onBackPressed: onBackPressed,
                    usernameEditing: usernameEditing,
                    usernameController: _usernameController,
                    selectedUser: selectedUser,
                    users: snapshot.users,
                    onUserSelected: (v) => setState(() => selectedUser = v),
                    startEditing: startEditingUser,
                    cancelEditing: cancelEditingUser,
                    addUser: (name) => addUser(name),
                    deleteUser: deleteUser,
                    updateUser: (oldName, newName) => updateUser(oldName, newName),
                  ),

                  // 하단 패널 (알약 모양 레이아웃)
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
                            // 식사 버튼
                            if (selectedUser.isNotEmpty)
                              MealButtons(mapping: mappingForBuild, toggleMeal: toggleMeal),
                            const SizedBox(height: 16),

                            // 약 슬롯 리스트
                            Expanded(
                              child: PillList(
                                pills: mappingForBuild.pills,
                                pillNameControllers: pillNameControllers,
                                pillCountControllers: pillCountControllers,
                                updateName: updatePillName,
                                updateCount: updatePillCount,
                                removeSlot: removePillSlot,
                                addSlot: addPillSlot,
                              ),
                            ),

                            // 저장 / 초기화 버튼
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
                  ),
                ],
              ),

              // 뒤로가기 경고 모달 (Positioned.fill으로 overlay)
              if (showBackModal)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: _buildDialog(
                        context,
                        "저장하지 않은 내용이 있습니다.\n뒤로가시겠습니까?",
                        onCancel: () => setState(() => showBackModal = false),
                        onConfirm: () {
                          widget.onBack();
                          setState(() => showBackModal = false);
                        },
                      ),
                    ),
                  ),
                ),

              // 초기화 모달
              if (showResetModal)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: _buildDialog(
                        context,
                        "선택한 사용자의 데이터를 초기화하시겠습니까?",
                        onCancel: () => setState(() => showResetModal = false),
                        onConfirm: () {
                          resetAll();
                          setState(() => showResetModal = false);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialog(BuildContext context, String text, {required VoidCallback onCancel, required VoidCallback onConfirm}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("취소"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("확인"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
