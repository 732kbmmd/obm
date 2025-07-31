// lib/data/models/assembly_item.dart

import 'package:flutter/material.dart';

// 오버뷰에 올라갈 아이템의 종류
enum AssemblyItemType { background, fanArt, title, body }

/// 오버뷰 캔버스에 놓일 하나의 아이템
class AssemblyItem {
  final AssemblyItemType type; // 아이템 종류
  Offset position; // 캔버스에서의 위치
  Size size; // 아이템의 크기
  dynamic data; // 실제 데이터 (BodyTemplate, 이미지 경로 등)

  AssemblyItem({
    required this.type,
    this.position = Offset.zero,
    this.size = const Size(100, 50),
    this.data,
  });
}
