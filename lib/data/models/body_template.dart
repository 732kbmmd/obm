// lib/data/models/body_template.dart

import 'package:flutter/material.dart';

// '방송중', '휴방' 등 컴포넌트의 상태를 나타내는 Enum
enum ComponentState { live, off }

/// '본문 템플릿'을 구성하는 가장 작은 단위 (예: '날짜', '시간' 텍스트)
class BodyElement {
  String placeholder;
  Offset localPosition;
  Alignment alignment;

  // 상태별로 다른 텍스트 스타일을 저장
  Map<ComponentState, TextStyle> styles = {};
  // 상태별로 다른 배경 이미지를 저장
  Map<ComponentState, String?> backgroundImages = {};

  BodyElement({
    required this.placeholder,
    this.localPosition = Offset.zero,
    this.alignment = Alignment.center,
  }) {
    // 기본 스타일 설정
    styles = {
      ComponentState.live: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      ComponentState.off: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        decoration: TextDecoration.lineThrough,
      ),
    };
    backgroundImages = {ComponentState.live: null, ComponentState.off: null};
  }

  // 객체 복사를 위한 clone 메소드
  BodyElement clone() {
    return BodyElement(
        placeholder: placeholder,
        localPosition: localPosition,
        alignment: alignment,
      )
      ..styles = Map.from(styles)
      ..backgroundImages = Map.from(backgroundImages);
  }
}

/// 여러 개의 BodyElement와 배경 이미지로 구성된 하나의 템플릿
class BodyTemplate {
  // 템플릿 자체의 배경 이미지 위치
  Offset backgroundPosition = Offset.zero;
  // 템플릿이 포함하는 모든 요소들
  List<BodyElement> elements;
  // 템플릿 자체의 배경 이미지
  Map<ComponentState, String?> backgroundImages = {
    ComponentState.live: null,
    ComponentState.off: null,
  };

  BodyTemplate({List<BodyElement>? initialElements})
    : elements =
          initialElements ??
          [
            BodyElement(placeholder: '날짜', localPosition: const Offset(10, 10)),
            BodyElement(placeholder: '요일', localPosition: const Offset(10, 40)),
            BodyElement(placeholder: '시간', localPosition: const Offset(10, 70)),
            BodyElement(
              placeholder: '활동',
              localPosition: const Offset(10, 100),
            ),
          ];

  // 템플릿 전체를 복사하는 clone 메소드
  BodyTemplate clone() {
    return BodyTemplate()
      ..backgroundPosition = backgroundPosition
      ..elements = elements.map((e) => e.clone()).toList()
      ..backgroundImages = Map.from(backgroundImages);
  }
}
