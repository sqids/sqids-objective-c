#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SqidsOptions : NSObject <NSCopying>

@property (nonatomic, copy, nullable) NSString *alphabet;
@property (nonatomic, nullable) NSNumber *minLength;
@property (nonatomic, copy, nullable) NSSet<NSString *> *blocklist;

- (instancetype)initWithAlphabet:(NSString * _Nullable)alphabet
                       minLength:(NSNumber * _Nullable)minLength
                       blocklist:(NSSet<NSString *> * _Nullable)blocklist;

@end

NS_ASSUME_NONNULL_END
