import 'dart:async';

class ChannelEventArgs {
  String command;
  String channel;
  dynamic args;

  ChannelEventArgs({this.command, this.channel, this.args});
}
StreamController<ChannelEventArgs> channelNotifyStreamController=StreamController.broadcast();
///用于在收件箱加管道后通知主界面刷新
StreamController netflowRefresherController=StreamController.broadcast();