import 'dart:convert';

import 'package:framework/framework.dart';

class HelpTypeOR {
  String id;
  String title;

  HelpTypeOR({this.id, this.title});

  HelpTypeOR.parse(obj) {
    id = obj['id'];
    title = obj['title'];
  }
}

class HelpFormOR {
  String id;
  String title;
  String content;
  String typeId;
  String typeTitle;
  List<HelpAttachmentOR> attachments;
  int ctime;
  String creator;

  HelpFormOR({
    this.id,
    this.title,
    this.content,
    this.typeId,
    this.typeTitle,
    this.attachments,
    this.ctime,
    this.creator,
  });

  HelpFormOR.parse(obj) {
    this.id = obj['id'];
    this.title = obj['title'];
    this.content = obj['content'];
    this.typeId = obj['typeId'];
    this.typeTitle = obj['typeTitle'];
    var list = obj['attachments'];
    var attachs = <HelpAttachmentOR>[];
    if (list != null) {
      for (var item in list) {
        attachs.add(
          HelpAttachmentOR.parse(item),
        );
      }
    }
    this.attachments = attachs;
    this.ctime = obj['ctime'];
    this.creator = obj['creator'];
  }
}

class HelpAttachmentOR {
  String text;
  String url;

  HelpAttachmentOR({
    this.text,
    this.url,
  });

  HelpAttachmentOR.parse(obj) {
    this.text = obj['text'];
    this.url = obj['url'];
  }

  toMap() {
    return {
      'text': text,
      'url': url,
    };
  }
}

mixin IHelperRemote {
  Future<List<HelpFormOR>> pageHelpForm(int limit, int offset) {}

  Future<List<HelpTypeOR>> listHelpTypes() {}

  Future<void> createHelpForm(String title, String typeId, String content,
      Iterable<HelpAttachmentOR> attachments);

  Future<bool> isHelpful(String formId) {}

  Future<bool> isHelpless(String formId) {}

  Future<void> setHelpfull(String formId) {}

  Future<void> setHelpless(String formId) {}

  Future<void> removeHelpForm(String id) {}

  Future<HelpFormOR> getHelpForm(String helpId) {}
}

class HelperRemote implements IHelperRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  String get helperPortsUrl => site.getService('@.prop.ports.feedback.helper');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<List<HelpFormOR>> pageHelpForm(int limit, int offset) async {
    var list = await remotePorts.portGET(
      helperPortsUrl,
      'pageHelpForm',
      parameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    List<HelpFormOR> forms = [];
    for (var obj in list) {
      forms.add(HelpFormOR.parse(obj));
    }
    return forms;
  }

  @override
  Future<List<HelpTypeOR>> listHelpTypes() async {
    var list = await remotePorts.portGET(
      helperPortsUrl,
      'listHelpTypes',
      parameters: {},
    );
    List<HelpTypeOR> forms = [];
    for (var obj in list) {
      forms.add(HelpTypeOR.parse(obj));
    }
    return forms;
  }

  @override
  Future<void> createHelpForm(String title, String typeId, String content,
      Iterable<HelpAttachmentOR> attachments) async {
    var list = [];
    if (attachments != null) {
      attachments.forEach((element) {
        list.add(element.toMap());
      });
    }
    await remotePorts.portPOST(
      helperPortsUrl,
      'createHelpForm',
      parameters: {
        'title': title,
        'typeId': typeId,
      },
      data: {
        'content': content,
        'attachments': jsonEncode(list),
      },
    );
  }

  @override
  Future<bool> isHelpful(String helpId) async {
    return await remotePorts.portGET(
      helperPortsUrl,
      'isHelpful',
      parameters: {
        'helpId': helpId,
      },
    );
  }

  @override
  Future<bool> isHelpless(String helpId) async {
    return await remotePorts.portGET(
      helperPortsUrl,
      'isHelpless',
      parameters: {
        'helpId': helpId,
      },
    );
  }

  @override
  Future<void> setHelpfull(String helpId) async {
    await remotePorts.portGET(
      helperPortsUrl,
      'setHelpful',
      parameters: {
        'helpId': helpId,
      },
    );
  }

  @override
  Future<void> setHelpless(String helpId) async {
    await remotePorts.portGET(
      helperPortsUrl,
      'setHelpless',
      parameters: {
        'helpId': helpId,
      },
    );
  }

  @override
  Future<void> removeHelpForm(String id) async {
    await remotePorts.portGET(
      helperPortsUrl,
      'removeHelpForm',
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<HelpFormOR> getHelpForm(String helpId) async {
    var obj=await remotePorts.portGET(
      helperPortsUrl,
      'getHelpForm',
      parameters: {
        'id': helpId,
      },
    );
    if(obj==null) {
      return null;
    }
    return HelpFormOR.parse(obj);
  }
}
