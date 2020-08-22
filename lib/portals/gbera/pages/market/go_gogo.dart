import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/system/local/entities.dart';

class Gogogo extends StatefulWidget {
  PageContext context;

  Gogogo({this.context});

  @override
  _GogogoState createState() => _GogogoState();
}

class _GogogoState extends State<Gogogo> with SingleTickerProviderStateMixin {
  TabController _controller;
  List<_Page> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _allPages();
    _controller = TabController(vsync: this, length: _pages.length);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _pages.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                widget.context.page.title,
              ),
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              actions: <Widget>[
                PopupMenuButton(
                  elevation: 0,
                  offset: Offset(20, 50),
//                  initialValue: 'myorders',
                  onSelected: (v) {
                    print('-----$v');
                  },
                  itemBuilder: (context) {
                    return <PopupMenuItem>[
                      PopupMenuItem(
                        child: Text('我的订单'),
                        value: 'myorders',
                      ),
                      PopupMenuItem(
                        child: Text('我的关注'),
                        value: 'mycollects',
                      ),
                    ];
                  },
                ),
              ],
              leading: IconButton(
                icon: Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  widget.context.backward();
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  margin: EdgeInsets.only(
                    bottom: 45,
                  ),
                  child: Image.network(
                    'https://f11.baidu.com/it/u=2675671810,782288130&fm=72',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _controller,
                isScrollable: true,
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: _pages.map<Tab>((_Page page) {
                  return Tab(
                    text: page.title,
                  );
                }).toList(),
              ),
            ),
          ];
        },
        body: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            TabBarView(
              controller: _controller,
              children: _pages.map<Widget>((_Page page) {
                return Container(
                  padding: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: _PageRegion(
                    context: widget.context,
                    page: page,
                  ),
                );
              }).toList(),
            ),
            _ShoppingCartBar(
              onOpenCart: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return widget.context
                          .part('/market/shopping_cart', context);
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_Page> _allPages() {
    return <_Page>[
      _Page(
        id: 'home',
        title: 'HoME',
        categories: [
          Category(
            id: 'all',
            title: '全部',
          ),
          Category(
            id: 'myorders',
            title: '我的订单',
          ),
          Category(
            id: 'recommends',
            title: '推荐',
          ),
        ],
        items: [
          _MyGoDownOrder(
            marchant: '老上海馄饨粥味多(沧头店)',
            contractNo: '00388283747477474',
            category: 'myorders',
            contractState: '派送中',
            type: 'GoDOWN',
            tyIndexMarket: '宏生帑指交易市场',
            tyIndexPrice: '5.89',
            amount: '93.50',
            wyAmount: '28.32',
            contractAmount: '69.80',
            total: '5',
            items: [
              _MemuItem(
                avatar:
                    'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3740417280,4055785255&fm=26&gp=0.jpg',
                title: '空心菜',
                price: '13.50',
                qty: '1',
              ),
              _MemuItem(
                avatar:
                    'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574497085432&di=07dc8a52f06f8070ee69e387841249bc&imgtype=0&src=http%3A%2F%2Fcp2.douguo.net%2Fupload%2Fcaiku%2F7%2F4%2F2%2F600x400_74ee3e1d09b6e79165de00d73bc41f42.jpeg',
                title: '牛腩萝卜汤',
                price: '24.00',
                qty: '1',
              ),
              _MemuItem(
                avatar:
                    'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574497085432&di=daa2dfa9d9526ca42dadf3e7db7293de&imgtype=0&src=http%3A%2F%2Fcp1.douguo.net%2Fupload%2Fcaiku%2F6%2Fa%2F1%2Fyuan_6a3a1eef62d8c21a651db0892a59a3c1.jpg',
                title: '凉拌油麦菜',
                price: '11.50',
                qty: '2',
              ),
            ],
          ),
          _MyGoUPOrder(
            category: 'myorders',
            contractNo: '003838727766216611882',
            contractMerchandisePrice: 8723,
            contractScale: 0.10,
            contractState: '交易中',
            highestBuyBillAmount: 8610,
            lowestMerchandisePrice: 9876.00,
            reducePoolAmount: 1256.32,
            maybeMerchant: '广州丰力华为专营店',
            storeAvatar:
                'https://img11.360buyimg.com/n1/s450x450_jfs/t1/81012/28/13665/159765/5dafcdf7Eb247ff7f/c516fc4de783079c.jpg',
            storeTitle:
                '华为 HUAWEI Mate 30 Pro 5G 麒麟990 OLED环幕屏双4000万徕卡电影四摄8GB+256GB丹霞橙5G全网通版',
            wyPrice: 0.00123837774747,
            wyQTY: 82837,
          ),
          _Merchant(
            title: '鲜又多水果超市',
            subtitle: '',
            leading:
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574359278193&di=99db9dbac1d7cdda741bff962e52f29b&imgtype=0&src=http%3A%2F%2Fhiphotos.baidu.com%2Flbsugc%2Fpic%2Fitem%2Fd01373f082025aaf958ff123feedab64024f1a9c.jpg',
            distance: '2.1',
            contractscale: '40%',
            category: 'recommends',
            issueTYAmount: '123万',
            issueWYAmount: '540',
            peratio: '5.8',
            whiteStartDeliveringAmount: '20',
            nightStartDeliveringAmount: '4',
            discountRules: {
              "1": '27返8',
              "2": '35返10',
              "3": '45返15',
              "4": '55返25',
              "5": '23返12',
              "6": '58返15',
            },
          ),
          _Merchandise(
              name: 'Apple iPhone 11 (A2223) 128GB 黑色 移动联通电信4G手机 双卡双待',
              category: 'recommends',
              images: [
                'https://img12.360buyimg.com/n1/s450x450_jfs/t1/59022/28/10293/141808/5d78088fEf6e7862d/68836f52ffaaad96.jpg',
                'https://img12.360buyimg.com/n1/s450x450_jfs/t1/61588/10/9949/164377/5d7808a1E6c3615dd/7c45f7039b9cbae8.jpg',
              ],
              desc: 'iPhoneXS系列性能强劲，样样出色，现特惠来袭，低至5599元。'),
        ],
      ),
      _Page(
        id: 'godown',
        title: 'GoDOWN',
        categories: [
          Category(
            id: 'meishi',
            title: '美食',
          ),
          Category(
            id: 'shuiguo',
            title: '水果',
          ),
        ],
        items: [
          _Merchant(
            title: '鲜又多水果超市',
            subtitle: '',
            leading:
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574359278193&di=99db9dbac1d7cdda741bff962e52f29b&imgtype=0&src=http%3A%2F%2Fhiphotos.baidu.com%2Flbsugc%2Fpic%2Fitem%2Fd01373f082025aaf958ff123feedab64024f1a9c.jpg',
            distance: '2.1',
            contractscale: '40%',
            category: 'shuiguo',
            issueTYAmount: '123万',
            issueWYAmount: '540',
            peratio: '5.8',
            whiteStartDeliveringAmount: '20',
            nightStartDeliveringAmount: '4',
            discountRules: {
              "1": '27返8',
              "2": '35返10',
              "3": '45返15',
              "4": '55返25',
              "5": '23返12',
              "6": '58返15',
            },
          ),
          _Merchant(
            title: '惠多水果店',
            subtitle: '',
            leading:
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574356459814&di=755102298867f501dabdc15c3a75deed&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fnuomi%2Fpic%2Fitem%2F00e93901213fb80e32247a5d31d12f2eb8389446.jpg',
            distance: '2.1',
            contractscale: '35%',
            category: 'shuiguo',
            issueTYAmount: '9382',
            issueWYAmount: '540',
            peratio: '5.8',
            whiteStartDeliveringAmount: '20',
            nightStartDeliveringAmount: '4',
            discountRules: {
              "1": '27返8',
              "2": '35返10',
              "3": '45返15',
              "4": '55返25',
            },
          ),
          _Merchant(
            title: 'G哥炸汉堡',
            subtitle: '东站店',
            contractscale: '20%',
            distance: '1.1',
            category: 'meishi',
            leading:
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574359247474&di=31782a29844c1637371b5225919115c6&imgtype=0&src=http%3A%2F%2Fpic45.huitu.com%2Fres%2F20151222%2F80430_20151222012130354200_1.jpg',
            issueTYAmount: '123万',
            issueWYAmount: '230',
            peratio: '9.8',
            whiteStartDeliveringAmount: '20',
            nightStartDeliveringAmount: '4',
            discountRules: {
              "1": '27返8',
              "2": '35返10',
              "3": '45返15',
              "4": '55返25',
            },
          ),
          _Merchant(
            title: '老上海馄饨粥味多',
            subtitle: '沧头店',
            distance: '3.1',
            contractscale: '100%',
            category: 'meishi',
            leading:
                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574356459814&di=808610c075ef8102534abeba312a8453&imgtype=0&src=http%3A%2F%2Fimg002.hc360.cn%2Fm8%2FM0B%2F22%2F14%2FwKhQplctq32EDs3kAAAAANGZPJI665.JPG',
            issueTYAmount: '2034',
            issueWYAmount: '540',
            peratio: '5.8',
            whiteStartDeliveringAmount: '20',
            nightStartDeliveringAmount: '4',
            discountRules: {
              "1": '27返8',
              "2": '35返10',
              "3": '45返15',
              "4": '55返25',
            },
          ),
        ],
      ),
      _Page(
        id: 'goup',
        title: 'GoUP',
        categories: [
          Category(
            id: 'phone',
            title: '手机卖场',
          ),
          Category(
            id: 'liuxing',
            title: '女装卖场',
          ),
        ],
        items: [
          _Merchandise(
              name:
                  '华为 HUAWEI Mate 30 Pro 5G 麒麟990 OLED环幕屏双4000万徕卡电影四摄8GB+256GB丹霞橙5G全网通版',
              category: 'phone',
              price: '99.00',
              sites: [
                _MerchantSite(
                    siteAvatar:
                        'https://g-search1.alicdn.com/img/bao/uploaded/i4//eb/1d/T19AHNFdJbXXb1upjX.jpg_140x140Q90.jpg',
                    siteTitle: '中国移动官方旗舰店'),
                _MerchantSite(
                    siteAvatar:
                        'https://g-search1.alicdn.com/img/bao/uploaded/i4//c4/13/TB1etCbSpXXXXcsXXXXSutbFXXX.jpg_140x140Q90.jpg',
                    siteTitle: 'Apple 产品京东自营旗舰店'),
              ],
              images: [
                'https://img11.360buyimg.com/n1/s450x450_jfs/t1/100072/19/531/218255/5dafcdf6E996f8eda/5ffdb56099d4da7c.jpg',
                'https://img11.360buyimg.com/n1/s450x450_jfs/t1/81012/28/13665/159765/5dafcdf7Eb247ff7f/c516fc4de783079c.jpg',
                'https://img11.360buyimg.com/n1/s450x450_jfs/t1/85120/6/577/92522/5dafcdf7E3ed87530/777b12adea1822f6.jpg',
                'https://img11.360buyimg.com/n1/s450x450_jfs/t1/85862/1/558/120277/5dafcdf8E2d92f14a/f0a5f500c3188252.jpg',
              ],
              desc:
                  '腊肉肠、香肠、火腿、牛肉，搭配菠萝、蘑菇、洋葱、青椒等蔬菜水果，如此丰盛馅料，口口都是令人满足的好滋味。主要原料:面团、牛肉粒、猪肉粒、火腿、腊肉肠、芝士、蔬菜、菠萝、黑橄榄。铁盘个人装250克建议1人用，铁盘普通装440克建议2-3人用，铁盘大装880克建议3-4人用，芝心普通装570克建议2-3人用，大方薄底普通装390克建议2-3人用。'),
          _Merchandise(
              name: '超级至尊比萨1',
              category: 'liuxing',
              price: '82.25',
              images: [
                'https://img.4008123123.com/resource/VersionP/phdi/3_348.JPG'
              ],
              desc:
                  '腊肉肠、香肠、火腿、牛肉，搭配菠萝、蘑菇、洋葱、青椒等蔬菜水果，如此丰盛馅料，口口都是令人满足的好滋味。主要原料:面团、牛肉粒、猪肉粒、火腿、腊肉肠、芝士、蔬菜、菠萝、黑橄榄。铁盘个人装250克建议1人用，铁盘普通装440克建议2-3人用，铁盘大装880克建议3-4人用，芝心普通装570克建议2-3人用，大方薄底普通装390克建议2-3人用。'),
          _Merchandise(
              name: 'Apple iPhone 11 (A2223) 128GB 黑色 移动联通电信4G手机 双卡双待',
              category: 'phone',
              images: [
                'https://img12.360buyimg.com/n1/s450x450_jfs/t1/59022/28/10293/141808/5d78088fEf6e7862d/68836f52ffaaad96.jpg',
                'https://img12.360buyimg.com/n1/s450x450_jfs/t1/61588/10/9949/164377/5d7808a1E6c3615dd/7c45f7039b9cbae8.jpg',
              ],
              desc: 'iPhoneXS系列性能强劲，样样出色，现特惠来袭，低至5599元。'),
        ],
      ),
    ];
  }
}

