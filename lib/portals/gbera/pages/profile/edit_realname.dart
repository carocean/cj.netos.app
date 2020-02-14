import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class EditRealName extends StatefulWidget {
  PageContext context;

  EditRealName({this.context});

  @override
  _EditRealNameState createState() => _EditRealNameState();
}

class _EditRealNameState extends State<EditRealName> {
  String _buttonLabel = '确定';
  bool _buttonEnabled = false;
  TextEditingController _realNameController;

  @override
  void initState() {
    super.initState();
    _realNameController = TextEditingController();
  }

  @override
  void dispose() {
    _realNameController.dispose();
    super.dispose();
  }

  Future<void> _updateRealName() async {
    _buttonLabel = '更新中...';
    _buttonEnabled = false;
    setState(() {});
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports(
      headline,
      restCommand: 'updatePersonRealName',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'realName': _realNameController.text,
      },
      onsucceed: ({rc, response}) async {
        widget.context.backward();
      },
      onerror: ({e, stack}) {
        print(e);
        _buttonLabel = '更新出错，请重试';
        _buttonEnabled = true;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var personInfo=widget.context.page.parameters['personInfo'] as Map<String,dynamic>;
    var bb = widget.context.page.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: TextField(
                      controller: _realNameController,
                      onChanged: (v) {
                        _buttonEnabled =
                            !StringUtil.isEmpty(_realNameController.text);
                        setState(() {});
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: '修改实名',
                        hintText: '${personInfo['realName']??''}',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: !_buttonEnabled
                        ? null
                        : () {
                            _updateRealName();
                          },
                    child: Container(
                      constraints: BoxConstraints.tightForFinite(
                        width: double.maxFinite,
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                      ),
                      color: _buttonEnabled ? Colors.green : Colors.grey[300],
                      child: Text(
                        _buttonLabel,
                        style: TextStyle(
                          color:
                              _buttonEnabled ? Colors.white : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        widget.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
