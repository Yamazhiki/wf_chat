//
// Created by 王斌 on 2020/4/2.
// Copyright (c) 2020 Yamazhiki. All rights reserved.
//

#import "WFChatNetworkServicePlugin.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFChatNetworkServicePlugin+ConnectionStatusDelegate.h"
#import "WFChatNetworkServicePlugin+ReceiveMessageDelegate.h"
#import "WFChatNetworkServicePlugin+User.h"
#import "WFChatNetworkServicePlugin+Conversation.h"
#import "WFChatNetworkServicePlugin+Message.h"

NSString *const WF_CONNECT = @"connect";
NSString *const WF_IS_LOGIN = @"isLogin";
NSString *const WF_GET_CLIENT_ID = @"getClientId";
NSString *const WF_SERVER_ADDRESS = @"serverAddress";
NSString *const WF_SERVER_DELTA_TIME = @"serverDeltaTime";
NSString *const WF_DISCONNECT = @"disconnect";

NSString *const WF_METHOD_CHANNEL = @"plugin.newstyle.flutter.io/wf_method";
NSString *const WF_EVENT_CHANNEL = @"plugin.newstyle.flutter.io/wf_event";

@interface WFChatNetworkServicePlugin () <FlutterStreamHandler>
@end


@implementation WFChatNetworkServicePlugin {
    FlutterEventSink _eventSink;
}

- (instancetype)init {
    self = [super init];
    return self;
}


#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    WFChatNetworkServicePlugin *plugin = [[WFChatNetworkServicePlugin alloc] init];
    FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:WF_METHOD_CHANNEL binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:plugin channel:methodChannel];

    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:WF_EVENT_CHANNEL binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:plugin];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSDictionary *params = call.arguments;
    if ([WF_GET_CLIENT_ID isEqualToString:call.method]) {
        result(WFCCNetworkService.sharedInstance.getClientId);
    } else if ([WF_CONNECT isEqualToString:call.method]) {
        if ([call.arguments isKindOfClass:[NSArray class]]) {
            NSArray *array = call.arguments;
            [WFCCNetworkService.sharedInstance connect:array.firstObject token:array.lastObject];
            result(@(WFChatNetworkServiceStatusNone));
        } else {
            result(@(WFChatNetworkServiceStatusLoginParamsError));
        }
    } else if ([WF_SERVER_ADDRESS isEqualToString:call.method]) {
        [WFCCNetworkService.sharedInstance setServerAddress:call.arguments];
        result(@(WFChatNetworkServiceStatusNone));
    } else if ([WF_DISCONNECT isEqualToString:call.method]) {
        NSNumber *number = @(NO);
        if (call.arguments) {
            number = call.arguments;
        }
        [WFCCNetworkService.sharedInstance disconnect:number.boolValue];
        result(@(WFChatNetworkServiceStatusNone));
    } else if ([WF_IS_LOGIN isEqualToString:call.method]) {
        result(@( [WFCCNetworkService.sharedInstance isLogined]));
    } else if ([WF_SERVER_DELTA_TIME isEqualToString:call.method]) {
        result(@(WFCCNetworkService.sharedInstance.serverDeltaTime));
    }
#pragma mark 用户相关 -----
    if ([@"getUserInfo" isEqualToString:method]) {
        result([self getUserInfo:params[@"userId"] refresh:[params[@"refresh"] boolValue]]);
    } else if ([@"searchUser" isEqualToString:method]) {
        [self searchUser:params[@"keyword"]
              searchType:[params[@"searchType"] boolValue]
                    page:[params[@"page"] intValue]
                   block:^(NSArray *users, int code) {
                       result(@{@"users": users ? (id) users : [NSNull null], @"code": @(code)});
                   }];
    }
#pragma mark 会话相关 -----
    if ([@"getConversationInfos" isEqualToString:method]) {
        result([self getConversationInfos:params]);
    } else if ([@"searchConversation" isEqualToString:method]) {
        result([self searchConversation:params]);
    } else if ([@"removeConversation" isEqualToString:method]) {
        [self removeConversation:params];
    } else if ([@"setDraftConversation" isEqualToString:method]) {
        [self setDraftConversation:params];
    } else if ([@"setTopConversation" isEqualToString:method]) {
        [self setTopConversation:params block:^(int i) {
            result(@(i));
        }];
    } else if ([@"setSilentConversation" isEqualToString:method]) {
        [self setSilentConversation:params block:^(int i) {
            result(@(i));
        }];
    }
#pragma mark 消息相关 -----
    if ([@"sendMessage" isEqualToString:method]) {
        result([self sendMessage:params]);
    } else if ([@"searchMessage" isEqualToString:method]) {
        result([self searchMessage:params]);
    }

}

#pragma mark - FlutterStreamHandler

- (FlutterError *_Nullable)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    _eventSink = events;
    _eventSink(@{
            @"type": @(WFChatEventTypeConnectStatus),
            @"status": @0,
    });
    _eventSink(@{
            @"type": @(WFChatEventTypeSendResult),
            @"status": @1001,
    });
    _eventSink(@{
            @"type": @(WFChatEventTypeConnectStatus),
            @"status": @1,
    });
    WFCCNetworkService.sharedInstance.connectionStatusDelegate = self;
    WFCCNetworkService.sharedInstance.receiveMessageDelegate = self;
    [self registerMessageNotification];
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id)arguments {
    [self removeMessageNotification];
    _eventSink = nil;
    return nil;
}


@end
