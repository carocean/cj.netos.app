import 'dart:async';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/portals.dart';
import 'package:netos_app/system/local/app_upgrade.dart';
import 'package:netos_app/system/local/migrations/microgeo.dart';
import 'package:netos_app/system/task_bar.dart';
import 'package:open_file/open_file.dart';

import 'system/local/dao/database.dart';
import 'system/system.dart';

final deviceStatus = DeviceStatus(
  state: DeviceNetState.closed,
  unreadCount: 0,
  reconnectTrytimes: 0,
);
final onlineEvent=StreamController.broadcast();

class ProgressTaskBar {
  Function(double percent) _target;

  void update(double percent) {
    if (_target != null) {
      _target(percent);
    }
  }

  set target(Function(double percent) v) {
    _target = v;
  }
}

var _progressTaskBar = ProgressTaskBar();

void main() => platformRun(
      AppCreator(
          title: '地微',
          entrypoint: '/public/entrypoint',
          appKeyPair: AppKeyPair(
            appid: 'system.netos',
            appKey: '995C2A861BE8064A1F8A022B5C0D2E36',
            appSecret: '6EA4774EE78DCDF0768CA18ECF3AD1DB',
          ),
          props: {
            ///默认应用，即终端未指定应用号时登录或注册的目标应用
            '@.prop.entrypoint.app': 'gbera.netos',
            '@.prop.ports.link.chatroom':
                'http://47.105.165.186/link/chatroom/self.service',
            '@.prop.ports.flow.chatroom':
                'http://47.105.165.186/flow/chat.service',
            '@.prop.ports.link.netflow':
                'http://47.105.165.186/link/netflow/self.service',
            '@.prop.ports.link.geosphere':
                'http://47.105.165.186/link/geosphere/self.service',
            '@.prop.ports.uc.auth': 'http://47.105.165.186/uc/auth.service',
            '@.prop.ports.uc.register':
                'http://47.105.165.186/uc/register.service',
            '@.prop.ports.uc.person':
                'http://47.105.165.186/uc/person/self.service',
            '@.prop.ports.uc.app': 'http://47.105.165.186/uc/app/self.service',
            '@.prop.ports.uc.platform':
                'http://47.105.165.186/uc/platform/self.service',
            '@.prop.ports.uc.product': 'http://47.105.165.186/uc/product.ports',
            '@.prop.ports.asc': 'http://47.105.165.186/asc/center.ports',
            '@.prop.fs.delfile': 'http://47.105.165.186:7110/del/file/',
            '@.prop.fs.uploader':
                'http://47.105.165.186:7110/upload/uploader.service',
            '@.prop.fs.reader': 'http://47.105.165.186:7100',
            '@.prop.ports.document.network.channel':
                'http://47.105.165.186/document/network/channel.service',
            '@.prop.ports.flow.channel':
                'http://47.105.165.186/flow/channel.service',
            '@.prop.ports.flow.geosphere':
                'http://47.105.165.186/flow/geosphere.service',
            '@.prop.taskbar.progress': _progressTaskBar,
            '@.prop.ports.document.geo.category':
                'http://47.105.165.186/document/geo/category.service',
            '@.prop.ports.document.geo.receptor':
                'http://47.105.165.186/document/geo/receptor.service',
            '@.prop.ports.wallet': 'http://47.105.165.186/wallet/wallet.ports',
            '@.prop.ports.wallet.payChannel':
                'http://47.105.165.186/wallet/partner/payChannel.ports',
            '@.prop.ports.wallet.channelBill':
                'http://47.105.165.186/wallet/partner/channel/bill.ports',
            '@.prop.ports.wallet.balance':
                'http://47.105.165.186/wallet/balance.ports',
            '@.prop.ports.wallet.record':
                'http://47.105.165.186/wallet/record.ports',
            '@.prop.ports.wallet.trade.receipt':
                'http://47.105.165.186/wallet/trade/receipt.ports',
            '@.prop.ports.wallet.bill.stock':
                'http://47.105.165.186/wallet/bill/stock.ports',
            '@.prop.ports.wallet.bill.freezen':
                'http://47.105.165.186/wallet/bill/freezen.ports',
            '@.prop.ports.wallet.bill.profit':
                'http://47.105.165.186/wallet/bill/profit.ports',
            '@.prop.ports.wallet.bill.balance':
                'http://47.105.165.186/wallet/bill/balance.ports',
            '@.prop.ports.wallet.bill.onorder':
                'http://47.105.165.186/wallet/bill/onorder.ports',
            '@.prop.ports.wallet.bill.absorb':
                'http://47.105.165.186/wallet/bill/absorb.ports',
            '@.prop.ports.wallet.bill.trial':
                'http://47.105.165.186/wallet/bill/trial.ports',
            '@.prop.ports.wybank': 'http://47.105.165.186/wybank/bank.ports',
            '@.prop.ports.wybank.balance':
                'http://47.105.165.186/wybank/balance.ports',
            '@.prop.ports.wybank.bill.price':
                'http://47.105.165.186/wybank/bill/price.ports',
            '@.prop.ports.wybank.bill.fund':
                'http://47.105.165.186/wybank/bill/fund.ports',
            '@.prop.ports.wybank.bill.stock':
                'http://47.105.165.186/wybank/bill/stock.ports',
            '@.prop.ports.wybank.bill.freezen':
                'http://47.105.165.186/wybank/bill/freezen.ports',
            '@.prop.ports.wybank.bill.free':
                'http://47.105.165.186/wybank/bill/free.ports',
            '@.prop.ports.wybank.bill.shunt':
                'http://47.105.165.186/wybank/bill/shunt.ports',
            '@.prop.ports.wybank.records':
                'http://47.105.165.186/wybank/record.ports',
            '@.prop.ports.org.isp': 'http://47.105.165.186/org/isp.ports',
            '@.prop.ports.org.la': 'http://47.105.165.186/org/la.ports',
            '@.prop.ports.org.licence':
                'http://47.105.165.186/org/licence.ports',
            '@.prop.ports.org.workflow':
                'http://47.105.165.186/org/workflow.ports',
            '@.prop.org.workflow.isp': 'workflow.isp.apply', //isp申请的工作流标识
            '@.prop.org.workflow.la': 'workflow.la.apply', //isp申请的工作流标识
            '@.prop.ports.org.receivingBank':
                'http://47.105.165.186/org/receivingBank.ports',
            '@.prop.ports.robot.hub': 'http://47.105.165.186/robot/hub.ports',
            '@.prop.ports.robot.record':
                'http://47.105.165.186/robot/record.ports',
            '@.prop.ports.robot.hubTails':
                'http://47.105.165.186/robot/bill/hubTails.ports',
            '@.prop.ports.chasechain.recommender':
                'http://47.105.165.186/chasechain.recommender/recommender.ports',
            '@.prop.ports.chasechain.trafficPool':
                'http://47.105.165.186/chasechain.recommender/trafficPool.ports',
            '@.prop.ports.feedback.helper':
                'http://47.105.165.186/feedback/helper.ports',
            '@.prop.ports.feedback.tipoff':
                'http://47.105.165.186/feedback/tipoff.ports',
            '@.prop.ports.feedback.woflow':
                'http://47.105.165.186/feedback/wo/flow.ports',
            '@.prop.ports.feedback.tiptool':
                'http://47.105.165.186/feedback/tiptool.ports',
          },
          buildServices: (site) async {
            await enableFluttifyLog(false); // 关闭amaplog
            /// !注意: 只要是返回Future的方法, 一律使用`await`修饰, 确保当前方法执行完成后再执行下一行, 在不能使用`await`修饰的环境下, 在`then`方法中执行下一步.
            /// 初始化 iOS在init方法中设置, android需要去AndroidManifest.xml里去设置, 详见 https://lbs.amap.com/api/android-sdk/gettingstarted
            if (Platform.isIOS) {
              try {
                await AmapLocation.instance.init(iosKey: 'd01465eb6d15b8df1ee56e5df1f6e1f6');
                await requestPermission();
              } catch (e) {
                print('amap on main error: $e');
              }
            } else {
              try {
                await AmapLocation.instance.init();
              } catch (e) {
                print('amap on main error: $e');
              }
            }
            final callback = Callback(
              onCreate: (database, version) {
                /* database has been created */
                print('--------database onCreate $version');
              },
              onOpen: (database) {
                /* database has been opened */
                print('--------database onOpen}');
              },
              onUpgrade: (database, startVersion, endVersion) {
                print('--------database onUpgrade $startVersion $endVersion');
                /* database has been upgraded */
              },
            );
            final database = await $FloorAppDatabase
                .databaseBuilder('app_database.db')
                .addCallback(callback)
                .addMigrations(migrationsMicrogeo)
                .build();
            return <String, dynamic>{
              '@.db': database,
            };
          },
          buildSystem: buildSystem,
          buildPortals: buildPortals,
          localPrincipal: DefaultLocalPrincipal(),
          messageNetwork: 'interactive-center',
          deviceOnmessageCount: (count) {
            deviceStatus.unreadCount = count;
            deviceStatus.state = DeviceNetState.online;
            if (deviceStatus.refresh != null) {
              deviceStatus.refresh();
            }
          },
          deviceOnopen: (connection) {
            deviceStatus.state = DeviceNetState.opened;
            if (deviceStatus.refresh != null) {
              deviceStatus.refresh();
            }
          },
          deviceOnclose: () {
            deviceStatus.state = DeviceNetState.closed;
            if (deviceStatus.refresh != null) {
              deviceStatus.refresh();
            }
          },
          deviceOnline: () {
            deviceStatus.state = DeviceNetState.online;
            onlineEvent.add("online");
            if (deviceStatus.refresh != null) {
              deviceStatus.refresh();
            }
          },
          deviceOffline: () {
            deviceStatus.state = DeviceNetState.offline;
            onlineEvent.add("offline");
            if (deviceStatus.refresh != null) {
              deviceStatus.refresh();
            }
          },
          deviceOnreconnect: (trytimes) {
            deviceStatus.state = DeviceNetState.reconnecting;
            deviceStatus.reconnectTrytimes = trytimes;
            if (deviceStatus.refresh != null) {
              deviceStatus.refresh();
            }
          },

          ///以下可装饰窗口区，比如在device连接状态改变时提醒用户
          appDecorator: (ctx, viewport, site) {
            return Window(
              viewport: viewport,
              site: site,
            );
          }),
    );

