import 'dart:math';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class Roles extends StatelessWidget {
  PageContext context;

  Roles({this.context});

  @override
  Widget build(BuildContext context) {
    var ucRoles = <Widget>[];
    var tenantRoles = <Widget>[];
    var appRoles = <Widget>[];
    var roles = this.context.principal.roles;
    for (String role in roles) {
      if (role.startsWith('platform:')) {
        ucRoles.add(_buildUcRole(role));
      }
      if (role.startsWith('tenant:')) {
        tenantRoles.add(_buildTenantRole(role));
      }
      if (role.startsWith('app:')) {
        appRoles.add(_buildAppRole(role));
      }
    }
    var items_platform = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            bottom: 5,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Image.asset(
                  'lib/portals/gbera/images/gbera.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 2,
                    ),
                    child: Text('平台'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(),
                    child: Text(
                      '郑州节点动力科技有限公司',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 50,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 50,
            top: 10,
          ),
          child: Column(
            children: ucRoles,
          ),
        ),
      ],
    );
    var items_tenant = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            bottom: 5,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Image.asset(
                  'lib/portals/gbera/images/gbera.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 2,
                    ),
                    child: Text('租户'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(),
                    child: Text(
                      this.context.principal.appid.substring(
                            this.context.principal.appid.indexOf('.') + 1,
                          ),
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 50,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 50,
            top: 10,
          ),
          child: Column(
            children: tenantRoles,
          ),
        ),
      ],
    );
    var items_app = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            bottom: 5,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Image.asset(
                  'lib/portals/gbera/images/gbera.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 2,
                    ),
                    child: Text('应用'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(),
                    child: Text(
                      '${this.context.principal?.appid}',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 50,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 50,
            top: 10,
          ),
          child: Column(
            children: appRoles,
          ),
        ),
      ],
    );
    var bb = this.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            child: items_platform,
          ),
          Container(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            child: items_tenant,
          ),
          Container(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            child: items_app,
          ),
        ],
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        this.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }

  _buildUcRole(String role) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text('-'),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text(role),
          ),
        ],
      ),
    );
  }

  _buildTenantRole(String role) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text('-'),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text(role),
          ),
        ],
      ),
    );
  }

  _buildAppRole(String role) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text('-'),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Text(role),
          ),
        ],
      ),
    );
  }
}
