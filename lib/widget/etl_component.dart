import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_component_data.dart';
import 'package:etl_diagram_editor/data/port_data.dart';
import 'package:etl_diagram_editor/etl_json/etl_components_list.dart';
import 'package:flutter/material.dart';

class EtlComponent extends StatelessWidget {
  final ComponentData componentData;

  const EtlComponent({
    Key key,
    this.componentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var customData = componentData.data as MyComponentData;

    return Container(
      decoration: BoxDecoration(
        color: customData.color,
        border: Border.all(
          width: 2.0,
          color: Colors.black,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              customData.label,
              maxLines: 4,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            if (customData.description != null && customData.description != '')
              Text(
                customData.description,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

ComponentData generateEtlComponentData({
  List<EtlPortItem> ports,
  EtlJarTemplateItem template,
  Offset position = Offset.zero,
  Size size = const Size(120, 80),
}) {
  List<PortData> portDataList = [];
  int inPortCount = ports
      .where((port) =>
          port.io == EtlPortItemType.inputConf ||
          port.io == EtlPortItemType.input)
      .length;
  int outPortCount =
      ports.where((port) => port.io == EtlPortItemType.output).length;
  int inPortIndex = 1;
  int outPortIndex = 1;

  ports.forEach((port) {
    bool isPortInput = port.io == EtlPortItemType.inputConf ||
        port.io == EtlPortItemType.input;
    Color portColor =
        Color('randomString${port.portType}'.hashCode | 0xFF000000);
    portDataList.add(
      PortData(
        binding: port.binding,
        color: portColor,
        io: isPortInput ? PortIO.input : PortIO.output,
        alignmentOnComponent: Alignment(
            (isPortInput) ? -1 : 1,
            (isPortInput)
                ? ((2 * inPortIndex++ - 1) / (inPortCount * 2)) * 2 - 1
                : ((2 * outPortIndex++ - 1) / (outPortCount * 2)) * 2 - 1),
        type: port.portType,
      ),
    );
  });

  return ComponentData(
    position: position,
    size: size,
    type: 'component',
    data: MyComponentData(
      color:
          Color(int.parse(template.color.substring(1), radix: 16) + 0xFF000000),
      label: template.label,
      ports: portDataList,
      templateId: template.id,
    ),
  );
}
