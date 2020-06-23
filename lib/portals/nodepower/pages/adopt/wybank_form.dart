import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class WybankForm {
  String title;
  String icon;
  String licence;
  String districtTitle;
  String districtCode;
  String creator;
  List<String> ispManagers;
  double serviceFeeRatio;
  double reserveRatio;
  double principalRatio;
  List<TtmInfo> ttmConfig;
  double platformRatio;
  double ispRatio;
  double laRatio;
  double absorbRatio;

  WybankForm(
      {this.title,
      this.icon,
      this.licence,
      this.districtTitle,
      this.districtCode,
      this.creator,
      this.ispManagers,
      this.serviceFeeRatio,
      this.reserveRatio,
      this.principalRatio,
      this.ttmConfig,
      this.platformRatio,
      this.ispRatio,
      this.laRatio,
      this.absorbRatio});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
      'licence': licence,
      'districtTitle': districtTitle,
      'districtCode': districtCode,
      'creator': creator,
      'ispManagers': ispManagers,
      'serviceFeeRatio': double.parse(serviceFeeRatio.toStringAsFixed(4)),
      'reserveRatio': double.parse(reserveRatio.toStringAsFixed(4)),
      'principalRatio': double.parse(principalRatio.toStringAsFixed(4)),
      'ttmConfig': ttmConfig.map((info) {
        return info.toMap();
      }).toList(),
      'platformRatio': double.parse(platformRatio.toStringAsFixed(4)),
      'ispRatio': double.parse(ispRatio.toStringAsFixed(4)),
      'laRatio': double.parse(laRatio.toStringAsFixed(4)),
      'absorbRatio': double.parse(absorbRatio.toStringAsFixed(4)),
    };
  }

  bool isValid() {
    if (ttmConfig.isEmpty) {
      return false;
    }
    if (serviceFeeRatio == 0.0 || reserveRatio == 0.00) {
      return false;
    }
    if ((platformRatio + ispRatio + laRatio + absorbRatio) != 1) {
      return false;
    }
    return true;
  }
}

class TtmInfo {
  double ttm;
  int maxAmount;
  int minAmount;

  TtmInfo({this.ttm, this.maxAmount, this.minAmount});

  Map<String, dynamic> toMap() {
    return {
      'ttm': double.parse(ttm.toStringAsFixed(4)),
      'maxAmount': maxAmount,
      'minAmount': minAmount,
    };
  }
}

final wybankConfigTemplateContainer = WybankConfigTemplateContainer();

class WybankConfigTemplateContainer {
  final List<WybankConfigTemplate> templates = [];
  bool _isloaded = false;

  Future<void> load() async {
    if (_isloaded) {
      return;
    }
    var yaml = await rootBundle.loadString(
      'lib/portals/nodepower/assets/wybank_config_template.yaml',
    );
    var list = await loadYaml(yaml);
    for (var item in list) {
      var ttmList = item['ttmConfig'];
      var ttmConfig = <TtmInfo>[];
      for (var ttm in ttmList) {
        ttmConfig.add(
          TtmInfo(
            maxAmount: ttm['maxAmount'],
            minAmount: ttm['minAmount'],
            ttm: ttm['ttm'],
          ),
        );
      }
      templates.add(
        WybankConfigTemplate(
          template: item['template'],
          absorbRatio: item['absorbRatio'],
          ispRatio: item['ispRatio'],
          laRatio: item['laRatio'],
          platformRatio: item['platformRatio'],
          reserveRatio: item['reserveRatio'],
          serviceFeeRatio: item['serviceFeeRatio'],
          ttmConfig: ttmConfig,
        ),
      );
    }
    _isloaded = true;
  }
}

class WybankConfigTemplate {
  String template;
  double serviceFeeRatio;
  double reserveRatio;
  List<TtmInfo> ttmConfig;
  double platformRatio;
  double ispRatio;
  double laRatio;
  double absorbRatio;

  WybankConfigTemplate(
      {this.template,
      this.serviceFeeRatio,
      this.reserveRatio,
      this.ttmConfig,
      this.platformRatio,
      this.ispRatio,
      this.laRatio,
      this.absorbRatio});
}
