import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/single_media_widget.dart';

Widget renderShareCard({
  PageContext context,
  String href,
  String title,
  String summary,
  String leading,
  Color background,
}) {
  return Container(
    margin: EdgeInsets.only(
      left: 20,
      right: 20,
    ),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: background == null ? Colors.grey[200] : background,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: SingleMediaWidget(
            context: context,
            image: leading,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${title ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              /*
              SizedBox(
                height: 5,
              ),
              Text(
                '${_summary ?? ''}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

               */
            ],
          ),
        ),
      ],
    ),
  );
}

Widget renderShareEditor({
  PageContext context,
  String href,
  String title,
  String summary,
  String leading,
  Color background,
}) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20,right: 20,),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '你怎么看...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (v) {},
                maxLines: 6,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      renderShareCard(
        summary: summary,
        leading: leading,
        href: href,
        title: title,
        context: context,
        background: background,
      ),
    ],
  );
}
