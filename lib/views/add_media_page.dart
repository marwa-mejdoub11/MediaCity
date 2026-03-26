import 'dart:async';

import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/firestore_service.dart';

class AddMediaPage extends StatefulWidget {
  final Media? media;

  const AddMediaPage({this.media});

  @override
  State<AddMediaPage> createState() => _AddMediaPageState();
}

class _AddMediaPageState extends State<AddMediaPage> {
  late TextEditingController titleController;
  late TextEditingController typeController;
  final FirestoreService service = FirestoreService();

  bool isLoading = false;
  bool isAvailable = true;

  String currentMediaId = '';
  Timer? _autoSaveDebounce;
  bool _autoSaveEnabled = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.media?.title ?? '');
    typeController = TextEditingController(text: widget.media?.type ?? '');
    isAvailable = widget.media?.available ?? true;
    currentMediaId = widget.media?.id ?? '';

    titleController.addListener(_scheduleAutoSave);
    typeController.addListener(_scheduleAutoSave);
  }

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    titleController.removeListener(_scheduleAutoSave);
    typeController.removeListener(_scheduleAutoSave);
    titleController.dispose();
    typeController.dispose();
    super.dispose();
  }

  void _scheduleAutoSave() {
    if (!_autoSaveEnabled) return;

    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 900), () async {
      if (!mounted) return;
      await _performSave(reloadAfterSave: false, showSnackbar: false);
    });
  }

  Future<void> _performSave({
    bool reloadAfterSave = true,
    bool showSnackbar = true,
  }) async {
    final title = titleController.text.trim();
    final type = typeController.text.trim();

    if (title.isEmpty || type.isEmpty) return;

    try {
      setState(() => isLoading = true);

      final media = Media(
        id: currentMediaId,
        title: title,
        type: type,
        available: isAvailable,
      );

      final savedId = await service.upsertMedia(media);
      if (currentMediaId.isEmpty) {
        currentMediaId = savedId;
      }

      if (showSnackbar && mounted) {
        _showSnackBar('Enregistrement automatique effectué', Colors.green);
      }

      if (reloadAfterSave && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted && showSnackbar) {
        _showSnackBar('Erreur enregistrement: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void saveMedia(BuildContext context) async {
    _autoSaveEnabled = false; // disable auto-save while manual save in progress
    await _performSave(reloadAfterSave: true, showSnackbar: true);
    _autoSaveEnabled = true;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.media == null ? "Add Media" : "Edit Media"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "Enter media title",
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: typeController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: "Type",
                  hintText: "e.g., Book, Movie, Album",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: CheckboxListTile(
                  enabled: !isLoading,
                  title: Text("Available"),
                  subtitle: Text("Is this media available?"),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() => isAvailable = value ?? true);
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : () => saveMedia(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.media == null ? "Add Media" : "Update Media",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}