import 'package:etl_diagram_editor/data/port_data.dart';
import 'package:flutter/material.dart';

class MyComponentData {
  Color color;

  String label;
  String description;
  String note;

  List<PortData> ports = [];

  bool isHighlightVisible = false;

  MyComponentData({
    this.color = Colors.white,
    this.label = '',
    this.description,
    this.note,
    this.ports,
  }) : assert(ports != null);

  MyComponentData.copy(MyComponentData customData)
      : this(
          color: customData.color,
          label: customData.label,
          description: customData.description,
          note: customData.note,
          ports: List.from(
              customData.ports.map((portData) => PortData.copy(portData))),
        );
}
