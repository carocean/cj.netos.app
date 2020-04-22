import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_shared_preferences.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

SyncTaskMananger syncTaskMananger = SyncTaskMananger(
  tasks: <String, SyncTask>{},
);

class SyncTaskMananger {
  Map<String, SyncTask> tasks;

  SyncTaskMananger({this.tasks});
}

class SyncTask {
  Future<void> Function(PageContext context, Frame frame) doTask;

  SyncTask({this.doTask});

  Future<void> run({
    ///不能为空
    String syncName,
    PageContext context,
    bool forceSync = false,

    ///返回null表示不需要同步
    Future<SyncArgs> Function(PageContext context) checkRemote,
  }) async {
    //检测本地属性，判断是否是第一次安装app，如果是则同步
    ISharedPreferences sharedPreferences =
        context.site.getService('@.sharedPreferences');
    var issync = sharedPreferences.getString('/system/${syncName??''}/issync',person: context.principal.person);
    if ('true' == issync && !forceSync) {
      return;
    }
    await sharedPreferences.setString('/system/${syncName??''}/issync', 'true',person: context.principal.person);
    var args = await checkRemote(context);
    if (args == null) {
      return;
    }
    var portTask = context.ports.portTask;
    var listenPath = '/${MD5Util.MD5(Uuid().v1())}';
    if (this.doTask != null) {
      portTask.listener(listenPath, (Frame frame) {
        var subcmd = frame.head('sub-command');
        switch (subcmd) {
          case 'begin':
            break;
          case 'error':
            print(frame.toText());
            break;
          case 'done':
            doTask(context, frame).then((v) {
              portTask.unlistener(listenPath);
            });
            break;
        }
      });
    }
    var cburl;
    if (StringUtil.isEmpty(args.callbackQueryString)) {
      cburl = listenPath;
    } else {
      cburl = '$listenPath?${args.callbackQueryString}';
    }
    if (args.httpMethod == 'post') {
      portTask.addPortPOSTTask(
        args.portsUrl,
        args.restCmd,
        parameters: args.parameters,
        callbackUrl: cburl,
        headers: args.headers,
        tokenName: args.tokenName,
      );
    } else {
      portTask.addPortGETTask(
        args.portsUrl,
        args.restCmd,
        parameters: args.parameters,
        callbackUrl: cburl,
        headers: args.headers,
        tokenName: args.tokenName,
      );
    }
  }
}

class SyncArgs {
  String portsUrl;
  String restCmd;
  String httpMethod;
  Map<String, dynamic> parameters;
  Map<String, dynamic> headers;
  String tokenName;
  String callbackQueryString;

  SyncArgs({
    this.portsUrl,
    this.restCmd,
    this.httpMethod = 'get',
    this.parameters,
    this.headers,
    this.tokenName = 'cjtoken',
    this.callbackQueryString,
  });
}
