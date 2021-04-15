import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/policy/custom_policy.dart';

mixin MyCanvasPolicy implements CanvasPolicy, CustomPolicy {
  @override
  onCanvasTap() {
    multipleSelected = [];

    selectedComponentId = null;
    hideAllHighlights();
  }
}
