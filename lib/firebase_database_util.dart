// import 'dart:async';
//
// import 'package:firebase_database/firebase_database.dart';
//
// import 'model/device.dart';
// import 'model/user.dart';
//
// class FirebaseDatabaseUtil {
//   DatabaseReference _deviceRef;
//   DatabaseReference _userRef;
//   StreamSubscription<Event> _deviceSubscription;
//   StreamSubscription<Event> _messagesSubscription;
//   FirebaseDatabase database = new FirebaseDatabase();
//   int _counter;
//   DatabaseError error;
//
//   static final FirebaseDatabaseUtil _instance =
//       new FirebaseDatabaseUtil.internal();
//
//   FirebaseDatabaseUtil.internal();
//
//   factory FirebaseDatabaseUtil() {
//     return _instance;
//   }
//
//   void initState() {
//     // Demonstrates configuring to the database using a file
//     _deviceRef = FirebaseDatabase.instance.reference().child('devices');
//     // Demonstrates configuring the database directly
//
//     _userRef = database.reference().child('users');
//     database.reference().child('devices').once().then((DataSnapshot snapshot) {
//       print('Connected to second database and read ${snapshot.value}');
//     });
//     database.setPersistenceEnabled(true);
//     database.setPersistenceCacheSizeBytes(10000000);
//     _deviceRef.keepSynced(true);
//
//     _deviceSubscription = _deviceRef.onValue.listen((Event event) {
//       error = null;
//       _counter = event.snapshot.value ?? 0;
//     }, onError: (Object o) {
//       error = o;
//     });
//   }
//
//   DatabaseError getError() {
//     return error;
//   }
//
//   int getCounter() {
//     return _counter;
//   }
//
//   DatabaseReference getUser() {
//     return _userRef;
//   }
//
//   DatabaseReference getDevice() {
//     return _deviceRef;
//   }
//
//   addUser(User user) async {
//     final TransactionResult transactionResult =
//         await _deviceRef.runTransaction((MutableData mutableData) async {
//       mutableData.value = (mutableData.value ?? 0) + 1;
//
//       return mutableData;
//     });
//
//     if (transactionResult.committed) {
//       _userRef.push().set(<String, String>{
//         "name": "" + user.name,
//         "age": "" + user.age,
//         "email": "" + user.email,
//         "mobile": "" + user.mobile,
//       }).then((_) {
//         print('Transaction  committed.');
//       });
//     } else {
//       print('Transaction not committed.');
//       if (transactionResult.error != null) {
//         print(transactionResult.error.message);
//       }
//     }
//   }
//
//   void deleteUser(User user) async {
//     await _userRef.child(user.id).remove().then((_) {
//       print('Transaction  committed.');
//     });
//   }
//
//   void deleteDevice(Device device) async {
//     await _deviceRef.child(device.id).remove().then((_) {
//       print('Transaction  committed.');
//     });
//   }
//
//   void updateUser(User user) async {
//     await _userRef.child(user.id).update({
//       "name": "" + user.name,
//       "age": "" + user.age,
//       "email": "" + user.email,
//       "mobile": "" + user.mobile,
//     }).then((_) {
//       print('Transaction  committed.');
//     });
//   }
//
//   void dispose() {
//     _messagesSubscription.cancel();
//     _deviceSubscription.cancel();
//   }
// }
