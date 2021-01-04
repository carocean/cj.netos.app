import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:intl/intl.dart' as intl;
Header easyRefreshHeader()=> ClassicalHeader(
  infoText: '${intl.DateFormat('mm:ss').format(DateTime.now())}',
  noMoreText: '没有了',
  refreshedText: '拉取完成',
  refreshingText: '正在拉取',
  refreshReadyText: '准备拉取',
  refreshText: '拉取',
);
Footer easyRefreshFooter()=> ClassicalFooter(
  noMoreText: '没有了',
  infoText: '${intl.DateFormat('mm:ss').format(DateTime.now())}',
  loadingText: '正在加载...',
  loadedText: '加载完成',
  loadReadyText: '准备加载',
);