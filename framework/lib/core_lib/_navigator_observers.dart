import 'package:flutter/material.dart';
import 'package:framework/core_lib/_app_surface.dart';
import 'package:framework/core_lib/_utimate.dart';

import '_page.dart';

class AppNavigatorObserver extends NavigatorObserver {
  IAppSurface appSurface;
  Function() onswitchSceneOrTheme;
  final _histories = <_PageMemento>[];
  _PageMemento _previous = null;
  _PageMemento _first=null;
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (_previous != null) {
      _histories.add(_previous);
    }
    _previous = _PageMemento(
      sceneName: appSurface.current.name,
      pageUrl: route.settings.name,
      theme: appSurface.current.theme,
    );
    if(previousRoute?.settings?.name==null) {
      _first=_previous;
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    var memento = _histories.last;
    _histories.removeLast();
    if(_histories.isEmpty) {
      _previous=_first;
    }
//    print(
//        '---$memento----${appSurface.current.name}......${appSurface.current.theme}');
    bool hasSwitch = false;
    if (memento.sceneName != appSurface.current.theme) {
      appSurface.switchScene(memento.sceneName, memento.pageUrl);
      hasSwitch = true;
    } else {
      if (memento.theme != appSurface.current.theme) {
        appSurface.switchTheme(memento.theme);
        hasSwitch = true;
      }
    }
    super.didPop(route, previousRoute);
    if (hasSwitch && onswitchSceneOrTheme != null) {
      onswitchSceneOrTheme();
    }
  }

  AppNavigatorObserver(this.appSurface, this.onswitchSceneOrTheme);
}

class _PageMemento {
  String sceneName;
  String theme;
  String pageUrl;

  _PageMemento({this.sceneName, this.theme, this.pageUrl});

  @override
  String toString() {
    return '$pageUrl $sceneName $theme';
  }
}
