import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_link_data.dart';
import 'package:etl_diagram_editor/policy/custom_policy.dart';
import 'package:flutter/material.dart';

mixin MyComponentPolicy implements ComponentPolicy, CustomPolicy {
  @override
  onComponentTap(String componentId) {
    if (isMultipleSelectionOn) {
      if (multipleSelected.contains(componentId)) {
        removeComponentFromMultipleSelection(componentId);
        hideComponentHighlight(componentId);
      } else {
        if (canvasReader.model.getComponent(componentId).type == 'component') {
          addComponentToMultipleSelection(componentId);
          highlightComponent(componentId);
        }
      }
    } else {
      hideAllHighlights();
      ComponentData component = canvasReader.model.getComponent(componentId);
      if (component.type == 'component') {
        selectedComponentId = componentId;
        highlightComponent(componentId);
      } else if (component.type == 'port') {
        if (selectedComponentId != null &&
            canvasReader.model.getComponent(selectedComponentId).type ==
                'port') {
          bool connected = connectComponents(selectedComponentId, componentId);
          if (connected) {
            selectedComponentId = null;
          } else {
            selectedComponentId = componentId;
            highlightComponent(componentId);
            highlightPossiblePorts(componentId);
          }
        } else {
          selectedComponentId = componentId;
          highlightComponent(componentId);
          highlightPossiblePorts(componentId);
        }
      }
    }
  }

  Offset lastFocalPoint;

  @override
  onComponentScaleStart(componentId, details) {
    lastFocalPoint = details.localFocalPoint;

    hideLinkOption();
    if (isMultipleSelectionOn) {
      if (canvasReader.model.getComponent(componentId).type == 'component') {
        addComponentToMultipleSelection(componentId);
        highlightComponent(componentId);
      }
    }
  }

  @override
  onComponentScaleUpdate(componentId, details) {
    Offset positionDelta = details.localFocalPoint - lastFocalPoint;

    if (isMultipleSelectionOn) {
      multipleSelected.forEach((compId) {
        var cmp = canvasReader.model.getComponent(compId);

        canvasWriter.model.moveComponentWithChildren(compId, positionDelta);

        cmp.connections.forEach((connection) {
          if (connection is ConnectionOut &&
              multipleSelected.contains(connection.otherComponentId)) {
            canvasWriter.model.moveAllLinkMiddlePoints(
                connection.connectionId, positionDelta);
          }
        });
      });
    } else {
      var component = canvasReader.model.getComponent(componentId);
      if (component.type == 'component') {
        canvasWriter.model
            .moveComponentWithChildren(componentId, positionDelta);
      } else if (component.type == 'port') {
        canvasWriter.model
            .moveComponentWithChildren(component.parentId, positionDelta);
      }
    }
    lastFocalPoint = details.localFocalPoint;
  }

  bool connectComponents(String sourcePortId, String targetPortId) {
    if (sourcePortId == null) {
      return false;
    }
    if (sourcePortId == targetPortId) {
      return false;
    }

    if (canvasReader.model
        .getComponent(sourcePortId)
        .connections
        .any((connection) => (connection.otherComponentId == targetPortId))) {
      return false;
    }

    if (!canConnectThesePorts(sourcePortId, targetPortId)) {
      return false;
    }

    canvasWriter.model.connectTwoComponents(
      sourceComponentId: sourcePortId,
      targetComponentId: targetPortId,
      linkStyle: LinkStyle(
        arrowType: ArrowType.pointedArrow,
        lineWidth: 1.5,
      ),
      data: MyLinkData(),
    );

    return true;
  }
}
