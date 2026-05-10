import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';
import '../utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  int? filterPriority;

  @override
  void initState() {
    super.initState();
    Provider.of<NoteProvider>(context, listen: false).loadNotes();
  }

  void _openNoteEditor(BuildContext context, Note? note) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteEditorScreen(note: note),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); 
          const end = Offset.zero;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    List<Note> filteredNotes = noteProvider.notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesPriority = filterPriority == null || note.priority == filterPriority;
      return matchesSearch && matchesPriority;
    }).toList();

    filteredNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Ghi chú",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm ghi chú...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) => setState(() => searchQuery = val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Lọc theo mức ưu tiên: "),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: filterPriority,
                      hint: const Text("Tất cả"),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Thấp")),
                        DropdownMenuItem(value: 2, child: Text("Trung bình")),
                        DropdownMenuItem(value: 3, child: Text("Cao")),
                      ],
                      onChanged: (v) => setState(() => filterPriority = v),
                    ),
                    if (filterPriority != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => filterPriority = null),
                      )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: filteredNotes.isEmpty
          ? _buildEmptyState()
          : _buildNotesGrid(filteredNotes),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add, size: 30),
        onPressed: () => _openNoteEditor(context, null),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "Chưa có ghi chú nào",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "tạo ghi chú mới",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) => _buildNoteCard(notes[index], index),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final colorPair = NoteColors.getGradient(index);

    return GestureDetector(
      onTap: () => _openNoteEditor(context, note),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colorPair,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin_rounded, size: 20, color: Colors.redAccent),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Ưu tiên: ${note.priority}",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return "Hôm nay";
    if (diff.inDays == 1) return "Hôm qua";
    if (diff.inDays < 7) return "${diff.inDays} ngày trước";

    return "${date.day}/${date.month}/${date.year}";
  }
}
