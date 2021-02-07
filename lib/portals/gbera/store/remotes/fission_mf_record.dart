import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

mixin IFissionMFCashierRecordRemote {}

class FissionMFCashierRecordRemote
    implements IFissionMFCashierRecordRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get fissionMfCashierPorts =>
      site.getService('@.prop.ports.fission.mf.cashier');

  get fissionMfReceiptPorts =>
      site.getService('@.prop.ports.fission.mf.receipt');

  get fissionMfRecordPorts =>
      site.getService('@.prop.ports.fission.mf.cashier.record');

  @override
  Future<void> builder(IServiceProvider site) {
    this.site = site;
    return null;
  }
}
