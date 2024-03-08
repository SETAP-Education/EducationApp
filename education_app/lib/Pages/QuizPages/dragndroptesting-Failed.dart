import 'package:flutter/material.dart';

class DraggableExample extends StatefulWidget {
  @override
  _DraggableExampleState createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  Map<String, Widget> itemWidgets = {
    'Item 1': Container(
      width: 100,
      height: 100,
      color: Colors.blue,
      child: Center(child: Text('Item 1')),
    ),
    'Item 2': Container(
      width: 100,
      height: 100,
      color: Colors.green,
      child: Center(child: Text('Item 2')),
    ),
    'Item 3': Container(
      width: 100,
      height: 100,
      color: Colors.red,
      child: Center(child: Text('Item 3')),
    ),
  };

  Map<String, GlobalKey> draggableKeyMap = {
    'Item 1': GlobalKey(),
    'Item 2': GlobalKey(),
    'Item 3': GlobalKey(),
  };

  GlobalKey targetKey = GlobalKey();

  Widget? currentAcceptedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draggable Example'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var item in items)
                Draggable<String>(
                  key: draggableKeyMap[item],
                  data: item,
                  child: itemWidgets[item]!,
                  feedback: itemWidgets[item]!,
                  childWhenDragging: Container(),
                  onDragCompleted: () {
                    setState(() {
                      // Remove from the original list when dragged
                      items.remove(item);
                    });
                  },
                ),
            ],
          ),
          SizedBox(height: 20),
          DragTarget<String>(
            key: targetKey,
            builder: (context, accepted, rejected) {
              return Container(
                width: 300,
                height: 200,
                color: Colors.grey,
                child: currentAcceptedItem != null
                    ? Draggable<String>(
                        key: draggableKeyMap[
                            items.firstWhere((item) =>
                                itemWidgets[item] == currentAcceptedItem,
                                orElse: () => '')],
                        data: items.firstWhere(
                            (item) =>
                                itemWidgets[item] == currentAcceptedItem,
                            orElse: () => ''),
                        feedback: currentAcceptedItem!,
                        child: currentAcceptedItem!,
                        onDragEnd: (details) {
                          if (!details.wasAccepted) {
                            // If not accepted in the target, snap back
                            setState(() {
                              currentAcceptedItem = null;
                            });
                          }
                        },
                      )
                    : Container(),
              );
            },
            onWillAccept: (String? data) {
              // Only accept if no item is accepted yet
              return currentAcceptedItem == null;
            },
            onAccept: (String data) {
              setState(() {
                currentAcceptedItem = itemWidgets[data];
              });
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DraggableExample(),
  ));
}
