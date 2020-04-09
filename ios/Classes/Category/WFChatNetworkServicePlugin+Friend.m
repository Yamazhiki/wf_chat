//
// Created by 王斌 on 2020/4/7.
//

#import <WFChatClient/WFCCIMService.h>
#import "WFChatNetworkServicePlugin+Friend.h"


@implementation WFChatNetworkServicePlugin (Friend)
- (BOOL)isMyFriend:(NSString *)userId {
    return [WFCCIMService.sharedWFCIMService isMyFriend:userId];
}

- (NSArray<NSString *> *)getMyFriendList:(BOOL)refresh {
    return [WFCCIMService.sharedWFCIMService getMyFriendList:refresh];
}

- (NSArray<WFCCUserInfo *> *)searchFriends:(NSString *)keyword {
    return [WFCCIMService.sharedWFCIMService searchFriends:keyword];
}

- (void)sendFriendRequest:(NSString *)userId
                   reason:(NSString *)reason
                  success:(void (^)(void))successBlock
                    error:(void (^)(int))errorBlock {
    [WFCCIMService.sharedWFCIMService sendFriendRequest:userId
                                                 reason:reason
                                                success:successBlock
                                                  error:errorBlock];
}

- (NSArray<WFCCFriendRequest *> *)getReceivedFriendRequest {
    return [WFCCIMService.sharedWFCIMService getIncommingFriendRequest];
}

- (void)handleFriendRequest:(NSString *)userId
                     accept:(BOOL)accept
                      extra:(NSString *)extra
                    success:(void (^)(void))successBlock
                      error:(void (^)(int))errorBlock {
    [WFCCIMService.sharedWFCIMService handleFriendRequest:userId accept:accept
                                                    extra:extra
                                                  success:successBlock
                                                    error:errorBlock];
}

- (void)setBlackList:(NSString *)userId
       isBlackListed:(BOOL)isBlackListed
             success:(void (^)(void))successBlock
               error:(void (^)(int))errorBlock {
    [WFCCIMService.sharedWFCIMService setBlackList:userId
                                     isBlackListed:isBlackListed
                                           success:successBlock
                                             error:errorBlock];
}


@end