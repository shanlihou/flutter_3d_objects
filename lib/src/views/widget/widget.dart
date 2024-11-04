import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_objects/src/common/const.dart';
import 'package:flutter_3d_objects/src/common/utils.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../scene.dart';
import '../../object.dart' as RenderObject;
import '../mixin/event_mixin.dart';
import 'hierarchy.dart';
import 'inspector.dart';

typedef SceneCreatedCallback = void Function(Scene scene);

class CubeController {
  ValueChanged<(String, RenderObject.Object)>? onObjReset;
  ValueChanged<(String, Vector3)>? onObjPositionReset;
  // get root function return RenderObject.Object
  Function()? doGetScene;

  void resetObjByName(String name, RenderObject.Object obj) {
    onObjReset?.call((name, obj));
  }

  Scene? getScene() {
    return doGetScene?.call();
  }

  void resetObjPosition(String name, Vector3 position) {
    onObjPositionReset?.call((name, position));
  }

  void dispose() {
    onObjReset = null;
    onObjPositionReset = null;
  }
}

class Cube extends StatefulWidget {
  const Cube({
    super.key,
    this.interactive = true,
    this.zoom = true,
    this.onSceneCreated,
    this.onObjectCreated,
    this.controller,
  });

  final CubeController? controller;
  final bool interactive;
  final bool zoom;
  final SceneCreatedCallback? onSceneCreated;
  final ObjectCreatedCallback? onObjectCreated;

  @override
  _CubeState createState() => _CubeState();
}

enum ControlTarget { camera, object, light }

class _CubeState extends State<Cube> with EventMixin {
  int _flags = 0;
  late Scene scene;
  final FocusNode _focusNode = FocusNode();
  final InspectorController _inspectorController = InspectorController();
  final HierarchyController _hierarchyController = HierarchyController();

  @override
  void initState() {
    super.initState();
    scene = Scene(
      onUpdate: () => setState(() {}),
      onObjectCreated: widget.onObjectCreated,
    );
    // prevent setState() or markNeedsBuild called during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSceneCreated?.call(scene);
    });

    widget.controller?.onObjReset = (value) {
      scene.resetObjByName(value.$1, value.$2);
      _hierarchyController.doRebuild();
    };

    widget.controller?.onObjPositionReset = (value) {
      scene.resetObjPosition(value.$1, value.$2);
      _hierarchyController.doRebuild();
    };

    widget.controller?.doGetScene = () => scene;
  }

  Widget _buildTools() {
    return Row(children: [
      IconButton(
          onPressed: () {
            if (bitTest(_flags, WIDGET_FLAG_HIERARCHY)) {
              _flags = bitClear(_flags, WIDGET_FLAG_HIERARCHY);
            } else {
              _flags = bitSet(_flags, WIDGET_FLAG_HIERARCHY);
            }
            setState(() {});
          },
          icon: bitTest(_flags, WIDGET_FLAG_HIERARCHY)
              ? const Icon(Icons.arrow_drop_down)
              : const Icon(Icons.arrow_left)),
      IconButton(
          onPressed: () {
            if (bitTest(_flags, WIDGET_FLAG_INSPECTOR)) {
              _flags = bitClear(_flags, WIDGET_FLAG_INSPECTOR);
            } else {
              _flags = bitSet(_flags, WIDGET_FLAG_INSPECTOR);
            }
            setState(() {});
          },
          icon: bitTest(_flags, WIDGET_FLAG_INSPECTOR)
              ? const Icon(Icons.arrow_drop_down)
              : const Icon(Icons.arrow_right)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildTools(),
      Expanded(
        child: Stack(
          children: [
            Positioned.fill(
              child: Focus(
                autofocus: true,
                focusNode: _focusNode,
                onKeyEvent: (node, event) {
                  handleCameraKeyEvent(event, scene);
                  setState(() {});
                  return KeyEventResult.handled;
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    scene.camera.viewportWidth = constraints.maxWidth;
                    scene.camera.viewportHeight = constraints.maxHeight;
                    final customPaint = CustomPaint(
                      painter: _CubePainter(scene),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    );
                    return widget.interactive
                        ? GestureDetector(
                            onScaleStart: handleScaleStart,
                            onScaleUpdate: (details) {
                              handleScaleUpdate(details, scene);
                              setState(() {});
                            },
                            onTapDown: (_) => _focusNode.requestFocus(),
                            child: customPaint,
                          )
                        : customPaint;
                  },
                ),
              ),
            ),
            if (bitTest(_flags, WIDGET_FLAG_HIERARCHY))
              Positioned(
                left: 0,
                top: 0,
                child: HierarchyWidget(
                  controller: _hierarchyController,
                  root: scene.world,
                  onSelected: (obj) {
                    print('hierarchy selected: ${obj.name}, ${obj.position}');
                    _inspectorController.setOnSelected(obj);
                    if (obj.name == "coordinate") {
                      return;
                    }

                    var coordinate = scene.getObjectByName("coordinate");
                    if (coordinate != null) {
                      coordinate.position.setFrom(obj.position);
                      coordinate.updateTransform();
                    }
                  },
                ),
              ),
            if (bitTest(_flags, WIDGET_FLAG_INSPECTOR))
              Positioned(
                right: 0,
                top: 0,
                child: InspectorWidget(
                  object: scene.world,
                  controller: _inspectorController,
                  onEvent: (event) {
                    print('inspector event: $event');
                    var obj = scene.getObjectByName(event.name);
                    if (obj == null) {
                      return;
                    }

                    obj.position.setFrom(event.position);
                    obj.rotation.setFrom(event.rotation);
                    obj.updateTransform();
                  },
                ),
              ),
          ],
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _inspectorController.dispose();
    super.dispose();
  }
}

class _CubePainter extends CustomPainter {
  final Scene _scene;
  const _CubePainter(this._scene);

  @override
  void paint(Canvas canvas, Size size) {
    _scene.render(canvas, size);
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_CubePainter oldDelegate) {
    return true;
  }
}
