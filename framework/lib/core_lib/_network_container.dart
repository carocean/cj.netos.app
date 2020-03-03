import 'package:framework/core_lib/_peer.dart';

mixin ILogicNetworkContainer {
  set peer(IPeer peer) {}

  void addNetwork(ILogicNetwork network) {}

  ILogicNetwork openNetwork(String networkName,
      {ListenMode listenMode, EndOrientation endOrientation}) {}

  void closeNetwork(String networkName,{bool leave}) {}

}

class DefaultLogicNetworkContainer implements ILogicNetworkContainer {
  Map<String, ILogicNetwork> _networks = {};
  IPeer _peer;

  @override
  void addNetwork(ILogicNetwork network) {
    if (!_networks.containsKey(network.networkName)) {
      return;
    }
    _networks[network.networkName] = network;
  }

  @override
  ILogicNetwork openNetwork(String networkName,
      {ListenMode listenMode, EndOrientation endOrientation}) {
    if (_networks.containsKey(networkName)) {
      return _networks[networkName];
    }
    var nw = _peer.listen(
        networkName,
        endOrientation ?? EndOrientation.frontend,
        listenMode ?? ListenMode.downstream);
    _networks[networkName] = nw;
    return nw;
  }

  @override
  void set peer(IPeer peer) {
    _peer = peer;
  }

  @override
  void closeNetwork(String networkName,{bool leave}) {
    ILogicNetwork nw=_networks[networkName];
    if(nw==null) {
      return;
    }
    if(leave!=null&&leave) {
      nw.leave();
    }
    _networks.remove(networkName);
  }
}
