//widgets/pill_list.dart
import 'package:flutter/material.dart';
import '../../models/pill.dart';

class PillList extends StatelessWidget {
  final List<Pill> pills;
  final Map<int, TextEditingController> pillNameControllers;
  final Map<int, TextEditingController> pillCountControllers;
  final Function(int, String) updateName;
  final Function(int, int) updateCount;
  final Function(int) removeSlot;
  final VoidCallback addSlot;

  const PillList({
    super.key,
    required this.pills,
    required this.pillNameControllers,
    required this.pillCountControllers,
    required this.updateName,
    required this.updateCount,
    required this.removeSlot,
    required this.addSlot,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pills.length + 1,
      itemBuilder: (context, index) {
        if (index < pills.length) {
          final pill = pills[index];
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
                SizedBox(width: 30, child: Text("${index + 1}", textAlign: TextAlign.center)),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: nameController,
                    onChanged: (v) => updateName(pill.id, v),
                    decoration: const InputDecoration(
                      hintText: "약 이름",
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: countController,
                    onChanged: (v) => updateCount(pill.id, int.tryParse(v) ?? 0),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => removeSlot(pill.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("X", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: addSlot,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(45),
              ),
              child: const Text("+ 추가하기", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          );
        }
      },
    );
  }
}
