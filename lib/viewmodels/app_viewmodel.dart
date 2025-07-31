// lib/viewmodels/app_viewmodel.dart (수정 완료)

import 'package:flutter/material.dart';
import 'package:obm/data/models/assembly_item.dart';
import 'package:obm/data/models/body_template.dart';

enum EditingTarget { none, body, title }

enum TemplateType { vertical, horizontal }

class AppViewModel with ChangeNotifier {
  TransformationController? transformationController;

  void setTransformationController(TransformationController controller) {
    transformationController = controller;
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  EditingTarget _editingTarget = EditingTarget.none;
  EditingTarget get editingTarget => _editingTarget;

  List<AssemblyItem> _overviewItems = [];
  List<AssemblyItem> get overviewItems => _overviewItems;

  Size _artboardSize = const Size(1280, 720);
  Size get artboardSize => _artboardSize;

  int? _selectedItemIndex;
  int? get selectedItemIndex => _selectedItemIndex;

  void selectItem(int? index) {
    if (_selectedItemIndex == index) {
      _selectedItemIndex = null;
    } else {
      _selectedItemIndex = index;
    }
    notifyListeners();
  }

  void createNewTemplate(TemplateType type) {
    _overviewItems = [];
    _artboardSize = const Size(1280, 720);
    print('$type 템플릿 생성 (1280x720)');

    _overviewItems.add(
      AssemblyItem(
        type: AssemblyItemType.background,
        position: Offset.zero,
        size: _artboardSize,
      ),
    );
    _overviewItems.add(
      AssemblyItem(
        type: AssemblyItemType.title,
        position: const Offset(40, 40),
        size: const Size(600, 100),
      ),
    );

    for (int i = 0; i < 7; i++) {
      _overviewItems.add(
        AssemblyItem(
          type: AssemblyItemType.body,
          position: Offset(40, 160.0 + (i * 75)),
          size: const Size(600, 65),
          data: BodyTemplate(
            initialElements: [
              BodyElement(placeholder: 'date'),
              BodyElement(placeholder: 'text'),
            ],
          ),
        ),
      );
    }
    _overviewItems.add(
      AssemblyItem(
        type: AssemblyItemType.fanArt,
        position: const Offset(680, 40),
        size: const Size(560, 640),
      ),
    );
    notifyListeners();
  }

  void startEditing(EditingTarget target, dynamic itemToEdit) {
    _isEditing = true;
    _editingTarget = target;
    notifyListeners();
  }

  void stopEditing() {
    _isEditing = false;
    _editingTarget = EditingTarget.none;
    notifyListeners();
  }

  /// 아이템의 위치를 업데이트하는 메소드
  void updateItemPosition(int index, Offset newPosition) {
    if (index < 0 || index >= _overviewItems.length) return;
    _overviewItems[index].position = newPosition;
    notifyListeners();
  }

  /// 화면의 절대 좌표를 아트보드의 상대 좌표로 변환하여 업데이트
  void updateItemPositionFromGlobal(int index, Offset globalPosition) {
    if (transformationController == null) return;

    final Matrix4 inverseMatrix = Matrix4.inverted(
      transformationController!.value,
    );

    // 이 부분을 수정했습니다.
    final Offset localPosition = MatrixUtils.transformPoint(
      inverseMatrix,
      globalPosition,
    );

    updateItemPosition(index, localPosition);
  }
}
