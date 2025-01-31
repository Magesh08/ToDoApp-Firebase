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
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  List<String> collectionNames = [];
  String? selectedCollection;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  // Load the collection names on init
  void _loadCollections() async {
    final names = await fireStoreData.getCollectionNames();
    setState(() {
      collectionNames = names;
      selectedCollection = names.isNotEmpty ? names.first : null;
    });
  }

  // Open the expense dialog
  void openExpenseDialog({String? expenseId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expenseId != null ? 'Edit Expense' : 'Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(hintText: 'Category'),
            ),
            TextField(
              controller: paymentMethodController,
              decoration: InputDecoration(hintText: 'Payment Method'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Description'),
            ),
            TextField(
              controller: notesController,
              decoration: InputDecoration(hintText: 'Notes'),
            ),
            TextField(
              controller: currencyController,
              decoration: InputDecoration(hintText: 'Currency'),
            ),
            TextField(
              controller: userIdController,
              decoration: InputDecoration(hintText: 'User ID'),
            ),
            TextField(
              controller: budgetController,
              decoration: InputDecoration(hintText: 'Budget'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final expenseData = {
                'amount': double.tryParse(amountController.text.trim()) ?? 0.0,
                'category': categoryController.text.trim(),
                'date': Timestamp.now(),
                'paymentMethod': paymentMethodController.text.trim(),
                'description': descriptionController.text.trim(),
                'notes': notesController.text.trim(),
                'currency': currencyController.text.trim(),
                'userId': userIdController.text.trim(),
                'budget': budgetController.text.trim(),
              };
              try {
                if (expenseId != null && selectedCollection != null) {
                  await fireStoreData.updateExpense(
                    selectedCollection!,
                    expenseId,
                    expenseData,
                  );
                } else if (selectedCollection != null) {
                  await fireStoreData.createExpenseInCollection(
                    selectedCollection!,
                    expenseData,
                  );
                }
                Navigator.of(context).pop();
              } catch (e) {
                print('Error saving expense: $e');
              }
            },
            child: Text('Save'),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.brown)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: collectionNames.length, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Expense Tracker',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.brown[200],
          elevation: 4,
          bottom: collectionNames.isNotEmpty
              ? TabBar(
                  tabs: collectionNames
                      .map((collectionName) => Tab(text: collectionName))
                      .toList(),
                  onTap: (index) {
                    setState(() {
                      selectedCollection = collectionNames[index];
                    });
                  },
                )
              : null,
        ),
        body: selectedCollection == null
            ? Center(child: Text('No collections available'))
            : StreamBuilder<QuerySnapshot>(
                stream: fireStoreData
                    .getExpensesStreamInCollection(selectedCollection!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No expenses found'));
                  }
                  final expenses = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expenseData =
                          expenses[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(
                            '${expenseData['amount']} ${expenseData['currency']}'),
                        subtitle: Text(
                            '${expenseData['category']} - ${expenseData['paymentMethod']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            fireStoreData.deleteExpense(
                                selectedCollection!, expenses[index].id);
                          },
                        ),
                        onTap: () {
                          openExpenseDialog(expenseId: expenses[index].id);
                        },
                      );
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: openExpenseDialog,
          backgroundColor: Colors.brown[200],
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
