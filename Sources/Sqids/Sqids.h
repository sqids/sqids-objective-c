#import <Foundation/Foundation.h>
#import <Sqids/SqidsOptions.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const SqidsErrorDomain;

NS_ERROR_ENUM(SqidsErrorDomain) {
    SqidsErrorRegenerationReachedMaxAttempts = -1000
};

@interface Sqids : NSObject

- (instancetype)initWithOptions:(SqidsOptions *)options;

- (NSString * _Nullable)encode:(NSArray <NSNumber *> *)numbers
                         error:(NSError * _Nullable *)error __attribute__((swift_error(nonnull_error)));

- (NSArray<NSNumber *> *)decode:(NSString *)id_;

@end

NS_ASSUME_NONNULL_END
