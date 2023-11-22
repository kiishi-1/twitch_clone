import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/models/user.dart' as model;
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/utils/utils.dart';

class AuthMethods {
  final _userRef = FirebaseFirestore.instance.collection("users");
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
    if (uid != null) {
      final snap = await _userRef.doc(uid).get();
      return snap.data();
    }
    return null;
  }

  Future<bool> signUpUser(BuildContext context, String email, String username,
      String password) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        model.User user = model.User(
            email: email.trim(),
            username: username.trim(),
            uid: cred.user!.uid);
        await _userRef.doc(cred.user!.uid).set(user.toMap());
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        // i think listen is false cus we are using the UserProvider or context outside
        //of the build function
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message ?? "error");
      showSnackbar(context, e.message ?? "error");
    }
    return res;
  }

  Future<bool> loginUser(
      BuildContext context, String email, String password) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).setUser(
            model.User.fromMap(await getCurrentUser(cred.user!.uid) ?? {}));
        // i think listen is false cus we are using the UserProvider or context outside
        //of the build function
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message ?? "error");
      showSnackbar(context, e.message ?? "error");
    }
    return res;
  }
}

// List<int> modifyRelativePositions(List<int> arr) {
//   List<int> sortedArr = List.from(arr)..sort();
//   Map<int, int> positionMap = {};
//   List<int> result = [];

//   for (int i = 0; i < sortedArr.length; i++) {
//     int num = sortedArr[i];
//     if (!positionMap.containsKey(num)) {
//       positionMap[num] = i + 1;
//     }
//   }

//   for (int j = 0; j < arr.length; j++) {
//     int currNum = arr[j];
//     result.add(positionMap[currNum]!);
//   }

//   return result;
// }