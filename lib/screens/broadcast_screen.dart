import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/config/appId.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/screens/home_screen.dart';
import 'package:twitch_clone/widgets/chat.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen(
      {super.key, required this.isBroadcaster, required this.channelId});
  final bool isBroadcaster;
  final String channelId;

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  bool switchCamera = true;
  bool isMuted = false;
  List<int> remoteUidList = [];

  _leaveChannel() async {
    await _engine.leaveChannel();
    // ignore: use_build_context_synchronously
    if ("${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}" ==
        widget.channelId) {
      //if the user created the channel for livestreaming
      await FirestoreMethods().endLivestream(widget.channelId);
    } else {
      //if not, the user is an audience/viewer
      await FirestoreMethods().updateViewCount(widget.channelId, false);
      //isIncrease is false cus user is leaving the channel view count needs to decrease
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint("switchCamera $err");
    });
  }

  onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEngine();
  }

  _initEngine() async {
    // _engine = RtcEngine.createWithContext(RtcEngineContext(appId: ,));
    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      // channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    _addListeners();
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    if (widget.isBroadcaster) {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    } else {
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
    _joinChannel();
  }

  _addListeners() {
    _engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
      debugPrint(
          "joinChannelSuccess ${connection.channelId} ${connection.localUid}  $elapsed");
    }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
      debugPrint("userJoined $remoteUid $elapsed ${connection.localUid}");
      print("remoteUid");
      print(remoteUid);
      print("remoteUid2");
      setState(() {
        remoteUidList.add(remoteUid);
      });
      print("remoteUidList");
      print(remoteUidList);
      print("remoteUidList2");
    }, onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
      debugPrint("userOffline $remoteUid left channel, $reason");
      setState(() {
        remoteUidList.removeWhere((element) => element == remoteUid);
      });
    }, onLeaveChannel: (connection, stats) {
      debugPrint("leaveChannel $stats");
      setState(() {
        remoteUidList.clear();
      });
    }));
  }

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(
        token: tempToken,
        channelId: "testing123",
        // ignore: use_build_context_synchronously
        userAccount:
            // ignore: use_build_context_synchronously
            Provider.of<UserProvider>(context, listen: false).user.uid);
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   remoteUidList.clear();
  //   _engine.leaveChannel();
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _renderVideo(user),
              if ("${user.uid}${user.username}" == widget.channelId)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _switchCamera,
                      child: const Text("Switch Camera"),
                    ),
                    InkWell(
                      onTap: onToggleMute,
                      child: Text(isMuted ? "Unmute" : "Mute"),
                    )
                  ],
                ),
              Expanded(
                  child: Chat(
                channelId: widget.channelId,
              ))
            ],
          ),
        ),
      ),
    );
  }

  _renderVideo(user) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" == widget.channelId
          //to check if it's the correct user
          //if the channel/livestream is created by the user
          //remoteUidList[0] cus it's the first user to join the chat
          //i.e it's the user that created it
          ? AgoraVideoView(
              controller: VideoViewController(
                useAndroidSurfaceView: true,
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
          //if it's not created by the user
          //check if remoteUidList is empty
          //if it isn't, check if it is web
          : remoteUidList.isNotEmpty
              ? Row(
                  children: [
                    ...List.of(
                      remoteUidList.map(
                        (e) => kIsWeb
                            //if it's web
                            ? AgoraVideoView(
                                controller: VideoViewController.remote(
                                  useAndroidSurfaceView: true,
                                  rtcEngine: _engine,
                                  canvas: VideoCanvas(uid: e),
                                  connection: RtcConnection(
                                      channelId: widget.channelId),
                                ),
                              )
                            //if it isn't
                            : AgoraVideoView(
                                controller: VideoViewController.remote(
                                  useFlutterTexture: true,
                                  rtcEngine: _engine,
                                  canvas: VideoCanvas(uid: e),
                                  connection: RtcConnection(
                                      channelId: widget.channelId),
                                ),
                              ),
                      ),
                    ),
                  ],
                )
              // if remoteUidList is empty
              : Container(),
    );
  }
}
