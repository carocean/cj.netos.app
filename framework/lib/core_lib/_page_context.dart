import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_notifications.dart';
import 'package:uuid/uuid.dart';

import '_desklet.dart';
import '_exceptions.dart';
import '_page.dart';
import '_principal.dart';
import '_scene.dart';
import '_shared_preferences.dart';
import '_theme.dart';
import '_utimate.dart';

class PageContext {
  final Page page;
  final IServiceProvider site;
  final BuildContext context;
  final String sourceScene;
  final String sourceTheme;

  const PageContext(
      {this.page, this.sourceScene, this.sourceTheme, this.site, this.context});

  UserPrincipal get principal => site.getService('@.principal');

  ///真实传过来的参数
  get parameters => ModalRoute.of(context).settings.arguments;

  ///真实传入的地址，特别是在part页中见到的地址实际上是其主页地址，而page才是part页
  String get url => ModalRoute.of(context).settings.name;

  ///存储器
  ISharedPreferences sharedPreferences() {
    return site.getService('@.sharedPreferences');
  }

  ///当前场景，可能是框架id，也可能是系统场景名
  String currentScene() {
    return site.getService("@.scene.current")?.name;
  }

  ///当前主题url，为相对于框架的地址
  String currentTheme() {
    return site.getService("@.scene.current")?.theme;
  }

  style(String path) {
    if (!path.startsWith("/")) {
      throw FlutterError('路径没有以/开头');
    }
    Style styleDef = site.getService("@.style:$path");
    var style = styleDef?.get();
    if (style == null) {
      throw FlutterError('样式未被发现:$path，在主题:${currentTheme()}');
    }
    return style;
  }

  Desklet desklet(String deskletUrl) {
    String path = deskletUrl;
    int pos = path.lastIndexOf('?');
    if (pos > -1) {
      path = path.substring(0, pos);
    }
    return site.getService("@.desklet:$path");
  }

  ///部件作为页面的界面元素被嵌入，因此不支持页面跳转动画，因为它在调用时不被作为路由页。
  Widget part(String pageUrl, BuildContext context,
      {Map<String, Object> arguments}) {

    String path = pageUrl;
    int pos = path.lastIndexOf('?');
    if (pos > 0) {
      String qs = path.substring(pos + 1, path.length);
      path = path.substring(0, pos);
      if (arguments == null) {
        arguments = Map();
      }
      _parseQureystringAndFillParams(qs, arguments);
    }
    Page page = site.getService("@.page:$path");
    if (page == null) return null;
    if (page.buildPage == null) {
      return null;
    }
    if (arguments != null) {
      page.parameters.addAll(arguments);
    }
    PageContext pageContext2 = PageContext(
      page: page,
      site: site,
      context: context,
      sourceTheme: currentTheme(),
      sourceScene: currentScene(),
    );
    Widget widget = page.buildPage(pageContext2);
    return widget;
  }

  _parseQureystringAndFillParams(qs, arguments) {
    while (qs.startsWith(' ')) {
      qs = qs.substring(1, qs.length);
    }
    if (StringUtil.isEmpty(qs)) {
      return;
    }
    int pos = qs.indexOf("&");
    String kv = '';
    if (pos < 0) {
      kv = qs;
      qs = '';
    } else {
      kv = qs.substring(0, pos);
      qs = qs.substring(pos + 1, qs.length);
    }
    pos = kv.indexOf('=');
    String k = '';
    String v = '';
    if (pos < 0) {
      k = kv;
      v = '';
    } else {
      k = kv.substring(0, pos);
      v = kv.substring(pos + 1, kv.length);
    }
    arguments[k] = v;
    if (!StringUtil.isEmpty(qs)) {
      _parseQureystringAndFillParams(qs, arguments);
    }
  }

