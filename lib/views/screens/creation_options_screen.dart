// lib/views/screens/creation_options_screen.dart

import 'package:flutter/material.dart';
import 'package:obm/viewmodels/app_viewmodel.dart';
import 'package:obm/views/screens/main_screen.dart';
import 'package:provider/provider.dart';

class CreationOptionsScreen extends StatelessWidget {
  const CreationOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시간표 제작')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // '새로운 시간표 생성' 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('새로운 시간표 생성'),
              onPressed: () => _showTemplateTypeDialog(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 80),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            // '시간표 패키지 불러오기' 버튼 (지금은 비활성화)
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('시간표 패키지 불러오기'),
              onPressed: null, // null로 설정하여 비활성화
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 80),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // '가로/세로' 템플릿 선택 다이얼로그를 보여주는 함수
  Future<void> _showTemplateTypeDialog(BuildContext context) async {
    // context를 안전하게 사용하기 위해 mounted 체크
    if (!context.mounted) return;

    final viewModel = Provider.of<AppViewModel>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('템플릿 유형 선택'),
          content: const Text('어떤 방향의 템플릿을 생성하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('세로 템플릿'),
              onPressed: () {
                // ViewModel에 세로 템플릿 생성을 요청
                viewModel.createNewTemplate(TemplateType.vertical);
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                // 메인 편집 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            TextButton(
              child: const Text('가로 템플릿'),
              onPressed: () {
                // ViewModel에 가로 템플릿 생성을 요청
                viewModel.createNewTemplate(TemplateType.horizontal);
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                // 메인 편집 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
