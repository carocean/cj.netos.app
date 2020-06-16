import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class Organization extends StatefulWidget {
  PageContext context;

  Organization({this.context});

  @override
  _OrganizationState createState() => _OrganizationState();
}

class _OrganizationState extends State<Organization> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text('同事'),
          centerTitle: true,
        ),
      ],
    );
  }
}
