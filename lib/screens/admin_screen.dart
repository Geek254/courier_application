import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../main.dart';

final DateTime currentDateTime = DateTime.now();

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  // Form controllers for creating users
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  bool _verifiedController = false;

  // Form controllers for creating trips
  final _destinationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _feeController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _destinationController.dispose();
    _capacityController.dispose();
    _feeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.teal[700],
        elevation: 8,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[800]!, Colors.teal[600]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  label: 'Overview',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _setSelectedIndex(0),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people,
                  label: 'Manage Users',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _setSelectedIndex(1),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_add,
                  label: 'Create Users',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                  onTap: () => _setSelectedIndex(2),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.directions_car,
                  label: 'Manage Trips',
                  index: 3,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _setSelectedIndex(3),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.add_location,
                  label: 'Create Trips',
                  index: 4,
                  isSelected: _selectedIndex == 4,
                  onTap: () => _setSelectedIndex(4),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.verified_user,
                  label: 'Manage Verifications',
                  index: 5,
                  isSelected: _selectedIndex == 5,
                  onTap: () => _setSelectedIndex(5),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.assessment,
                  label: 'Live Tracking',
                  index: 6,
                  isSelected: _selectedIndex == 6,
                  onTap: () => _setSelectedIndex(6),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  index: 7,
                  isSelected: _selectedIndex == 7,
                  onTap: () => _setSelectedIndex(7),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[100]!, Colors.white.withAlpha((0.95 * 255).round())],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required int index, required bool isSelected, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.teal[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selected: isSelected,
      selectedTileColor: Colors.teal[900]?.withAlpha((0.3 * 255).round()),
    );
  }

  void _setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Center(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withAlpha((0.95 * 255).round()),
            margin: const EdgeInsets.all(20.0),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Admin Dashboard Overview',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Manage users, trips, verifications, reports, and settings efficiently.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case 1:
        return _buildManageUsersContent();
      case 2:
        return _buildCreateUsersContent();
      case 3:
        return _buildManageTripsContent();
      case 4:
        return _buildCreateTripsContent();
      case 5:
        return _buildManageVerificationsContent();
      case 6:
        return _buildLiveTrackingContent();
      case 7:
        return _buildSettingsContent();
      default:
        return const Center(child: Text('Content not implemented'));
    }
  }

  Widget _buildManageUsersContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildUserSection('admin', 'Admin'),
        _buildUserSection('travelers', 'Travelers'),
        _buildUserSection('passengers', 'Passengers'),
      ],
    );
  }

  Widget _buildUserSection(String collection, String title) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!.docs;
        if (users.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'No $title found.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final data = user.data() as Map<String, dynamic>;
                final verified = data['verified'] ?? false;
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.teal),
                    title: Text(
                      data['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Verified: $verified',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () {
                        // Add edit functionality here
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateUsersContent() {
    return Center(
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withAlpha((0.95 * 255).round()),
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New User',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: 'Role (admin/traveler/passenger)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Verified'),
                  value: _verifiedController,
                  onChanged: (value) {
                    setState(() {
                      _verifiedController = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection(_roleController.text.toLowerCase()).add({
                      'name': _nameController.text,
                      'verified': _verifiedController,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User created successfully!')),
                    );
                    _nameController.clear();
                    _roleController.clear();
                    setState(() {
                      _verifiedController = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                  child: const Text('Create User', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageTripsContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('trips').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final trips = snapshot.data!.docs;
            if (trips.isEmpty) {
              return const Center(
                child: Text(
                  'No trips found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final data = trip.data() as Map<String, dynamic>? ?? {};
                final destination = data['destination'] as String? ?? 'Unknown';
                final status = data['status'] as String? ?? 'Unknown';
                final date = data['date']?.toDate().toString().split(' ')[0] ?? 'N/A';
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, color: Colors.teal),
                    title: Text(
                      destination,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: $status | Date: $date',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () {
                        // Add edit functionality here
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCreateTripsContent() {
    return Center(
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withAlpha((0.95 * 255).round()),
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New Trip',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _capacityController,
                  decoration: InputDecoration(
                    labelText: 'Weight Capacity (kg)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _feeController,
                  decoration: InputDecoration(
                    labelText: 'Service Fee (USD)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _statusController,
                  decoration: InputDecoration(
                    labelText: 'Status (e.g., Available, In Progress)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('trips').add({
                      'destination': _destinationController.text,
                      'capacity': double.parse(_capacityController.text),
                      'fee': double.parse(_feeController.text),
                      'status': _statusController.text,
                      'date': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trip created successfully!')),
                    );
                    _destinationController.clear();
                    _capacityController.clear();
                    _feeController.clear();
                    _statusController.clear();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                  child: const Text('Create Trip', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageVerificationsContent() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('verifications').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final verifications = snapshot.data!.docs;
        if (verifications.isEmpty) {
          return const Center(
            child: Text(
              'No verifications found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: verifications.length,
          itemBuilder: (context, index) {
            final verification = verifications[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.verified, color: Colors.teal),
                title: Text(
                  'User ID: ${verification['userId'] ?? 'Unknown'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Status: ${verification['verified'] ?? false} | Submitted: ${verification['createdAt']?.toDate().toString().split(' ')[0] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.teal),
                  onPressed: () {
                    // Add verification approval logic here
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLiveTrackingContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('user_locations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final locations = snapshot.data!.docs;
        if (locations.isEmpty) {
          return const Center(
            child: Text(
              'No live locations found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            final data = location.data() as Map<String, dynamic>;
            final lat = data['latitude']?.toString() ?? 'N/A';
            final lng = data['longitude']?.toString() ?? 'N/A';
            final timestamp = data['timestamp']?.toDate().toString() ?? 'N/A';
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.teal),
                title: Text(
                  'User ${location.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Lat: $lat, Lng: $lng\nTime: $timestamp',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGenerateReportsContent() {
    return Center(
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withAlpha((0.95 * 255).round()),
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Generate Reports',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text('Select Report Type'),
                items: <String>['Users', 'Trips', 'Verifications']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add report generation logic here
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                child: const Text('Generate', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Center(
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withAlpha((0.95 * 255).round()),
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Admin Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.security, color: Colors.teal),
                title: const Text('Change Password'),
                onTap: () {
                  // Add password change logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.teal),
                title: const Text('About'),
                onTap: () {
                  // Add about info logic here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}