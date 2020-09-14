import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;

class AbsorberRecipientsViewPage extends StatefulWidget {
  PageContext context;

  AbsorberRecipientsViewPage({this.context});

  @override
  _AbsorberRecipientsViewPageState createState() =>
      _AbsorberRecipientsViewPageState();
}

class _AbsorberRecipientsViewPageState
    extends State<AbsorberRecipientsViewPage> {
  AbsorberResultOR _absorberResultOR;
  RecipientsOR _recipientsOR;

  @override
  void initState() {
    _absorberResultOR = widget.context.parameters['absorber'];
    _recipientsOR = widget.context.parameters['recipients'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {}

  Future<double> _totalRecipientsRecordWhere(String recipientsId) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.totalRecipientsRecordWhere(_absorberResultOR.absorber.id,recipientsId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _renderHeaderCard(),
          SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder<double>(
                future: _totalRecipientsRecordWhere(_recipientsOR.id),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Text(
                      '-',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    );
                  }
                  var v = snapshot.data;
                  if (v == null) {
                    v = 0.00;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '共获得洇金',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        '¥${(v / 100.00).toStringAsFixed(14)}',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Text(
                '激励原因: ${_recipientsOR.encourageCause ?? ''}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,

          ),
          Expanded(
            child: _renderRecords(),
          ),
        ],
      ),
    );
  }

  Widget _renderHeaderCard() {
    return Container(
//      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 10,
        bottom: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Person>(
            future: _getPerson(widget.context.site, _recipientsOR.person),
            builder: (ctx, snapshot) {
              double size = 60;
              if (snapshot.connectionState != ConnectionState.done) {
                return Image.asset(
                  'lib/portals/gbera/images/default_watting.gif',
                  width: size,
                  height: size,
                );
              }
              var person = snapshot.data;
              var avatar = person.avatar;
              if (StringUtil.isEmpty(avatar)) {
                return Image.asset(
                  'lib/portals/gbera/images/default_avatar.png',
                  width: size,
                  height: size,
                );
              }
              var child;
              if (avatar.startsWith('/')) {
                child = Image.file(
                  File(avatar),
                  width: size,
                  height: size,
                );
              } else {
                child = FadeInImage.assetNetwork(
                  placeholder: 'lib/portals/gbera/images/default_watting.gif',
                  image:
                      '${person.avatar}?accessToken=${widget.context.principal.accessToken}',
                  width: size,
                  height: size,
                );
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.context.forward('/person/view',
                      arguments: {'person': snapshot.data});
                },
                child: child,
              );
            },
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_recipientsOR.personName ?? ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 5,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: <Widget>[
                    Text(
                      '权重: ${_recipientsOR.weight?.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    _absorberResultOR.absorber.type == 0
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Text(
                            '距中心: ${_recipientsOR.distance?.toStringAsFixed(2)}米',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                    Text(
                      '${intl.DateFormat('yyyy年M月d日 HH:mm:ss').format(parseStrTime(_recipientsOR.ctime))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderRecords() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      constraints: BoxConstraints.expand(),
      child: Column(
        children: [

          CardItem(
            title: '他的洇取记录',
            onItemTap: () {
              widget.context.forward('/absorber/recipient/records', arguments: {
                'absorber': _absorberResultOR,
                'recipients': _recipientsOR,
              });
            },
          ),
        ],
      ),
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