  Future<void> ports(
    ///请求头，格式，如：get http://localhost:8080/uc/p1.service?name=cj&age=33 http/1.1
    String headline, {

    ///远程服务的方法名
    String restCommand,
    Map<String, String> headers,
    Map<String, String> parameters,
    Map<String, Object> content,
    void Function({dynamic rc, Response response}) onsucceed,
    void Function({dynamic e, dynamic stack}) onerror,
    void Function(int, int) onReceiveProgress,
    void Function(int, int) onSendProgress,
  }) async {
    String cmd = '';
    String uri = '';
    String protocol = '';
    String hl = headline;
    while (hl.startsWith(" ")) {
      hl = hl.substring(1, hl.length);
    }
    int pos = hl.indexOf(" ");
    if (pos < 0) {
      throw FlutterError(
          '请求行格式错误，缺少uri和protocol，错误请求行为：$hl,合法格式应为：get|post uri http/1.1');
    }
    cmd = hl.substring(0, pos);
    hl = hl.substring(pos + 1, hl.length);
    while (hl.startsWith(" ")) {
      hl = hl.substring(1, hl.length);
    }
    pos = hl.indexOf(" ");
    if (pos < 0) {
      throw FlutterError(
          '请求行格式错误，缺少protocol，错误请求行为：$hl,合法格式应为：get|post uri http/1.1');
    }
    uri = hl.substring(0, pos);
    if (uri.indexOf("://") < 0) {
      throw FlutterError('不是正确的请求地址：${hl},合法格式应为：https://sss/ss/ss?ss=ss');
    }
    hl = hl.substring(pos + 1, hl.length);
    while (hl.startsWith(" ")) {
      hl = hl.substring(1, hl.length);
    }
    while (hl.endsWith(" ")) {
      hl = hl.substring(0, hl.length - 1);
    }
    if (StringUtil.isEmpty(hl)) {
      throw FlutterError('请求行缺少协议:$hl');
    }
    protocol = hl;

    Dio _dio = site.getService("@.http");
    //dio会自动将头转换为小写
    Options options = Options(
      headers: headers,
    );
    options.headers['Rest-Command'] = restCommand;
    cmd = cmd.toUpperCase();
    switch (cmd) {
      case 'GET':
        try {
          var response = await _dio.get(
            uri,
            queryParameters: parameters,
            onReceiveProgress: onReceiveProgress,
            options: options,
          );
          var data = response.data;
          Map<String, Object> rc = jsonDecode(data);
          int status = rc['status'];
          if ((status >= 200 && status < 300) || status == 304) {
            if (onsucceed != null) {
              onsucceed(rc: rc, response: response);
            }
          } else {
            if (onerror != null) {
              onerror(
                  e: OpenportsException(
                    state: status,
                    message: rc['message'],
                    cause: rc['dataText'],
                  ),
                  stack: null);
            }
          }
        } on DioError catch (e, stack) {
          if (e.response != null) {
            // Something happened in setting up or sending the request that triggered an Error
            if (onerror != null) {
              onerror(e: e, stack: stack);
              return;
            }
            FlutterErrorDetails details =
                FlutterErrorDetails(exception: e, stack: stack);
            FlutterError.reportError(details);
            return;
          }
          throw FlutterError(e.error);
        }
        break;
      case 'POST':
        options.headers['Content-Type'] =
            'application/x-www-form-urlencoded; charset=UTF-8';
        try {
          var response = await _dio.post(
            uri,
            data: content ?? json.encode(content),
            queryParameters: parameters,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            options: options,
          );
          var data = response.data;
          Map<String, Object> rc = jsonDecode(data);
          int status = rc['status'];
          if ((status >= 200 && status < 300) || status == 304) {
            if (onsucceed != null) {
              var dataText = jsonDecode(rc['dataText']);
              onsucceed(rc: rc, response: response);
            }
          } else {
            if (onerror != null) {
              onerror(
                  e: OpenportsException(
                    state: status,
                    message: rc['message'],
                    cause: rc['dataText'],
                  ),
                  stack: null);
            }
          }
        } on DioError catch (e, stack) {
          if (e.response != null) {
            // Something happened in setting up or sending the request that triggered an Error
            if (onerror != null) {
              onerror(e: e, stack: stack);
              return;
            }
            FlutterErrorDetails details =
                FlutterErrorDetails(exception: e, stack: stack);
            FlutterError.reportError(details);
            return;
          }
          throw FlutterError(e.error);
        }
        break;
      default:
        throw FlutterErrorDetails(exception: Exception('不支持的命令:$cmd'));
    }
  }

  Page findPage(String url) {
    String path = url;
    int pos = path.lastIndexOf('?');
    if (pos > -1) {
      path = path.substring(0, pos);
    }
    return site.getService("@.page:$path");
  }

  ///@clearHistoryPageUrl 清除历史路由页，按路径前缀来匹配，如果是/表示清除所有历史
  ///                     注意：如果该参数非空将不能传递result参数给前页
  ///@result 放入返回给前页的结果
  bool backward({
    String clearHistoryPageUrl,
    result,
  }) {
    NavigatorState state = Navigator.of(context);
    if (!state.canPop()) {
      return false;
    }
    if (StringUtil.isEmpty(clearHistoryPageUrl)) {
      return state.pop(result);
    }
    state.popUntil(_checkHistoryRoute(clearHistoryPageUrl));
    return true;
  }

