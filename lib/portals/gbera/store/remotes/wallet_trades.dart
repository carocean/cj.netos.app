import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
class ExchangeResult{
  String sn;
  String personName;
  String currency;
  int amount;
  double stock;
  int profit;
  int purchaseAmount;
  int principalAmount;
  int serviceFeeamount;
  String ctime;
  int state;
  String bankid;

  ExchangeResult(
      {this.sn,
      this.personName,
      this.currency,
      this.amount,
      this.stock,
      this.profit,
      this.purchaseAmount,
      this.principalAmount,
      this.serviceFeeamount,
      this.ctime,
      this.state,
      this.bankid});
}
mixin IWalletTradeRemote{
 Future<ExchangeResult> exchange(String sn) {}

}

class WalletTradeRemote implements IWalletTradeRemote,IServiceBuilder{
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get walletTradePorts => site.getService('@.prop.ports.wallet.trade.receipt');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<ExchangeResult> exchange(String sn)async {
    var obj = await remotePorts.portGET(
      walletTradePorts,
      'exchangeWeny',
      parameters: {
        'purchase_sn': sn,
        'note':'',
      },
    );
    return ExchangeResult(
      ctime: obj['ctime'],
      state: obj['state'],
      stock: obj['stock'],
      bankid: obj['bankid'],
      sn: obj['sn'],
      profit: obj['profit'],
      amount: obj['amount'],
      principalAmount: obj[''],
      currency: obj['currency'],
      personName: obj['personName'],
      purchaseAmount: obj['purchaseAmount'],
      serviceFeeamount: obj['serviceFeeamount'],
    );
  }

}