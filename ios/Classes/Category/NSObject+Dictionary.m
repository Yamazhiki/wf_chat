//
// Created by 王斌 on 2020/4/3.
//

#import "NSObject+Dictionary.h"
#import <objc/runtime.h>


@implementation NSObject (Dictionary)
- (NSDictionary *)dictionaryValue {
    NSMutableArray *propertyKeys = [NSMutableArray array];
    Class currentClass = self.class;
    while ([currentClass superclass]) { // avoid printing NSObject's attributes
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if (propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                [propertyKeys addObject:propertyName];
            }
        }
        free(properties);
        currentClass = [currentClass superclass];
    }
    return [self dictionaryWithValuesForKeys:propertyKeys];
}
@end