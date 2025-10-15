// widgets/meal_buttons.dart

import 'package:flutter/material.dart';
import '../../models/mapping.dart';

class MealButtons extends StatefulWidget {
  final Mapping mapping;
  const MealButtons({super.key, required this.mapping, required this.toggleMeal});

  @override
  State<MealButtons> createState() => _MealButtonsState();
}

class _MealButtonsState extends State<MealButtons> {
  @override
  Widget build(BuildContext context) {
    final meals = ["breakfast", "lunch", "dinner"];
    final labels = {"breakfast": "아침", "lunch": "점심", "dinner": "저녁"};

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: meals.map((meal) {
        final active = widget.mapping.meals[meal] ?? false;
        return ElevatedButton(
          onPressed: () => setState(() => widget.mapping.toggleMeal(meal)),
          style: ElevatedButton.styleFrom(
            backgroundColor: active ? Colors.orange : Colors.grey.shade400,
            minimumSize: const Size(100, 40),
          ),
          child: Text(labels[meal]!, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }
}
