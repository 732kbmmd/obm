// lib/views/screens/selection_screen.dart

import 'package:flutter/material.dart';
import 'package:obm/views/screens/creation_options_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오뱅몇 시작하기'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '원하는 작업을 선택하세요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildModeButton(
              context: context,
              icon: Icons.design_services,
              label: '시간표 제작',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreationOptionsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildModeButton(
              context: context,
              icon: Icons.edit_note,
              label: '시간표 수정',
              onPressed: () {
                // TODO: '수정 모드'로 이동하는 로직 추가
              },
            ),
          ],
        ),
      ),
    );
  }

  // 버튼 스타일을 통일하기 위한 헬퍼 위젯
  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(300, 80),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
