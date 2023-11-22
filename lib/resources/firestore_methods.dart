import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/models/livestream.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/resources/storage_methods.dart';
import 'package:twitch_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? image) async {
    String channelId = "";
    final user = Provider.of<UserProvider>(context, listen: false);
    //listen is set to false cus we are outside te build function
    try {
      if (title.isNotEmpty && image != null) {
        if (!((await _firestore
                .collection("livestream")
                .doc("${user.user.uid}${user.user.username}")
                .get())
            .exists)) {
          String thumbnailUrl = await _storageMethods.uploadImageToStorage(
              "livestream-thumbnails", image, user.user.uid);
          channelId = "${user.user.uid}${user.user.username}";
          Livestream livestream = Livestream(
              image: thumbnailUrl,
              channelId: channelId,
              viewers: 0,
              startedAt: DateTime.now(),
              uid: user.user.uid,
              title: title,
              username: user.user.username);
          _firestore
              .collection("livestream")
              .doc(channelId)
              .set(livestream.toMap());
        } else {
          // ignore: use_build_context_synchronously
          showSnackbar(context, "Two livestream cannot start at the same time");
        }
      } else {
        showSnackbar(context, "Please enter all the fields");
      }
    } on FirebaseException catch (e) {
      showSnackbar(context, e.message!);
    }
    return channelId;
  }

  Future<void> endLivestream(String channelId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection("livestream")
          .doc(channelId)
          .collection("comments")
          .get();
      for (int i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection("livestream")
            .doc(channelId)
            .collection("comments")
            .doc(((snap.docs[i].data()! as dynamic)["commentId"]))
            .delete();
        //in the document(channelId) we have a subcollection(comments)
        //basically, we're looping through the the list of document in the subcollection(comments)
        //and deleting the documents in the subcollection one by one,
        //using commentId as the document name
      }
      //deleting the document of the particular channel in the livestream collection
      await _firestore.collection("livestream").doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  chat(String text, String id, BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    try {
      String commentId = const Uuid().v1();
      await _firestore
          .collection("livestream")
          .doc(id)
          .collection("comments")
          .doc(commentId)
          .set({
        "username": user.user.username,
        "message": text,
        "uid": user.user.uid,
        "createdAt": DateTime.now(),
        "commentId": commentId,
      });
    } on FirebaseException catch (e) {
      showSnackbar(context, e.message!);
    }
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firestore.collection("livestream").doc(id).update({
        "viewers": FieldValue.increment(isIncrease ? 1 : -1),
        //if isIncrease is true, it means user is coming from the feed screen
        //i.e the user is coming in as an audience/viewer
        // leading to the view count to increase
        //if isIncrease is false, the user is leaving the braodcast screen
        // leading to the view count to decrease
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
