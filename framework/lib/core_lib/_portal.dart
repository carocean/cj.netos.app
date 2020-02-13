import 'package:flutter/material.dart';
import 'package:framework/core_lib/_store.dart';

import '_desklet.dart';
import '_page.dart';
import '_theme.dart';
import '_utimate.dart';


typedef BuildPortals = List<BuildPortal> Function(IServiceProvider site);
typedef BuildPortal = Portal Function(IServiceProvider site);
typedef BuildPortalStore = PortalStore Function(
    IServiceProvider site);

class Portal {
  const Portal({
    @required this.id,
    @required this.title,
    @required this.icon,
    @required this.defaultTheme,
    @required this.buildDesklets,
    @required this.buildPages,
    @required this.buildThemes,
    @required this.buildStore,
  });

  final BuildPortalStore buildStore;
  final BuildDesklets buildDesklets;
  final BuildThemes buildThemes;
  final BuildPages buildPages;
  final String id;
  final String defaultTheme;
  final String title;
  final IconData icon;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Portal typedOther = other;
    return typedOther.id == id &&
        typedOther.title == title &&
        typedOther.icon == icon;
  }

  @override
  int get hashCode => hashValues(id, title, icon);

  @override
  String toString() {
    return '$runtimeType($id)';
  }
}
