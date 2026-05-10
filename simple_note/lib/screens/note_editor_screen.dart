import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool isEditing;
  late bool isPinned;
  late int priority;

  @override
  void initState() {
    super.initState();
    isEditing = widget.note != null;

    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(text: widget.note?.content ?? "");

    isPinned = widget.note?.isPinned ?? false;
    priority = widget.note?.priority ?? 1;
  }

  void _saveNote() async {
    final provider = Provider.of<NoteProvider>(context, listen: false);

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hãy nhập tiêu đề")),
      );
      return;
    }

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: isPinned,
      priority: priority,
    );

    if (isEditing) {
      await provider.updateNote(note);
    } else {
      await provider.addNote(note);
    }

    Navigator.pop(context);
  }

  void _deleteNote() async {
    if (!isEditing) return;

    final provider = Provider.of<NoteProvider>(context, listen: false);
    await provider.deleteNote(widget.note!.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? "Chỉnh sửa" : "Ghi chú mới",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, 
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.black),
            onPressed: () {
              setState(() => isPinned = !isPinned);
            },
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text("Xác nhận xóa"),
                    content: const Text("Bạn có chắc muốn xóa ghi chú này không?"),
                    actions: [
                      TextButton(
                        child: const Text(
                          "Hủy",
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      TextButton(
                        child: const Text(
                          "Xóa",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  );
                },
              );
              if (confirm == true) {
                _deleteNote();
              }
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _saveNote,
        child: const Icon(Icons.save, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Mức ưu tiên: ",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: priority,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Thấp")),
                    DropdownMenuItem(value: 2, child: Text("Trung bình")),
                    DropdownMenuItem(value: 3, child: Text("Cao")),
                  ],
                  onChanged: (v) => setState(() => priority = v!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Tiêu đề...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "Nội dung...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
