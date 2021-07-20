import 'package:diagram_editor/diagram_editor.dart';
import 'package:etl_diagram_editor/policy/my_policy_set.dart';
import 'package:etl_diagram_editor/widget/menu.dart';
import 'package:etl_diagram_editor/widget/option_icon.dart';
import 'package:flutter/material.dart';

void main() => runApp(SimpleDemoEditor());

class SimpleDemoEditor extends StatefulWidget {
  @override
  _SimpleDemoEditorState createState() => _SimpleDemoEditorState();
}

class _SimpleDemoEditorState extends State<SimpleDemoEditor> {
  DiagramEditorContext diagramEditorContext;

  MyPolicySet myPolicySet = MyPolicySet();

  bool isMenuVisible = true;
  bool areOptionsVisible = true;

  Future<bool> isComponentSetLoading;
  Future<bool> isDiagramLoading;

  final pipelineUrlController = TextEditingController(
      text:
          'https://demo.etl.linkedpipes.com/resources/pipelines/1560425451529'); // example

  @override
  void initState() {
    diagramEditorContext = DiagramEditorContext(
      policySet: myPolicySet,
    );

    isComponentSetLoading = myPolicySet.loadComponentSet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(color: Colors.grey),
              Positioned(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: DiagramEditor(
                    diagramEditorContext: diagramEditorContext,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: Row(
                  children: [
                    Visibility(
                      visible: isMenuVisible,
                      child: Container(
                        color: Colors.grey.withOpacity(0.7),
                        width: 120,
                        height: 400,
                        // child: DraggableMenu(myPolicySet: myPolicySet),
                        child: Center(
                          child: FutureBuilder<bool>(
                            future: isComponentSetLoading,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return DraggableMenu(myPolicySet: myPolicySet);
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                        ),
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMenuVisible = !isMenuVisible;
                          });
                        },
                        child: Container(
                          color: Colors.grey[300],
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child:
                                Text(isMenuVisible ? 'hide menu' : 'show menu'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 24,
                top: 24,
                child: Column(children: [
                  Container(
                    width: 320,
                    height: 64,
                    child: TextField(
                      controller: pipelineUrlController,
                      decoration: InputDecoration(
                        labelText: 'Pipeline URL',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      myPolicySet.removeAll();
                      isDiagramLoading =
                          myPolicySet.loadPipeline(pipelineUrlController.text);
                      setState(() {});
                    },
                    child: Text('LOAD'),
                  ),
                ]),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  color: Colors.grey.withOpacity(0.2),
                  child: FutureBuilder<bool>(
                    future: isDiagramLoading,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                            'Pipeline name: ${myPolicySet.pipelineLabel}');
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      OptionIcon(
                        color: Colors.grey.withOpacity(0.7),
                        iconData:
                            areOptionsVisible ? Icons.menu_open : Icons.menu,
                        shape: BoxShape.rectangle,
                        onPressed: () {
                          setState(() {
                            areOptionsVisible = !areOptionsVisible;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      Visibility(
                        visible: areOptionsVisible,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            OptionIcon(
                              tooltip: 'reset view',
                              color: Colors.grey.withOpacity(0.7),
                              iconData: Icons.replay,
                              onPressed: () => myPolicySet.resetView(),
                            ),
                            SizedBox(width: 8),
                            OptionIcon(
                              tooltip: 'delete all',
                              color: Colors.grey.withOpacity(0.7),
                              iconData: Icons.delete_forever,
                              onPressed: () => myPolicySet.removeAll(),
                            ),
                            SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: myPolicySet.isMultipleSelectionOn,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OptionIcon(
                                        tooltip: 'select all',
                                        color: Colors.grey.withOpacity(0.7),
                                        iconData: Icons.all_inclusive,
                                        onPressed: () =>
                                            myPolicySet.selectAll(),
                                      ),
                                      SizedBox(height: 8),
                                      OptionIcon(
                                        tooltip: 'duplicate selected',
                                        color: Colors.grey.withOpacity(0.7),
                                        iconData: Icons.copy,
                                        onPressed: () =>
                                            myPolicySet.duplicateSelected(),
                                      ),
                                      SizedBox(height: 8),
                                      OptionIcon(
                                        tooltip: 'remove selected',
                                        color: Colors.grey.withOpacity(0.7),
                                        iconData: Icons.delete,
                                        onPressed: () =>
                                            myPolicySet.removeSelected(),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                OptionIcon(
                                  tooltip: myPolicySet.isMultipleSelectionOn
                                      ? 'cancel multiselection'
                                      : 'enable multiselection',
                                  color: Colors.grey.withOpacity(0.7),
                                  iconData: myPolicySet.isMultipleSelectionOn
                                      ? Icons.group_work
                                      : Icons.group_work_outlined,
                                  onPressed: () {
                                    setState(() {
                                      if (myPolicySet.isMultipleSelectionOn) {
                                        myPolicySet.turnOffMultipleSelection();
                                      } else {
                                        myPolicySet.turnOnMultipleSelection();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
