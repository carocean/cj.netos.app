import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/market/org_licence.dart';

class ViewLicence extends StatelessWidget {
  PageContext context;

  ViewLicence({this.context});

  @override
  Widget build(BuildContext context) {
    var organ = this.context.parameters['organ'];
    var type = this.context.parameters['type'];
    return Scaffold(
      appBar: AppBar(
        title: Text('执照'),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20,right: 20,bottom: 30,top: 20,),
          child: OrgLicenceCard(
            context: this.context,
            organ: organ,
            type: type,
          ),
        ),
      ),
    );
  }
}
