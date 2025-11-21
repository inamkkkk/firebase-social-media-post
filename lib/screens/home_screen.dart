import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/post_model.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postTextController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _createPost(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated.')),
      );
      return;
    }

    String? imageUrl;
    if (_image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      await uploadTask.whenComplete(() => null);
      imageUrl = await storageRef.getDownloadURL();
    }

    final post = Post(
      userId: user.uid,
      text: _postTextController.text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    await FirebaseFirestore.instance.collection('posts').add(post.toMap());

    _postTextController.clear();
    setState(() {
      _image = null;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postTextController,
                    decoration: const InputDecoration(hintText: 'Write a post...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: getImage,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _createPost(context),
                ),
              ],
            ),
          ),
          if (_image != null)
            Image.file(
              _image!,
              height: 100,
              width: 100,
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                    Post post = Post.fromMap(
                        document.data() as Map<String, dynamic>);
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User: ${post.userId}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(post.timestamp),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 8.0),
                            Text(post.text),
                            if (post.imageUrl != null)
                              Image.network(post.imageUrl!),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}