import 'dart:convert';

String jarTemplateType = 'http://linkedpipes.com/ontology/JarTemplate';
String templateType = 'http://linkedpipes.com/ontology/Template';
String itemTemplateType = 'http://linkedpipes.com/ontology/template';

String colorType = 'http://linkedpipes.com/ontology/color';
String labelType = 'http://www.w3.org/2004/02/skos/core#prefLabel';

String inputConfPortType =
    'http://linkedpipes.com/ontology/RuntimeConfiguration';
String inputPortType = 'http://linkedpipes.com/ontology/Input';
String outputPortType = 'http://linkedpipes.com/ontology/Output';

String portBindingType = 'http://linkedpipes.com/ontology/binding';
String portTypeSubType = 'http://linkedpipes.com/ontology/dataUnit';

class EtlComponentsJsonObject {
  final String etlJson;
  List<EtlComponentsGraph> graphList;

  EtlComponentsJsonObject({
    this.etlJson,
  }) {
    graphList = (jsonDecode(etlJson) as List)
        .map((graph) => EtlComponentsGraph.fromJson(graph))
        .toList();
  }

  EtlComponentsGraph getComponentGraphFromTemplateId(String templateId) {
    return graphList.firstWhere((graph) {
      if (graph.graphItems.whereType<EtlJarTemplateItem>().isNotEmpty) {
        if (graph.graphItems.whereType<EtlJarTemplateItem>().single.id ==
            templateId) {
          return true;
        }
      } else {
        if (graph.graphItems.whereType<EtlTemplateItem>().single.id ==
            templateId) {
          return true;
        }
      }
      return false;
    });
  }
}

class EtlComponentsGraph {
  final String id;
  final List<EtlComponentsGraphItem> graphItems;

  EtlComponentsGraph({
    this.id,
    this.graphItems,
  });

  factory EtlComponentsGraph.fromJson(Map<String, dynamic> json) {
    var graphItems = (json['@graph'] as List).map((graphItem) {
      var graphItemAsList = (graphItem['@type'] as List);
      if (graphItemAsList.contains(jarTemplateType)) {
        return EtlJarTemplateItem.fromJson(graphItem);
      } else if (graphItemAsList.contains(templateType)) {
        return EtlTemplateItem.fromJson(graphItem);
      } else if (graphItemAsList.contains(inputConfPortType)) {
        return EtlPortItem.fromJson(graphItem, EtlPortItemType.inputConf);
      } else if (graphItemAsList.contains(inputPortType)) {
        return EtlPortItem.fromJson(graphItem, EtlPortItemType.input);
      } else if (graphItemAsList.contains(outputPortType)) {
        return EtlPortItem.fromJson(graphItem, EtlPortItemType.output);
      }
      return null;
    }).toList();
    graphItems.removeWhere((value) => value == null);

    return EtlComponentsGraph(
      id: json['@id'],
      graphItems: graphItems,
    );
  }
}

abstract class EtlComponentsGraphItem {}

class EtlJarTemplateItem extends EtlComponentsGraphItem {
  final String id;
  final String color;
  final String label;

  EtlJarTemplateItem({
    this.id,
    this.color,
    this.label,
  });

  factory EtlJarTemplateItem.fromJson(Map<String, dynamic> json) {
    return EtlJarTemplateItem(
      id: json['@id'],
      color: (json[colorType] as List).first['@value'],
      label: (json[labelType] as List).first['@value'],
    );
  }
}

class EtlTemplateItem extends EtlComponentsGraphItem {
  final String id;
  final String label;
  final String template;

  EtlTemplateItem({
    this.id,
    this.label,
    this.template,
  });

  factory EtlTemplateItem.fromJson(Map<String, dynamic> json) {
    return EtlTemplateItem(
      id: json['@id'],
      label: (json[labelType] as List).first['@value'],
      template: (json[itemTemplateType] as List).first['@id'],
    );
  }
}

enum EtlPortItemType { inputConf, input, output }

class EtlPortItem extends EtlComponentsGraphItem {
  final String id;
  final EtlPortItemType io;
  final String portType;
  final String label;
  final String binding;

  EtlPortItem({
    this.id,
    this.io,
    this.portType,
    this.label,
    this.binding,
  });

  factory EtlPortItem.fromJson(Map<String, dynamic> json, EtlPortItemType io) {
    return EtlPortItem(
      id: json['@id'],
      io: io,
      portType: (json['@type'] as List)
          .singleWhere((type) => type.contains(portTypeSubType)),
      label: (json[labelType] as List).first['@value'],
      binding: (json[portBindingType] as List).first['@value'],
    );
  }
}
