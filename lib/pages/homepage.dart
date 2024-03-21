import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project/FirestoreService/FireStoreService.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService fireStoreData = FirestoreService();
  final TextEditingController textController = TextEditingController();

  void openNoteDialog({String? noteId, String? initialContent}) {
    textController.text = initialContent ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(noteId != null ? 'Edit Note' : 'Add Note'),
        content: TextField(controller: textController),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (noteId != null) {
                  await fireStoreData.updateNote(noteId, textController.text);
                } else {
                  await fireStoreData.createNote(textController.text);
                }
                textController.clear();
                Navigator.of(context).pop();
              } catch (e) {
                print('Error saving note: $e');
              }
            },
            child: Text('Save'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.brown),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do App'),
        backgroundColor: Colors.brown[200], // Lighter background color
        elevation: 4, // Add elevation
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fireStoreData.getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final notes = snapshot.data!.docs;
                  // Debug: Print notes to terminal
                  notes.forEach((note) {
                    print('Note ID: ${note.id}');
                    print('Note data: ${note.data()}');
                  });
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final noteData =
                          notes[index].data() as Map<String, dynamic>;
                      return Container(
                        margin: EdgeInsets.all(15.0),
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Lighter background color
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 3), // Changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(noteData['content']),
                          subtitle: Text(noteData['timestamp'] != null
                              ? 'Created at: ${noteData['timestamp'].toDate()}'
                              : ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  openNoteDialog(
                                    noteId: notes[index].id,
                                    initialContent: noteData['content'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  fireStoreData.deleteNote(notes[index].id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[200],
        onPressed: openNoteDialog,
        child: Icon(Icons.add),
        elevation: 8, // Add elevation
      ),
    );
  }
}
