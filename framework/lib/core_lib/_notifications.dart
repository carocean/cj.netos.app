import 'package:flutter/material.dart';

class SwitchSceneNotification extends Notification {
  final String scene;
  final String pageUrl;
  final Function() onfinished;
  SwitchSceneNotification({@required this.scene,@required this.pageUrl,@required this.onfinished});
}
class SwitchThemeNotification extends Notification {
  final String theme;

  SwitchThemeNotification({@required  this.theme});
}