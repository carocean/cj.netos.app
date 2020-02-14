import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class ChannelsOfUser extends StatefulWidget {
  PageContext context;

  ChannelsOfUser({this.context});

  @override
  _ChannelsOfUserState createState() => _ChannelsOfUserState();
}

class _ChannelsOfUserState extends State<ChannelsOfUser> {
  @override
  Widget build(BuildContext context) {
    var channels = <_ChannelInfo>[
      _ChannelInfo(
        name: '云台花园',
        avatar: Image.network(
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573909575198&di=5ba4a3597027f9bb1aae55e76a202a93&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
          width: 30,
          height: 30,
        ),
        onDeleted: () {},
      ),
      _ChannelInfo(
        name: '华南理工大学',
        avatar: Image.network(
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573909575198&di=5ba4a3597027f9bb1aae55e76a202a93&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
          width: 30,
          height: 30,
        ),
        onDeleted: () {},
      ),
      _ChannelInfo(
        name: '中央电视台',
        avatar: Image.network(
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573909575198&di=5ba4a3597027f9bb1aae55e76a202a93&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
          width: 30,
          height: 30,
        ),
        onDeleted: () {},
      ),
      _ChannelInfo(
        name: '中国电信',
        avatar: Image.network(
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573909575198&di=5ba4a3597027f9bb1aae55e76a202a93&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
          width: 30,
          height: 30,
        ),
        onDeleted: () {},
      ),
      _ChannelInfo(
        name: '中国邮政',
        avatar: Image.network(
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573909575198&di=5ba4a3597027f9bb1aae55e76a202a93&imgtype=0&src=http%3A%2F%2Fpic34.nipic.com%2F20131023%2F13997442_154947337000_2.jpg',
          width: 30,
          height: 30,
        ),
        onDeleted: () {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page.title,
        ),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Text.rich(
                TextSpan(
                  text: '被拒的管道。从列表中移除后方可继续接收其管道活动',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Wrap(
                spacing: 10,
                children: channels.map((channel) {
                  return InputChip(
                    label: Text(channel.name),
                    elevation: 1.0,
                    deleteButtonTooltipMessage: '从他的管道中移除',
                    deleteIcon: Icon(
                      Icons.clear,
                      color: Colors.black54,
                      size: 20.0,
                    ),
                    avatar: channel.avatar == null
                        ? Container(
                            width: 0,
                            height: 0,
                          )
                        : channel.avatar,
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 5,
                      bottom: 5,
                    ),
                    onDeleted: channel.onDeleted,
//                    onPressed: () {
//                      //弹出对话框，是否删除
//                    },
                    shadowColor: Colors.grey,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelInfo {
  String name;
  Widget avatar;
  Function() onDeleted;

  _ChannelInfo({this.name, this.avatar, this.onDeleted});
}
