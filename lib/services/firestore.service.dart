import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // GET COLLECTION OF NOTES
  final CollectionReference notesCollection = FirebaseFirestore.instance
      .collection('notes');

  // CREATE:
  Future<void> addNote(String title) {
    return notesCollection.add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ:
  Stream<QuerySnapshot> getNotes() {
    return notesCollection
        .where('createdAt', isNotEqualTo: null)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE:
  Future<void> updateNote(String noteId, String title) {
    return notesCollection.doc(noteId).update({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE:
  Future<void> deleteNote(String noteId) {
    return notesCollection.doc(noteId).delete();
  }
}
