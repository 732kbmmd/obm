// lib/views/widgets/body_inspector.dart

import 'package:flutter/material.dart';
import 'package:obm/viewmodels/body_canvas_viewmodel.dart';
import 'package:provider/provider.dart';

class BodyInspector extends StatelessWidget {
  const BodyInspector({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer로 ViewModel을 구독하여 데이터 변경 시 자동으로 UI가 업데이트되도록 함
    return Consumer<BodyCanvasViewModel>(
      builder: (context, viewModel, child) {
        // 선택된 요소가 없으면 안내 메시지를 표시
        if (viewModel.selectedElementIndex == null) {
          return Container(
            width: 280,
            color: const Color(0xFF2a2a2a),
            child: const Center(
              child: Text(
                '캔버스에서 요소를 선택하여\n편집하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        // 선택된 요소가 있으면 편집 UI를 표시
        final selectedElement =
            viewModel.template.elements[viewModel.selectedElementIndex!];
        final currentStyle = selectedElement
            .styles[viewModel.template.backgroundImages.keys.first]!;

        return Container(
          width: 280,
          color: const Color(0xFF2a2a2a),
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // 선택된 요소의 이름 표시
              Text(
                '속성: ${selectedElement.placeholder}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 30),

              // 글꼴 크기 조절
              const Text(
                '글꼴 크기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: currentStyle.fontSize ?? 16.0,
                      min: 8,
                      max: 128,
                      label: (currentStyle.fontSize ?? 16.0).toStringAsFixed(1),
                      onChanged: (size) {
                        viewModel.updateSelectedElementFontSize(size);
                      },
                    ),
                  ),
                  Text((currentStyle.fontSize ?? 16.0).toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 16),

              // TODO: 색상 및 꾸미기(굵게 등) UI 추가 예정
            ],
          ),
        );
      },
    );
  }
}
