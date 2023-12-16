#import <XCTest/XCTest.h>
#import <Sqids/Sqids.h>

@interface BlocklistTests : XCTestCase

@end

@implementation BlocklistTests

- (void)testDefaultBlocklist {
    Sqids *sqids = [[Sqids alloc] init];

    XCTAssertEqualObjects([sqids decode:@"aho1e"], @[@4572721]);
    XCTAssertEqualObjects([sqids encode:@[@4572721] error:nil], @"JExTR");
}

- (void)testEmptyBlocklist {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.blocklist = [NSSet set];
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    XCTAssertEqualObjects([sqids decode:@"aho1e"], @[@4572721]);
    XCTAssertEqualObjects([sqids encode:@[@4572721] error:nil], @"aho1e");
}

- (void)testCustomBlocklist {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.blocklist = [NSSet setWithArray:@[
        @"ArUO", // originally encoded [100000]
    ]];
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    XCTAssertEqualObjects([sqids decode:@"aho1e"], @[@4572721]);
    XCTAssertEqualObjects([sqids encode:@[@4572721] error:nil], @"aho1e");

    XCTAssertEqualObjects([sqids decode:@"ArUO"], @[@100000]);
    XCTAssertEqualObjects([sqids encode:@[@100000] error:nil], @"QyG4");
    XCTAssertEqualObjects([sqids decode:@"QyG4"], @[@100000]);
}

- (void)testBlocklist {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.blocklist = [NSSet setWithArray:@[
        @"JSwXFaosAN", // normal result of 1st encoding, let's block that word on purpose
        @"OCjV9JK64o", // result of 2nd encoding
        @"rBHf", // result of 3rd encoding is `4rBHfOiqd3`, let's block a substring
        @"79SM", // result of 4th encoding is `dyhgw479SM`, let's block the postfix
        @"7tE6", // result of 4th encoding is `7tE6jdAHLe`, let's block the prefix
    ]];
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    XCTAssertEqualObjects([sqids encode:(@[@1000000, @2000000]) error:nil], @"1aYeB7bRUt");
    XCTAssertEqualObjects([sqids decode:@"1aYeB7bRUt"], (@[@1000000, @2000000]));
}

- (void)testDecodingBlocklistWords {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.blocklist = [NSSet setWithArray:@[@"86Rf07", @"se8ojk", @"ARsz1p", @"Q8AI49", @"5sQRZO"]];
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    XCTAssertEqualObjects([sqids decode:@"86Rf07"], (@[@1, @2, @3]));
    XCTAssertEqualObjects([sqids decode:@"se8ojk"], (@[@1, @2, @3]));
    XCTAssertEqualObjects([sqids decode:@"ARsz1p"], (@[@1, @2, @3]));
    XCTAssertEqualObjects([sqids decode:@"Q8AI49"], (@[@1, @2, @3]));
    XCTAssertEqualObjects([sqids decode:@"5sQRZO"], (@[@1, @2, @3]));
}

- (void)testMatchAgainstShortBlocklistWord {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.blocklist = [NSSet setWithArray:@[@"pnd"]];
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    XCTAssertEqualObjects([sqids decode:[sqids encode:@[@1000] error:nil]], @[@1000]);
}

- (void)testBlocklistFilteringInConstructor {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    options.blocklist = [NSSet setWithArray:@[@"sxnzkl"]]; // lowercase blocklist in only-uppercase alphabet
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    NSString *id_ = [sqids encode:@[@1, @2, @3] error:nil];
    NSArray<NSNumber *> *numbers = [sqids decode:id_];

    XCTAssertEqualObjects(id_, @"IBSHOZ"); // without blocklist, would've been "SXNZKL"
    XCTAssertEqualObjects(numbers, (@[@1, @2, @3]));
}

- (void)testMaxEncodingAttempts {
    NSString *alphabet = @"abc";
    NSNumber *minLength = @3;
    NSSet<NSString *> *blocklist = [NSSet setWithArray:@[@"cab", @"abc", @"bca"]];
    SqidsOptions *options = [[SqidsOptions alloc] initWithAlphabet:alphabet
                                                         minLength:minLength
                                                         blocklist:blocklist];
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    XCTAssertEqualObjects(@(alphabet.length), minLength);
    XCTAssertEqualObjects(@(blocklist.count), minLength);

    NSError *error;
    XCTAssertNil([sqids encode:@[@0] error:&error]);
    XCTAssertNotNil(error);
}

@end
