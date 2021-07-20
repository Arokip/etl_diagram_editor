import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_component_data.dart';
import 'package:etl_diagram_editor/policy/my_policy_set.dart';
import 'package:flutter/material.dart';

class DraggableMenu extends StatelessWidget {
  final MyPolicySet myPolicySet;

  const DraggableMenu({
    Key key,
    this.myPolicySet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ...myPolicySet.menuComponents.map(
          (ComponentData componentData) {
            return Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Tooltip(
                    message: componentData.type,
                    child: DraggableComponent(
                      myPolicySet: myPolicySet,
                      componentData: componentData,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ],
    );
  }

  ComponentData getComponentData(String componentType) {
    switch (componentType) {
      default:
        return ComponentData(
          size: Size(120, 72),
          minSize: Size(80, 64),
          data: MyComponentData(
            color: Colors.white,
          ),
          type: componentType,
        );
        break;
    }
  }
}

class DraggableComponent extends StatelessWidget {
  final MyPolicySet myPolicySet;
  final ComponentData componentData;

  const DraggableComponent({
    Key key,
    this.myPolicySet,
    this.componentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentData>(
      affinity: Axis.horizontal,
      ignoringFeedbackSemantics: true,
      data: componentData,
      childWhenDragging: myPolicySet.showComponentBody(componentData),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: componentData.size.width,
          height: componentData.size.height,
          child: myPolicySet.showComponentBody(componentData),
        ),
      ),
      child: myPolicySet.showComponentBody(componentData),
    );
  }
}
