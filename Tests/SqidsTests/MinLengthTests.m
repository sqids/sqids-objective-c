#import <Sqids/Sqids.h>
#import <XCTest/XCTest.h>

@interface Sqids ()

+ (NSUInteger)minLengthLimit;
+ (NSString *)defaultAlphabet;

@end

@interface MinLengthTests : XCTestCase

@end

@implementation MinLengthTests

- (void)testSimple {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.minLength = @(Sqids.defaultAlphabet.length);
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    NSArray<NSNumber *> *numbers = @[@1, @2, @3];
    NSString *id_ = @"86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM";

    XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
    XCTAssertEqualObjects([sqids decode:id_], numbers);
}

- (void)testIncremental {
    NSArray<NSNumber *> *numbers = @[@1, @2, @3];

    NSDictionary<NSNumber *, NSString *> *map = @{
        @6: @"86Rf07",
        @7: @"86Rf07x",
        @8: @"86Rf07xd",
        @9: @"86Rf07xd4",
        @10: @"86Rf07xd4z",
        @11: @"86Rf07xd4zB",
        @12: @"86Rf07xd4zBm",
        @13: @"86Rf07xd4zBmi",
        @(Sqids.defaultAlphabet.length + 0):
            @"86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM",
        @(Sqids.defaultAlphabet.length + 1):
            @"86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy",
        @(Sqids.defaultAlphabet.length + 2):
            @"86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf",
        @(Sqids.defaultAlphabet.length + 3):
            @"86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1",
    };

    [map enumerateKeysAndObjectsUsingBlock:^(NSNumber *minLength, NSString *id_, BOOL *stop) {
        SqidsOptions *options = [[SqidsOptions alloc] init];
        options.minLength = minLength;
        Sqids *sqids = [[Sqids alloc] initWithOptions:options];

        XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
        XCTAssertEqualObjects(@([sqids encode:numbers error:nil].length), minLength);
        XCTAssertEqualObjects([sqids decode:id_], numbers);
    }];
}

- (void)testIncrementalNumbers {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.minLength = @(Sqids.defaultAlphabet.length);
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    NSDictionary<NSString *, NSArray<NSNumber *> *> *ids = @{
        @"SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu": @[@0, @0],
        @"n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc": @[@0, @1],
        @"tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ": @[@0, @2],
        @"eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE": @[@0, @3],
        @"rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX": @[@0, @4],
        @"sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2": @[@0, @5],
        @"uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0": @[@0, @6],
        @"74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy": @[@0, @7],
        @"30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS": @[@0, @8],
        @"moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin": @[@0, @9],
    };

    [ids enumerateKeysAndObjectsUsingBlock:^(NSString *id_, NSArray<NSNumber *> *numbers, BOOL *stop) {
        XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
        XCTAssertEqualObjects([sqids decode:id_], numbers);
    }];
}

- (void)testMinLengths {
    for (NSNumber *minLength in @[@0, @1, @5, @10, @(Sqids.defaultAlphabet.length)]) {
        for (NSArray<NSNumber *> *numbers in @[
            @[@0],
            @[@0, @0, @0, @0, @0],
            @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10],
            @[@100, @200, @300],
            @[@1000, @2000, @3000],
            @[@1000000],
            @[@(NSUIntegerMax)],
        ]) {
            SqidsOptions *options = [[SqidsOptions alloc] init];
            options.minLength = minLength;
            Sqids *sqids = [[Sqids alloc] initWithOptions:options];

            NSString *id_ = [sqids encode:numbers error:nil];
            XCTAssertGreaterThanOrEqual(id_.length, minLength.unsignedIntegerValue);
            XCTAssertEqualObjects([sqids decode:id_], numbers);
        }
    }
}

- (void)testInvalidMinLength {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.minLength = @(-1);
    XCTAssertThrows([[Sqids alloc] initWithOptions:options]);
    options.minLength = @(Sqids.minLengthLimit + 1);
    XCTAssertThrows([[Sqids alloc] initWithOptions:options]);
}

@end
