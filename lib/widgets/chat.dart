import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/widgets/custom_textfield.dart';
import 'package:twitch_clone/widgets/loading_indicator.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.channelId});
  final String channelId;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _chatController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: StreamBuilder<dynamic>(
            stream: FirebaseFirestore.instance
                .collection("livestream")
                .doc(widget.channelId)
                .collection("comments")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        snapshot.data.docs[index]["username"],
                        style: TextStyle(
                          color:
                              snapshot.data.docs[index]["uid"] == user.user.uid
                                  ? Colors.blue
                                  : Colors.black,
                        ),
                      ),
                      subtitle: Text(snapshot.data.docs[index]["message"]),
                    );
                  });
            },
          )),
          CustomTextfield(
            controller: _chatController,
            onTap: (val) {
              FirestoreMethods().chat(val, widget.channelId, context);
              setState(() {
                _chatController.text = "";
              });
            },
          )
        ],
      ),
    );
  }
}
