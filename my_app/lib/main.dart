import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

// 1️⃣ Định nghĩa Model
class MyItem {
  final int id;
  final String title;

  MyItem({required this.id, required this.title});

  factory MyItem.fromJson(Map<String, dynamic> json) {
    return MyItem(
      id: json['id'],
      title: json['title'],
    );
  }
}

void main() {
  runApp(const JsonFileSelectorApp());
}

class JsonFileSelectorApp extends StatelessWidget {
  const JsonFileSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON → Map → Object → UI',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const JsonFileScreen(),
    );
  }
}

class JsonFileScreen extends StatefulWidget {
  const JsonFileScreen({super.key});

  @override
  State<JsonFileScreen> createState() => _JsonFileScreenState();
}

class _JsonFileScreenState extends State<JsonFileScreen> {
  String? jsonString;
  Map<String, dynamic>? mapData;
  MyItem? item;

  Future<void> pickJsonFile() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'json',
      extensions: ['json'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final content = await file.readAsString();
      setState(() {
        jsonString = content;
        mapData = jsonDecode(jsonString!);
        item = MyItem.fromJson(mapData!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích JSON từ file')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickJsonFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Chọn file JSON'),
            ),
            const SizedBox(height: 20),

            if (jsonString != null) ...[
              Text('1️⃣ JSON String:', style: titleStyle),
              Container(
                padding: boxPadding,
                decoration: boxDecoration,
                child: Text(jsonString!),
              ),
              const SizedBox(height: 16),

              Text('2️⃣ Sau khi parse → Map:', style: titleStyle),
              Container(
                padding: boxPadding,
                decoration: boxDecoration,
                child: Text(mapData.toString()),
              ),
              const SizedBox(height: 16),

              Text('3️⃣ Sau khi convert → Object (Model):', style: titleStyle),
              Container(
                padding: boxPadding,
                decoration: boxDecoration,
                child: Text('id: ${item!.id}\ntitle: ${item!.title}'),
              ),
              const SizedBox(height: 16),

              Text('4️⃣ Hiển thị lên UI:', style: titleStyle),
              Card(
                color: Colors.indigo.shade50,
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text(item!.id.toString(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(item!.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Dữ liệu đã được chuyển thành Object'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Style helper
  final titleStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo);
  final boxPadding = const EdgeInsets.all(12);
  final boxDecoration = BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.indigo.shade100),
  );
}
