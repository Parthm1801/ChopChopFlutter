import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';

void main() {
  runApp(const MaterialApp(home: TextPage()));
}

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  var textController = TextEditingController();
  String statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Enter widget text",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      textController.clear();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _updateWidget();
              },
              child: const Text("Push to Widget"),
            ),
            const SizedBox(height: 10),
            Text(statusMessage, style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  void _updateWidget() {
    try {
      final widgetData = WidgetData(textController.text);
      final jsonData = jsonEncode(widgetData.toJson());
      
      // Debug print to verify data
      print('Updating widget with data: $jsonData');
      
      WidgetKit.setItem(
        'widgetData',
        jsonData,
        'group.com.parth.flutterWidgetTest',
      );
      WidgetKit.reloadTimelines('FlutterIOSWidget');
      
      setState(() {
        statusMessage = 'Widget updated with: ${textController.text}';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error updating widget: $e';
      });
      print('Error updating widget: $e');
    }
  }
}

class WidgetData {
  final String text;

  WidgetData(this.text);

  WidgetData.fromJson(Map<String, dynamic> json) : text = json['text'];

  Map<String, dynamic> toJson() => {'text': text};
}
