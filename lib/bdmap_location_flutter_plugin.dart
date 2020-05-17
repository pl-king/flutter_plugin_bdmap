import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// 百度地图定位flutter插件
/// 实现基本定位需求，能够返回全球经纬度、逆地理信息、周边poi、位置语义化等丰富定位结果信息
class LocationFlutterPlugin {
  /// flutter端主动调用原生端方法
  static const MethodChannel _channel =
      const MethodChannel('bdmap_location_flutter_plugin');

  /// 原生端主动回传结果数据到flutter端
  static const EventChannel _stream =
      const EventChannel("bdmap_location_flutter_plugin_stream");

  /// 判断flutter app 是在android系统上运行还是ios系统上运行
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 设置ios的key，android可以直接在清单文件中设置
  static Future<bool> setApiKey(String key) async {
    return await _channel.invokeMethod("setApiKey", key);
  }

  /// 设置定位SDK参数
  /// android端目前支持设置如下定位参数:
  ///      'coorType': "bd09ll",    // 设置返回的位置坐标系类型
  ///      'isNeedAddres': true,   // true为需要返回地址信息, false为不需要返回地址信息
  ///      'isNeedAltitude': true,   // true为需要返回海拔高度, false为不需要返回海拔高度
  ///      'isNeedLocationPoiList': true,  // true为需要返回附近poi列表, false为不需要返回poi列表
  ///      'scanspan': 2000, // 设置发起定位请求时间间隔
  ///      'openGps': true, // true为允许开启gps，false为不允许开启gps
  ///      'isNeedLocationDescribe': true, // true为需要返回位置语义化信息，false为不需要返回位置语义化信息
  ///      'locationMode': 1, // 设置定位模式: 1为高精度模式，2为低功耗模式，3为仅使用设备模式
  ///      'isNeedNewVersionRgc': true // 是否需要最新版本rgc数据,true为需要,false为不需要
  /// ios端目前支持设置如下定位参数:
  ///        'desiredAccuracy': "kCLLocationAccuracyBest", // 设置预期精度参数
  ///        'locationTimeout': 10, // 设置位置获取超时时间
  ///        'reGeocodeTimeout': 10, // 设置获取地址信息超时时间
  ///        'activityType': "CLActivityTypeAutomotiveNavigation", // 设置应用位置类型
  ///        'BMKLocationCoordinateType': "BMKLocationCoordinateTypeBMK09LL",  // 设置返回位置的坐标系类型
  ///        'isNeedNewVersionRgc': true // 是否需要最新版本rgc数据,true为需要,false为不需要
  void prepareLoc(Map androidMap, Map iosMap)  {
    Map map;
    if (Platform.isAndroid) {
      map = androidMap;
    } else {
      map = iosMap;
    }
     _channel.invokeMethod("updateOption", map);
     return;
  }

  /// 启动定位
  void startLocation() {
    _channel.invokeMethod('startLocation');
    return;
  }

  /// 停止定位
  void stopLocation() {
    _channel.invokeMethod('stopLocation');
    return;
  }

  /// 原生端回传键值对map到flutter端
  /// map中key为isInChina对应的value，如果为1则判断是在国内，为0则判断是在国外
  /// map中存在key为nearby则判断为已到达设置监听位置附近
  Stream<Map<String, Object>> onResultCallback() {
    Stream<Map<String, Object>> _resultMap;
    if (_resultMap == null) {
      _resultMap = _stream
          .receiveBroadcastStream()
          .map<Map<String, Object>>(
              (element) => element.cast<String, Object>());
    }
    return _resultMap;
  }

  /// 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    await PermissionHandler()
        .requestPermissions([PermissionGroup.location]);

    // 申请结果
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    if (permission == PermissionStatus.granted) {
      print("定位权限申请通过");
    } else {
      print("定位权限申请不通过");
    }

  }
}
