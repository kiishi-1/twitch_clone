class Livestream {
  final String uid;
  final String title;
  final String username;
  final String image;
  final String channelId;
  final int viewers;
  final startedAt;

  Livestream(
      {required this.image,
      required this.channelId,
      required this.viewers,
      required this.startedAt,
      required this.uid,
      required this.title,
      required this.username});

  factory Livestream.fromMap(Map<String, dynamic> map) {
    return Livestream(
      uid: map["uid"] ?? "",
      title: map["title"] ?? "",
      username: map["username"] ?? "",
      channelId: map["channelId"] ?? "",
      startedAt: map["startedAt"] ?? "",
      image: map["image"] ?? "",
      viewers: map["viewers"]?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "title": title,
      "username": username,
      "channelId": channelId,
      "image": image,
      "viewers": viewers,
      "startedAt": startedAt
    };
  }
}
