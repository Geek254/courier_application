import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

final DateTime currentDateTime = DateTime.now();
class TravelerListingsScreen extends StatefulWidget {
  const TravelerListingsScreen({super.key});

  @override
  _TravelerListingsScreenState createState() => _TravelerListingsScreenState();
}

class _TravelerListingsScreenState extends State<TravelerListingsScreen> {
  final _destinationController = TextEditingController();
  final _weightCapacityController = TextEditingController();
  final _feeController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _createListing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_destinationController.text.isEmpty || _weightCapacityController.text.isEmpty || _feeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')),
        );
        return;
      }
      await _firestoreService.createTrip({
        'userId': user.uid,
        'origin': 'Current Location', // Placeholder, update with geolocation if needed
        'destination': _destinationController.text.trim(),
        'weightCapacity': double.parse(_weightCapacityController.text),
        'fee': double.parse(_feeController.text),
        'date': DateTime.now(),
        'status': 'available',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing created successfully')),
      );
      _destinationController.clear();
      _weightCapacityController.clear();
      _feeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Traveler Listing', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create a New Listing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _weightCapacityController,
                    decoration: InputDecoration(
                      labelText: 'Weight Capacity (kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _feeController,
                    decoration: InputDecoration(
                      labelText: 'Fee',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _createListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Create Listing', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _weightCapacityController.dispose();
    _feeController.dispose();
    super.dispose();
  }
}