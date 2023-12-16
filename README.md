# [Sqids Objective-C](https://sqids.org/objective-c)

[Sqids](https://sqids.org/objective-c) (*pronounced "squids"*) is a small library that lets you **generate unique IDs from numbers**. It's good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

Features:

- **Encode multiple numbers** - generate short IDs from one or several non-negative numbers
- **Quick decoding** - easily decode IDs back into numbers
- **Unique IDs** - generate unique IDs by shuffling the alphabet once
- **ID padding** - provide minimum length to make IDs more uniform
- **URL safe** - auto-generated IDs do not contain common profanity
- **Randomized output** - Sequential input provides nonconsecutive IDs
- **Many implementations** - Support for [40+ programming languages](https://sqids.org/)

## 🧰 Use-cases

Good for:

- Generating IDs for public URLs (eg: link shortening)
- Generating IDs for internal systems (eg: event tracking)
- Decoding for quicker database lookups (eg: by primary keys)

Not good for:

- Sensitive data (this is not an encryption library)
- User IDs (can be decoded revealing user count)

## 🚀 Getting started

This library supports [Swift Package Manager](https://www.swift.org/package-manager/):

```swift
.package(url: "https://github.com/sqids/sqids-objective-c.git", from: "0.1.0")
```

## 👩‍💻 Examples

Import Sqids via:

```objective-c
@import Sqids;
```

Simple encode & decode:

```objective-c
Sqids *sqids = [[Sqids alloc] init];
NSString *id_ = [sqids encode:@[@1, @2, @3] error:nil]; // @"86Rf07"
NSArray<NSNumber *> *numbers = [sqids decode:id_]; // @[@1, @2, @3]
```

> **Note**
> 🚧 Because of the algorithm's design, **multiple IDs can decode back into the same sequence of numbers**. If it's important to your design that IDs are canonical, you have to manually re-encode decoded numbers and check that the generated ID matches.

Enforce a *minimum* length for IDs:

```objective-c
SqidsOptions *options = [[SqidsOptions alloc] init];
options.minLength = @10;
Sqids *sqids = [[Sqids alloc] initWithOptions:options];
NSString *id_ = [sqids encode:@[@1, @2, @3] error:nil]; // @"86Rf07xd4z"
NSArray<NSNumber *> *numbers = [sqids decode:id_]; // @[@1, @2, @3]
```

Randomize IDs by providing a custom alphabet:

```objective-c
SqidsOptions *options = [[SqidsOptions alloc] init];
options.alphabet = @"FxnXM1kBN6cuhsAvjW3Co7l2RePyY8DwaU04Tzt9fHQrqSVKdpimLGIJOgb5ZE";
Sqids *sqids = [[Sqids alloc] initWithOptions:options];
NSString *id_ = [sqids encode:@[@1, @2, @3] error:nil]; // @"B4aajs"
NSArray<NSNumber *> *numbers = [sqids decode:id_]; // @[@1, @2, @3]
```

Prevent specific words from appearing anywhere in the auto-generated IDs:

```objective-c
SqidsOptions *options = [[SqidsOptions alloc] init];
options.blocklist = [NSSet setWithArray:@[@"86Rf07"]];
Sqids *sqids = [[Sqids alloc] initWithOptions:options];
NSString *id_ = [sqids encode:@[@1, @2, @3] error:nil]; // @"se8ojk"
NSArray<NSNumber *> *numbers = [sqids decode:id_]; // @[@1, @2, @3]
```

## 📝 License

[MIT](LICENSE)
