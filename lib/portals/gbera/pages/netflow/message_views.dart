
class MessageView {
  final String who;
  final String content;
  final String money;
  final int picCount;
  final String time;
  final String channel;
  final Function() onTap;

  const MessageView({
    this.who,
    this.content,
    this.money,
    this.picCount,
    this.time,
    this.channel,
    this.onTap,
  });
}
class ActivityTabView {
  const ActivityTabView({this.text, this.id});

  final String text;
  final String id;
}
