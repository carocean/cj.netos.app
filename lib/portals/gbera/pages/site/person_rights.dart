import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class PersonRights extends StatefulWidget {
  PageContext context;

  PersonRights({this.context});

  @override
  _PersonRightsState createState() => _PersonRightsState();
}

class _PersonRightsState extends State<PersonRights> {
  bool _denyUpstream = false;
  bool _denyDownstream = false;

  @override
  void initState() {
    () async {
      Person person = widget.context.parameters['person'];
      IPersonService personService =
          widget.context.site.getService('/gbera/persons');
      var p = await personService.getPerson(person.official);
      var _rights = p?.rights;
      switch (_rights) {
        case 'denyUpstream':
          _denyUpstream = true;
          _denyDownstream = false;
          break;
        case 'denyDownstream':
          _denyUpstream = false;
          _denyDownstream = true;
          break;
        case 'denyBoth':
          _denyUpstream = true;
          _denyDownstream = true;
          break;
        default:
          _denyUpstream = false;
          _denyDownstream = false;
          break;
      }
      setState(() {});
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _setRights() async {
    Person person = widget.context.parameters['person'];
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    if (!_denyUpstream && !_denyDownstream) {
      personService.updateRights(person.official, '');
      return;
    }
    if (_denyUpstream && _denyDownstream) {
      personService.updateRights(person.official, 'denyBoth');
      return;
    }
    if (_denyUpstream) {
      personService.updateRights(person.official, 'denyUpstream');
      return;
    }
    if (_denyDownstream) {
      personService.updateRights(person.official, 'denyDownstream');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('权限设置'),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        shrinkWrap: true,
        children: <Widget>[
          CardItem(
            title: '拒绝接收他的消息',
            onItemTap: () {
              this._denyUpstream = !_denyUpstream;
              _setRights().then((v) {
                setState(() {});
              });
            },
            tail: this._denyUpstream
                ? Icon(
                    Icons.check,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.remove,
                    color: Colors.grey[400],
                  ),
          ),
          CardItem(
            title: '拒绝推送消息给他',
            onItemTap: () {
              this._denyDownstream = !_denyDownstream;
              _setRights().then((v) {
                setState(() {});
              });
            },
            tail: this._denyDownstream
                ? Icon(
                    Icons.check,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.remove,
                    color: Colors.grey[400],
                  ),
          ),
        ],
      ),
    );
  }
}
