// lib/viewmodels/body_canvas_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:obm/data/models/body_template.dart'; // 우리가 만든 데이터 모델 import

// ChangeNotifier를 mixin하여 상태 변경을 UI에 알릴 수 있게 합니다.
class BodyCanvasViewModel with ChangeNotifier {
  // ViewModel이 관리할 핵심 데이터: BodyTemplate
  final BodyTemplate _template = BodyTemplate();
  BodyTemplate get template => _template; // 외부에서는 이 getter를 통해 template 데이터에 접근

  // 현재 선택된 요소의 인덱스. 선택된 것이 없으면 null.
  int? _selectedElementIndex;
  int? get selectedElementIndex => _selectedElementIndex;

  // 그리드 보이기/숨기기 상태
  bool _isGridVisible = true;
  bool get isGridVisible => _isGridVisible;

  // --- 상태를 변경하는 메소드들 ---
  // 메소드가 호출되면 데이터를 변경하고, 마지막에 notifyListeners()를 호출하여
  // 이 ViewModel을 구독하는 모든 위젯에게 "데이터 바뀌었으니 화면 새로고침 해!"라고 알려줍니다.

  /// 요소를 선택하는 메소드
  void selectElement(int? index) {
    if (_selectedElementIndex == index) return; // 이미 선택된 요소를 다시 누르면 아무것도 안 함
    _selectedElementIndex = index;
    notifyListeners();
  }

  /// 선택된 요소를 이동시키는 메소드
  void moveSelectedElement(Offset delta) {
    if (_selectedElementIndex == null) return;
    _template.elements[_selectedElementIndex!].localPosition += delta;
    notifyListeners();
  }

  /// 특정 요소의 위치를 직접 설정하는 메소드 (드래그 종료 시 사용)
  void setElementPosition(int index, Offset newPosition) {
    _template.elements[index].localPosition = newPosition;
    notifyListeners();
  }

  /// 그리드 표시 여부를 토글하는 메소드
  void toggleGridVisibility() {
    _isGridVisible = !_isGridVisible;
    notifyListeners();
  }

  /// 템플릿의 배경 이미지를 변경하는 메소드
  void updateBackgroundImage(String path) {
    _template.backgroundImages[ComponentState.live] = path;
    // TODO: 배경 이미지 위치를 캔버스 중앙으로 설정하는 로직 추가
    notifyListeners();
  }

  /// 템플릿의 배경 이미지를 제거하는 메소드
  void removeBackgroundImage() {
    _template.backgroundImages[ComponentState.live] = null;
    notifyListeners();
  }

  /// 선택된 요소의 스타일을 업데이트하는 메소드
  void updateSelectedElementStyle(TextStyle newStyle) {
    if (_selectedElementIndex == null) return;
    _template.elements[_selectedElementIndex!].styles[ComponentState.live] =
        newStyle;
    notifyListeners();
  }

  // 여기에 앞으로 필요한 다른 로직들(폰트 크기 조절, 색상 변경 등)을 계속 추가해 나갈 것입니다.
  /// 선택된 요소의 글꼴 크기를 변경하는 메소드
  void updateSelectedElementFontSize(double size) {
    if (_selectedElementIndex == null) return;
    final currentStyle =
        _template.elements[_selectedElementIndex!].styles[ComponentState.live]!;
    updateSelectedElementStyle(currentStyle.copyWith(fontSize: size));
  }

  /// 선택된 요소의 색상을 변경하는 메소드
  void updateSelectedElementColor(Color color) {
    if (_selectedElementIndex == null) return;
    final currentStyle =
        _template.elements[_selectedElementIndex!].styles[ComponentState.live]!;
    updateSelectedElementStyle(currentStyle.copyWith(color: color));
  }

  /// 선택된 요소의 굵기(Bold) 속성을 토글하는 메소드
  void toggleSelectedElementBold() {
    if (_selectedElementIndex == null) return;
    final currentStyle =
        _template.elements[_selectedElementIndex!].styles[ComponentState.live]!;
    final newWeight = currentStyle.fontWeight == FontWeight.bold
        ? FontWeight.normal
        : FontWeight.bold;
    updateSelectedElementStyle(currentStyle.copyWith(fontWeight: newWeight));
  }
}
