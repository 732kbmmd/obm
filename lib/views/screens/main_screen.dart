// lib/views/screens/main_screen.dart (전체 코드 교체)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 키보드 입력을 위해 추가
import 'package:obm/data/models/assembly_item.dart';
import 'package:obm/viewmodels/app_viewmodel.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 키보드 입력을 받기 위해 Focus 위젯으로 감쌉니다.
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        final viewModel = Provider.of<AppViewModel>(context, listen: false);
        if (viewModel.selectedItemIndex == null || viewModel.isEditing) {
          return KeyEventResult.ignored;
        }

        final currentPosition =
            viewModel.overviewItems[viewModel.selectedItemIndex!].position;
        Offset newPosition;

        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp:
            newPosition = currentPosition.translate(0, -1);
            break;
          case LogicalKeyboardKey.arrowDown:
            newPosition = currentPosition.translate(0, 1);
            break;
          case LogicalKeyboardKey.arrowLeft:
            newPosition = currentPosition.translate(-1, 0);
            break;
          case LogicalKeyboardKey.arrowRight:
            newPosition = currentPosition.translate(1, 0);
            break;
          default:
            return KeyEventResult.ignored;
        }
        viewModel.updateSelectedItemPosition(newPosition);
        return KeyEventResult.handled;
      },
      child: Consumer<AppViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.isEditing ? '세부 편집 모드' : '오버뷰 모드'),
              centerTitle: true,
            ),
            body: Row(
              children: [
                if (viewModel.isEditing)
                  Expanded(
                    child: Container(
                      color: Colors.indigo.shade900,
                      child: const Center(child: Text('축소된 오버뷰 캔버스')),
                    ),
                  ),
                Expanded(child: _buildRightPanel(context, viewModel)),
                _buildInspector(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, AppViewModel viewModel) {
    if (!viewModel.isEditing) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          child: GestureDetector(
            onTap: () => viewModel.selectItem(null),
            child: Center(
              child: Container(
                width: viewModel.artboardSize.width,
                height: viewModel.artboardSize.height,
                color: const Color(0xFFE6E0F8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: viewModel.overviewItems.asMap().entries.map((
                    entry,
                  ) {
                    int index = entry.key;
                    AssemblyItem item = entry.value;
                    if (item.type == AssemblyItemType.background) {
                      return const SizedBox.shrink();
                    }

                    final positionedItem = Positioned(
                      left: item.position.dx,
                      top: item.position.dy,
                      child: GestureDetector(
                        onTap: () => viewModel.selectItem(index),
                        child: _buildAssemblyItem(
                          item,
                          viewModel.selectedItemIndex == index,
                        ),
                      ),
                    );

                    return Draggable<int>(
                      data: index,
                      feedback: Opacity(
                        opacity: 0.7,
                        child: _buildAssemblyItem(item, false),
                      ),
                      onDragUpdate: (details) {
                        // 드래그 중 실시간 위치 업데이트 (선택사항)
                        // final RenderBox viewerBox = context.findRenderObject() as RenderBox;
                        // final Offset localOffset = viewerBox.globalToLocal(details.globalPosition);
                        // viewModel.updateSelectedItemPosition(localOffset);
                      },
                      onDragEnd: (details) {
                        final RenderBox viewerBox =
                            context.findRenderObject() as RenderBox;
                        // InteractiveViewer 내부의 좌표계가 아닌, 전체 화면 기준의 좌표로 변환해야 함
                        // 이 부분은 더 복잡한 계산이 필요하므로, 여기서는 우선 간단한 오프셋만 사용
                        // 정확한 구현을 위해서는 TransformationController를 사용해야 합니다.
                        // 지금은 드래그 시작점 대비 변화량으로 위치를 계산합니다.
                        final currentPos =
                            viewModel.overviewItems[index].position;
                        viewModel.updateSelectedItemPosition(
                          currentPos + details.offset,
                        );
                      },
                      child: positionedItem,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black87,
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100.0),
        minScale: 0.1,
        maxScale: 4.0,
        child: Center(child: _buildDetailEditor(viewModel)),
      ),
    );
  }

  Widget _buildDetailEditor(AppViewModel viewModel) {
    switch (viewModel.editingTarget) {
      case EditingTarget.body:
        return Container(
          width: 800,
          height: 600,
          color: Colors.teal.shade900,
          child: const Center(child: Text('본문 편집 캔버스')),
        );
      case EditingTarget.title:
        return Container(
          width: 800,
          height: 200,
          color: Colors.red.shade900,
          child: const Center(child: Text('타이틀 편집 캔버스')),
        );
      case EditingTarget.none:
      default:
        return Container(color: Colors.grey, child: const Text('오류'));
    }
  }

  Widget _buildInspector(BuildContext context, AppViewModel viewModel) {
    final selectedItem = viewModel.selectedItemIndex != null
        ? viewModel.overviewItems[viewModel.selectedItemIndex!]
        : null;

    return Container(
      width: 280,
      color: const Color(0xFF2a2a2a),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.isEditing) ...[
            const Text(
              '세부 편집 중',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ElevatedButton(
              onPressed: () => viewModel.stopEditing(),
              child: const Text('편집 완료'),
            ),
          ] else if (selectedItem != null) ...[
            Text(
              '선택됨: ${selectedItem.type.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            if (selectedItem.type == AssemblyItemType.body ||
                selectedItem.type == AssemblyItemType.title)
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('세부 편집'),
                onPressed: () {
                  final target = selectedItem.type == AssemblyItemType.body
                      ? EditingTarget.body
                      : EditingTarget.title;
                  viewModel.startEditing(target, selectedItem);
                },
              ),
            const Divider(height: 20),
            _buildCoordinateController(
              label: 'X 좌표',
              value: selectedItem.position.dx,
              onUpdate: (newValue) {
                viewModel.updateSelectedItemPosition(
                  Offset(newValue, selectedItem.position.dy),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildCoordinateController(
              label: 'Y 좌표',
              value: selectedItem.position.dy,
              onUpdate: (newValue) {
                viewModel.updateSelectedItemPosition(
                  Offset(selectedItem.position.dx, newValue),
                );
              },
            ),
          ] else
            const Center(child: Text('전체 속성 패널')),
        ],
      ),
    );
  }

  Widget _buildCoordinateController({
    required String label,
    required double value,
    required Function(double) onUpdate,
  }) {
    final controller = TextEditingController(text: value.toStringAsFixed(1));
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              onPressed: () => onUpdate(value - 5),
              icon: const Icon(Icons.keyboard_double_arrow_left),
              iconSize: 18,
            ),
            IconButton(
              onPressed: () => onUpdate(value - 1),
              icon: const Icon(Icons.keyboard_arrow_left),
              iconSize: 18,
            ),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onFieldSubmitted: (textValue) =>
                      onUpdate(double.tryParse(textValue) ?? value),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => onUpdate(value + 1),
              icon: const Icon(Icons.keyboard_arrow_right),
              iconSize: 18,
            ),
            IconButton(
              onPressed: () => onUpdate(value + 5),
              icon: const Icon(Icons.keyboard_double_arrow_right),
              iconSize: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssemblyItem(AssemblyItem item, bool isSelected) {
    Widget content;
    switch (item.type) {
      case AssemblyItemType.fanArt:
        content = Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Text('frame', style: TextStyle(color: Colors.black54)),
          ),
        );
        break;
      case AssemblyItemType.title:
        content = Container(
          color: const Color(0xFFE6E0F8),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TITLE subtitle',
              style: TextStyle(color: Colors.black, fontSize: 48),
            ),
          ),
        );
        break;
      case AssemblyItemType.body:
        content = Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE6E0F8),
            border: Border(
              top: BorderSide(color: Colors.white, width: 2),
              bottom: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('date', style: TextStyle(color: Colors.black54)),
                Text(
                  'text',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        content = Container();
    }

    return Container(
      width: item.size.width,
      height: item.size.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.yellowAccent : Colors.transparent,
          width: 3,
        ),
      ),
      child: content,
    );
  }
}
