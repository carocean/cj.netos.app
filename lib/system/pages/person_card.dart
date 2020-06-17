import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/system/local/entities.dart';

class PersonCard extends StatefulWidget {
  PageContext context;

  PersonCard({this.context});

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  @override
  Widget build(BuildContext context) {
    Person person = widget.context.parameters['person'];
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            MediaQuery.removePadding(
              removeBottom: true,
              removeLeft: true,
              removeRight: true,
              context: context,
              child: AppBar(
                elevation: 0,
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    bottom: 20,
                    top: 20,
                  ),
                  margin: EdgeInsets.only(
                    left: 40,
                    right: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                              left: 20,
                            ),
                            child: Image.file(
                              File('${person.avatar}'),
                              width: 60,
                              height: 60,
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 4,
                              children: <Widget>[
                                Text(
                                  '${person.nickName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('${person.official}'),
                                Text('${person.uid}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      StringUtil.isEmpty(person.signature)
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                top: 30,
                                bottom: 20,
                              ),
                              child: Text(
                                '${person.signature}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
