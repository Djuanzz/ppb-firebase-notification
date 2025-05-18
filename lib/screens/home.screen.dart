import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notification_firebase/screens/login.screen.dart';
import 'package:notification_firebase/services/firestore.service.dart';
import 'package:notification_firebase/services/notification.service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController noteController = TextEditingController();

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  void openNotes({String? docId, String? title}) {
    if (title != null) {
      noteController.text = title;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notes'),
            content: SizedBox(
              height: 120,
              width: 300,
              child: Column(
                children: [
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Enter your note',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (docId != null) {
                        // UPDATE NOTE
                        firestoreService.updateNote(docId, noteController.text);
                      } else {
                        // ADD NOTE
                        firestoreService.addNote(noteController.text);
                      }

                      // CLEAR
                      noteController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(docId != null ? 'Save Note' : 'Add Note'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Account Information'),
              centerTitle: true,
            ),
            body: Center(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text('Logged in as ${snapshot.data?.email}'),
                  const SizedBox(height: 24),

                  OutlinedButton(
                    onPressed: () => logout(context),
                    child: const Text('Logout'),
                  ),

                  OutlinedButton(
                    onPressed: openNotes,
                    child: const Text("Add Notes"),
                  ),

                  OutlinedButton(
                    onPressed: () async {
                      await NotificationService.createNotification(
                        id: 1,
                        title: 'Default Notification',
                        body: 'This is the body of the notification',
                        summary: 'Small summary',
                      );
                    },
                    child: const Text('Default Notification'),
                  ),

                  const SizedBox(height: 20),

                  StreamBuilder(
                    stream: firestoreService.getNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No notes found'));
                      }

                      final notes = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final createdAt =
                              note['createdAt'] != null
                                  ? note['createdAt'].toDate().toString()
                                  : 'No date';

                          return Card(
                            child: ListTile(
                              title: Text(note['title']),
                              subtitle: Text(createdAt),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      openNotes(
                                        docId: note.id,
                                        title: note['title'],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      firestoreService.deleteNote(note.id);
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
                ],
              ),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
