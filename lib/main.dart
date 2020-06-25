import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/portals.dart';
import 'package:netos_app/system/task_bar.dart';

import 'system/local/dao/database.dart';
import 'system/system.dart';

final _peerStatus = _PeerStatus(
  state: _State.closed,
  unreadCount: 0,
  reconnectTrytimes: 0,
);

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
            '@.prop.ports.nameserver':
                'http://47.105.165.186/ns/nameports.service',
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
            '@.prop.ports.wallet':'http://47.105.165.186/wallet/wallet.ports',
            '@.prop.ports.wallet.balance':'http://47.105.165.186/wallet/balance.ports',
            '@.prop.ports.wallet.record':'http://47.105.165.186/wallet/record.ports',
            '@.prop.ports.wallet.trade.receipt':'http://47.105.165.186/wallet/trade/receipt.ports',
            '@.prop.ports.wallet.bill.stock':'http://47.105.165.186/wallet/bill/stock.ports',
            '@.prop.ports.wallet.bill.freezen':'http://47.105.165.186/wallet/bill/freezen.ports',
            '@.prop.ports.wallet.bill.profit':'http://47.105.165.186/wallet/bill/profit.ports',
            '@.prop.ports.wallet.bill.balance':'http://47.105.165.186/wallet/bill/balance.ports',
            '@.prop.ports.wallet.bill.onorder':'http://47.105.165.186/wallet/bill/onorder.ports',
            '@.prop.ports.wallet.bill.absorb':'http://47.105.165.186/wallet/bill/absorb.ports',
            '@.prop.ports.wybank':'http://47.105.165.186/wybank/bank.ports',
            '@.prop.ports.wybank.balance':'http://47.105.165.186/wybank/balance.ports',
            '@.prop.ports.wybank.bill.price':'http://47.105.165.186/wybank/bill/price.ports',
            '@.prop.ports.wybank.bill.fund':'http://47.105.165.186/wybank/bill/fund.ports',
            '@.prop.ports.wybank.records':'http://47.105.165.186/wybank/record.ports',
            '@.prop.ports.org.isp':'http://47.105.165.186/org/isp.ports',
            '@.prop.ports.org.la':'http://47.105.165.186/org/la.ports',
            '@.prop.ports.org.licence':'http://47.105.165.186/org/licence.ports',
            '@.prop.ports.org.workflow':'http://47.105.165.186/org/workflow.ports',
            '@.prop.org.workflow.isp':'workflow.isp.apply',//isp申请的工作流标识
            '@.prop.org.workflow.la':'workflow.la.apply',//isp申请的工作流标识
            '@.prop.ports.org.receivingBank':'http://47.105.165.186/org/receivingBank.ports',
          },
          buildServices: (site) async {
            final database = await $FloorAppDatabase
                .databaseBuilder('app_database.db')
                .build();
            return <String, dynamic>{
              '@.db': database,
            };
          },
          buildSystem: buildSystem,
          buildPortals: buildPortals,
          localPrincipal: DefaultLocalPrincipal(),
          messageNetwork: 'interactive-center',
          peerOnmessageCount: (count) {
            _peerStatus.unreadCount = count;
            _peerStatus.state = _State.online;
            if (_peerStatus.refresh != null) {
              _peerStatus.refresh();
            }
          },
          peerOnopen: () {
            _peerStatus.state = _State.opened;
            if (_peerStatus.refresh != null) {
              _peerStatus.refresh();
            }
          },
          peerOnclose: () {
            _peerStatus.state = _State.closed;
            if (_peerStatus.refresh != null) {
              _peerStatus.refresh();
            }
          },
          peerOnline: () {
            _peerStatus.state = _State.online;
            if (_peerStatus.refresh != null) {
              _peerStatus.refresh();
            }
          },
          peerOnreconnect: (trytimes) {
            _peerStatus.state = _State.reconnecting;
            _peerStatus.reconnectTrytimes = trytimes;
            if (_peerStatus.refresh != null) {
              _peerStatus.refresh();
            }
          },

          ///以下可装饰窗口区，比如在peer连接状态改变时提醒用户
          appDecorator: (ctx, viewport, site) {
            return Window(
              viewport: viewport,
              site: site,
            );
          }),
    );

class Window extends StatelessWidget {
  Widget viewport;
  IServiceProvider site;

  Window({this.viewport, this.site});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        this.viewport,
        Positioned(
          top: Platform.isAndroid ? 6 : 14,
          left: Platform.isAndroid ? 90 : 30,
          right: 0,
          child: StatusBar(),
        ),
        Positioned(
          top: Platform.isAndroid ? 23 : 31,
          left: Platform.isAndroid ? 90 : 30,
          height: 1,
          width: 30,
          child: TaskBar(site, _progressTaskBar),
        ),
      ],
    );
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
    _peerStatus.refresh = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    _peerStatus.refresh = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stateText = '';
    switch (_peerStatus.state) {
      case _State.opened:
        stateText = '离线';
        break;
      case _State.online:
        stateText = '在线';
        break;
      case _State.closed:
        stateText = '未连接';
        break;
      case _State.reconnecting:
        stateText = '重试${_peerStatus.reconnectTrytimes}次';
        break;
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
              Text(
                '${_peerStatus.unreadCount}',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
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

enum _State {
  opened,
  online,
  closed,
  reconnecting,
}

class _PeerStatus {
  _State state;
  int unreadCount = 0;

  int reconnectTrytimes;
  Function() refresh;

  _PeerStatus({
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
