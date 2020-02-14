import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/local_principals.dart' as lp;

class EditSignature extends StatefulWidget {
  PageContext context;

  EditSignature({this.context});

  @override
  _EditSignatureState createState() => _EditSignatureState();
}

class _EditSignatureState extends State<EditSignature> {
  String _buttonLabel = '确定';
  bool _buttonEnabled = false;
  TextEditingController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = TextEditingController();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _updateSignature() async {
    _buttonLabel = '更新中...';
    _buttonEnabled = false;
    setState(() {});
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports(
      headline,
      restCommand: 'updatePersonSignature',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'signature': _signatureController.text,
      },
      onsucceed: ({rc, response}) async {
       lp. IPlatformLocalPrincipalManager manager =
            widget.context.site.getService('/local/principals');
        await manager.updateSignature(
            widget.context.principal.person, _signatureController.text);
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
                      controller: _signatureController,
                      onChanged: (v) {
                        _buttonEnabled =
                            !StringUtil.isEmpty(_signatureController.text);
                        setState(() {});
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: '个人签名',
                        hintText: '${widget.context.principal.signature ?? ''}',
                        hintStyle: TextStyle(
                          fontSize: 10,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: !_buttonEnabled
                        ? null
                        : () {
                            _updateSignature();
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
