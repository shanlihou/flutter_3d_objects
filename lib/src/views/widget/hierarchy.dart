import 'package:flutter/material.dart';
import '../../object.dart' as RenderObject;

class HierarchyController {
  ValueChanged<void>? rebuild;

  void doRebuild() {
    rebuild?.call(null);
  }
}

final class HierarchyWidget extends StatefulWidget {
  final RenderObject.Object root;
  final ValueChanged<RenderObject.Object> onSelected;
  final HierarchyController controller;
  const HierarchyWidget(
      {super.key,
      required this.root,
      required this.onSelected,
      required this.controller});

  @override
  State<HierarchyWidget> createState() => _HierarchyWidgetState();
}

class ObjectContext {
  final RenderObject.Object object;
  final int depth;
  ObjectContext(this.object, this.depth);
}

final class _HierarchyWidgetState extends State<HierarchyWidget> {
  final List<ObjectContext> _objects = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _objects.clear();
    _buildObjects(widget.root, 0);
    widget.controller.rebuild = (value) {
      _objects.clear();
      _buildObjects(widget.root, 0);
      setState(() {});
    };
  }

  void _buildObjects(RenderObject.Object object, int depth) {
    _objects.add(ObjectContext(object, depth));
    for (var child in object.children) {
      _buildObjects(child, depth + 1);
    }
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
      child: ListView.builder(
        itemCount: _objects.length,
        itemBuilder: (context, index) {
          var obj = _objects[index];
          String intent = '  ' * obj.depth;
          String name = obj.object.name ?? 'null';
          if (name.isEmpty) {
            name = 'empty';
          }
          return GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedIndex == index) {
                  _selectedIndex = -1;
                } else {
                  _selectedIndex = index;
                  widget.onSelected(obj.object);
                }
              });
            },
            child: Container(
              color: _selectedIndex == index ? Colors.grey : Colors.transparent,
              child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  '$intent[$name]'),
            ),
          );
        },
      ),
    );
  }
}