class Window extends StatefulWidget {
  Widget viewport;
  IServiceProvider site;

  Window({this.viewport, this.site});

  @override
  _WindowState createState() => _WindowState();
}

class _WindowState extends State<Window> {
  UpgradeInfo _upgradeInfo;
  double _progressValue = 0.0;
  int _isInstalling = 0; //1下戴中；2正在安装；
  @override
  void initState() {
    () async {
      IAppUpgrade appUpgrade = widget.site.getService('/app/upgrade');
      _upgradeInfo = await appUpgrade.loadUpgradeInfo();
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _installApp() async {
    if (Platform.isIOS) {
      // await InstallPlugin.gotoAppStore(_upgradeInfo.newestVersionDownloadUrl);
      return;
    }
    if (mounted) {
      setState(() {
        _isInstalling = 1;
      });
    }
    IAppUpgrade appUpgrade = widget.site.getService('/app/upgrade');
    appUpgrade.downloadApp((i, j, f) async {
      if (mounted) {
        setState(() {
          _progressValue = (i * 1.0) / j;
        });
      }
      if (i == j) {
        //完成下载
        if (mounted) {
          _isInstalling = 2;
        }
        await OpenFile.installApk(f);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[
      widget.viewport,
      Positioned(
        // top: Platform.isAndroid ? 6 : 14,
        // left: Platform.isAndroid ? 90 : 30,
        // right: 0,
        bottom: 10,
        left: -4,
        child: StatusBar(),
      ),
      Positioned(
        // top: Platform.isAndroid ? 23 : 31,
        // left: Platform.isAndroid ? 90 : 30,
        height: 1,
        width: 30,
        left: 0,
        bottom: 30,
        child: TaskBar(widget.site, _progressTaskBar),
      ),
    ];
    if (_upgradeInfo != null &&
        !_upgradeInfo.isHide &&
        _upgradeInfo.canUpgrade) {
      items.add(Scaffold(
        backgroundColor: Color(0xdd8E8E8E),
        body: Container(
          constraints: BoxConstraints.expand(),
          padding: EdgeInsets.only(
            left: 40,
            right: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                ),
                padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 15,
                  bottom: 10,
                ),
                child: Text(
                  '检测到新版本 ${_upgradeInfo.currentVersion}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 1,
                child: LinearProgressIndicator(
                  value: _progressValue,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _renderFunctionList(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _renderButtons(),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return Stack(
      fit: StackFit.loose,
      children: items,
    );
  }

  _renderFunctionList() {
    var items = <Widget>[];
    var functionList = _upgradeInfo?.productVersion?.functionList ?? [];
    for (var i = 0; i < functionList.length; i++) {
      var f = functionList[i];
      if (StringUtil.isEmpty(f)) {
        continue;
      }
      items.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '*',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                '$f',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
      if (i < functionList.length - 1) {
        items.add(
          SizedBox(
            height: 10,
          ),
        );
      }
    }
    return items;
  }

  _renderButtons() {
    var items = <Widget>[];
    var forceUpgrade = _upgradeInfo.productVersion?.forceUpgrade ?? 0;
    if (forceUpgrade == 0) {
      items.add(
        Expanded(
          child: RaisedButton(
            color: Colors.grey,
            textColor: Colors.white,
            onPressed: () {
              _upgradeInfo.isHide = true;
              if (mounted) {
                setState(() {});
              }
            },
            child: Text('下次再说'),
          ),
        ),
      );
      items.add(
        SizedBox(
          width: 10,
        ),
      );
    }
    items.add(
      Expanded(
        child: RaisedButton(
          color: _isInstalling == 0 ? Colors.green : Colors.grey,
          textColor: Colors.white,
          onPressed: _isInstalling > 0
              ? null
              : () {
                  _installApp();
                },
          child: Text('${_rendProgressTips()}'),
        ),
      ),
    );
    return items;
  }

  _rendProgressTips() {
    if (_isInstalling == 0) {
      return '立即升级';
    }
    if (_isInstalling == 1) {
      return '下载中... ${(_progressValue * 100).toStringAsFixed(2)}%';
    }
    if (_isInstalling == 2) {
      return '正在安装...';
    }
  }
}

class StatusBar extends StatefulWidget {
  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  @override
  void initState() {
    super.initState();
    deviceStatus.refresh = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    deviceStatus.refresh = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stateText = '';
    switch (deviceStatus.state) {
      case DeviceNetState.offline:
      case DeviceNetState.opened:
        stateText = '离线';
        break;
      case DeviceNetState.online:
        stateText = '在线';
        break;
      case DeviceNetState.closed:
        stateText = '未连接';
        break;
      case DeviceNetState.reconnecting:
        stateText = '重试${deviceStatus.reconnectTrytimes}次';
        break;
    }
    if (deviceStatus.state == DeviceNetState.online && deviceStatus.unreadCount < 1) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Container(
      alignment: Alignment.topLeft,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 2,
            ),
            child: Image.asset(
              'lib/portals/gbera/images/gbera_op.png',
              width: 16,
              height: 16,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    Icons.mark_chat_unread_outlined,
                    size: 7,
                  ),
                  SizedBox(
                    width: 1,
                  ),
                  Text(
                    '${deviceStatus.unreadCount}',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.black54,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Text(
                stateText,
                style: TextStyle(
                  fontSize: 6,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum DeviceNetState {
  opened,
  online,
  offline,
  closed,
  reconnecting,
}

class DeviceStatus {
  DeviceNetState state;
  int unreadCount = 0;

  int reconnectTrytimes;
  Function() refresh;

  DeviceStatus({
    this.state,
    this.unreadCount,
    this.reconnectTrytimes,
    this.refresh,
  });
}

class DefaultLocalPrincipal implements ILocalPrincipal {
  ILocalPrincipalVisitor _visitor;

  @override
  String current() {
    return _visitor?.current();
  }

  @override
  IPrincipal get(String person) {
    return _visitor?.get(person);
  }

  @override
  void setVisitor(ILocalPrincipalVisitor visitor) {
    this._visitor = visitor;
  }
}