  Future<T> forward<T extends Object>(
    String pageUrl, {
    Map<String, Object> arguments,
    ///如果为空在当前切景下跳转，如果要跳转的地址是其它框架的，则为框架id，输入/表示跳到系统场景
    String scene,

    ///当参数scene不为空时可以使用该参数以接受跳转的返回值。在场景切换完成时回调,参数为回调结果
    Function(T) onFinishedSwitchScene,
    String clearHistoryByPagePath,
  }) {
    var pagePath = pageUrl;
    int pos = pagePath.lastIndexOf('?');
    if (pos > -1) {
      pagePath = pagePath.substring(0, pos);
      var qs = pageUrl.substring(pos + 1);
      if (arguments == null) {
        arguments = <String, Object>{};
      }
      _parseQureystringAndFillParams(qs, arguments);
    }

    if (StringUtil.isEmpty(scene)) {
      return _forward(pagePath,
          arguments: arguments, clearHistoryByPagePath: clearHistoryByPagePath);
    }
    SwitchSceneNotification(
        scene: scene,
        pageUrl: pagePath,
        onfinished: ()async {
          _forward(pagePath,
              arguments: arguments,
              clearHistoryByPagePath: clearHistoryByPagePath)
              .then((result) {
            if (onFinishedSwitchScene != null) {
              onFinishedSwitchScene(result);
            }
          });
        }).dispatch(context);
  }

  Future<T> _forward<T extends Object>(
    String pagePath, {
    Map<String, Object> arguments,
    String clearHistoryByPagePath,
  }) {
    if (arguments == null) {
      arguments = Map();
    }
    if (!StringUtil.isEmpty(clearHistoryByPagePath)) {
      return Navigator.of(context).pushNamedAndRemoveUntil(
        pagePath,
        _checkHistoryRoute(clearHistoryByPagePath),
        arguments: arguments,
      );
    }
    return Navigator.pushNamed(
      context,
      pagePath,
      arguments: arguments,
    );
  }

  void switchTheme(String url) {
    SwitchThemeNotification(theme: url).dispatch(context);
  }

  RoutePredicate _checkHistoryRoute(String url) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally &&
          route is ModalRoute &&
          _checkUrl(route, url);
    };
  }

  bool _checkUrl(ModalRoute route, String url) {
    String name = route.settings.name;
    if (StringUtil.isEmpty(name)) {
      return false;
    }
    return !name.startsWith(url);
  }

  ///下载文件
  Future<void> download(
    String url,
    String localFile, {
    void Function(int, int) onReceiveProgress,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options options,
  }) async {
    Dio dio = site.getService('@.http');
    await dio.download(
      url,
      localFile,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      data: data,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  Future<void> deleteRemoteFile(
    String file,
  ) async {
    Dio dio = site.getService('@.http');
    var response = await dio.get(
      site.getService('@.prop.fs.delfile'),
      options: Options(
          //上传的accessToken在header中，为了兼容在参数里也放
//        headers: {
//          "Cookie": 'accessToken=$accessToken',
//        },
          ),
      queryParameters: {'path': file, 'type': 'f'},
    );
    if (response.statusCode > 400) {
      throw FlutterError(
          '删除失败：${response.statusCode} ${response.statusMessage}');
    }
  }

  Future<Map<String, String>> upload(String remoteDir, List<String> localFiles,
      {String accessToken,
      void Function(int, int) onReceiveProgress,
      void Function(int, int) onSendProgress}) async {
    if (localFiles == null || localFiles.isEmpty) {
      return null;
    }
    Dio dio = site.getService('@.http');

    var files = <MultipartFile>[];
    var remoteFiles = <String, String>{};
    for (var i = 0; i < localFiles.length; i++) {
      var f = localFiles[i];
      int pos = f.lastIndexOf('.');
      var ext = '';
      var prev = '';
      if (pos > -1) {
        ext = f.substring(pos + 1, f.length);
        prev = f.substring(0, pos);
      } else {
        prev = f;
      }
      prev = prev.substring(prev.lastIndexOf('/') + 1, prev.length);
      String fn = "${Uuid().v1()}_$prev.$ext";
      remoteFiles[f] = '${site.getService('@.prop.fs.reader')}$remoteDir/$fn';
      print(remoteFiles[f]);
      files.add(await MultipartFile.fromFile(
        f,
        filename: fn,
      ));
    }
    FormData data = FormData.fromMap({
      'files': files,
    });
    var response = await dio.post(
      site.getService('@.prop.fs.uploader'),
      data: data,
      options: Options(
        //上传的accessToken在header中，为了兼容在参数里也放
        headers: {
          "Cookie": 'accessToken=$accessToken',
        },
      ),
      queryParameters: {
        'accessToken': accessToken,
        'dir': remoteDir,
      },
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
    if (response.statusCode > 400) {
      throw FlutterError(
          '上传失败：${response.statusCode} ${response.statusMessage}');
    }
    return remoteFiles;
  }
}
