// lib/views/widgets/body_canvas.dart

import 'package:flutter/material.dart';
import 'package:obm/viewmodels/body_canvas_viewmodel.dart'; // ViewModel import
import 'package:provider/provider.dart'; // Provider import

class BodyCanvas extends StatelessWidget {
  const BodyCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer 위젯을 사용하여 ViewModel에 접근하고, 데이터 변경 시 자동으로 다시 그려지도록 합니다.
    return Consumer<BodyCanvasViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () {
            // 캔버스의 빈 공간을 탭하면 선택 해제
            viewModel.selectElement(null);
          },
          child: Container(
            color: Colors.grey.shade900,
            // Stack을 사용하여 여러 위젯(요소)들을 겹겹이 쌓습니다.
            child: Stack(
              children: [
                // 모든 요소를 화면에 그립니다.
                ...viewModel.template.elements.asMap().entries.map((entry) {
                  int index = entry.key;
                  var element = entry.value;
                  bool isSelected = viewModel.selectedElementIndex == index;

                  // 텍스트 위젯 생성
                  final textWidget = Text(
                    element.placeholder,
                    style:
                        element.styles[viewModel
                            .template
                            .backgroundImages
                            .keys
                            .first]!,
                  );

                  return Positioned(
                    left: element.localPosition.dx,
                    top: element.localPosition.dy,
                    child: Draggable(
                      // 드래그할 때 보여줄 위젯
                      feedback: Material(
                        color: Colors.transparent,
                        child: textWidget,
                      ),
                      // 드래그가 끝났을 때 호출
                      onDragEnd: (details) {
                        // 캔버스의 로컬 좌표로 변환하여 ViewModel에 위치 업데이트를 요청
                        final RenderBox canvasRenderBox =
                            context.findRenderObject() as RenderBox;
                        final newPosition = canvasRenderBox.globalToLocal(
                          details.offset,
                        );
                        viewModel.setElementPosition(index, newPosition);
                      },
                      // 실제 화면에 보여지는 위젯
                      child: GestureDetector(
                        onTap: () {
                          // 요소를 탭하면 선택
                          viewModel.selectElement(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          // 선택되었을 때 테두리 표시
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurpleAccent
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: textWidget,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
