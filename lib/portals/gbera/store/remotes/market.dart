import 'package:framework/framework.dart';

class EcSourceOR {
  String id;
  String title;
  int state;
  String ctime;

  EcSourceOR({
    this.id,
    this.title,
    this.state,
    this.ctime,
  });

  EcSourceOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.state = obj['state'];
    this.ctime = obj['ctime'];
  }
}

class EcSiteOR {
  String id;
  String title;
  String source;
  int sort;
  String ctime;

  EcSiteOR({
    this.id,
    this.title,
    this.source,
    this.sort,
    this.ctime,
  });

  EcSiteOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.source = obj['source'];
    this.sort = obj['sort'];
    this.ctime = obj['ctime'];
  }
}

class EcChannelOR {
  String id;
  String code;
  String title;
  String site;
  String source;
  int sort;
  String ctime;

  EcChannelOR({
    this.id,
    this.code,
    this.title,
    this.site,
    this.source,
    this.sort,
    this.ctime,
  });

  EcChannelOR.parse(obj) {
    this.id = obj['id'];
    this.code = obj['code'];
    this.title = obj['title'];
    this.site = obj['site'];
    this.source = obj['source'];
    this.sort = obj['sort'];
    this.ctime = obj['ctime'];
  }
}

mixin IMarketRemote {
  Future<List<EcSourceOR>> listSource();

  Future<List<EcSiteOR>> listSite(String source);

  Future<List<EcChannelOR>> listChannel(String source, String site);
}

class TaobaoMarketRemote implements IMarketRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  get marketPortsUrl => site.getService('@.prop.ports.market');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    return null;
  }

  @override
  Future<List<EcChannelOR>> listChannel(String source, String site) async{
    List list = await remotePorts.portGET(
      marketPortsUrl,
      'listChannel',
      parameters: {
        'source':source,
        'site':site,
      },
    );
    List<EcChannelOR> sites=[];
    for(var obj in list) {
      sites.add(EcChannelOR.parse(obj));
    }
    return sites;
  }

  @override
  Future<List<EcSiteOR>> listSite(String source)async {
    List list = await remotePorts.portGET(
      marketPortsUrl,
      'listSite',
      parameters: {
        'source':source,
      },
    );
    List<EcSiteOR> sites=[];
    for(var obj in list) {
      sites.add(EcSiteOR.parse(obj));
    }
    return sites;
  }

  @override
  Future<List<EcSourceOR>> listSource() async{
    List list = await remotePorts.portGET(
      marketPortsUrl,
      'listSource',
      parameters: {
      },
    );
    List<EcSourceOR> sources=[];
    for(var obj in list) {
      sources.add(EcSourceOR.parse(obj));
    }
    return sources;
  }
}
