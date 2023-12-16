#import <Foundation/Foundation.h>
#import "NSString+Sqids.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSString (Sqids)

- (NSArray<NSString *> *)componentsSeparatedByCharacter {
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:self.length];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (substring) {
            [components addObject:substring];
        }
    }];
    return components;
}

@end

NS_ASSUME_NONNULL_END
