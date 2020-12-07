import 'dart:convert';

import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/isp/pages/weny_purchase.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';

import 'wallet_records.dart';

class PurchaseInfo {
  BusinessBuckets businessBuckets;
  BankInfo bankInfo;
  MyWallet myWallet;

  PurchaseInfo({this.businessBuckets, this.bankInfo, this.myWallet});
}

mixin IWyBankPurchaserRemote {
  Future<PurchaseInfo> getPurchaseInfo(String distinct);

  Future<PurchaseOR> doPurchase(String bank, int amount,int payMethod, String outTradeType,
      String outTradeSn, String note);

  Future<PurchaseOR> getPurchaseRecordPerson(String owner, String record_sn);

  Future<PurchaseOR> getPurchaseRecord(String record_sn);

  Future<WenyBank> getWenyBank(String bankid) {}
}

class DefaultWyBankPurchaserRemote
    implements IWyBankPurchaserRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  IWyBankRemote wyBankRemote;
  IWalletAccountRemote walletAccountRemote;
  IWalletTradeRemote walletTradeRemote;
  IWalletRecordRemote walletRecordRemote;

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    wyBankRemote = site.getService('/remote/wybank');
    walletAccountRemote = site.getService('/wallet/accounts');
    walletTradeRemote = site.getService('/wallet/trades');
    walletRecordRemote = site.getService('/wallet/records');
    return null;
  }

  @override
  Future<PurchaseInfo> getPurchaseInfo(String distinct) async {
    BankInfo bankInfo =
        await wyBankRemote.getAndAutoCreateWenyBankByDistrict(distinct);
    BusinessBuckets businessBuckets =
        await wyBankRemote.getBusinessBucketsOfBank(bankInfo.id);
    MyWallet myWallet = await walletAccountRemote.getAllAcounts();
    return PurchaseInfo(
      bankInfo: bankInfo,
      businessBuckets: businessBuckets,
      myWallet: myWallet,
    );
  }

  @override
  Future<PurchaseOR> doPurchase(String bank, int amount,int payMethod, String outTradeType,
      String outTradeSn, String note) async {
    return await walletTradeRemote.purchaseWeny(
        bank, amount,payMethod, outTradeType, outTradeSn, note);
  }

  @override
  Future<PurchaseOR> getPurchaseRecord(String record_sn) async {
    if (StringUtil.isEmpty(record_sn)) {
      return null;
    }
    return await walletRecordRemote.getPurchaseRecord(record_sn);
  }

  @override
  Future<PurchaseOR> getPurchaseRecordPerson(
      String owner, String record_sn) async {
    if (StringUtil.isEmpty(record_sn)) {
      return null;
    }
    return await walletRecordRemote.getPurchaseRecordOfPerson(owner, record_sn);
  }

  @override
  Future<WenyBank> getWenyBank(String bankid) async {
    return await walletAccountRemote.getWenyBankAcount(bankid);
  }
}
