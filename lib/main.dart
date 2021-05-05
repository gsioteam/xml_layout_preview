import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xml_layout/xml_layout.dart';
import 'preview.xml_layout.dart' as preview;
import 'package:xml_layout/types/colors.dart' as colors;
import 'package:xml_layout/types/icons.dart' as icons;
import 'dart:html';
import 'preview.dart' as preview;

void main() {
  preview.register();
  colors.register();
  icons.register();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  StreamSubscription<MessageEvent> _subscription;
  String template;
  Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return XmlLayout(
      template: template,
      objects: data,
      onUnkownElement: (NodeData data, Key key) {
        window.console.log("Unkown tag ${data.name}");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    template = '<Text>Initializing...</Text>';
    _subscription = window.onMessage.listen((event) {
      String tmp = event.data["xml"];
      if (tmp != null) {
        window.console.log("On get template!");
        setState(() {
          template = tmp;
          try {
            data = jsonDecode(event.data["data"]);
          } catch (e) {
            data = null;
          }
        });
      }
    });
    List<String> types = [];
    for (var type in XmlLayout.registerTypes) {
      types.add(type);
    }
    window.postMessage({
      "type": "ready",
      "types": types
    }, "*");
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
