import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class PriceOR {
  String sn;
  String ctime;
  double price;
  double afterPrice;
  int order;
  String refsn;
  String title;
  String bankid;
  String note;
  String workday;
  int day;
  int month;
  int weekday;
  int season;

  PriceOR({
    this.sn,
    this.ctime,
    this.price,
    this.afterPrice,
    this.order,
    this.refsn,
    this.title,
    this.bankid,
    this.note,
    this.workday,
    this.day,
    this.month,
    this.weekday,
    this.season,
  });
}

mixin IPriceRemote {
  Future<List<PriceOR>> page(int limit, int offset) {}

  Future<List<PriceOR>> getDay(
      {String wenyBankID,
      int year,
      int month,
      int day,
      int limit,
      int offset}) {}

  Future<List<PriceOR>> getMonth(
      {String wenyBankID, int year, int month, int limit, int offset}) {}
}

class PriceRemote implements IPriceRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get wybankBillPricePorts => site.getService('@.prop.ports.wybank.bill.price');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<List<PriceOR>> getDay(
      {String wenyBankID,
      int year,
      int month,
      int day,
      int limit,
      int offset}) async {
    var list = await remotePorts.portGET(
      wybankBillPricePorts,
      'getPriceBillOfDay',
      parameters: {
        'wenyBankID': wenyBankID,
        'year': year,
        'month': month,
        'day': day,
        'limit': limit,
        'offset': offset,
      },
    );
    print(list);
    return null;
  }

  @override
  Future<List<PriceOR>> getMonth(
      {String wenyBankID, int year, int month, int limit, int offset}) async {
    var list = await remotePorts.portGET(
      wybankBillPricePorts,
      'getPriceBillOfMonth',
      parameters: {
        'wenyBankID': wenyBankID,
        'year': year,
        'month': month,
        'limit': limit,
        'offset': offset,
      },
    );
    List<PriceOR> prices = [];
    for (var obj in list) {
      prices.add(PriceOR(
        month: obj['month'],
        day: obj['day'],
        sn: obj['sn'],
        price: obj['price'],
        note: obj['note'],
        bankid: obj['bankid'],
        ctime: obj['ctime'],
        title: obj['title'],
        afterPrice: obj['afterPrice'],
        order: obj['order'],
        refsn: obj['refsn'],
        season: obj['season'],
        weekday: obj['weekday'],
        workday: obj['workday'],
      ));
    }
    return prices;
  }

  @override
  Future<List<PriceOR>> page(int limit, int offset) {
    // TODO: implement page
    return null;
  }
}