class _MyGoUPOrder {
  String contractNo;
  String contractState;
  String category;
  String storeAvatar;
  String storeTitle;
  double lowestMerchandisePrice;
  double reducePoolAmount;
  double highestBuyBillAmount;
  double contractMerchandisePrice;
  double contractScale;
  int wyQTY;
  double wyPrice;
  String maybeMerchant;

  _MyGoUPOrder(
      {this.contractNo,
      this.contractState,
      this.category,
      this.maybeMerchant,
      this.storeAvatar,
      this.storeTitle,
      this.lowestMerchandisePrice,
      this.reducePoolAmount,
      this.highestBuyBillAmount,
      this.contractMerchandisePrice,
      this.contractScale,
      this.wyQTY,
      this.wyPrice});
}

class _MyGoDownOrder {
  String contractNo;
  String marchant;
  String contractAmount;
  String wyAmount;
  String type = 'GoDOWN';
  String contractState;
  String amount;
  String total;
  String category;
  String tyIndexMarket;
  String tyIndexPrice;
  List<_MemuItem> items;

  _MyGoDownOrder(
      {this.contractNo,
      this.marchant,
      this.contractAmount,
      this.wyAmount,
      this.tyIndexMarket,
      this.tyIndexPrice,
      this.type,
      this.contractState,
      this.amount,
      this.total,
      this.category,
      this.items}) {
    if (items == null) {
      this.items = [];
    }
  }
}

