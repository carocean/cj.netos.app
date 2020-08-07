import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';

class RecommenderConfig {
  //最大每次推荐的内空数
  int maxRecommendItemCount;
  double countryRecommendWeight; //国家级别的推荐权重
  double normalRecommendWeight; //常规级别的推荐权重
  double provinceRecommendWeight; //省级别的推荐权重
  double cityRecommendWeight; //市级别的推荐权重
  double districtRecommendWeight; //区县级别的推荐权重
  double townRecommendWeight; //乡镇级别的推荐权重
  double weightCapacity;

  RecommenderConfig(
      {this.maxRecommendItemCount,
      this.countryRecommendWeight,
      this.normalRecommendWeight,
      this.provinceRecommendWeight,
      this.cityRecommendWeight,
      this.districtRecommendWeight,
      this.townRecommendWeight,
      this.weightCapacity}); //每权可分配的内容数

}

class ContentItem {
  String id; //标识来自由pointer的类型+标识的md5，所以在所有流量池中都是唯一的，只要告诉内容物在哪个池，就可以在池中找到它
  ItemPointer pointer;
  String box; //归属的内容盒
  LatLng location; //内容物可能有位置属性
  String upstreamPool; //来自上游的流量池，一般是低级池
  int ctime;
  String pool; //多一个多余字段，用于客户端识别是哪个池的内容
  bool isBubbled;

  ContentItem(
      {this.id,
      this.pointer,
      this.box,
      this.location,
      this.upstreamPool,
      this.ctime,
      this.pool,
      this.isBubbled}); //是否已冒泡了

}

class ItemPointer {
  String id;
  String type;
  String creator;
  int ctime;

  ItemPointer({this.id, this.type, this.creator, this.ctime});
}

mixin IChasechainRecommenderRemote {
  Future<List<ContentItem>> pullItem(String towncode);

  Future<RecommenderConfig> getPersonRecommenderConfig();

  Future<void> configPersonRecommender(
    int maxRecommendItemCount,
    double countryRecommendWeight,
    double normalRecommendWeight,
    double provinceRecommendWeight,
    double cityRecommendWeight,
    districtRecommendWeight,
    townRecommendWeight,
  );
}

class ChasechainRecommenderRemote
    implements IChasechainRecommenderRemote, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  IRemotePorts get remotePorts => site.getService('@.remote.ports');

  get recommenderPorts =>
      site.getService('@.prop.ports.chasechain.recommender');

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
  }

  @override
  Future<void> configPersonRecommender(
      int maxRecommendItemCount,
      double countryRecommendWeight,
      double normalRecommendWeight,
      double provinceRecommendWeight,
      double cityRecommendWeight,
      districtRecommendWeight,
      townRecommendWeight) async {
    await remotePorts.portGET(
      recommenderPorts,
      'configPersonRecommender',
      parameters: {
        'cityRecommendWeight': cityRecommendWeight,
        'countryRecommendWeight': countryRecommendWeight,
        'districtRecommendWeight': districtRecommendWeight,
        'maxRecommendItemCount': maxRecommendItemCount,
        'normalRecommendWeight': normalRecommendWeight,
        'provinceRecommendWeight': provinceRecommendWeight,
        'townRecommendWeight': townRecommendWeight,
      },
    );
  }

  @override
  Future<RecommenderConfig> getPersonRecommenderConfig() async {
    var obj = await remotePorts.portGET(
      recommenderPorts,
      'getPersonRecommenderConfig',
    );
    if (obj == null) {
      return null;
    }
    return RecommenderConfig(
      cityRecommendWeight: obj['cityRecommendWeight'],
      countryRecommendWeight: obj['countryRecommendWeight'],
      districtRecommendWeight: obj['districtRecommendWeight'],
      maxRecommendItemCount: obj['maxRecommendItemCount'],
      normalRecommendWeight: obj['normalRecommendWeight'],
      provinceRecommendWeight: obj['provinceRecommendWeight'],
      townRecommendWeight: obj['townRecommendWeight'],
      weightCapacity: obj['weightCapacity'],
    );
  }

  @override
  Future<List<ContentItem>> pullItem(String towncode) async {
    var list = await remotePorts.portGET(
      recommenderPorts,
      'pullItem',
      parameters: {
        'towncode': towncode,
      },
    );
    List<ContentItem> items = [];
    for (var obj in list) {
      var objPointer = obj['pointer'];
      var pointer = ItemPointer(
        id: objPointer['id'],
        ctime: objPointer['ctime'],
        type: objPointer['type'],
        creator: objPointer['creator'],
      );
      var location =
          obj['location'] != null ? LatLng.fromJson(obj['location']) : null;
      items.add(
        ContentItem(
          ctime: obj['ctime'],
          id: obj['id'],
          location: location,
          box: obj['box'],
          isBubbled: obj['isBubbled'],
          pointer: pointer,
          pool: obj['pool'],
          upstreamPool: obj['upstreamPool'],
        ),
      );
    }
    return items;
  }
}
