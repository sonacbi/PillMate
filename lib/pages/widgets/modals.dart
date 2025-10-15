// widgets/modals.dart

import 'package:flutter/material.dart';

class BottomModals extends StatelessWidget {
  final bool showBackModal;
  final bool showResetModal;
  final VoidCallback onCancelBack;
  final VoidCallback onConfirmBack;
  final VoidCallback onCancelReset;
  final VoidCallback onConfirmReset;

  const BottomModals({
    super.key,
    required this.showBackModal,
    required this.showResetModal,
    required this.onCancelBack,
    required this.onConfirmBack,
    required this.onCancelReset,
    required this.onConfirmReset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showBackModal)
          _buildDialog(
            context,
            "저장하지 않은 변경사항이 있습니다. 돌아가시겠습니까?",
            onConfirmBack,
            onCancelBack,
          ),
        if (showResetModal)
          _buildDialog(
            context,
            "선택한 사용자의 데이터를 초기화하시겠습니까?",
            onConfirmReset,
            onCancelReset,
          ),
      ],
    );
  }

  Widget _buildDialog(BuildContext context, String text, VoidCallback onConfirm, VoidCallback onCancel) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
