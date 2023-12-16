#import <Sqids/Sqids.h>
#import <XCTest/XCTest.h>

@interface AlphabetTests : XCTestCase

@end

@implementation AlphabetTests

- (void)testSimple {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"0123456789abcdef";
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    NSArray<NSNumber *> *numbers = @[@1, @2, @3];
    NSString *id_ = @"489158";

    XCTAssertEqualObjects([sqids encode:numbers error:nil], id_);
    XCTAssertEqualObjects([sqids decode:id_], numbers);
}

- (void)testShortAlphabet {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"abc";
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    NSArray<NSNumber *> *numbers = @[@1, @2, @3];
    XCTAssertEqualObjects([sqids decode:[sqids encode:numbers error:nil]], numbers);
}

- (void)testLongAlphabet {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:\'\"/?.>,<`~";
    Sqids *sqids = [[Sqids alloc] initWithOptions:options];

    NSArray<NSNumber *> *numbers = @[@1, @2, @3];
    XCTAssertEqualObjects([sqids decode:[sqids encode:numbers error:nil]], numbers);
}

- (void)testMultibyteCharactersAlphabet {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"ë1092";
    XCTAssertThrows([[Sqids alloc] initWithOptions:options]);
}

- (void)testRepeatingCharactersAlphabet {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"aabcdefg";
    XCTAssertThrows([[Sqids alloc] initWithOptions:options]);
}

- (void)testTooShortAlphabet {
    SqidsOptions *options = [[SqidsOptions alloc] init];
    options.alphabet = @"ab";
    XCTAssertThrows([[Sqids alloc] initWithOptions:options]);
}

@end
