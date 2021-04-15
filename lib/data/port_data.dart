import 'package:flutter/material.dart';

enum PortState { hidden, shown, selected, highlighted }
enum PortIO { input, output }

class PortData {
  final String binding;
  final String type;
  final PortIO io;
  final Color color;
  final Size size;
  final Alignment alignmentOnComponent;

  PortState portState = PortState.shown;

  PortData({
    this.binding,
    this.type,
    this.io,
    this.color = Colors.white,
    this.size = const Size(20, 20),
    this.alignmentOnComponent = Alignment.center,
  });

  PortData.copy(PortData portData)
      : this(
          binding: portData.binding,
          type: portData.type,
          io: portData.io,
          color: portData.color,
          size: portData.size,
          alignmentOnComponent: portData.alignmentOnComponent,
        );
}
