import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

import 'go_gogo.dart';

class SelectGoGoGoCategory extends StatefulWidget {
  PageContext context;

  SelectGoGoGoCategory({this.context});

  @override
  _SelectGoGoGoCategoryState createState() => _SelectGoGoGoCategoryState();
}

class _SelectGoGoGoCategoryState extends State<SelectGoGoGoCategory> {
  @override
  Widget build(BuildContext context) {
    List<Category> categories = widget.context.page.parameters['categories'];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          widget.context.page.title,
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: categories == null
            ? [
                Text('无分类'),
              ]
            : categories.map(
                (c) {
                  return Column(
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context)
                              .pop(<String, Object>{'category': c});
                        },
                        child: Container(
                          alignment: Alignment.center,
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 15,
                            bottom: 15,
                          ),
                          color: Colors.white,
                          child: Text(
                            c.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                    ],
                  );
                },
              ).toList(),
      ),
    );
  }
}
