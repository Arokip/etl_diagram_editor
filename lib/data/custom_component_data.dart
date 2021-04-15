import 'package:etl_diagram_editor/data/port_data.dart';
import 'package:flutter/material.dart';

class MyComponentData {
  Color color;

  String label;
  String description;
  String templateId;

  List<PortData> ports = [];

  bool isHighlightVisible = false;

  MyComponentData({
    this.color = Colors.white,
    this.label = '',
    this.description,
    this.templateId,
    this.ports,
  }) : assert(ports != null);

  MyComponentData.copy(MyComponentData customData)
      : this(
          color: customData.color,
          label: customData.label,
          description: customData.description,
          templateId: customData.templateId,
          ports: List.from(
              customData.ports.map((portData) => PortData.copy(portData))),
        );
}
