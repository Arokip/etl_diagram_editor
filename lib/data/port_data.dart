import 'package:flutter/material.dart';

enum PortState { hidden, shown, selected, highlighted }

class PortData {
  final String binding;
  final String type;
  final Color color;
  final Size size;
  final Alignment alignmentOnComponent;

  PortState portState = PortState.shown;

  PortData({
    this.binding,
    this.type,
    this.color,
    this.size,
    this.alignmentOnComponent,
  });

  setPortState(PortState portState) {
    this.portState = portState;
  }
}
