import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/dialog/edit_component_dialog.dart';
import 'package:etl_diagram_editor/policy/custom_policy.dart';
import 'package:etl_diagram_editor/widget/option_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin MyComponentWidgetsPolicy implements ComponentWidgetsPolicy, CustomPolicy {
  @override
  Widget showCustomWidgetWithComponentDataOver(
      BuildContext context, ComponentData componentData) {
    bool showOptions = (!isMultipleSelectionOn);

    return Visibility(
      visible: componentData.type == 'component' &&
          componentData.data.isHighlightVisible,
      child: Stack(
        children: [
          if (showOptions) componentTopOptions(componentData, context),
          highlight(
              componentData, isMultipleSelectionOn ? Colors.cyan : Colors.red),
        ],
      ),
    );
  }

  Widget componentTopOptions(ComponentData componentData, context) {
    Offset componentPosition =
        canvasReader.state.toCanvasCoordinates(componentData.position);
    return Positioned(
      left: componentPosition.dx - 24,
      top: componentPosition.dy - 48,
      child: Row(
        children: [
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.delete_forever,
            tooltip: 'delete',
            size: 40,
            onPressed: () {
              canvasWriter.model.removeComponentWithChildren(componentData.id);
              selectedComponentId = null;
            },
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.copy,
            tooltip: 'duplicate',
            size: 40,
            onPressed: () {
              String newId = duplicate(componentData);
              selectedComponentId = newId;
              hideComponentHighlight(componentData.id);
              highlightComponent(newId);
            },
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.edit,
            tooltip: 'edit',
            size: 40,
            onPressed: () => showEditComponentDialog(context, componentData),
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget highlight(ComponentData componentData, Color color) {
    return Positioned(
      left: canvasReader.state
          .toCanvasCoordinates(componentData.position - Offset(2, 2))
          .dx,
      top: canvasReader.state
          .toCanvasCoordinates(componentData.position - Offset(2, 2))
          .dy,
      child: CustomPaint(
        painter: ComponentHighlightPainter(
          width: (componentData.size.width + 4) * canvasReader.state.scale,
          height: (componentData.size.height + 4) * canvasReader.state.scale,
          color: color,
        ),
      ),
    );
  }
}
