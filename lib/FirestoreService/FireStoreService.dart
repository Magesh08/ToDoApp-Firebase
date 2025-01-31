import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to the collections_metadata
  final CollectionReference collectionsMetadata =
      FirebaseFirestore.instance.collection('collections_metadata');

  // Fetch the list of collection names
  Future<List<String>> getCollectionNames() async {
    try {
      final snapshot = await collectionsMetadata.get();
      final List<String> collectionNames = [];
      snapshot.docs.forEach((doc) {
        collectionNames.add(doc.id);
      });
      return collectionNames;
    } catch (e) {
      print('Error fetching collection names: $e');
      return [];
    }
  }

  // Create a new collection and add an expense
  Future<void> createCollectionAndAddExpense(
      String collectionName, Map<String, dynamic> expenseData) async {
    try {
      // Add a document to collections_metadata
      await collectionsMetadata.doc(collectionName).set({
        'created_at': Timestamp.now(),
      });

      // Add an expense to the collection
      await _db.collection(collectionName).add(expenseData);
    } catch (e) {
      print('Error creating collection and adding expense: $e');
      throw e;
    }
  }

  // Create a new expense in an existing collection
  Future<void> createExpenseInCollection(
      String collectionName, Map<String, dynamic> expenseData) async {
    try {
      final collection = _db.collection(collectionName);
      await collection.add(expenseData);
    } catch (e) {
      print('Error creating expense: $e');
      throw e;
    }
  }

  // Update an existing expense
  Future<void> updateExpense(String collectionName, String expenseId,
      Map<String, dynamic> expenseData) async {
    try {
      final collection = _db.collection(collectionName);
      await collection.doc(expenseId).update(expenseData);
    } catch (e) {
      print('Error updating expense: $e');
      throw e;
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String collectionName, String expenseId) async {
    try {
      final collection = _db.collection(collectionName);
      await collection.doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      throw e;
    }
  }

  // Get expenses from a specific collection as a stream
  Stream<QuerySnapshot> getExpensesStreamInCollection(String collectionName) {
    return _db
        .collection(collectionName)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
