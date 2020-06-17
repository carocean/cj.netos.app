import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/nodepower/pages/search_person_of_app.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:netos_app/portals/nodepower/remote/workgroup_remote.dart';
import 'package:netos_app/system/local/entities.dart';

class WorkgroupDetails extends StatefulWidget {
  PageContext context;

  WorkgroupDetails({this.context});

  @override
  _WorkgroupDetailsState createState() => _WorkgroupDetailsState();
}

class _WorkgroupDetailsState extends State<WorkgroupDetails> {
  List<Person> _recipients = [];

  @override
  void initState() {
    _loadWorkgroupRecipients();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadWorkgroupRecipients() async {
    Workgroup workgroup = widget.context.parameters['workgroup'];
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    List<String> recipients =
        await workflowRemote.getWorkGroupRecipients(workgroup.code);
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');

    for (String official in recipients) {
      var person =
          await personService.getPerson(official, isDownloadAvatar: true);
      if (person == null) {
        continue;
      }
      _recipients.add(person);
    }
    if (mounted) {
      setState(() {});
    }
  }

  _removeWorkRecipient(Person person) async {
    IWorkflowRemote workflowRemote =
        widget.context.site.getService('/remote/org/workflow');
    Workgroup workgroup = widget.context.parameters['workgroup'];
    await workflowRemote.removeWorkRecipient(workgroup.code, person.official);
    _recipients.removeWhere((element) => element.official == person.official);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Workgroup workgroup = widget.context.parameters['workgroup'];
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (cxt, v) {
          return [
            SliverAppBar(
              pinned: true,
              title: Text(workgroup.name),
              elevation: 0,
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _DemoHeader(
                child: Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 5,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            child: Text(
                              '组标识:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${workgroup.code}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 5,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            child: Text(
                              '创建人:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${workgroup.creator}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 5,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            child: Text(
                              '说明:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${workgroup.creator}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '组成员',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              showSearch(
                                context: context,
                                delegate: PersonOfAppSearchDelegate(
                                    widget.context, workgroup),
                              ).then((v) {
                                _recipients.clear();
                                _loadWorkgroupRecipients();
                              });
                            },
                            child: Icon(
                              Icons.add,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: ListView(
            children: _renderRecipients(),
          ),
        ),
      ),
    );
  }

  _renderRecipients() {
    var list = <Widget>[];
    for (var recipient in _recipients) {
      list.add(
        Column(
          children: <Widget>[
            Slidable(
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: '删除',
                  foregroundColor: Colors.grey[500],
                  icon: Icons.delete,
                  onTap: () async {
                    _removeWorkRecipient(recipient);
                  },
                ),
              ],
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
              widget.context.forward('/public/card/basicPerson',
                  arguments: {'person': recipient});
                },
                child: Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 10,
                        ),
                        child: SizedBox(
                          width: 40,
                          child: Image.file(
                            File(recipient.avatar),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${recipient.nickName ?? ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${recipient.official}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 15,
              ),
              child: Divider(
                height: 1,
                indent: 65,
              ),
            ),
          ],
        ),
      );
    }
    return list;
  }
}

class _DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;

  _DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: child,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return 105;
  } // 最大高度

  @override
  double get minExtent => 105.0; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}
