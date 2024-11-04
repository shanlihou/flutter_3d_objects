import 'package:flutter/material.dart';
import 'widget.dart';

final class EditorWidget extends StatefulWidget {
  const EditorWidget({super.key});

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

final class _EditorWidgetState extends State<EditorWidget> {
  @override
  Widget build(BuildContext context) {
    return const Cube();
  }
}
