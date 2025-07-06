import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String userId;
  final String origin;
  final String destination;
  final double weightCapacity;
  final double fee;
  final DateTime date;
  final String status; // e.g., 'available', 'in_transit', 'delivered'

  Trip({
    required this.id,
    required this.userId,
    required this.origin,
    required this.destination,
    required this.weightCapacity,
    required this.fee,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'origin': origin,
      'destination': destination,
      'weightCapacity': weightCapacity,
      'fee': fee,
      'date': date,
      'status': status,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map, String id) {
    return Trip(
      id: id,
      userId: map['userId'],
      origin: map['origin'],
      destination: map['destination'],
      weightCapacity: (map['weightCapacity'] as num?)?.toDouble() ?? 0.0,
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'available',
    );
  }
}