import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String>uploadImageToStorage(String childName, Uint8List file, String uid) async {
    Reference ref = _storage.ref().child(childName).child(uid);
    UploadTask uploadTask =
        ref.putData(file, SettableMetadata(contentType: "image/jpg"));
    //SettableMetadata(contentType: "image/jpg") is firbase to recognise the content type
    //usually it does but just incase

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
