import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wf_chat/model/event.dart';
import 'package:wf_chat/model/message.dart';

import 'model/conversation.dart';
import 'model/user.dart';

/// 野火SDK
class WFChat {
  static WFChat _instance;

  static const String _getClientId = "getClientId";
  static const String _login = "connect";
  static const String _serverAddress = "serverAddress";
  static const String _disconnect = "disconnect";
  static const String _serverDeltaTime = "serverDeltaTime";

  factory WFChat() {
    if (_instance == null) {
      final MethodChannel _methodChannel = MethodChannel('plugin.newstyle.flutter.io/wf_method');
      final EventChannel _eventChannel = EventChannel("plugin.newstyle.flutter.io/wf_event");

      // ignore: close_sinks
      final StreamController _connectStream = StreamController<IMEventConnect>();
      // ignore: close_sinks
      final StreamController _sendResultStream = StreamController<IMEventSendResult>();
      _eventChannel.receiveBroadcastStream().listen((value) {
        final v = Map<String, dynamic>.from(value);
        final event = IMEvent.fromJson(v);
        switch (event.type) {
          case 1: //Connecting Event
            _connectStream.sink.add(IMEventConnect.fromJson(v));
            break;
          case 2:
            _sendResultStream.sink.add(IMEventSendResult.fromJson(v));
            break;
          default:
            break;
        }
      });
      _instance = WFChat._(_methodChannel, _connectStream, _sendResultStream);
    }
    return _instance;
  }

  WFChat._(this._methodChannel, this._connectStream, this._sendResultStream);

  final MethodChannel _methodChannel;
  final StreamController<IMEventConnect> _connectStream;
  final StreamController<IMEventSendResult> _sendResultStream;

  Stream<IMEventConnect> get connectStatus => _connectStream.stream.asBroadcastStream();

  Stream<IMEventSendResult> get sendResult => _sendResultStream.stream.asBroadcastStream();

  /// 设置IM服务器地址
  Future<void> setServerAddress(String endpoint) {
    return _methodChannel.invokeMethod(_serverAddress);
  }

  ///登录
  /// int 0 SDK受理了登录请求
  /// int 1 参数错误
  Future<int> connect(String userId, String token) {
    return _methodChannel.invokeMethod(_login, [userId, token]).then((value) => value);
  }

  /// 断开IM连接
  Future<void> disconnect(bool clearSession) {
    return _methodChannel.invokeMethod(_disconnect);
  }

  /// 获取IM服务器与本地的时间差
  Future<double> serverDeltaTime() {
    return _methodChannel.invokeMethod(_serverDeltaTime).then((value) => value);
  }

  /// 获取用户信息
  Future<IMUser> getUserInfo(String userId, bool refresh) {
    return _methodChannel.invokeMapMethod<String, dynamic>("getUserInfo",
        {"userId": userId, "refresh": refresh}).then((value) => IMUser.fromJson(value));
  }

  /// 搜索用户
  /// keyword 搜索关键词
  /// searchType 搜索类型 0: 一般搜索(模糊搜索displayName ,精确搜索name和电话)，1:确匹配name和电话 2:精确匹配name 3:确匹配电话
  Future<IMSearchUser> searchUser(String keyword, {int searchType = 0, int page = 0}) {
    return _methodChannel.invokeMapMethod<String, dynamic>("searchUser", {
      "keyword": keyword,
      "searchType": searchType,
      "page": page
    }).then((value) => IMSearchUser.fromJson(value));
  }

  /// 获取会话列表
  /// conversationTypes 0单人，1群聊 2聊天室 3频道
  /// lines [0]
  Future<List<IMConversationInfo>> getConversationInfos(
      {List<int> conversationTypes = const [0, 1, 2, 3], List<int> lines = const [0]}) {
    return _methodChannel.invokeListMethod<dynamic>("getConversationInfos", {
      "conversationTypes": conversationTypes,
      "lines": lines
    }).then((value) => value.map((e) => IMConversationInfo.fromJson(e)).toList());
  }

  Future<List<IMConversationSearchInfo>> searchConversation(String keyword,
      {List<int> inConversation = const [0, 1, 2, 3], List lines = const [0]}) {
    return _methodChannel.invokeListMethod<dynamic>("searchConversation", {
      "keyword": keyword,
      "inConversation": inConversation,
      "lines": lines
    }).then((value) => value.map((e) => IMConversationSearchInfo.fromJson(e)).toList());
  }

  ///删除会话
  Future<void> removeConversation(IMConversation conversation, {bool clearMessage = true}) {
    return _methodChannel.invokeMethod<void>("removeConversation",
        {"conversation": conversation.toJson(), "clearMessage": clearMessage});
  }

  ///设置会话草稿
  Future<int> setDraftConversation(IMConversation conversation, String draft) {
    return _methodChannel.invokeMethod<int>(
        "setDraftConversation", {"conversation": conversation.toJson(), "draft": draft});
  }

  // 会话指定
  Future<int> setTopConversation(IMConversation conversation, bool isTop) {
    return _methodChannel.invokeMethod<int>(
        "setTopConversation", {"conversation": conversation.toJson(), "isTop": isTop});
  }

  // 会话草稿
  Future<int> setSilentConversation(IMConversation conversation, bool isDraft) {
    return _methodChannel.invokeMethod<int>(
        "setSilentConversation", {"conversation": conversation.toJson(), "isSilent": isDraft});
  }

  /// 发送消息
  Future<IMMessage> sendMessage(IMConversation conversation, int type, dynamic content,
      {List<String> toUser = const [], int expireDuration = 0}) {
    return _methodChannel.invokeMethod("sendMessge", {
      "conversation": conversation.toJson(),
      "type": type,
      "content": content,
      "toUsers": toUser,
      "expireDuration": expireDuration
    });
  }

  /// 搜索消息
  Future<List<IMMessage>> searchMessage(IMConversation conversation, String keyword) {
    return _methodChannel.invokeListMethod("searchMessage", {
      "conversation": conversation.toJson(),
      "keyword": keyword
    }).then((value) => value.map((e) => IMMessage.fromJson(e)).toList());
  }
}
