import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/media_model.dart';
import 'add_media_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService service = FirestoreService();
  final FirebaseService authService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Media Catalogue"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddMediaPage()));
        },
        child: Icon(Icons.add),
        tooltip: "Add Media",
      ),
      body: StreamBuilder<List<Media>>(
        stream: service.getMedia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                ],
              ),
            );
          }

          final mediaList = snapshot.data ?? [];

          if (mediaList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No media added yet",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first media",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: mediaList.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final media = mediaList[index];
              return MediaCard(
                media: media,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMediaPage(media: media),
                    ),
                  );
                },
                onDelete: () => _deleteMedia(context, media.id),
                onToggleAvailability: () => _toggleAvailability(media),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleAvailability(Media media) async {
    try {
      final updatedMedia = media.copyWith(available: !media.available);
      await service.updateMedia(updatedMedia);
      _showSnackBar(
        "Status updated to ${updatedMedia.available ? 'Available' : 'Unavailable'}",
        Colors.blue,
      );
    } catch (e) {
      _showSnackBar("Error updating status: $e", Colors.red);
    }
  }

  void _deleteMedia(BuildContext context, String mediaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Media?"),
        content: Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await service.deleteMedia(mediaId);
                _showSnackBar("Media deleted successfully", Colors.green);
              } catch (e) {
                _showSnackBar("Error deleting media: $e", Colors.red);
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout?"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              }
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
}

class MediaCard extends StatelessWidget {
  final Media media;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const MediaCard({
    required this.media,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: media.available ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              media.available ? Icons.check_circle : Icons.cancel,
              color: media.available ? Colors.green : Colors.red,
            ),
          ),
        ),
        title: Text(
          media.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(media.type),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text("Toggle Availability"),
              onTap: onToggleAvailability,
            ),
            PopupMenuItem(
              child: Text("Edit"),
              onTap: onEdit,
            ),
            PopupMenuItem(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}