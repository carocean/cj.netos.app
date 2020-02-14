import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

class AmountSettings extends StatefulWidget {
  PageContext context;

  AmountSettings({this.context});

  @override
  _AmountSettingsState createState() => _AmountSettingsState();
}

class _AmountSettingsState extends State<AmountSettings> {
  bool _add_button_clicked = false;
  var _amount_focus_node = new FocusNode();
  var _memo_focus_node = new FocusNode();
  var _amount_value = '';
  var _memo_value = '';

//表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var item1 = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: TextFormField(
        autofocus: false,
        focusNode: _amount_focus_node,
        keyboardType: TextInputType.numberWithOptions(),
        validator: amountValidator,
        onSaved: (value) {
          _amount_value = value;
        },
        decoration: InputDecoration(
          prefixText: '¥ ',
          labelText: '金额',
          hintText: '输入金额',
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
    var button = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: FlatButton(
        child: Text('添加收款理由'),
        onPressed: () {
          setState(() {
            _add_button_clicked = true;
            _amount_focus_node.unfocus();
            _memo_focus_node.requestFocus();
          });
        },
      ),
      alignment: Alignment.centerRight,
    );
    var item2 = Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: TextFormField(
        autofocus: false,
        focusNode: _memo_focus_node,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          _memo_value = value;
        },
        decoration: InputDecoration(
          labelText: '收款理由',
          hintText: '输入收款理由',
        ),
      ),
    );
    var save = Container(
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      padding: EdgeInsets.only(
        top: 40,
        left: 20,
        right: 20,
      ),
      child: RaisedButton(
        child: Text('保存'),
        color: Colors.white,
        onPressed: () {
          _memo_focus_node.unfocus();
          _amount_focus_node.unfocus();
          if (_formKey.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey.currentState.save();
          }
          widget.context.backward(result:{
            'amount': _amount_value,
            'memo': _memo_value,
          });
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
            color: Colors.grey[800],
          ),
        ),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              item1,
              _add_button_clicked ? item2 : button,
              save,
            ],
          ),
        ),
      ),
    );
  }

  String amountValidator(String value) {
    if (StringUtil.isEmpty(value)) {
      return '金额不能为空';
    }
    if(double.parse(value)>100000000){
      return '收款一个亿，太牛B了，但我不支持';
    }
    return null;
  }
}
