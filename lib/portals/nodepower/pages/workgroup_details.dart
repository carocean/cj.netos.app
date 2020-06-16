import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:netos_app/portals/nodepower/remote/workgroup_remote.dart';

class WorkgroupDetails extends StatefulWidget {
  PageContext context;

  WorkgroupDetails({this.context});

  @override
  _WorkgroupDetailsState createState() => _WorkgroupDetailsState();
}

class _WorkgroupDetailsState extends State<WorkgroupDetails> {
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
                                delegate: PersonSearchDelegate(widget.context),
                              ).then((v) {
                                print('------$v');
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
    for (var i = 0; i < 100; i++) {
      list.add(
        Container(
          height: 40,
          child: Text('1'),
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
