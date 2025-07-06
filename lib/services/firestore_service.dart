import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

final DateTime currentDateTime = DateTime.now();

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTrip(Map<String, dynamic> tripData) async {
    await _firestore.collection('trips').add({
      'userId': tripData['userId'],
      'origin': tripData['origin'],
      'destination': tripData['destination'],
      'weightCapacity': tripData['weightCapacity'],
      'fee': tripData['fee'],
      'date': tripData['date'],
      'status': tripData['status'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createRequest(Map<String, dynamic> requestData) async {
    await _firestore.collection('requests').add({
      'passengerId': requestData['passengerId'],
      'travelerId': requestData['travelerId'],
      'origin': requestData['origin'],
      'destination': requestData['destination'],
      'weight': requestData['weight'],
      'description': requestData['description'],
      'status': requestData['status'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Trip>> getTrips() {
    return _firestore.collection('trips').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromMap(doc.data(), doc.id)).toList());
  }
}