#import <Foundation/Foundation.h>
#import "SqidsOptions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SqidsOptions

- (instancetype)initWithAlphabet:(NSString * _Nullable)alphabet
                       minLength:(NSNumber * _Nullable)minLength
                       blocklist:(NSSet<NSString *> * _Nullable)blocklist {
    if (self = [super init]) {
        self.alphabet = alphabet;
        self.minLength = minLength;
        self.blocklist = blocklist;
    }
    return self;
}

- (id)copyWithZone:(NSZone * _Nullable)zone {
    return [[SqidsOptions allocWithZone:zone] initWithAlphabet:self.alphabet
                                                     minLength:self.minLength
                                                     blocklist:self.blocklist];
}

@end

NS_ASSUME_NONNULL_END