class _MemuItem {
  String avatar;
  String title;
  String qty;
  String price;

  _MemuItem({this.avatar, this.title, this.qty, this.price});
}

class _ShoppingCartBar extends StatefulWidget {
  Function() onOpenCart;

  _ShoppingCartBar({this.onOpenCart});

  @override
  __ShoppingCartBarState createState() => __ShoppingCartBarState();
}

class __ShoppingCartBarState extends State<_ShoppingCartBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpenCart,
        child: Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 20,
            bottom: 10,
            top: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.add_shopping_cart,
                  size: 20,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Page {
  String title;
  String id;
  List<Category> categories;
  List<dynamic> items;

  _Page({this.id, this.title, this.categories, this.items}) {
    if (this.categories == null) {
      this.categories = [];
    }
    if (this.items == null) this.items = [];
  }
}

class _MerchantSite {
  String siteTitle;
  String siteAvatar;

  _MerchantSite({this.siteTitle, this.siteAvatar});
}

///商品
class _Merchandise {
  String category;
  String name;
  String desc;
  List<String> images;
  List<_MerchantSite> sites;
  String price;
  int count;

  _Merchandise(
      {this.category,
      this.sites,
      this.name,
      this.desc,
      this.images,
      this.price,
      this.count}) {
    if (images == null) {
      this.images = [];
    }
    if (sites == null) {
      this.sites = [];
    }
  }
}

