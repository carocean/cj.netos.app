import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

List<Style> buildBlueStyles(IServiceProvider site) {
  return <Style>[
    Style(
        url: '/desktop/settings/portlet.activeColor',
        desc: '栏目列表siwtch组件激活色',
        get: () {
          return Colors.blue[800];
        }
    ),
    Style(
        url: '/desktop/desklets/settings.icon',
        desc: '桌面栏目设置列表',
        get: () {
          return Colors.blue[500];
        }
    ),
    Style(
        url: '/bottom.unselectedItemColor',
        desc: '低部导航未选中时颜色',
        get: () {
          return Colors.black26;
        }
    ),
    Style(
        url: '/bottom.selectedItemColor',
        desc: '低部导航选中时颜色',
        get: () {
          return Colors.blue[700];
        }
    ),
    Style(
      url: '/geosphere/mydq.text',
      desc: '我的地圈中间的主标题',
      get: () {
        return TextStyle(
          fontSize: 14,
        );
      },
    ),
    Style(
      url: '/geosphere/title.text',
      desc: '金证喷泉等标题',
      get: () {
        return TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        );
      },
    ),
    Style(
      url: '/geosphere/sec-title.text',
      desc: '二级标题,应用于帑指和纹指',
      get: () {
        return TextStyle(
          fontSize: 12,
          color: Colors.blue[600],
        );
      },
    ),
    Style(
      url: '/geosphere/title-red.text',
      desc: '',
      get: () {
        return TextStyle(
          fontSize: 12,
          color: Colors.red,
        );
      },
    ),
    Style(
      url: '/geosphere/title-grey.text',
      desc: '',
      get: () {
        return TextStyle(
          fontSize: 12,
          color: Colors.blue[600],
        );
      },
    ),
    Style(
      url: '/geosphere/discovery/title.text',
      desc: '实时栏中发现区域的类别',
      get: () {
        return TextStyle(
          fontSize: 14,
          color: Colors.blue[600],
          fontWeight: FontWeight.w500,
        );
      },
    ),
    Style(
      url: '/geosphere/discovery/count.text',
      desc: '实时栏中发现区域的数量',
      get: () {
        return TextStyle(
          fontSize: 14,
          color: Colors.red,
        );
      },
    ),
    Style(
      url: '/geosphere/listItemMsgTitle.text',
      desc: '',
      get: () {
        return TextStyle(
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
          fontSize: 15,
        );
      },
    ),
    Style(
      url: '/login2/appTitle.text',
      desc: '',
      get: () {
        return TextStyle(
          fontSize: 20,
          color: Colors.blue[700],
        );
      },
    ),
    Style(
      url: '/profile/header-right-qrcode.icon',
      desc: '设置页头区域中的二维码位',
      get: () {
        return Icon(
          FontAwesomeIcons.qrcode,
          size: 16,
          color: Colors.blue[400],
        );
      },
    ),
    Style(
      url: '/profile/header-right-arrow.icon',
      desc: '设置页头区域中的右箭头',
      get: () {
        return Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue[400],
        );
      },
    ),
    Style(
      url: '/profile/header-bg.color',
      desc: '背景色',
      get: () {
        return Colors.white;
      },
    ),
    Style(
      url: '/profile/header-face-title.text',
      desc: '头像旁边的个人名字',
      get: () {
        return TextStyle(
          fontSize: 18,
          color: Colors.blue[800],
          fontWeight: FontWeight.w600,
        );
      },
    ),
    Style(
      url: '/profile/header-face-no.text',
      desc: 'app中的用户号，即用户统一id',
      get: () {
        return TextStyle(
          fontSize: 14,
          color: Colors.blue[500],
        );
      },
    ),
    Style(
      url: '/profile/list/item-icon.color',
      desc: '列表项图片的颜色',
      get: () {
        return Colors.blue[600];
      },
    ),
    Style(
      url: '/profile/list/item-title.text',
      desc: '列表项标题样式',
      get: () {
        return TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        );
      },
    ),
    Style(
      url: '/wallet/banner/total-value.text',
      desc: '当前总资产值样式',
      get: () {
        return TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 25,
        );
      },
    ),
    Style(
      url: '/wallet/banner/total-label.text',
      desc: '当前总资产标签样式',
      get: () {
        return TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.blue[500],
        );
      },
    ),
    Style(
      url: '/wallet/change/mychange.text',
      desc: '我的零钱字体标签样式',
      get: () {
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blue[800],
        );
      },
    ),
    Style(
      url: '/wallet/change/money-sign.text',
      desc: '我的零钱钱数样式',
      get: () {
        return TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );
      },
    ),
    Style(
      url: '/wallet/change/money.text',
      desc: '我的零钱钱数样式',
      get: () {
        return TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        );
      },
    ),
    Style(
      url: '/wallet/change/deposit.textColor',
      desc: '充值按钮文本样式',
      get: () {
        return Colors.white;
      },
    ),
    Style(
      url: '/wallet/change/deposit.color',
      desc: '充值按钮背景样式',
      get: () {
        return Colors.green;
      },
    ),
    Style(
      url: '/wallet/change/deposit.highlightColor',
      desc: '充值按钮背景高亮样式',
      get: () {
        return Colors.green[600];
      },
    ),
    Style(
      url: '/wallet/change/cashout.textColor',
      desc: '提现按钮文本样式',
      get: () {
        return Colors.green;
      },
    ),
    Style(
      url: '/wallet/change/cashout.color',
      desc: '提现按钮背景样式',
      get: () {
        return Colors.blue[200];
      },
    ),
    Style(
      url: '/wallet/change/cashout.highlightColor',
      desc: '提现按钮背景高亮样式',
      get: () {
        return Colors.blue[300];
      },
    ),
    Style(
      url: '/wallet/change/deposit/method/title.text',
      desc: '支付方式标题标签样式',
      get: () {
        return TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        );
      },
    ),
    Style(
      url: '/wallet/change/deposit/method/subtitle.text',
      desc: '支付方式子标题标签样式',
      get: () {
        return TextStyle(
          fontSize: 13,
          color: Colors.blue[600],
        );
      },
    ),
    Style(
      url: '/wallet/change/deposit/method/arrow-label.text',
      desc: '支付方式箭头说明标签样式',
      get: () {
        return TextStyle(
          fontSize: 13,
          color: Colors.blue[600],
        );
      },
    ),
    Style(
      url: '/wallet/change/deposit/method/arrow.icon',
      desc: '支付方式箭头样式',
      get: () {
        return Colors.blue[400];
      },
    ),
    Style(
      url: '/wallet/change/detail/header/title.text',
      desc: '零钱明细头部的提现字样样式',
      get: () {
        return TextStyle(
          fontWeight: FontWeight.w500,
        );
      },
    ),
    Style(
      url: '/wallet/change/detail/header/money.text',
      desc: '提现的钱样式',
      get: () {
        return TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 25,
        );
      },
    ),
    Style(
      url: '/wallet/change/detail/body/label.text',
      desc: '明细的字段标签字样',
      get: () {
        return TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.blue[500],
        );
      },
    ),
  ];
}
