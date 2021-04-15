import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/policy/etl_load_policy.dart';
import 'package:flutter/material.dart';

mixin MyInitPolicy implements InitPolicy, EtlLoadPolicy {
  @override
  initializeDiagramEditor() async {
    canvasWriter.state.setCanvasColor(Colors.white);
  }
}
