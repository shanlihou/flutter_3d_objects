import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/utils.dart';
import '../../scene.dart';

mixin EventMixin {
  late Offset _lastFocalPoint;
  // double? _lastZoom;

  void handleScaleStart(Offset position) {
    _lastFocalPoint = position;
    // _lastZoom = null;
  }

  void handleScaleUpdate(Offset position, Scene scene) {
    scene.camera.trackBall(toVector2(_lastFocalPoint), toVector2(position), 30);
    _lastFocalPoint = position;
    // if (widget.zoom) {
    //   if (_lastZoom == null) {
    //     _lastZoom = scene.camera.zoom;
    //   } else {
    //     scene.camera.zoom = _lastZoom! * details.scale;
    //   }
    //}
  }

  void handlerPointerScroll(PointerScrollEvent event, Scene scene) {
    scene.camera.goVertical(event.scrollDelta.dy / 100);
  }

  void handleCameraKeyEvent(KeyEvent event, Scene scene) {
    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      scene.camera.goHorizontal(1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
      scene.camera.goHorizontal(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      scene.camera.go(1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      scene.camera.go(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyQ) {
      scene.camera.rotateZAsix(1);
    } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
      scene.camera.rotateZAsix(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      scene.camera.goVertical(1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      scene.camera.goVertical(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      scene.camera.goHorizontal(1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      scene.camera.goHorizontal(-1);
    }
  }
}
