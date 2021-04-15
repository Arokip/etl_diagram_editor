import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_component_data.dart';
import 'package:etl_diagram_editor/data/port_data.dart';
import 'package:flutter/material.dart';

mixin CustomPolicy implements PolicySet {
  List<String> bodies = [
    'component',
    'port',
  ];

  List<ComponentData> menuComponents = [];

  String selectedComponentId;

  bool isMultipleSelectionOn = false;
  List<String> multipleSelected = [];

  Offset deleteLinkPos = Offset.zero;

  String selectedLinkId;
  Offset tapLinkPosition = Offset.zero;

  hideAllHighlights() {
    canvasWriter.model.hideAllLinkJoints();
    hideLinkOption();
    canvasReader.model.getAllComponents().values.forEach((component) {
      if (component.type == 'component') {
        (component.data as MyComponentData).isHighlightVisible = false;
        canvasWriter.model.updateComponent(component.id);
      } else if (component.type == 'port') {
        (component.data as PortData).portState = PortState.shown;
        canvasWriter.model.updateComponent(component.id);
      }
    });
  }

  highlightComponent(String componentId) {
    ComponentData component = canvasReader.model.getComponent(componentId);
    if (component.type == 'component') {
      (component.data as MyComponentData).isHighlightVisible = true;
    } else if (component.type == 'port') {
      (component.data as PortData).portState = PortState.selected;
    }
    canvasWriter.model.updateComponent(component.id);
  }

  highlightPossiblePorts(String portId) {
    // ComponentData portComponent = canvasReader.model.getComponent(portId);
    var components = canvasReader.model.canvasModel.components.values;

    components.forEach((port) {
      if (port.type == 'port') {
        if (canConnectThesePorts(portId, port.id)) {
          (port.data as PortData).portState = PortState.highlighted;
        }
      }
    });
  }

  hideComponentHighlight(String componentId) {
    ComponentData component = canvasReader.model.getComponent(componentId);
    if (component.type == 'component') {
      (component.data as MyComponentData).isHighlightVisible = false;
    } else if (component.type == 'port') {
      (component.data as PortData).portState = PortState.shown;
    }
    canvasWriter.model.updateComponent(component.id);
  }

  turnOnMultipleSelection() {
    isMultipleSelectionOn = true;
    ComponentData component =
        canvasReader.model.getComponent(selectedComponentId);

    if (selectedComponentId != null) {
      if (component.type == 'component') {
        addComponentToMultipleSelection(selectedComponentId);
      } else if (component.type == 'port') {
        (component.data as PortData).portState = PortState.shown;
      }
      selectedComponentId = null;
    }
  }

  turnOffMultipleSelection() {
    isMultipleSelectionOn = false;
    multipleSelected = [];
    hideAllHighlights();
  }

  addComponentToMultipleSelection(String componentId) {
    if (!multipleSelected.contains(componentId)) {
      multipleSelected.add(componentId);
    }
  }

  removeComponentFromMultipleSelection(String componentId) {
    multipleSelected.remove(componentId);
  }

  // TODO: duplicate check
  String duplicate(ComponentData componentData) {
    var newComponentData = ComponentData(
      type: componentData.type,
      size: componentData.size,
      minSize: componentData.minSize,
      data: MyComponentData.copy(componentData.data),
      position: componentData.position + Offset(32, 32),
    );

    addComponentDataWithPorts(newComponentData);
    return newComponentData.id;
  }

  showLinkOption(String linkId, Offset position) {
    selectedLinkId = linkId;
    tapLinkPosition = position;
  }

  hideLinkOption() {
    selectedLinkId = null;
  }

  addComponentDataWithPorts(ComponentData componentData) {
    canvasWriter.model.addComponent(componentData);

    componentData.data.ports.forEach((PortData port) {
      var newPort = ComponentData(
        size: port.size,
        type: 'port',
        data: port,
        position: componentData.position +
            componentData.getPointOnComponent(port.alignmentOnComponent) -
            port.size.center(Offset.zero),
      );
      canvasWriter.model.addComponent(newPort);
      canvasWriter.model.setComponentParent(newPort.id, componentData.id);
    });
    canvasWriter.model.moveComponentToTheFrontWithChildren(componentData.id);
  }

  bool canConnectThesePorts(String portId1, String portId2) {
    if (portId1 == null || portId2 == null) {
      return false;
    }
    if (portId1 == portId2) {
      return false;
    }
    var port1 = canvasReader.model.getComponent(portId1);
    var port2 = canvasReader.model.getComponent(portId2);

    if (port1.data.type != port2.data.type) {
      return false;
    }

    if (port1.data.io == PortIO.input) {
      return false;
    }

    if (port1.data.io == port2.data.io) {
      return false;
    }

    if (port1.connections
        .any((connection) => (connection.otherComponentId == portId2))) {
      return false;
    }

    if (port1.parentId == port2.parentId) {
      return false;
    }

    return true;
  }
}

mixin CustomBehaviourPolicy implements PolicySet, CustomPolicy {
  removeAll() {
    canvasWriter.model.removeAllComponents();
  }

  resetView() {
    canvasWriter.state.resetCanvasView();
  }

  removeSelected() {
    multipleSelected.forEach((compId) {
      canvasWriter.model.removeComponentWithChildren(compId);
    });
    multipleSelected = [];
  }

  duplicateSelected() {
    List<String> duplicated = [];
    multipleSelected.forEach((componentId) {
      String newId = duplicate(canvasReader.model.getComponent(componentId));
      duplicated.add(newId);
    });
    hideAllHighlights();
    multipleSelected = [];
    duplicated.forEach((componentId) {
      addComponentToMultipleSelection(componentId);
      highlightComponent(componentId);
      canvasWriter.model.moveComponentToTheFrontWithChildren(componentId);
    });
  }

  selectAll() {
    var components = canvasReader.model.canvasModel.components.values;

    components.forEach((component) {
      if (component.type == 'component') {
        addComponentToMultipleSelection(component.id);
        highlightComponent(component.id);
      }
    });
  }
}
