import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

/// Convert Offset to Vector2
Vector2 toVector2(Offset value) {
  return Vector2(value.dx, value.dy);
}

int bitSet(int flags, int bit) {
  return flags | (1 << bit);
}

int bitClear(int flags, int bit) {
  return flags & ~(1 << bit);
}

bool bitTest(int flags, int bit) {
  return (flags & (1 << bit)) != 0;
}
