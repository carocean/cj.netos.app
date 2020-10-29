import 'dart:io';

import 'package:framework/core_lib/_remote_ports.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class ProductVersion {
  String product;
  String os;
  String version;
  String readmeFile;
  String pubTime;
  int pubType;
  int forceUpgrade;
  String note;

  List<String> get functionList {
    if (StringUtil.isEmpty(note)) {
      return [];
    }
    List<String> list = note.split(';');
    return list;
  }

  ProductVersion({
    this.product,
    this.os,
    this.version,
    this.readmeFile,
    this.pubTime,
    this.pubType,
    this.forceUpgrade,
    this.note,
  });

  ProductVersion.parse(obj) {
    this.product = obj['product'];
    this.os = obj['os'];
    this.version = obj['version'];
    this.readmeFile = obj['readmeFile'];
    this.pubTime = obj['pubTime'];
    this.pubType = obj['pubType'];
    this.forceUpgrade = obj['forceUpgrade'];
    this.note = obj['note'];
  }
}

class UpgradeInfo {
  bool canUpgrade;
  Map<String, dynamic> versions;
  ProductVersion productVersion;
  bool isHide = false;
  String newestVersionDownloadUrl;

  String get currentVersion {
    if (Platform.isAndroid) {
      return versions['android'];
    }
    return versions['ios'];
  }

  UpgradeInfo(
      {this.canUpgrade,
      this.versions,
      this.productVersion,
      this.newestVersionDownloadUrl});
}

mixin IAppUpgrade {
  Future<bool> isUpgrade(Map<String, String> versions) {}

  Future<UpgradeInfo> loadUpgradeInfo();

  Future<Map<String, dynamic>> getNewestVersion(String product);

  Future<void> downloadApp(void Function(int, int,String) onReceiveProgress);
}

class DefaultAppUpgrade implements IAppUpgrade, IServiceBuilder {
  IServiceProvider site;

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  String get productPortsUrl => site.getService('@.prop.ports.uc.product');

  UpgradeInfo _upgradeInfo;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<UpgradeInfo> loadUpgradeInfo() async {
    if (_upgradeInfo != null) {
      return _upgradeInfo;
    }
    var versions = await getNewestVersion('microgeo');
    String url;
    ProductVersion version;
    if (Platform.isAndroid) {
      version = await getVersion('microgeo', 'android', versions['android']);
      url = await getNewestVersionDownloadUrl('microgeo', 'android');
    } else if (Platform.isIOS) {
      version = await getVersion('microgeo', 'ios', versions['ios']);
      url = await getNewestVersionDownloadUrl('microgeo', 'ios');
    }
    _upgradeInfo = UpgradeInfo(
      canUpgrade: await isUpgrade(versions),
      versions: versions,
      productVersion: version,
      newestVersionDownloadUrl: url,
    );

    return _upgradeInfo;
  }

  @override
  Future<bool> isUpgrade(Map<String, dynamic> versions) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String v;
    if (Platform.isAndroid) {
      v = versions['android'];
    } else if (Platform.isIOS) {
      v = versions['ios'];
    }
    if (StringUtil.isEmpty(v)) {
      return false;
    }
    return v.compareTo(localVersion) > 0;
  }

  @override
  Future<Map<String, dynamic>> getNewestVersion(String product) async {
    var obj = await remotePorts.portGET(
      productPortsUrl,
      'getNewestVersion',
      parameters: {
        'id': product,
      },
    );
    return obj;
  }

  Future<ProductVersion> getVersion(String product, String os, version) async {
    var obj = await remotePorts.portGET(
      productPortsUrl,
      'getVersion',
      parameters: {
        'product': product,
        'os': os,
        'version': version,
      },
    );
    if (obj == null) {
      return obj;
    }
    return ProductVersion.parse(obj);
  }

  Future<String> getNewestVersionDownloadUrl(String product, String os) async {
    return await remotePorts.portGET(
      productPortsUrl,
      'getNewestVersionDownloadUrl',
      parameters: {
        'product': product,
        'os': os,
      },
    );
  }

  @override
  Future<void> downloadApp(void Function(int, int,String) onReceiveProgress) async {
    var url = _upgradeInfo.newestVersionDownloadUrl;
    var pos = url.lastIndexOf('/');
    var fn = url.substring(pos + 1);
    var dir = await getExternalStorageDirectory();
    var file = '${dir.path}';
    var localFile = '$file/$fn';
    await remotePorts.download(
      url,
      localFile,
      onReceiveProgress: (i,j){
        if(onReceiveProgress==null) {
          return;
        }
        onReceiveProgress(i,j,localFile);
      },
    );
  }
}
