//
// Created by 王斌 on 2020/4/2.
// Copyright (c) 2020 Yamazhiki. All rights reserved.
//

#import "WFChatNetworkServicePlugin+ConnectionStatusDelegate.h"


@implementation WFChatNetworkServicePlugin (ConnectionStatusDelegate)
- (void)onConnectionStatusChanged:(ConnectionStatus)status {
    self.eventSink(@{
            @"type": @(WFChatEventTypeConnectStatus),
            @"status": @(status)
    });
}
@end