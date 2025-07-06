import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _ratingController = TextEditingController();
  final _commentsController = TextEditingController();

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('reviews').add({
        'travelerId': 'placeholder_traveler_id', // To be linked with selected traveler
        'passengerId': user.uid,
        'rating': int.parse(_ratingController.text),
        'comments': _commentsController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted!')),
      );
      _ratingController.clear();
      _commentsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Rating (1-5)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _commentsController,
              decoration: const InputDecoration(labelText: 'Comments'),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ratingController.dispose();
    _commentsController.dispose();
    super.dispose();
  }
}