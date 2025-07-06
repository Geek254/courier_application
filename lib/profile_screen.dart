import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'main.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

final DateTime currentDateTime = DateTime.now();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sender Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal[700],
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
            color: Colors.teal[600],
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Sender Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.local_shipping,
                  label: 'Request Package',
                  onTap: () => _showRequestPackage(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_search,
                  label: 'Browse Travelers',
                  onTap: () => _showBrowseTravelers(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  label: 'Manage Trips',
                  onTap: () => _showManageTrips(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.support,
                  label: 'Support',
                  onTap: () => _showSupport(context),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[100]!, Colors.white],
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
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome, Sender!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Manage your packages and requests',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
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

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
      hoverColor: Colors.teal[700],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  void _showRequestPackage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Request Package', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal[700],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Request Package Form', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(labelText: 'Destination', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBrowseTravelers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Browse Travelers', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal[700],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('travelers')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final travelers = snapshot.data!.docs;
              if (travelers.isEmpty) {
                return const Center(child: Text('No travelers available.', style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: travelers.length,
                itemBuilder: (context, index) {
                  final traveler = travelers[index];
                  final travelerId = traveler.id;
                  final data = traveler.data();
                  final name = data['name'] as String? ?? 'Unknown Traveler';
                  final destination = data['destination'] as String? ?? 'Not specified';
                  final weightCapacity = data['weightCapacity'] as num? ?? 0;
                  final fee = data['fee'] as num? ?? 0;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Colors.green),
                      title: Text(
                        '$name (ID: $travelerId)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'To: $destination | Capacity: $weightCapacity kg | Fee: $fee',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Send Package Request', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.teal[700],
                                ),
                                body: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Request for $name (ID: $travelerId)'),
                                      const SizedBox(height: 20),
                                      const TextField(
                                        decoration: InputDecoration(labelText: 'Package Weight', border: OutlineInputBorder()),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                                        child: const Text('Send Request', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                        child: const Text('Select', style: TextStyle(color: Colors.white)),
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

  void _showManageTrips(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (kDebugMode) print("Fetching trips for userId: $userId at $currentDateTime");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Manage Trips', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal[700],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (kDebugMode) print("No snapshot data for trips at $currentDateTime");
                return const Center(child: CircularProgressIndicator());
              }
              final trips = snapshot.data!.docs;
              if (kDebugMode) print("Found ${trips.length} trips for userId: $userId at $currentDateTime");
              if (trips.isEmpty) {
                if (kDebugMode) print("No trips found for userId: $userId at $currentDateTime");
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
                  if (kDebugMode) print("Trip $index: destination=$destination, status=$status, date=$date at $currentDateTime");
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

  void _showSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Support', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal[700],
          ),
          body: const Center(
            child: Text('Contact support at support@courierapp.com', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}