class Category {
  String id;
  String title;

  @override
  bool operator ==(other) {
    return id == other?.origin;
  }

  @override
  int get hashCode {
    return id == null ? super.hashCode : id.hashCode;
  }

  Category({this.id, this.title});
}

class _Merchant {
  String title;
  String subtitle;
  String leading;
  String category;
  String issueTYAmount;
  String peratio;
  String contractscale;
  String issueWYAmount;
  String whiteStartDeliveringAmount;
  String nightStartDeliveringAmount;
  String distance;
  Map<String, String> discountRules;

  _Merchant(
      {this.title,
      this.subtitle,
      this.leading,
      this.category,
      this.issueTYAmount,
      this.contractscale,
      this.peratio,
      this.issueWYAmount,
      this.whiteStartDeliveringAmount,
      this.nightStartDeliveringAmount,
      this.distance,
      this.discountRules}) {
    if (discountRules == null) {
      this.discountRules = {};
    }
  }
}

class _PageRegion extends StatefulWidget {
  PageContext context;
  _Page page;
  Category filter;

  _PageRegion({this.context, this.page, this.filter});

  @override
  _PageRegionState createState() => _PageRegionState();
}

class _PageRegionState extends State<_PageRegion> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ListView(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          children: widget.page.categories.map((category) {
            if (widget.filter == null ||
                widget.filter ==
                    Category(
                      id: 'all',
                    )) {
              List<dynamic> items = [];
              widget?.page?.items?.forEach((m) {
                if (m?.category == category?.id) {
                  items.add(m);
                }
              });
              return _CategoryRegion(
                pageid: widget.page.id,
                category: category,
                items: items,
                context: widget.context,
              );
            }
            if (widget.filter == category) {
              List<dynamic> items = [];
              widget?.page?.items?.forEach((m) {
                if (m?.category == category?.id) {
                  items.add(m);
                }
              });
              return _CategoryRegion(
                context: widget.context,
                pageid: widget.page.id,
                category: category,
                items: items,
              );
            }
            return Container(
              height: 0,
              width: 0,
            );
          }).toList(),
        ),
        Positioned(
          right: 10,
          top: 6,
          child: GestureDetector(
            child: Icon(
              FontAwesomeIcons.filter,
              color: Colors.grey,
              size: 16,
            ),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return widget.context.part(
                        '/goGOGO/category/filter', context,
                        arguments: <String, Object>{
                          'categories': widget.page.categories
                        });
                  }).then((result) {
                print('----$result');
                setState(() {
                  widget.filter = result['category'];
                });
              });
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryRegion extends StatefulWidget {
  String pageid;
  Category category;
  List<dynamic> items;
  PageContext context;

  _CategoryRegion({this.context, this.pageid, this.category, this.items});

  @override
  __CategoryRegionState createState() => __CategoryRegionState();
}

