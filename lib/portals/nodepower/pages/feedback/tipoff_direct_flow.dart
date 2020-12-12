import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tipoff.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';

class TipOffDirectFlowPage extends StatefulWidget {
  PageContext context;

  TipOffDirectFlowPage({this.context});

  @override
  _TipOffDirectFlowPageState createState() => _TipOffDirectFlowPageState();
}

class _TipOffDirectFlowPageState extends State<TipOffDirectFlowPage> {
  TipOffDirectFormOR _form;
  bool _processing = false;

  @override
  void initState() {
    _form = widget.context.parameters['form'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _closeForm() async {
    if (_processing) {
      return;
    }
    setState(() {
      _processing = true;
    });
    ITipOffRemote tipOffRemote =
        widget.context.site.getService('/feedback/tipoff');
    await tipOffRemote.closeDirectForm(_form.id);
    _form.state = -1;
    if (mounted) {
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('处理'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${_form.typeTitle ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('状态:'),
                    SizedBox(
                      width: 10,
                    ),
                    Text('${_getFormState()}'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('举报编号:'),
                    SizedBox(
                      width: 10,
                    ),
                    Text('${_form.id}'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                  ),
                  child: Column(
                    children: _renderFlowPanel(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderFlowPanel() {
    var items = <Widget>[];
    items.add(
      rendTimelineListRow(
        title: Container(
          child: Row(
            children: [
              Text(
                '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_form.ctime))}',
              ),
            ],
          ),
        ),
        paddingLeft: 12,
        paddingContentLeft: 40,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '举报人',
                  ),
                ),
                _renderParticipant(_form.creator),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '填报姓名',
                  ),
                ),
                Text('${_form.realName}'),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '举报电话',
                  ),
                ),
                Text('${_form.phone}'),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(
                left: 10,
              ),
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_form.content ?? ''}'),
                  StringUtil.isEmpty(_form.attachment)
                      ? SizedBox(
                          width: 0,
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.all(10),
                          child: MediaWidget(
                            [
                              MediaSrc(
                                id: Uuid().v1(),
                                type: 'image',
                                text: '',
                                sourceType: 'image',
                                src: _form.attachment,
                              ),
                            ],
                            widget.context,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (_form.state != -1) {
      items.add(
        SizedBox(
          height: 30,
          child: Divider(
            height: 1,
          ),
        ),
      );
      items.add(
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                color: Colors.green,
                textColor: Colors.white,
                onPressed: _processing
                    ? null
                    : () {
                        _closeForm();
                      },
                child: Text(
                  '结束',
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      items.add(
        rendTimelineListRow(
          title: Container(
            child: Icon(
              Icons.check,
              size: 14,
              color: Colors.grey,
            ),
          ),
          paddingLeft: 12,
          paddingContentLeft: 40,
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(10),
            child: Text('处理完毕'),
          ),
        ),
      );
    }

    items.add(
      SizedBox(
        height: 20,
      ),
    );
    return items;
  }

  _getFormState() {
    switch (_form.state) {
      case 0:
        return '处理中';
      case -1:
        return '已关闭';
    }
  }

  Future<Person> _loadPerson(participant) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.fetchPerson(participant);
  }

  Widget _renderParticipant(String participant) {
    if (widget.context.principal.person == participant) {
      return Text(
        '${widget.context.principal.nickName}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return FutureBuilder<Person>(
      future: _loadPerson(participant),
      builder: (cxt, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return SizedBox(
            width: 0,
            height: 0,
          );
        }
        return Text(
          '${snapshot.data.nickName}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
