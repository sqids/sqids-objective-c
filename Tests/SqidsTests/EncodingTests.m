#import <Sqids/Sqids.h>
#import <XCTest/XCTest.h>

@interface EncodingTests : XCTestCase

@end

@implementation EncodingTests

- (void)testSimple {
    Sqids *sqids = [[Sqids alloc] init];

    NSArray<NSNumber *> *numbers = @[@1, @2, @3];
    NSString *id_ = @"86Rf07";

    XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
    XCTAssertEqualObjects([sqids decode:id_], numbers);
}

- (void)testDifferentInputs {
    Sqids *sqids = [[Sqids alloc] init];

    NSArray<NSNumber *> *numbers = @[@0, @0, @0, @1, @2, @3, @100, @1000, @100000, @1000000, @(NSUIntegerMax)];
    XCTAssertEqualObjects([sqids decode:[sqids encode:numbers error:nil]], numbers);
}

- (void)testIncrementalNumbers {
    Sqids *sqids = [[Sqids alloc] init];

    NSDictionary<NSString *, NSArray<NSNumber *> *> *ids = @{
        @"bM": @[@0],
        @"Uk": @[@1],
        @"gb": @[@2],
        @"Ef": @[@3],
        @"Vq": @[@4],
        @"uw": @[@5],
        @"OI": @[@6],
        @"AX": @[@7],
        @"p6": @[@8],
        @"nJ": @[@9],
    };

    [ids enumerateKeysAndObjectsUsingBlock:^(NSString *id_, NSArray<NSNumber *> *numbers, BOOL *stop) {
        XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
        XCTAssertEqualObjects([sqids decode:id_], numbers);
    }];
}

- (void)testIncrementalNumbersSameIndex0 {
    Sqids *sqids = [[Sqids alloc] init];

    NSDictionary<NSString *, NSArray<NSNumber *> *> *ids = @{
        @"SvIz": @[@0, @0],
        @"n3qa": @[@0, @1],
        @"tryF": @[@0, @2],
        @"eg6q": @[@0, @3],
        @"rSCF": @[@0, @4],
        @"sR8x": @[@0, @5],
        @"uY2M": @[@0, @6],
        @"74dI": @[@0, @7],
        @"30WX": @[@0, @8],
        @"moxr": @[@0, @9],
    };

    [ids enumerateKeysAndObjectsUsingBlock:^(NSString *id_, NSArray<NSNumber *> *numbers, BOOL *stop) {
        XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
        XCTAssertEqualObjects([sqids decode:id_], numbers);
    }];
}

- (void)testIncrementalNumbersSameIndex1 {
    Sqids *sqids = [[Sqids alloc] init];

    NSDictionary<NSString *, NSArray<NSNumber *> *> *ids = @{
        @"SvIz": @[@0, @0],
        @"nWqP": @[@1, @0],
        @"tSyw": @[@2, @0],
        @"eX68": @[@3, @0],
        @"rxCY": @[@4, @0],
        @"sV8a": @[@5, @0],
        @"uf2K": @[@6, @0],
        @"7Cdk": @[@7, @0],
        @"3aWP": @[@8, @0],
        @"m2xn": @[@9, @0],
    };

    [ids enumerateKeysAndObjectsUsingBlock:^(NSString *id_, NSArray<NSNumber *> *numbers, BOOL *stop) {
        XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
        XCTAssertEqualObjects([sqids decode:id_], numbers);
    }];
}

- (void)testMultiInput {
    Sqids *sqids = [[Sqids alloc] init];

    NSMutableArray<NSNumber *> *numbers = [NSMutableArray array];
    for (NSUInteger n = 0; n < 100; n++) {
        [numbers addObject:@(n)];
    }

    NSArray<NSNumber *> *output = [sqids decode:[sqids encode:numbers error:nil]];
    XCTAssertEqualObjects(numbers, output);
}

- (void)testEncodingNoNumbers {
    Sqids *sqids = [[Sqids alloc] init];
    XCTAssertEqualObjects([sqids encode:@[] error:nil], @"");
}

- (void)testDecodingEmptyString {
    Sqids *sqids = [[Sqids alloc] init];
    XCTAssertEqualObjects([sqids decode:@""], @[]);
}

- (void)testDecodingInvalidCharacter {
    Sqids *sqids = [[Sqids alloc] init];
    XCTAssertEqualObjects([sqids decode:@"*"], @[]);
}

@end