class __CategoryRegionState extends State<_CategoryRegion> {
  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(
        height: 0,
        width: 0,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 5,
          ),
          child: Text(
            widget.category.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.items?.map((item) {
//                          return _CategoryRegion(merchandise);
            switch (widget.pageid) {
              case 'home':
                if (item.category == 'myorders') {
                  if (item is _MyGoDownOrder) {
                    return _MyGoDownOrderOnHomeCard(
                      item: item,
                      context: widget.context,
                    );
                  }
                  if (item is _MyGoUPOrder) {
                    return _MyGoUPOrderOnHomeCard(
                      item: item,
                      context: widget.context,
                    );
                  }
                }
                if (item.category == 'recommends') {
                  if (item is _Merchant) {
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: _GodownCard(
                        merchant: item,
                        context: widget.context,
                      ),
                    );
                  }
                  if (item is _Merchandise) {
                    return _GoupCard(
                      merchandise: item,
                      context: widget.context,
                    );
                  }
                }
                return Container(
                  height: 0,
                  width: 0,
                );
              case 'godown':
                return _GodownCard(
                  merchant: item,
                  context: widget.context,
                );
              case 'goup':
                return _GoupCard(
                  merchandise: item,
                  context: widget.context,
                );
              default:
                return Container(
                  height: 0,
                  width: 0,
                );
            }
          })?.toList(),
        ),
        Container(
          height: 10,
        ),
      ],
    );
  }
}

class _MyGoUPOrderOnHomeCard extends StatefulWidget {
  _MyGoUPOrder item;
  PageContext context;

  _MyGoUPOrderOnHomeCard({this.item, this.context});

  @override
  __MyGoUPOrderOnHomeCardState createState() => __MyGoUPOrderOnHomeCardState();
}

