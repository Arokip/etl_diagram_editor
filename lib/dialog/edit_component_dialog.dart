import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_component_data.dart';
import 'package:etl_diagram_editor/dialog/pick_color_dialog.dart';
import 'package:flutter/material.dart';

void showEditComponentDialog(
  BuildContext context,
  ComponentData componentData, [
  List<ComponentData> componentPorts,
  Function(String) updateLinks,
]) {
  MyComponentData customData = componentData.data;

  Color color = customData.color;

  final labelController = TextEditingController(text: customData.label ?? '');
  final descriptionController =
      TextEditingController(text: customData.description ?? '');

  showDialog(
    barrierDismissible: false,
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 600),
              Text('Edit component', style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Text('Component color:'),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      var pickedColor = showPickColorDialog(
                          context, color, 'Pick a component color');
                      color = await pickedColor;
                      setState(() {});
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          scrollable: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('DISCARD'),
            ),
            TextButton(
              onPressed: () {
                customData.label = labelController.text;
                customData.description = descriptionController.text;

                double width;
                double height = 60;
                double pixelsPerLetter = 6.0;
                double baseWidth = 40;

                if (customData.description == null) {
                  width = baseWidth + customData.label.length * pixelsPerLetter;
                } else {
                  var len =
                      customData.description.length > customData.label.length
                          ? customData.description.length
                          : customData.label.length;
                  width = baseWidth + len * pixelsPerLetter;
                }

                componentData.size = Size(width, height);

                componentPorts.forEach((port) {
                  port.setPosition(componentData.position +
                      componentData
                          .getPointOnComponent(port.data.alignmentOnComponent) -
                      port.data.size.center(Offset.zero));
                  updateLinks(port.id);
                });

                customData.color = color;
                componentData.updateComponent();
                Navigator.of(context).pop();
              },
              child: Text('SAVE'),
            )
          ],
        );
      });
    },
  );
}
