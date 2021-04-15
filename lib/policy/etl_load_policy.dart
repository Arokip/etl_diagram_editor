import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/etl_json/etl_components_list.dart';
import 'package:etl_diagram_editor/etl_json/etl_http.dart';
import 'package:etl_diagram_editor/policy/custom_policy.dart';
import 'package:etl_diagram_editor/widget/etl_component.dart';
import 'package:flutter/material.dart';

mixin EtlLoadPolicy implements PolicySet, CustomPolicy {
  Future<bool> loadComponentSet() async {
    EtlHttp etlHttp = EtlHttp();

    String components = await etlHttp.getJson('resources/components');

    var etlComponentsJsonObject = EtlComponentsJsonObject(
      etlJson: components,
    );
    var listOfComponentGraph = etlComponentsJsonObject.graphList;

    bool isJarTemplate(EtlComponentsGraph graph) {
      return graph.graphItems.whereType<EtlJarTemplateItem>().isNotEmpty;
    }

    var jarTemplateList =
        listOfComponentGraph.where((graph) => isJarTemplate(graph));
    var templateList =
        listOfComponentGraph.where((graph) => !isJarTemplate(graph));

    jarTemplateList.forEach((graph) {
      EtlJarTemplateItem template;
      List<EtlPortItem> ports = [];
      graph.graphItems.forEach((item) {
        if (item is EtlJarTemplateItem) {
          template = item;
        } else if (item is EtlPortItem) {
          // TODO: rules
          // model.portRules.addRule(
          //   item.portType + EtlPortItemType.output.toString(),
          //   item.portType + EtlPortItemType.input.toString(),
          // );
          ports.add(item);
        }
      });

      // model.addNewComponentBody(
      //   template.id,
      //   ComponentBody(
      //     menuComponentBody: MenuComponentBodyRect(template: template),
      //     componentBody: ComponentBodyRect(template: template),
      //     fromJsonCustomData: (json) => RectCustomComponentData.fromJson(json),
      //   ),
      // );

      var componentSize = Size(40 + template.label.length * 6.0, 60);

      menuComponents.add(generateEtlComponentData(
        size: componentSize,
        ports: ports,
        template: template,
      ));

      // model.menuData.addComponentsToMenu([
      //   generateComponentRect(
      //     model: model,
      //     ports: ports,
      //     template: template,
      //     size: componentSize,
      //   ),
      // ]);
    });

    templateList.forEach((graph) {
      var futureJarTemplateGraph = graph;

      do {
        futureJarTemplateGraph =
            etlComponentsJsonObject.getComponentGraphFromTemplateId(
                (futureJarTemplateGraph.graphItems.single as EtlTemplateItem)
                    .template);
      } while (!isJarTemplate(futureJarTemplateGraph));

      EtlTemplateItem etlTemplateItem = graph.graphItems.single;

      EtlJarTemplateItem etlJarTemplateItem;
      List<EtlPortItem> ports = [];
      futureJarTemplateGraph.graphItems.forEach((item) {
        if (item is EtlJarTemplateItem) {
          etlJarTemplateItem = item;
        } else if (item is EtlPortItem) {
          ports.add(item);
        }
      });

      EtlJarTemplateItem finalTemplate = EtlJarTemplateItem(
        id: etlTemplateItem.id,
        color: etlJarTemplateItem.color,
        label: etlTemplateItem.label,
      );

      // model.addNewComponentBody(
      //   finalTemplate.id,
      //   ComponentBody(
      //     menuComponentBody: MenuComponentBodyRect(template: finalTemplate),
      //     componentBody: ComponentBodyRect(template: finalTemplate),
      //     fromJsonCustomData: (json) => RectCustomComponentData.fromJson(json),
      //   ),
      // );

      var componentSize = Size(40 + finalTemplate.label.length * 6.0, 60);

      menuComponents.add(generateEtlComponentData(
        size: componentSize,
        ports: ports,
        template: finalTemplate,
      ));

      // model.menuData.addComponentsToMenu([
      //   generateComponentRect(
      //     model: model,
      //     ports: ports,
      //     template: finalTemplate,
      //     size: componentSize,
      //   ),
      // ]);
    });
    return true;
  }
}
