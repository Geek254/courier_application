import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/user.dart';

final DateTime currentDateTime = DateTime.now();

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signUp(String email, String password, String name, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final collection = role.toLowerCase() == 'admin'
          ? _firestore.collection('admin')
          : (role.toLowerCase() == 'traveler'
          ? _firestore.collection('travelers')
          : _firestore.collection('passengers')); // Passengers go to passengers
      await collection.doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role.toLowerCase(),
        'verified': role.toLowerCase() == 'admin', // Auto-verify admins
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) print("User signed up: UID=${userCredential.user!.uid}, role=${role.toLowerCase()}, verified=${role.toLowerCase() == 'admin'} at $currentDateTime");

      // Sign out immediately after signup to redirect to login screen
      await _auth.signOut();
      if (kDebugMode) print("User signed out after signup for UID=${userCredential.user!.uid} at $currentDateTime");

      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: role.toLowerCase(),
        verified: role.toLowerCase() == 'admin',
      );
      notifyListeners();
      return user;
    } catch (e) {
      if (kDebugMode) print("Sign up error: $e at $currentDateTime");
      return null;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) print("User signed in: UID=${userCredential.user!.uid} at $currentDateTime");
      return await fetchUserData(userCredential.user!.uid);
    } catch (e) {
      if (kDebugMode) print("Sign in error: $e at $currentDateTime");
      return null;
    }
  }

  Future<UserModel?> fetchUserData(String uid) async {
    try {
      if (kDebugMode) print("Fetching user data for UID $uid at $currentDateTime");
      DocumentSnapshot adminDoc = await _firestore.collection('admin').doc(uid).get();
      if (adminDoc.exists) {
        final data = adminDoc.data() as Map<String, dynamic>;
        if (kDebugMode) print("Admin data found for UID $uid: $data at $currentDateTime");
        return UserModel.fromMap(data, uid);
      }
      DocumentSnapshot travelerDoc = await _firestore.collection('travelers').doc(uid).get();
      if (travelerDoc.exists) {
        final data = travelerDoc.data() as Map<String, dynamic>;
        if (kDebugMode) print("Traveler data found for UID $uid: $data at $currentDateTime");
        return UserModel.fromMap(data, uid);
      }
      DocumentSnapshot passengerDoc = await _firestore.collection('passengers').doc(uid).get();
      if (passengerDoc.exists) {
        final data = passengerDoc.data() as Map<String, dynamic>;
        if (kDebugMode) print("Passenger data found for UID $uid: $data at $currentDateTime");
        return UserModel.fromMap(data, uid);
      }
      if (kDebugMode) print("No user data found for UID $uid at $currentDateTime");
      return null;
    } catch (e) {
      if (kDebugMode) print("Fetch user data error: $e at $currentDateTime");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (kDebugMode) print("User signed out at $currentDateTime");
    notifyListeners();
  }

  Future<void> submitVerification(String idNumber, String packageContent) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('verifications').doc(user.uid).set({
        'userId': user.uid,
        'idNumber': idNumber,
        'packageContent': packageContent,
        'verified': false,
        'verifiedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) print("Verification submitted for UID ${user.uid} at $currentDateTime");
      notifyListeners();
    }
  }

  Future<bool> isVerified(String uid) async {
    final doc = await _firestore.collection('verifications').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      return data?['verified'] as bool? ?? false;
    }
    return false;
  }
}