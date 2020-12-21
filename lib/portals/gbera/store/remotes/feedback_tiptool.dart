import 'package:framework/framework.dart';

class TipsDocOR {
  String id;
  String title;
  String summary;
  String leading;
  String href; //可以是网址，可以是帮助（help://xxx)，可以是其它，均以协议来表示来源类型，因此不设专门的类型属性
  int ctime;
  int state; //审核的状态；0为待审；1为已上架;-1未通过;
  String creator;

  TipsDocOR({
    this.id,
    this.title,
    this.summary,
    this.leading,
    this.href,
    this.ctime,
    this.state,
    this.creator,
  });

  TipsDocOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.summary = obj['summary'];
    this.leading = obj['leading'];
    this.href = obj['href'];
    this.ctime = obj['ctime'];
    this.state = obj['state'];
    this.creator = obj['creator'];
  }
}

mixin ITipToolRemote {
  Future<void> createTipsDoc(
      String title, String leading, String summary, String href);

  Future<void> downTipsDoc(String id);

  Future<void> releaseTipsDoc(String id);

  Future<TipsDocOR> getTipsDoc(String id);

  Future<void> removeTipsDoc(String id);

  Future<List<TipsDocOR>> pageAllTipsDoc(int limit, int offset);

  Future<List<TipsDocOR>> pageDownTipsDoc(int limit, int offset);

  Future<List<TipsDocOR>> pageOpenedTipsDoc(int limit, int offset);

  Future<List<TipsDocOR>> pageReleasedTipsDoc(int limit, int offset);

  Future<List<TipsDocOR>> readNextTipsDocs(int limit, int offset);

  Future<int> totalReadableTipDocs() {}
}

class TipToolRemote implements ITipToolRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  String get tiptoolPortsUrl =>
      site.getService('@.prop.ports.feedback.tiptool');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<void> createTipsDoc(
      String title, String leading, String summary, String href) async {
    await remotePorts.portPOST(
      tiptoolPortsUrl,
      'createTipsDoc',
      parameters: {
        'title': title,
        'leading': leading,
      },
      data: {
        'href': href,
        'summary': summary,
      },
    );
  }

  @override
  Future<void> downTipsDoc(String id) async {
    await remotePorts.portGET(
      tiptoolPortsUrl,
      'downTipsDoc',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<TipsDocOR> getTipsDoc(String id) async {
    var obj = await remotePorts.portGET(
      tiptoolPortsUrl,
      'getTipsDoc',
      parameters: {
        'id': id,
      },
    );
    if (obj == null) {
      return null;
    }
    return TipsDocOR.parse(obj);
  }

  @override
  Future<List<TipsDocOR>> pageAllTipsDoc(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tiptoolPortsUrl,
      'pageAllTipsDoc',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<TipsDocOR> docs = [];
    for (var obj in list) {
      docs.add(TipsDocOR.parse(obj));
    }
    return docs;
  }

  @override
  Future<List<TipsDocOR>> pageDownTipsDoc(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tiptoolPortsUrl,
      'pageDownTipsDoc',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<TipsDocOR> docs = [];
    for (var obj in list) {
      docs.add(TipsDocOR.parse(obj));
    }
    return docs;
  }

  @override
  Future<List<TipsDocOR>> pageOpenedTipsDoc(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tiptoolPortsUrl,
      'pageOpenedTipsDoc',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<TipsDocOR> docs = [];
    for (var obj in list) {
      docs.add(TipsDocOR.parse(obj));
    }
    return docs;
  }

  @override
  Future<List<TipsDocOR>> pageReleasedTipsDoc(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tiptoolPortsUrl,
      'pageReleasedTipsDoc',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<TipsDocOR> docs = [];
    for (var obj in list) {
      docs.add(TipsDocOR.parse(obj));
    }
    return docs;
  }

  @override
  Future<List<TipsDocOR>> readNextTipsDocs(int limit, int offset) async {
    var list = await remotePorts.portGET(
      tiptoolPortsUrl,
      'readNextTipsDocs',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<TipsDocOR> docs = [];
    for (var obj in list) {
      docs.add(TipsDocOR.parse(obj));
    }
    return docs;
  }

  @override
  Future<void> releaseTipsDoc(String id) async {
    await remotePorts.portGET(
      tiptoolPortsUrl,
      'releaseTipsDoc',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<void> removeTipsDoc(String id) async {
    await remotePorts.portGET(
      tiptoolPortsUrl,
      'removeTipsDoc',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<int> totalReadableTipDocs() async {
    return await remotePorts.portGET(
      tiptoolPortsUrl,
      'totalReadableTipDocs',
      parameters: {},
    );
  }
}
