import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/dialog/edit_link_dialog.dart';
import 'package:etl_diagram_editor/policy/custom_policy.dart';
import 'package:flutter/material.dart';

mixin MyLinkWidgetsPolicy implements LinkWidgetsPolicy, CustomPolicy {
  @override
  List<Widget> showWidgetsWithLinkData(
      BuildContext context, LinkData linkData) {
    return [
      if (selectedLinkId == linkData.id) showLinkOptions(context, linkData),
    ];
  }

  Widget showLinkOptions(BuildContext context, LinkData linkData) {
    var nPos = canvasReader.state.toCanvasCoordinates(tapLinkPosition);
    return Positioned(
      left: nPos.dx,
      top: nPos.dy,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              canvasWriter.model.removeLink(linkData.id);
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                width: 32,
                height: 32,
                child: Center(child: Icon(Icons.close, size: 20))),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              showEditLinkDialog(
                context,
                linkData,
              );
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                width: 32,
                height: 32,
                child: Center(child: Icon(Icons.edit, size: 20))),
          ),
        ],
      ),
    );
  }
}
