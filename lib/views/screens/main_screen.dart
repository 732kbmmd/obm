// lib/views/screens/main_screen.dart (최종 수정)

import 'package:flutter/material.dart';
import 'package:obm/data/models/assembly_item.dart';
import 'package:obm/viewmodels/app_viewmodel.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    Provider.of<AppViewModel>(
      context,
      listen: false,
    ).setTransformationController(_transformationController);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
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
              Expanded(child: _buildRightPanel(viewModel)),
              _buildInspector(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightPanel(AppViewModel viewModel) {
    if (!viewModel.isEditing) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          transformationController: _transformationController,
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
                    return Positioned(
                      left: item.position.dx,
                      top: item.position.dy,
                      child: Draggable<int>(
                        data: index,
                        feedback: Opacity(
                          opacity: 0.7,
                          child: _buildAssemblyItem(item, false),
                        ),
                        onDragEnd: (details) {
                          viewModel.updateItemPositionFromGlobal(
                            index,
                            details.offset,
                          );
                        },
                        child: GestureDetector(
                          onTap: () => viewModel.selectItem(index),
                          child: _buildAssemblyItem(
                            item,
                            viewModel.selectedItemIndex == index,
                          ),
                        ),
                      ),
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

  // --- 나머지 헬퍼 메소드들은 변경 사항 없음 ---
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
      default:
        return Container(color: Colors.grey, child: const Text('오류'));
    }
  }

  Widget _buildInspector(AppViewModel viewModel) {
    final selectedItem = viewModel.selectedItemIndex != null
        ? viewModel.overviewItems[viewModel.selectedItemIndex!]
        : null;
    return Container(
      width: 280,
      color: const Color(0xFF2a2a2a),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: viewModel.isEditing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('세부 속성 패널'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => viewModel.stopEditing(),
                    child: const Text('편집 완료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              )
            : selectedItem != null &&
                  (selectedItem.type == AssemblyItemType.body ||
                      selectedItem.type == AssemblyItemType.title)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('선택됨: ${selectedItem.type.name}'),
                  const SizedBox(height: 20),
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
                ],
              )
            : const Text('전체 속성 패널'),
      ),
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
