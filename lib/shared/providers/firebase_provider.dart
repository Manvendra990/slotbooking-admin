// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final firebaseAuthProvider = Provider<FirebaseAuth>(
//   (_) => FirebaseAuth.instance,
// );

// final firestoreProvider = Provider<FirebaseFirestore>(
//   (_) => FirebaseFirestore.instance,
// );

// final firebaseStorageProvider = Provider<FirebaseStorage>(
//   (_) => FirebaseStorage.instance,
// );

// final authStateProvider = StreamProvider<User?>(
//   (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
// );

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// /// ─────────────────────────────────────────────────────────────────────────────
// /// FirebaseBookingService
// /// Saare booking-related Firestore operations yahan hain.
// /// AdminBookingsScreen ya kisi bhi screen se import karke use karo.
// /// ─────────────────────────────────────────────────────────────────────────────
// class FirebaseBookingService {
//   static final _db = FirebaseFirestore.instance;

//   // ── 1. Booking Cancel ──────────────────────────────────────────────────────
//   /// Admin jab slot cancel kare:
//   ///   - admin_bookings  → bookingStatus: 'cancelled'
//   ///   - user_bookings   → bookingStatus: 'cancelled'  (userId se dhundh ke)
//   ///   - notifications   → user ko in-app notification
//   static Future<void> cancelBooking({
//     required String bookingId,
//     required Map<String, dynamic> bookingData,
//   }) async {
//     final userId = bookingData['userId'] as String? ?? '';
//     final groundName = bookingData['groundName'] as String? ?? 'Ground';
//     final slotLabel = bookingData['slotLabel'] as String? ?? '';
//     final amount = bookingData['amount'] ?? 0;

//     // Batch write — sab ek saath hoga, koi partial update nahi
//     final batch = _db.batch();

//     // ── Step 1: admin_bookings update ────────────────────────────────────────
//     final adminBookingRef = _db.collection('admin_bookings').doc(bookingId);
//     batch.update(adminBookingRef, {
//       'bookingStatus': 'cancelled',
//       'cancelledAt': FieldValue.serverTimestamp(),
//       'cancelledBy': FirebaseAuth.instance.currentUser?.uid ?? '',
//     });

//     // ── Step 2: user_bookings update (userId se match karo) ──────────────────
//     // user_bookings me same bookingId hoga (payment ke waqt same ID se save kiya)
//     if (userId.isNotEmpty) {
//       final userBookingRef = _db.collection('user_bookings').doc(bookingId);
//       batch.update(userBookingRef, {
//         'bookingStatus': 'cancelled',
//         'cancelledAt': FieldValue.serverTimestamp(),
//       });
//     }

//     // ── Step 3: Notification document banao ──────────────────────────────────
//     if (userId.isNotEmpty) {
//       final notifRef = _db.collection('notifications').doc();
//       batch.set(notifRef, {
//         'userId': userId,
//         'type': 'booking_cancelled',
//         'title': 'Booking Cancelled',
//         'body':
//             'Your booking at $groundName ($slotLabel) has been cancelled by the admin.',
//         'bookingId': bookingId,
//         'groundName': groundName,
//         'amount': amount,
//         'isRead': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }

//     // Commit all 3 writes together
//     await batch.commit();
//   }

//   // ── 2. Booking Status Update (non-cancel) ──────────────────────────────────
//   /// Sirf bookingStatus update karna ho (e.g. available → confirmed)
//   static Future<void> updateBookingStatus({
//     required String bookingId,
//     required String newStatus,
//     required Map<String, dynamic> bookingData,
//   }) async {
//     final userId = bookingData['userId'] as String? ?? '';
//     final groundName = bookingData['groundName'] as String? ?? 'Ground';

//     final batch = _db.batch();

//     // admin_bookings update
//     batch.update(_db.collection('admin_bookings').doc(bookingId), {
//       'bookingStatus': newStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     // user_bookings update
//     if (userId.isNotEmpty) {
//       batch.update(_db.collection('user_bookings').doc(bookingId), {
//         'bookingStatus': newStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     }

//     // Notification (status change ke liye)
//     if (userId.isNotEmpty) {
//       final notifRef = _db.collection('notifications').doc();
//       batch.set(notifRef, {
//         'userId': userId,
//         'type': 'booking_status_update',
//         'title': 'Booking Updated',
//         'body':
//             'Your booking at $groundName status has been updated to ${newStatus.toUpperCase()}.',
//         'bookingId': bookingId,
//         'groundName': groundName,
//         'isRead': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }

//     await batch.commit();
//   }

//   // ── 3. Slot Delete ─────────────────────────────────────────────────────────
//   /// Slot delete karo — agar userId hai toh user ko notify karo
//   static Future<void> deleteSlot({
//     required String bookingId,
//     required Map<String, dynamic> bookingData,
//   }) async {
//     final userId = bookingData['userId'] as String? ?? '';
//     final groundName = bookingData['groundName'] as String? ?? 'Ground';
//     final slotLabel = bookingData['slotLabel'] as String? ?? '';

