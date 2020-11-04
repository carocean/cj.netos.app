
import 'package:netos_app/system/local/entities.dart';

class MessageView {
  final String who;
  final Person whois;
  final String content;
  final String money;
  final int picCount;
  final String time;
  final String channel;
  final Channel channelis;
  final Function() onTap;

  const MessageView({
    this.who,
    this.whois,
    this.content,
    this.money,
    this.picCount,
    this.time,
    this.channel,
    this.channelis,
    this.onTap,
  });
}
class ActivityTabView {
  const ActivityTabView({this.text, this.id});

  final String text;
  final String id;
}
