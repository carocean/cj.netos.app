import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class CardItem extends StatefulWidget {
  String title;
  Widget subtitle;
  bool hiddenSubTitle;
  Color titleColor;
  double titleSize;
  TextOverflow tipsOverflow;
  IconData tipsIconData;
  String tipsText;
  Color tipsColor;
  double tipsSize;
  Widget tail;
  Widget leading;
  double paddingTop;
  double paddingBottom;
  double paddingLeft;
  double paddingRight;
  Function() onItemTap;
  Function() onItemLongPress;
  TextDirection tipsTextDirection;

  CardItem({
    this.title,
    this.subtitle,
    this.hiddenSubTitle = false,
    this.titleColor,
    this.titleSize,
    this.tipsOverflow,
    this.tipsText = '',
    this.tipsIconData,
    this.tipsSize,
    this.tipsColor,
    this.tail,
    this.leading,
    this.paddingBottom,
    this.paddingTop,
    this.paddingLeft,
    this.paddingRight,
    this.onItemTap,
    this.onItemLongPress,
    this.tipsTextDirection,
  }) {
    if (tail == null) {
      this.tail = Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey[400],
      );
    }
  }

  @override
  State createState() => CardItemState();
}

class CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onItemTap,
      onLongPress: widget.onItemLongPress,
      child: Container(
        padding: EdgeInsets.only(
          top: widget.paddingTop == null ? 15 : widget.paddingTop,
          bottom: widget.paddingBottom == null ? 15 : widget.paddingBottom,
          left: widget.paddingLeft == null ? 0 : widget.paddingLeft,
          right: widget.paddingRight == null ? 0 : widget.paddingRight,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.leading == null
                ? Container(
                    height: 0,
                    width: 0,
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: widget.leading,
                  ),
            Flexible(
              fit: FlexFit.tight,
              child: Container(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                     '${ widget.title??''}',
                      style: TextStyle(
                        color: widget.titleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: widget.titleSize ?? 15,
                      ),
                    ),
                    widget.subtitle == null || widget.hiddenSubTitle
                        ? SizedBox(
                            width: 0,
                            height: 0,
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                              top: 3,
                            ),
                            child: Flexible(
                              fit: FlexFit.loose,
                              child: widget.subtitle,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            StringUtil.isEmpty(widget.tipsText) && widget.tipsIconData == null
                ? Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: widget.tail,
                  )
                : Flexible(
                    fit: FlexFit.loose,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: StringUtil.isEmpty(widget.tipsText)
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    widget.tipsText,
                                    softWrap: true,
                                    style: TextStyle(
                                      color:
                                          widget.tipsColor ?? Colors.grey[600],
                                      fontSize: widget.tipsSize ?? 12,
                                    ),
                                    textDirection: widget.tipsTextDirection ??
                                        TextDirection.rtl,
                                    overflow: widget.tipsOverflow ?? null,
                                  ),
                                ),
                        ),
                        widget.tipsIconData == null
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Icon(
                                  widget.tipsIconData,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: widget.tail,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
