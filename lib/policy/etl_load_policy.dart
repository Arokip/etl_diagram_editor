import 'dart:collection';

import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/data/custom_component_data.dart';
import 'package:etl_diagram_editor/data/port_data.dart';
import 'package:etl_diagram_editor/etl_json/etl_components_list.dart';
import 'package:etl_diagram_editor/etl_json/etl_http.dart';
import 'package:etl_diagram_editor/etl_json/etl_pipeline_graph.dart';
import 'package:etl_diagram_editor/policy/custom_policy.dart';
import 'package:etl_diagram_editor/widget/etl_component.dart';
import 'package:flutter/material.dart';

mixin EtlLoadPolicy implements PolicySet, CustomPolicy {
  String pipelineLabel;

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
          ports.add(item);
        }
      });

      var componentSize = Size(40 + template.label.length * 6.0, 60);

      menuComponents.add(generateEtlComponentData(
        size: componentSize,
        ports: ports,
        template: template,
      ));
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

      var componentSize = Size(40 + finalTemplate.label.length * 6.0, 60);

      menuComponents.add(generateEtlComponentData(
        size: componentSize,
        ports: ports,
        template: finalTemplate,
      ));
    });
    return true;
  }

  Future<bool> loadPipeline(String pipelineUrl) async {
    if (!pipelineUrl.contains('demo.etl.linkedpipes.com/resources')) {
      return false;
    }
    EtlHttp etlHttp = EtlHttp();
    String pipeline = await etlHttp
        .getJson(pipelineUrl.substring(pipelineUrl.indexOf('resources/')));

    if (pipeline == null) {
      return false;
    }

    var etlDiagramJsonObject = EtlPipelineJsonObject(
      etlJson: pipeline,
      pipelineUrlId: pipelineUrl,
    );

    var etlDiagramGraph = etlDiagramJsonObject.getEtlPipelineGraph();

    etlDiagramGraph.graphItems.forEach((item) {
      if (item is EtlPipelineItem) {
        this.pipelineLabel = item.label;
      }
      if (item is EtlComponentItem) {
        var componentData = duplicate(
            menuComponents
                .where((cd) => cd.data.templateId == item.template)
                .single,
            newId: item.id);

        componentData.setPosition(Offset(item.x, item.y));

        (componentData.data as MyComponentData).color = item.color == null
            ? (componentData.data as MyComponentData).color
            : colorFromString(item.color);
        (componentData.data as MyComponentData).description = item.description;

        double width;
        double height = 60;
        double pixelsPerLetter = 6.0;
        double baseWidth = 40;

        if (item.description == null) {
          width = baseWidth + item.label.length * pixelsPerLetter;
        } else {
          var len = item.description.length > item.label.length
              ? item.description.length
              : item.label.length;
          width = baseWidth + len * pixelsPerLetter;
        }

        componentData.size = Size(width, height);

        addComponentDataWithPorts(componentData);
      }
    });

    etlDiagramGraph.graphItems.forEach((EtlPipelineGraphItem item) {});

    etlDiagramGraph.graphItems.forEach((item) {
      if (item is EtlConnectionItem) {
        var sourceComponent =
            canvasReader.model.getComponent(item.sourceComponent);
        var targetComponent =
            canvasReader.model.getComponent(item.targetComponent);

        var sourcePortId =
            sourceComponent.childrenIds.singleWhere((childPortId) {
          return (canvasReader.model.getComponent(childPortId).data as PortData)
                  .binding ==
              item.sourceBinding;
        });

        var targetPortId =
            targetComponent.childrenIds.singleWhere((childPortId) {
          return (canvasReader.model.getComponent(childPortId).data as PortData)
                  .binding ==
              item.targetBinding;
        });

        String linkId = canvasWriter.model.connectTwoComponents(
          sourceComponentId: sourcePortId,
          targetComponentId: targetPortId,
          linkStyle: LinkStyle(
            arrowType: ArrowType.pointedArrow,
            lineWidth: 1.5,
          ),
        );

        if (item.vertices.isNotEmpty) {
          var link = canvasReader.model.getLink(linkId);
          var vertexList =
              etlDiagramGraph.graphItems.whereType<EtlVertexItem>().toList();
          SplayTreeMap<int, Offset> vertexMap = SplayTreeMap<int, Offset>();
          item.vertices.forEach((String vertexId) {
            EtlVertexItem vertexItem = vertexList.singleWhere(
                (element) => element.id == vertexId,
                orElse: () => null);
            if (vertexItem != null) {
              // sometimes there are some random vertices in json that doesn't exists.
              vertexMap[vertexItem.order] = Offset(vertexItem.x, vertexItem.y);
            }
          });
          for (final int index in vertexMap.keys) {
            link.insertMiddlePoint(vertexMap[index], index);
          }
        }
        canvasWriter.model.updateLink(linkId);
      }
    });

    return true;
  }
}
