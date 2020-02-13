import 'package:flutter/material.dart';
import 'package:framework/core_lib/_store.dart';

import '_page.dart';
import '_theme.dart';
import '_utimate.dart';

typedef BuildSystem = System Function(IServiceProvider site);
typedef BuildSystemStore = SystemStore Function(IServiceProvider site);

class System {
  final BuildSystemStore buildStore;
  final String defaultTheme;
  final BuildThemes buildThemes;
  final BuildPages buildPages;

  System({
    @required this.defaultTheme,
    @required this.buildStore,
    @required this.buildThemes,
    @required this.buildPages,
  });
}

