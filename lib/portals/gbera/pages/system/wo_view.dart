import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart' as intl;

class WOView extends StatefulWidget {
  PageContext context;

  WOView({this.context});

  @override
  _WOViewState createState() => _WOViewState();
}

class _WOViewState extends State<WOView> {
  WOFormOR _form;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('详情'),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () {
            widget.context.backward();
          },
        ),
      ),
      // resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text(
                '${_form.typeTitle}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('状态:'),
                      SizedBox(
                        width: 5,
                      ),
                      Text('${_getFormState()}'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 20,
                bottom: 20,
              ),
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: Text.rich(
                TextSpan(
                  text: '',
                  children: [TextSpan(text: '${_form.content ?? ''}')],
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StringUtil.isEmpty(_form.attachment)
                ? SizedBox(
                    width: 0,
                    height: 0,
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: Center(
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
                  ),
            SizedBox(
              height: 40,
              child: Divider(
                height: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Text('创建者:'),
                      SizedBox(
                        width: 5,
                      ),
                      FutureBuilder<Person>(
                        future: _loadPerson(_form.creator),
                        builder: (cxt, snapshot) {
                          if (snapshot.connectionState !=
                                  ConnectionState.done ||
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
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Text('电话:'),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${_form.phone}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                children: [
                  Text('时间:'),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_form.ctime))}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getFormState() {
    switch (_form.state) {
      case 0:
        return '已提交';
      case 1:
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
}
