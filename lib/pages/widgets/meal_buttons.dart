// widgets/meal_buttons.dart

import 'package:flutter/material.dart';
import '../../models/mapping.dart';

class MealButtons extends StatelessWidget {
  final Mapping mapping;
  final void Function(String) toggleMeal;

  const MealButtons({
    super.key,
    required this.mapping,
    required this.toggleMeal,
  });

  @override
  Widget build(BuildContext context) {
    final meals = ["breakfast", "lunch", "dinner"];
    final labels = {"breakfast": "아침", "lunch": "점심", "dinner": "저녁"};

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: meals.map((meal) {
          final active = mapping.meals[meal] ?? false;
          return ElevatedButton(
            onPressed: () => toggleMeal(meal),
            style: ElevatedButton.styleFrom(
              backgroundColor: active ? Colors.orange : Colors.grey,
              minimumSize: const Size(100, 40),
            ),
            child: Text(labels[meal]!, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
      ),
    );
  }
}
