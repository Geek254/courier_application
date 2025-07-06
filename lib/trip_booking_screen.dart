import 'package:courier_application/screens/traveler_listings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class TripBookingScreen extends StatefulWidget {
  const TripBookingScreen({super.key});

  @override
  State<TripBookingScreen> createState() => _TripBookingScreenState();
}

class _TripBookingScreenState extends State<TripBookingScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;

  Future<void> _bookTrip() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('trips').add({
          'passengerId': user.uid,
          'origin': _originController.text.trim(),
          'destination': _destinationController.text.trim(),
          'date': _dateController.text.trim().isNotEmpty
              ? DateTime.parse(_dateController.text.trim())
              : FieldValue.serverTimestamp(),
          'weight': double.parse(_weightController.text),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip booked successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Trip or Browse Travelers"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TravelerListingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Updated to include assets/ prefix
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black26,
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_car, size: 100, color: Colors.grey),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _originController,
                          decoration: InputDecoration(
                            labelText: "Origin",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _destinationController,
                          decoration: InputDecoration(
                            labelText: "Destination",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: "Date (YYYY-MM-DD)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: "Weight (kg)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.scale),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _bookTrip,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF6D214F),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Book Trip",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}