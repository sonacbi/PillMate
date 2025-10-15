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

class _ManagePageState extends State<ManagePage> {
  String status = "on call";
  bool connecting = false;
  Snapshot snapshot = Snapshot(users: [], mapping: []);
  String selectedUser = "";
  bool usernameEditing = false;
  late TextEditingController _usernameController;

  bool showBackModal = false;
  bool showResetModal = false;

  Map<int, TextEditingController> pillNameControllers = {};
  Map<int, TextEditingController> pillCountControllers = {};

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  Mapping get selectedMapping => snapshot.mapping.firstWhere(
        (m) => m.user == selectedUser,
        orElse: () => Mapping(user: "", pills: []),
      );

  void onBackPressed() {
    if (hasUnsavedChanges()) {
      setState(() => showBackModal = true);
    } else {
      widget.onBack();
    }
  }

  bool hasUnsavedChanges() {
    return usernameEditing ||
        _usernameController.text.isNotEmpty ||
        selectedUser.isNotEmpty ||
        selectedMapping.pills.any((p) => p.name.isNotEmpty || p.count > 0);
  }

  void addUser(String name) {
    if (name.isEmpty) return;
    setState(() {
      snapshot.users.add(name);
      snapshot.mapping.add(Mapping(user: name, pills: []));
      selectedUser = name;
      usernameEditing = false;
      _usernameController.clear();
    });
  }

  void deleteUser() {
    setState(() {
      snapshot.users.remove(selectedUser);
      snapshot.mapping.removeWhere((m) => m.user == selectedUser);
      selectedUser = snapshot.users.isNotEmpty ? snapshot.users.last : "";
      usernameEditing = false;
      _usernameController.clear();
    });
  }

  void updateUser(String oldName, String newName) {
    if (newName.isEmpty) return;
    setState(() {
      snapshot.users = snapshot.users.map((u) => u == oldName ? newName : u).toList();
      snapshot.mapping = snapshot.mapping.map((m) {
        return m.user == oldName
            ? Mapping(
                user: newName,
                pills: m.pills,
                breakfast: m.breakfast,
                lunch: m.lunch,
                dinner: m.dinner,
              )
            : m;
      }).toList();
      selectedUser = newName;
      usernameEditing = false;
      _usernameController.clear();
    });
  }

  void toggleMeal(String meal) {
    setState(() {
      selectedMapping.toggleMeal(meal);
    });
  }

  void addPillSlot() {
    if (selectedUser.isEmpty) return;
    setState(() {
      selectedMapping.pills.add(
        Pill(id: DateTime.now().millisecondsSinceEpoch),
      );
    });
  }

  void removePillSlot(int id) {
    setState(() {
      selectedMapping.pills.removeWhere((p) => p.id == id);
      pillNameControllers.remove(id);
      pillCountControllers.remove(id);
    });
  }

  void updatePillName(int id, String name) {
    for (var p in selectedMapping.pills) {
      if (p.id == id) p.name = name;
    }
  }

  void updatePillCount(int id, int count) {
    for (var p in selectedMapping.pills) {
      if (p.id == id) p.count = count;
    }
  }

  void resetAll() {
    if (selectedUser.isNotEmpty) {
      snapshot.mapping.removeWhere((m) => m.user == selectedUser);
      snapshot.mapping.add(Mapping(user: selectedUser, pills: []));
    } else {
      snapshot = Snapshot(users: [], mapping: []);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 844),
          child: Stack(
            children: [
              Column(
                children: [
                  TopPanel(
                    status: status,
                    connecting: connecting,
                    onBackPressed: onBackPressed,
                    usernameEditing: usernameEditing,
                    usernameController: _usernameController,
                    selectedUser: selectedUser,
                    users: snapshot.users,
                    onUserSelected: (v) => setState(() => selectedUser = v),
                    startEditing: () => setState(() => usernameEditing = true),
                    cancelEditing: () => setState(() => usernameEditing = false),
                    addUser: addUser,
                    deleteUser: deleteUser,
                    updateUser: updateUser,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (selectedUser.isNotEmpty)
                            MealButtons(mapping: selectedMapping, toggleMeal: toggleMeal),
                          const SizedBox(height: 16),
                          Expanded(
                            child: PillList(
                              pills: selectedMapping.pills,
                              pillNameControllers: pillNameControllers,
                              pillCountControllers: pillCountControllers,
                              updateName: updatePillName,
                              updateCount: updatePillCount,
                              removeSlot: removePillSlot,
                              addSlot: addPillSlot,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              BottomModals(
                showBackModal: showBackModal,
                showResetModal: showResetModal,
                onCancelBack: () => setState(() => showBackModal = false),
                onConfirmBack: () {
                  widget.onBack();
                  setState(() => showBackModal = false);
                },
                onCancelReset: () => setState(() => showResetModal = false),
                onConfirmReset: () {
                  resetAll();
                  setState(() => showResetModal = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

