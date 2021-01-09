import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class ScreenResultOR {
  PopupRuleOR rule;
  ScreenSubjectOR subject;

  ScreenResultOR({this.rule, this.subject});

  ScreenResultOR.parse(obj) {
    var rule = obj['rule'];
    if (rule != null) {
      this.rule = PopupRuleOR.parse(rule);
    }
    var subject = obj['subject'];
    if (subject != null) {
      this.subject = ScreenSubjectOR.parse(subject);
    }
  }
}

class ScreenSubjectOR {
  String id;
  String title;
  String subTitle;
  String href;
  String creator;
  int sort;
  int ctime;
  String leading;

  ScreenSubjectOR({
    this.id,
    this.title,
    this.subTitle,
    this.href,
    this.creator,
    this.sort,
    this.ctime,
    this.leading,
  });

  ScreenSubjectOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.subTitle = obj['subTitle'];
    this.href = obj['href'];
    this.creator = obj['creator'];
    this.sort = obj['sort'];
    this.ctime = obj['ctime'];
    this.leading = obj['leading'];
  }
}

class PopupRuleOR {
  String code;
  String name;
  String args;

  PopupRuleOR({
    this.code,
    this.name,
    this.args,
  });

  PopupRuleOR.parse(obj) {
    this.code = obj['code'];
    this.name = obj['name'];
    this.args = obj['args'];
  }
}

mixin IScreenRemote {
  Future<void> createSubject(
      String title, String subTitle, String leading, String href);

  Future<ScreenResultOR> getCurrent();

  Future<List<PopupRuleOR>> listPopupRule();

  Future<List<ScreenSubjectOR>> pageSubject(int limit, int offset);

  Future<void> putOnScreen(String subject, String popupRule);

  Future<void> removeSubject(String id);

  Future<void> clearScreen() {}

  Future<void> moveDownSubject(id) {}

  Future<void> moveUpSubject(id) {}

  Future<void> updateSubject(
      String id, String title, String subTitle, String leading, String href) {}

  Future<void> updatePopupRuleArgs(String code, String args) {}
}

class DefaultScreenRemote implements IScreenRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get screenPorts => site.getService('@.prop.ports.operation.screen');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<void> createSubject(
      String title, String subTitle, String leading, String href) async {
    await remotePorts.portPOST(
      screenPorts,
      'createSubject',
      parameters: {
        'title': title,
        'subTitle': subTitle,
        'leading': leading,
      },
      data: {
        'href': href,
      },
    );
  }

  @override
  Future<ScreenResultOR> getCurrent() async {
    var obj = await remotePorts.portGET(
      screenPorts,
      'getCurrent',
    );
    if (obj == null) {
      return null;
    }
    return ScreenResultOR.parse(obj);
  }

  @override
  Future<List<PopupRuleOR>> listPopupRule() async {
    var list = await remotePorts.portGET(
      screenPorts,
      'listPopupRule',
    );
    var rules = <PopupRuleOR>[];
    for (var obj in list) {
      rules.add(PopupRuleOR.parse(obj));
    }
    return rules;
  }

  @override
  Future<List<ScreenSubjectOR>> pageSubject(int limit, int offset) async {
    var list = await remotePorts.portGET(
      screenPorts,
      'pageSubject',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    var rules = <ScreenSubjectOR>[];
    for (var obj in list) {
      rules.add(ScreenSubjectOR.parse(obj));
    }
    return rules;
  }

  @override
  Future<void> putOnScreen(String subject, String popupRule) async {
    await remotePorts.portGET(
      screenPorts,
      'putOnScreen',
      parameters: {
        'subject': subject,
        'popupRule': popupRule,
      },
    );
  }

  @override
  Future<void> removeSubject(String id) async {
    await remotePorts.portGET(
      screenPorts,
      'removeSubject',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<Function> moveDownSubject(id) async {
    await remotePorts.portGET(
      screenPorts,
      'moveDownSubject',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<Function> moveUpSubject(id) async {
    await remotePorts.portGET(
      screenPorts,
      'moveUpSubject',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<void> clearScreen() async {
    await remotePorts.portGET(
      screenPorts,
      'clearScreen',
      parameters: {},
    );
  }

  @override
  Future<void> updateSubject(String id, String title, String subTitle,
      String leading, String href) async {
    await remotePorts.portPOST(
      screenPorts,
      'updateSubject',
      parameters: {
        'id': id,
        'title': title,
        'subTitle': subTitle,
        'leading': leading,
      },
      data: {
        'href': href,
      },
    );
  }

  @override
  Future<void> updatePopupRuleArgs(String code, String args) async{
    await remotePorts.portPOST(
      screenPorts,
      'updatePopupRuleArgs',
      parameters: {
        'code': code,
      },
      data: {
        'args': args,
      },
    );
  }
}
