import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Collection reference
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // Create a new note
  Future<void> createNote(String content) async {
    try {
      await notes.add({
        'content': content,
        'timestamp': Timestamp.now(), // Changed to 'timestamp' field
      });
    } catch (e) {
      print('Error creating note: $e');
      throw e;
    }
  }

  // Update an existing note
  Future<void> updateNote(String id, String content) async {
    try {
      await notes.doc(id).update({
        'content': content,
        'timestamp': Timestamp.now(), // Changed to 'timestamp' field
      });
    } catch (e) {
      print('Error updating note: $e');
      throw e;
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await notes.doc(id).delete();
    } catch (e) {
      print('Error deleting note: $e');
      throw e;
    }
  }

  // Stream of all notes
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }
}
