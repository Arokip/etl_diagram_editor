import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_component_data.dart';
import 'package:etl_diagram_editor/dialog/pick_color_dialog.dart';
import 'package:flutter/material.dart';

void showEditComponentDialog(
    BuildContext context, ComponentData componentData) {
  MyComponentData customData = componentData.data;

  Color color = customData.color;

  final labelController = TextEditingController(text: customData.label ?? '');

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
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Label',
                ),
              ),
              SizedBox(height: 16),
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
