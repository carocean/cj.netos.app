import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';

IPortletMarket market = _PortletMarketForAssets();
IDesktopManager desktopManager = _DesktopManagerForAssets();

mixin IDesktopManager {
  Future<List<Portlet>> getInstalledPortlets(PageContext context);

  void installPortlets(List<Portlet> portlets, PageContext context);

  Future<bool> isInstalledPortlet(String id, PageContext context);

  Future unInstalledPortlet(String id, PageContext context);

  Future installPortlet(Portlet portlet, PageContext context);

  Future<bool> isDefaultPortlet(String id, PageContext context);
}
mixin IPortletMarket {
  Future<List<Portlet>> fetchPortletsByPortletids(
      List<String> portletids, PageContext context);

  Future<List<Portlet>> fetchAllPortlets(PageContext context);

  Future<List<Portlet>> fetchPortletsByDeskletUrl(
      String deskletUrl, PageContext context);

  Future<Portlet> fetchPortlet(String portletid, PageContext context);
}

class _PortletMarketForAssets implements IPortletMarket {
  @override
  Future<List<Portlet>> fetchAllPortlets(PageContext context) async {
    var json = await DefaultAssetBundle.of(context.context)
        .loadString('lib/portals/gbera/data/portlets.json');

    return jsonConvertToPortletList(json);
  }

  @override
  Future<Portlet> fetchPortlet(String portletid, PageContext context) async {
    var list = await fetchAllPortlets(context);
    for (Portlet portlet in list) {
      if (portlet.id == portletid) {
        return portlet;
      }
    }
    return null;
  }

  @override
  Future<List<Portlet>> fetchPortletsByDeskletUrl(
      String deskletUrl, PageContext context) async {
    var list = await fetchAllPortlets(context);
    var ret = <Portlet>[];
    for (Portlet portlet in list) {
      if (portlet.deskletUrl == deskletUrl) {
        ret.add(portlet);
      }
    }
    return ret;
  }

  @override
  Future<List<Portlet>> fetchPortletsByPortletids(
      List<String> portletids, PageContext context) async {
    var list = await fetchAllPortlets(context);
    var ret = <Portlet>[];
    for (Portlet portlet in list) {
      for (var id in portletids) {
        if (portlet.id == id) {
          ret.add(portlet);
        }
      }
    }
    return ret;
  }
}

class _DesktopManagerForAssets implements IDesktopManager {
  static final KEY = '!.desktop.portlets';

  @override
  Future<List<Portlet>> getInstalledPortlets(PageContext context) async {
    var portlets = _getInstalledPortlets(context);
    if (portlets.length == 0||portlets.length == 1) {
      //装载应用默认插件
      await _installDefaultPortlets(context);
      portlets = _getInstalledPortlets(context);
    }
    return portlets;
  }

  @override
  Future<bool> isDefaultPortlet(String id, PageContext context) async {
    String json = await DefaultAssetBundle.of(context.context)
        .loadString('lib/portals/gbera/data/portlet_defaults.json');
    List list = jsonDecode(json);
    for (var eid in list) {
      if (eid == id) {
        return true;
      }
    }
    return false;
  }

  //从远程服务接口获取应用默认的必装栏目
  void _installDefaultPortlets(PageContext context) async {
    String json = await DefaultAssetBundle.of(context.context)
        .loadString('lib/portals/gbera/data/portlet_defaults.json');
    List list = jsonDecode(json);
    var defaults = <String>[];
    for (var id in list) {
      defaults.add(id);
    }
    List<Portlet> portlets =
        await market.fetchPortletsByPortletids(defaults, context);
    installPortlets(portlets, context);
  }

  List<Portlet> _getInstalledPortlets(PageContext context) {
    var json = context.sharedPreferences().getString(KEY,
        scene: context.currentScene(), person: context.principal.person);
    return jsonConvertToPortletList(json);
  }

  @override
  void installPortlets(List<Portlet> portlets, PageContext context) {
    var list = [];
    for (Portlet let in portlets) {
      list.add(let.toMap());
    }
    var json = jsonEncode(list);
    context.sharedPreferences().setString(KEY, json,person: context.principal.person,scene: context.currentScene());
  }

  @override
  Future installPortlet(Portlet portlet, PageContext context) async {
    var list = await getInstalledPortlets(context);
    list.add(portlet);
    installPortlets(list, context);
  }

  @override
  Future<bool> isInstalledPortlet(String id, PageContext context) async {
    var list = await getInstalledPortlets(context);
    bool exists = false;
    for (Portlet let in list) {
      if (id == let.id) {
        exists = true;
        break;
      }
    }
    return exists;
  }

  @override
  Future unInstalledPortlet(String id, PageContext context) async {
    var list = await getInstalledPortlets(context);
    for (Portlet let in list) {
      if (id == let.id) {
        list.remove(let);
        break;
      }
    }
    installPortlets(list, context);
  }
}

List<Portlet> jsonConvertToPortletList(String json) {
  if (json == null) return [];
  var list = jsonDecode(json);
  var portlets = <Portlet>[];
  for (Map<String, Object> obj in list) {
    if (obj == null) continue;
    portlets.add(Portlet(
      id: obj['id'],
      deskletUrl: obj['deskletUrl'],
      title: obj['title'],
      desc: obj['desc'],
      subtitle: obj['subtitle'],
      imgSrc: obj['imgSrc'],
    ));
  }
  return portlets;
}
