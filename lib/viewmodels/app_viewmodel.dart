// lib/viewmodels/app_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:obm/data/models/body_template.dart'; // 데이터 모델 import
import 'package:obm/data/models/assembly_item.dart';

// 편집 대상의 타입을 정의 (나중에 타이틀 등 추가 확장 가능)
enum EditingTarget { none, body, title }

// 템플릿 방향 타입을 정의하는 enum 추가
enum TemplateType { vertical, horizontal }

class AppViewModel with ChangeNotifier {
  // --- 상태 변수들 ---

  /// 현재 편집 모드인지 여부 (화면 분할의 기준)
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  /// 현재 무엇을 편집하고 있는지 (본문, 타이틀 등)
  EditingTarget _editingTarget = EditingTarget.none;
  EditingTarget get editingTarget => _editingTarget;

  /// 오버뷰에 표시될 모든 아이템들의 목록
  List<AssemblyItem> _overviewItems = [];
  List<AssemblyItem> get overviewItems => _overviewItems;

  /// 아트보드의 크기를 저장할 변수 추가
  Size _artboardSize = const Size(1280, 720);
  Size get artboardSize => _artboardSize;

  /// 현재 선택된 아이템의 인덱스를 저장할 변수
  int? _selectedItemIndex;
  int? get selectedItemIndex => _selectedItemIndex;

  // TODO: 오버뷰에 표시될 아이템들의 목록 (AssemblyItem 리스트) 추가 예정
  // TODO: 현재 편집 중인 아이템의 실제 데이터 (BodyTemplate 등) 저장할 변수 추가 예정

  /// 사용자의 선택에 따라 새로운 기본 템플릿을 생성하는 메소드
  void createNewTemplate(TemplateType type) {
    _overviewItems = [];

    // 가로 템플릿 (1280x720) 기준으로 레이아웃 설정
    _artboardSize = const Size(1280, 720);
    print('$type 템플릿 생성 (1280x720)');

    // 0. 배경 (아트보드 자체)
    _overviewItems.add(
      AssemblyItem(
        type: AssemblyItemType.background,
        position: Offset.zero,
        size: _artboardSize,
      ),
    );

    // 1. 타이틀
    _overviewItems.add(
      AssemblyItem(
        type: AssemblyItemType.title,
        position: const Offset(40, 40),
        size: const Size(600, 100),
      ),
    );

    // 2. 본문 (7개)
    for (int i = 0; i < 7; i++) {
      _overviewItems.add(
        AssemblyItem(
          type: AssemblyItemType.body,
          position: Offset(40, 160.0 + (i * 75)), // y 위치를 75씩 증가
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

    // 3. 팬아트 프레임
    _overviewItems.add(
      AssemblyItem(
        type: AssemblyItemType.fanArt,
        position: const Offset(680, 40),
        size: const Size(560, 640),
      ),
    );

    notifyListeners();
  }
  // --- 상태 변경 메소드들 ---

  /// 편집 모드를 시작하는 메소드
  void startEditing(EditingTarget target, dynamic itemToEdit) {
    _isEditing = true;
    _editingTarget = target;
    // TODO: itemToEdit을 상태에 저장하는 로직
    print('편집 시작: $target');
    notifyListeners(); // UI에 변경사항 알림
  }

  /// 편집 모드를 종료하는 메소드
  void stopEditing() {
    _isEditing = false;
    _editingTarget = EditingTarget.none;
    // TODO: 편집 중인 아이템 정보 초기화
    print('편집 종료');
    notifyListeners(); // UI에 변경사항 알림
  }

  // TODO: 세부 편집 로직들 (글자 크기 변경 등)을 이곳으로 옮겨올 예정
}