class __MyGoUPOrderOnHomeCardState extends State<_MyGoUPOrderOnHomeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 10,
      ),
      color: Colors.white,
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      child: Text(
                        '合约号',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      padding: EdgeInsets.only(
                        right: 2,
                      ),
                    ),
                    Text(
                      widget.item.contractNo ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.item.contractState,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
          Container(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: SizedBox(
                                width: 50,
                                child: Image.network(
                                  widget.item.storeAvatar ?? '',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: widget.item.storeTitle ?? '',
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            top: 5,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '现市价',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${widget.item.lowestMerchandisePrice - widget.item.reducePoolAmount}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            left: 30,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '=',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '当前最低现货价',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${widget.item.lowestMerchandisePrice}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '-',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '当前降价金',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text: '${widget.item.reducePoolAmount}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '本轮成交差',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${((widget.item.lowestMerchandisePrice - widget.item.reducePoolAmount) - widget.item.highestBuyBillAmount).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            left: 30,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '=',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '现市价',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${(widget.item.lowestMerchandisePrice - widget.item.reducePoolAmount)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '-',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '最高买单',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${widget.item.highestBuyBillAmount}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    top: 5,
                  ),
                  child: Divider(
                    height: 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: '合约货价',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: ' '),
                            TextSpan(
                              text: '¥${widget.item.contractMerchandisePrice}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '合约比',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: ' '),
                            TextSpan(
                              text: '${widget.item.contractScale * 100}%',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '您离成交差',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${widget.item.lowestMerchandisePrice - widget.item.reducePoolAmount - widget.item.contractMerchandisePrice * widget.item.contractScale}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            left: 30,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '=',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '现市价',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${widget.item.lowestMerchandisePrice - widget.item.reducePoolAmount}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '-',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '合约金额',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${(widget.item.contractMerchandisePrice * widget.item.contractScale).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '追加买入',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: 5,
                    top: 5,
                  ),
                  child: Divider(
                    height: 1,
                    indent: 30,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '合约纹银',
                                  children: [
                                    TextSpan(text: ' WY'),
                                    TextSpan(
                                      text: '${widget.item.wyQTY}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            left: 30,
                          ),
                          child: Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  text: '=',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '现市值',
                                  children: [
                                    TextSpan(text: ' ¥'),
                                    TextSpan(
                                      text:
                                          '${(widget.item.wyQTY * widget.item.wyPrice).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            text: '承兑',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: 'GoUP: ',
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: '目前可能交易的商家 ',
                                  style: TextStyle(
                                    color: Colors.black26,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.item.maybeMerchant ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Divider(
                          height: 1,
                          indent: 50,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Wrap(
                              runSpacing: 4,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: '委托商家理财: ',
                                    style: TextStyle(
                                      color: Colors.black26,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '旺生堂纹银银行',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '  ',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '现价 ',
                                    style: TextStyle(
                                      color: Colors.black26,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '¥${widget.item.wyPrice}',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyGoDownOrderOnHomeCard extends StatefulWidget {
  _MyGoDownOrder item;
  PageContext context;

  _MyGoDownOrderOnHomeCard({this.item, this.context});

  @override
  _MyGoDownOrderOnHomeCardState createState() =>
      _MyGoDownOrderOnHomeCardState();
}

class _MyGoDownOrderOnHomeCardState extends State<_MyGoDownOrderOnHomeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 10,
      ),
      color: Colors.white,
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      child: Text(
                        '合约号',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      padding: EdgeInsets.only(
                        right: 2,
                      ),
                    ),
                    Text(
                      widget.item.contractNo ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.item.contractState ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
          Container(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Wrap(
                    spacing: 5,
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: '金额',
                          children: [
                            TextSpan(text: ' ¥'),
                            TextSpan(
                              text: widget.item.amount ?? '',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '数量',
                          children: [
                            TextSpan(text: ' '),
                            TextSpan(
                              text: widget.item.total ?? '',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                ),
                Column(
                  children: widget.item.items.map((item) {
                    return Column(
                      children: <Widget>[
                        CardItem(
                          leading: Image.network(
                            item.avatar ?? '',
                            fit: BoxFit.fitWidth,
                            width: 40,
                          ),
                          title: item.title ?? '',
                          paddingBottom: 10,
                          paddingTop: 10,
                          tipsText: '${item.qty}  ¥${item.price}',
                          tail: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                        Divider(
                          height: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    top: 3,
                  ),
                  child: Wrap(
                    spacing: 5,
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: '支付合约市值',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black26,
                          ),
                          children: [
                            TextSpan(text: ' '),
                            TextSpan(
                              text: '¥${widget.item.contractAmount ?? ''}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '返纹现市值',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black26,
                          ),
                          children: [
                            TextSpan(text: ' '),
                            TextSpan(
                              text: '¥${widget.item.wyAmount ?? ''}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: 'GoDOWN: ',
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.item.marchant ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Divider(
                          height: 1,
                          indent: 50,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: '委托店家理财: ',
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.item.tyIndexMarket ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '  ',
                                    ),
                                  ],
                                ),
                                TextSpan(
                                  text: '现价 ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '¥${widget.item.tyIndexPrice ?? ''}',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///商家展窗
class _GodownCard extends StatefulWidget {
  _Merchant merchant;
  PageContext context;

  _GodownCard({this.merchant, this.context});

  @override
  _GodownCardState createState() => _GodownCardState();
}

class _GodownCardState extends State<_GodownCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: SizedBox(
              width: 100,
              child: Image.network(
                widget.merchant.leading ?? '',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: widget.merchant.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      children: [
                        TextSpan(
                          text: StringUtil.isEmpty(widget.merchant.subtitle)
                              ? ''
                              : '(${widget.merchant.subtitle})',
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Wrap(
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: '合约比',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(
                              text: '${widget.merchant.contractscale ?? '0'}',
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '月发帑',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(
                              text: '${widget.merchant.issueTYAmount}张',
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '市盈率',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(
                              text: widget.merchant.peratio,
                            ),
                          ],
                        ),
                      ),
                    ],
                    spacing: 5,
                    runSpacing: 5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              text: '起送',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              children: [
                                TextSpan(
                                  text: widget
                                      .merchant.whiteStartDeliveringAmount,
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: '夜间配送',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              children: [
                                TextSpan(
                                  text: widget
                                      .merchant.nightStartDeliveringAmount,
                                ),
                              ],
                            ),
                          ),
                        ],
                        spacing: 5,
                        runSpacing: 5,
                      ),
                      Text(
                        '${widget.merchant.distance}km',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        children: widget.merchant.discountRules.values.map((v) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[300],
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            ),
                            padding: EdgeInsets.only(
                              left: 2,
                              right: 2,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: v,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        spacing: 5,
                        runSpacing: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 5,
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: '该商家收取纹银,并接受纹银现价支付',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///商品展窗
class _GoupCard extends StatefulWidget {
  _Merchandise merchandise;
  PageContext context;

  _GoupCard({this.merchandise, this.context});

  @override
  _GoupCardState createState() => _GoupCardState();
}

class _GoupCardState extends State<_GoupCard> {
  int title_maxLines = 2;
  int desc_maxLines = 3;

  @override
  Widget build(BuildContext context) {
    var medias = <MediaSrc>[];
    for (var img in widget.merchandise.images) {
      medias.add(Media(
        null,
        'image',
        img,
        null,
        null,
        null,
        null,
        widget.context.principal.person,
      ).toMediaSrc());
    }
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                child: DefaultTabController(
                  length: widget.merchandise.images.length,
                  child: PageSelector(
                    medias: medias,
                    height: 150,
                    context: widget.context,
                    onMediaLongTap: (media,index) {
                      widget.context.forward(
                        '/images/viewer',
                        arguments: {
                          'medias': medias,
                          'index': index,
                        },
                      );
                    },
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: 5,
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text(
                                        '本轮成交差',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '¥',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '382.34',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '买单',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    text: '423',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                    children: [],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '最高',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    text: '¥4300.00',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                    children: [],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Text(
                                                    '降价金',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    text: '¥1823.00',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                    children: [],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: Text(
                                      '下单',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 3,
                            bottom: 3,
                          ),
                          child: Divider(
                            height: 1,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 10,
                            alignment: WrapAlignment.end,
                            runSpacing: 3,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 2),
                                      child: Text(
                                        '现市价',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '¥',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueGrey[800],
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '4382.34',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 2),
                                      child: Text(
                                        '最低现货价',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '¥',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '5999.00',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blueGrey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 2),
                                      child: Text(
                                        '成交轮次',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '243',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueGrey[800],
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '万',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: widget.merchandise.name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              if (title_maxLines == 2) {
                                title_maxLines = 10;
                              } else {
                                title_maxLines = 2;
                              }
                            });
                          },
                      ),
                      maxLines: title_maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: widget.merchandise.desc ?? '',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              if (desc_maxLines == 3) {
                                desc_maxLines = 10;
                              } else {
                                desc_maxLines = 3;
                              }
                            });
                          },
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      maxLines: desc_maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: widget.merchandise.sites.map((site) {
                            return Image.network(
                              site.siteAvatar,
                              fit: BoxFit.fitHeight,
                              height: 20,
                            );
                          }).toList(),
                        ),
                      ),
                      fit: FlexFit.loose,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                      ),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 0,
                            ),
                            child: Text(
                              '125个商家 上货1003个',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 10,
        ),
      ],
    );
  }
}
