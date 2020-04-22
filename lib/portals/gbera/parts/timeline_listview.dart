import 'package:flutter/material.dart';

Widget rendTimelineListRow({Widget content, Widget title,Color lineColor=Colors.grey,double paddingLeft=15,double paddingRight=15,double paddingContentLeft=37}) {
  Widget firstRow;
  Widget contentWidget = SizedBox();
  //跟进记录
  contentWidget = content;

  firstRow = Row(
    children: <Widget>[
      title,
    ],
  );

  Widget pointWidget;
  double topSpace = 0;
  topSpace = 3;
  pointWidget = ClipOval(
    child: Container(
      width: 7,
      height: 7,
      color: lineColor,
    ),
  );

  return Container(
    padding: EdgeInsets.only(
      left: paddingLeft,
      right: paddingRight,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //灰色右
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: paddingContentLeft),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: topSpace == 0 ? 4 : 0,
                    ),
                    firstRow,
                    SizedBox(
                      height: 12.0,
                    ),
                    contentWidget,
                    SizedBox(
                      height: 12.0,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                width: 37,
                bottom: 0,
                top: topSpace,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      pointWidget,
                      Expanded(
                        child: Container(
                          width: 27,
                          child: TimelineSeparatorVertical(
                            color: lineColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

class TimelineSeparatorVertical extends StatelessWidget {
  final Color color;

  const TimelineSeparatorVertical({this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.constrainHeight();
        final dashWidth = 4.0;
        final dashCount = (height / (2 * dashWidth)).floor();
        print("dashCount $dashCount  height $height");

        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: 1,
              height: dashWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
    );
  }
}
