import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as VectorMath;
import '../../object.dart' as RenderObject;

class InspectorController {
  ValueChanged<RenderObject.Object>? onSelected;
  void setOnSelected(RenderObject.Object value) {
    onSelected?.call(value);
  }

  void dispose() {
    onSelected = null;
  }
}

class InspectorEvent {
  String name;
  VectorMath.Vector3 position;
  VectorMath.Vector3 rotation;

  InspectorEvent(this.name, this.position, this.rotation);
}

class InspectorWidget extends StatefulWidget {
  final RenderObject.Object object;
  final InspectorController controller;
  final ValueChanged<InspectorEvent>? onEvent;
  const InspectorWidget(
      {super.key,
      required this.object,
      required this.controller,
      this.onEvent});

  @override
  State<InspectorWidget> createState() => _InspectorWidgetState();
}

class _InspectorWidgetState extends State<InspectorWidget> {
  RenderObject.Object? _selectedObject;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _selectedObject = widget.object;
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
    }

    _reset();

    widget.controller.onSelected = (obj) {
      setState(() {
        _selectedObject = obj;
        _reset();
      });
    };
  }

  void _reset() {
    _controllers[0].text = _selectedObject!.position.x.toString();
    _controllers[1].text = _selectedObject!.position.y.toString();
    _controllers[2].text = _selectedObject!.position.z.toString();
    _controllers[3].text = _selectedObject!.rotation.x.toString();
    _controllers[4].text = _selectedObject!.rotation.y.toString();
    _controllers[5].text = _selectedObject!.rotation.z.toString();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildVector3(String label, List<int> indices) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text('$label:'),
          for (int index in indices)
            Container(
              padding: const EdgeInsets.all(2),
              width: 60,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _controllers[index],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      width: 200,
      height: 900,
      child: Column(
        children: [
          _buildVector3('pos', [0, 1, 2]),
          _buildVector3('rot', [3, 4, 5]),
          ElevatedButton(
            onPressed: () {
              widget.onEvent?.call(InspectorEvent(
                  _selectedObject!.name!,
                  VectorMath.Vector3(
                      double.parse(_controllers[0].text),
                      double.parse(_controllers[1].text),
                      double.parse(_controllers[2].text)),
                  VectorMath.Vector3(
                      double.parse(_controllers[3].text),
                      double.parse(_controllers[4].text),
                      double.parse(_controllers[5].text))));
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
