import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class AddPersonCardPage extends StatefulWidget {
  PageContext context;

  AddPersonCardPage({this.context});

  @override
  _AddPersonCardPageState createState() => _AddPersonCardPageState();
}

class _AddPersonCardPageState extends State<AddPersonCardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.context.backward();
                },
                child: Row(
                  children: [
                    Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '添加银行卡',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '请绑定持卡人本人的银行卡',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            '持卡人',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '赵向彬',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            '卡号',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            expands: false,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '持卡人本人银行卡号',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: ()async{
                            // var cardDetails = await CardScanner.scanCard(
                            //     scanOptions: CardScanOptions (
                            //         scanCardHolderName: true,
                            //         scanCardIssuer: true,
                            //     )
                            // );
                            //
                            // print(cardDetails);
                          },
                          child: Icon(
                            Icons.camera_enhance,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
