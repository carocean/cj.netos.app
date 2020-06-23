import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

mixin IWyBankRemote {
  Future<BankInfo> getWenyBankByLicence(String licence) {}
}

class WybankRemote implements IWyBankRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');


  get wybankPorts => site.getService('@.prop.ports.wybank');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }

  @override
  Future<BankInfo> getWenyBankByLicence(String licence) async {
    var map = await remotePorts.portGET(
      wybankPorts,
      'getWenyBankByLicence',
      parameters: {
        'licence': licence,
      },
    );
    if (map == null) {
      return null;
    }
    return BankInfo(
      title: map['title'],
      id: map['id'],
      state: (map['state'] as double).floor(),
      creator: map['creator'],
      ctime: map['ctime'],
      icon: map['icon'],
      districtCode: map['districtCode'],
      districtTitle: map['districtTitle'],
      licence: map['licence'],
      principalRatio: map['principalRatio'],
      reserveRatio: map['reserveRatio'],
      freeRatio: map['freeRatio'],
    );
  }
}
