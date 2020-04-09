//
// Created by 王斌 on 2020/4/3.
//

#import "NSArray+Util.h"
#import "NSObject+Dictionary.h"


@implementation NSArray (Util)
- (NSArray *)dictionaryArray {
    __block NSMutableArray *rlt = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {
        [rlt addObject:obj.dictionaryValue];
    }];
    return rlt;
}
@end