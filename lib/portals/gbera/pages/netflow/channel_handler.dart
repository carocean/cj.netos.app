import 'dart:async';

class ChannelEventArgs {
  String command;
  String channel;
  dynamic args;

  ChannelEventArgs({this.command, this.channel, this.args});
}
StreamController<ChannelEventArgs> channelNotifyStreamController=StreamController.broadcast();