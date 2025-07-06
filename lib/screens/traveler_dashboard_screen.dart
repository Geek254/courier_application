import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import 'dart:async';

final DateTime currentDateTime = DateTime.now();

class TravelerDashboardScreen extends StatefulWidget {
  const TravelerDashboardScreen({super.key});

  @override
  _TravelerDashboardScreenState createState() => _TravelerDashboardScreenState();
}

class _TravelerDashboardScreenState extends State<TravelerDashboardScreen> {
  final LocationService _locationService = LocationService();
  String? _selectedRideId; // To store the currently tracked ride ID
  bool _isTracking = false; // To track the tracking state

  @override
  void initState() {
    super.initState();
    // Check initial tracking state if needed (e.g., from Firestore or app state)
  }

  Future<void> _startTracking(String rideId) async {
    setState(() => _isTracking = true);
    await _locationService.startLocationUpdates(FirebaseAuth.instance.currentUser!.uid, rideId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live tracking started for this trip.')),
    );
  }

  void _stopTracking() {
    _locationService.stopLocationUpdates();
    setState(() => _isTracking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live tracking stopped.')),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
      hoverColor: Colors.purple[700],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traveler Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications placeholder')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.purple[600],
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Traveler Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.directions_car,
                  label: 'View My Trips',
                  onTap: () => _showMyTrips(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.check_circle,
                  label: 'Manage Requests',
                  onTap: () => _showManageRequests(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.update,
                  label: 'Update Availability',
                  onTap: () => _showUpdateAvailability(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.payment,
                  label: 'Earnings',
                  onTap: () => _showEarnings(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.support,
                  label: 'Support',
                  onTap: () => _showSupport(context),
                ),
                if (_isTracking)
                  _buildMenuItem(
                    context,
                    icon: Icons.stop,
                    label: 'Stop Tracking',
                    onTap: _stopTracking,
                  ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.purple,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome, Traveler!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Manage your trips and requests',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (_isTracking)
                            const SizedBox(height: 20),
                          if (_isTracking)
                            const Text(
                              'Live tracking is active for your trip.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
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

  void _showMyTrips(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('My Trips', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.purple[700],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final trips = snapshot.data!.docs;
              if (trips.isEmpty) {
                return const Center(child: Text('No trips found.', style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final destination = trip['destination'] as String? ?? 'Unknown';
                  final status = trip['status'] as String? ?? 'Pending';
                  final date = trip['date']?.toDate().toString().split(' ')[0] ?? 'N/A';
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Colors.green),
                      title: Text(
                        'To: $destination',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Status: $status | Date: $date',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status == 'in_transit' && !_isTracking)
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.blue),
                              onPressed: () {
                                setState(() => _selectedRideId = trip.id);
                                _startTracking(trip.id);
                                Navigator.pop(context); // Return to dashboard
                              },
                            ),
                          DropdownButton<String>(
                            value: status,
                            items: ['available', 'in_transit', 'delivered']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (newStatus) async {
                              if (newStatus != null) {
                                await FirebaseFirestore.instance
                                    .collection('trips')
                                    .doc(trip.id)
                                    .update({'status': newStatus});
                                if (newStatus == 'delivered' && _isTracking) {
                                  _stopTracking();
                                }
                              }
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
      ),
    );
  }

  void _showManageRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Manage Requests', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.purple[700],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('travelerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final requests = snapshot.data!.docs;
              if (requests.isEmpty) {
                return const Center(child: Text('No requests found.', style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final senderId = request['senderId'] as String? ?? 'Unknown';
                  final destination = request['destination'] as String? ?? 'Unknown';
                  final weight = request['weight'] as num? ?? 0;
                  final status = request['status'] as String? ?? 'Pending';
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping, color: Colors.orange),
                      title: Text(
                        'To: $destination',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Weight: $weight kg | From: $senderId | Status: $status',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('requests')
                                  .doc(request.id)
                                  .update({'status': 'Accepted'});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('requests')
                                  .doc(request.id)
                                  .update({'status': 'Rejected'});
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
      ),
    );
  }

  void _showUpdateAvailability(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Update Availability', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.purple[700],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Set Availability Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('travelers')
                          .doc(user.uid)
                          .update({'status': 'available'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Availability updated to Available')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                  child: const Text('Set Available', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('travelers')
                          .doc(user.uid)
                          .update({'status': 'unavailable'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Availability updated to Unavailable')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                  child: const Text('Set Unavailable', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEarnings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Earnings', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.purple[700],
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Earnings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Details coming soon...', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Support', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.purple[700],
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Contact support at support@courierapp.com', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}