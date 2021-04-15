import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/widget/etl_component.dart';
import 'package:etl_diagram_editor/widget/port_component.dart';
import 'package:flutter/material.dart';

mixin MyComponentDesignPolicy implements ComponentDesignPolicy {
  @override
  Widget showComponentBody(ComponentData componentData) {
    switch (componentData.type) {
      case 'component':
        return EtlComponent(componentData: componentData);
        break;
      case 'port':
        return PortComponent(componentData: componentData);
        break;
      default:
        return null;
        break;
    }
  }
}