//     final batch = _db.batch();

//     // admin_bookings delete
//     batch.delete(_db.collection('admin_bookings').doc(bookingId));

//     // Agar user ne book kiya tha — user_bookings me cancelled mark karo
//     // (delete mat karo — user ki history rahni chahiye)
//     if (userId.isNotEmpty) {
//       batch.update(_db.collection('user_bookings').doc(bookingId), {
//         'bookingStatus': 'cancelled',
//         'cancelledAt': FieldValue.serverTimestamp(),
//       });

//       // Notification
//       final notifRef = _db.collection('notifications').doc();
//       batch.set(notifRef, {
//         'userId': userId,
//         'type': 'slot_deleted',
//         'title': 'Slot Removed',
//         'body':
//             'The slot $slotLabel at $groundName has been removed by the admin.',
//         'bookingId': bookingId,
//         'groundName': groundName,
//         'isRead': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }

//     await batch.commit();
//   }

//   // ── 4. Unread notification count ───────────────────────────────────────────
//   /// User ke unread notifications count karo
//   static Stream<int> unreadNotificationCount(String userId) {
//     return _db
//         .collection('notifications')
//         .where('userId', isEqualTo: userId)
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .map((snap) => snap.docs.length);
//   }

//   // ── 5. Mark notification as read ──────────────────────────────────────────
//   static Future<void> markNotificationRead(String notifId) async {
//     await _db.collection('notifications').doc(notifId).update({
//       'isRead': true,
//       'readAt': FieldValue.serverTimestamp(),
//     });
//   }

//   // ── 6. Mark all notifications read ────────────────────────────────────────
//   static Future<void> markAllNotificationsRead(String userId) async {
//     final unread = await _db
//         .collection('notifications')
//         .where('userId', isEqualTo: userId)
//         .where('isRead', isEqualTo: false)
//         .get();

//     final batch = _db.batch();
//     for (final doc in unread.docs) {
//       batch.update(doc.reference, {
//         'isRead': true,
//         'readAt': FieldValue.serverTimestamp(),
//       });
//     }
//     await batch.commit();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseBookingService {
  static final _db = FirebaseFirestore.instance;

  // ── 1. Booking Cancel ──────────────────────────────────────────────────────
  static Future<void> cancelBooking({
    required String bookingId,
    required Map<String, dynamic> bookingData,
  }) async {
    final userId = bookingData['userId'] as String? ?? '';

    final batch = _db.batch();

    // ── Step 1: admin_bookings update ────────────────────────────────────────
    final adminBookingRef = _db.collection('admin_bookings').doc(bookingId);
    batch.update(adminBookingRef, {
      'bookingStatus': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': FirebaseAuth.instance.currentUser?.uid ?? '',
    });

    // ── Step 2: user_bookings update (exists check) ───────────────────────────
    if (userId.isNotEmpty) {
      final userBookingRef = _db.collection('user_bookings').doc(bookingId);
      final docSnap = await userBookingRef.get();
      if (docSnap.exists) {
        batch.update(userBookingRef, {
          'bookingStatus': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // ── 2. Booking Status Update ───────────────────────────────────────────────
  static Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
    required Map<String, dynamic> bookingData,
  }) async {
    final userId = bookingData['userId'] as String? ?? '';

    final batch = _db.batch();

    batch.update(_db.collection('admin_bookings').doc(bookingId), {
      'bookingStatus': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (userId.isNotEmpty) {
      final userBookingRef = _db.collection('user_bookings').doc(bookingId);
      final docSnap = await userBookingRef.get();
      if (docSnap.exists) {
        batch.update(userBookingRef, {
          'bookingStatus': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // ── 3. Slot Delete ─────────────────────────────────────────────────────────
  static Future<void> deleteSlot({
    required String bookingId,
    required Map<String, dynamic> bookingData,
  }) async {
    final userId = bookingData['userId'] as String? ?? '';

    final batch = _db.batch();

    batch.delete(_db.collection('admin_bookings').doc(bookingId));

    if (userId.isNotEmpty) {
      final userBookingRef = _db.collection('user_bookings').doc(bookingId);
      final docSnap = await userBookingRef.get();
      if (docSnap.exists) {
        batch.update(userBookingRef, {
          'bookingStatus': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // ── 4. Unread notification count ───────────────────────────────────────────
  static Stream<int> unreadNotificationCount(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── 5. Mark notification as read ──────────────────────────────────────────
  static Future<void> markNotificationRead(String notifId) async {
    await _db.collection('notifications').doc(notifId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // ── 6. Mark all notifications read ────────────────────────────────────────
  static Future<void> markAllNotificationsRead(String userId) async {
    final unread = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
