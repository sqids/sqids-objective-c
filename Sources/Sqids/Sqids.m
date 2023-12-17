#import <Foundation/Foundation.h>
#import "NSString+Sqids.h"
#import "Sqids.h"
#import "SqidsOptions.h"

NS_ASSUME_NONNULL_BEGIN

NSErrorDomain const SqidsErrorDomain = @"SqidsErrorDomain";

@interface Sqids ()

@property (nonatomic, copy) NSArray<NSString *> *alphabet;
@property (nonatomic) NSUInteger minLength;
@property (nonatomic, copy) NSSet<NSString *> *blocklist;

- (NSString * _Nullable)encodeNumbers:(NSArray <NSNumber *> *)numbers
                            increment:(NSUInteger)increment
                                error:(NSError * _Nullable *)error;

- (NSArray<NSString *> *)shuffledAlphabet:(NSArray<NSString *> *)alphabet;

- (NSSet<NSString *> *)cleanedUpBlocklist:(NSSet<NSString *> *)blocklist alphabet:(NSString *)alphabet;

- (NSString *)toId:(NSNumber *)number alphabet:(NSArray<NSString *> *)alphabet;

- (NSNumber *)toNumber:(NSString *)id_ alphabet:(NSArray<NSString *> *)alphabet;

- (BOOL)isBlockedId:(NSString *)id_;

+ (NSUInteger)minLengthLimit;
+ (NSString *)defaultAlphabet;
+ (NSUInteger)defaultMinLength;
+ (NSSet<NSString *> *)defaultBlocklist;

@end

@implementation Sqids

- (instancetype)init {
    self = [self initWithOptions:[[SqidsOptions alloc] init]];
    return self;
}

- (instancetype)initWithOptions:(SqidsOptions *)options {
    if (self = [super init]) {
        NSString *alphabet = options.alphabet ?: Sqids.defaultAlphabet;
        NSUInteger minLength = options.minLength ? options.minLength.unsignedIntegerValue : Sqids.defaultMinLength;
        NSSet<NSString *> *blocklist = options.blocklist ?: Sqids.defaultBlocklist;

        NSAssert(strlen(alphabet.UTF8String) == alphabet.length,
                 @"Alphabet cannot contain multibyte characters");

        NSAssert(alphabet.length >= 3,
                 @"Alphabet length must be at least 3");

        NSAssert([NSSet setWithArray:[alphabet componentsSeparatedByCharacter]].count == alphabet.length,
                 @"Alphabet must contain unique characters");

        NSAssert(minLength <= Sqids.minLengthLimit,
                 ([NSString stringWithFormat:@"Minimum length has to be between 0 and %lu", Sqids.minLengthLimit]));

        self.alphabet = [self shuffledAlphabet:[alphabet componentsSeparatedByCharacter]];
        self.minLength = minLength;
        self.blocklist = [self cleanedUpBlocklist:blocklist alphabet:alphabet];
    }
    return self;
}

- (NSString * _Nullable)encode:(NSArray<NSNumber *> *)numbers
                         error:(NSError * _Nullable *)error {
    if (numbers.count == 0) {
        return @"";
    }

    return [self encodeNumbers:numbers increment:0 error:error];
}

- (NSArray<NSNumber *> *)decode:(NSString *)id_ {
    NSMutableArray<NSNumber *> *result = [NSMutableArray array];

    if ([id_ isEqualToString:@""]) {
        return result;
    }

    NSCharacterSet *nonAlphabetCharacterSet =
        [NSCharacterSet characterSetWithCharactersInString:[self.alphabet componentsJoinedByString:@""]].invertedSet;
    if ([id_ rangeOfCharacterFromSet:nonAlphabetCharacterSet].location != NSNotFound) {
        return result;
    }

    NSString *prefix = [id_ substringWithRange:NSMakeRange(0, 1)];
    NSUInteger offset = [self.alphabet indexOfObject:prefix];
    NSArray<NSString *> *alphabet = [[self.alphabet subarrayWithRange:NSMakeRange(offset, self.alphabet.count - offset)] arrayByAddingObjectsFromArray:[self.alphabet subarrayWithRange:NSMakeRange(0, offset)]];
    alphabet = alphabet.reverseObjectEnumerator.allObjects;
    NSString *slicedId = [id_ substringFromIndex:1];

    while (slicedId.length > 0) {
        NSString *separator = alphabet[0];

        NSArray<NSString *> *chunks = [slicedId componentsSeparatedByString:separator];
        if (chunks.count > 0) {
            if ([chunks[0] isEqualToString:@""]) {
                return result;
            }

            NSArray *alphabetWithoutSeparator = [alphabet subarrayWithRange:NSMakeRange(1, alphabet.count - 1)];
            [result addObject:[self toNumber:chunks[0] alphabet:alphabetWithoutSeparator]];

            if (chunks.count > 1) {
                alphabet = [self shuffledAlphabet:alphabet];
            }
        }

        slicedId = [[chunks subarrayWithRange:NSMakeRange(1, chunks.count - 1)] componentsJoinedByString:separator];
    }

    return result;
}

- (NSString * _Nullable)encodeNumbers:(NSArray<NSNumber *> *)numbers
                            increment:(NSUInteger)increment
                                error:(NSError * _Nullable *)error {
    if (increment > self.alphabet.count) {
        *error = [NSError errorWithDomain:SqidsErrorDomain
                                     code:SqidsErrorRegenerationReachedMaxAttempts
                                 userInfo:@{NSLocalizedDescriptionKey:@"Reached max attempts to re-generate the ID"}];
        return nil;
    }

    __block NSUInteger offset = numbers.count;
    [numbers enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        offset = [self.alphabet[number.unsignedIntegerValue % self.alphabet.count] characterAtIndex:0] + idx + offset;
    }];
    offset %= self.alphabet.count;
    offset = (offset + increment) % self.alphabet.count;

    __block NSArray<NSString *> *alphabet = [[self.alphabet subarrayWithRange:NSMakeRange(offset, self.alphabet.count - offset)] arrayByAddingObjectsFromArray:[self.alphabet subarrayWithRange:NSMakeRange(0, offset)]];
    NSString *prefix = alphabet[0];
    alphabet = alphabet.reverseObjectEnumerator.allObjects;
    NSMutableArray<NSString *> *result = [NSMutableArray arrayWithObject:prefix];

    [numbers enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        NSArray *alphabetWithoutSeparator = [alphabet subarrayWithRange:NSMakeRange(1, alphabet.count - 1)];
        [result addObject:[self toId:number alphabet:alphabetWithoutSeparator]];

        if (idx < numbers.count - 1) {
            [result addObject:alphabet[0]];
            alphabet = [self shuffledAlphabet:alphabet];
        }
    }];

    NSMutableString *id_ = [[result componentsJoinedByString:@""] mutableCopy];

    if (self.minLength > id_.length) {
        [id_ appendString:alphabet[0]];

        while (self.minLength - id_.length > 0) {
            alphabet = [self shuffledAlphabet:alphabet];
            for (NSString *character in [alphabet subarrayWithRange:NSMakeRange(0, MIN(self.minLength - id_.length, alphabet.count))]) {
                [id_ appendString:character];
            }
        }
    }

    if ([self isBlockedId:id_]) {
        id_ = [[self encodeNumbers:numbers increment:increment + 1 error:error] mutableCopy];
    }

    return id_;
}

- (NSArray<NSString *> *)shuffledAlphabet:(NSArray<NSString *> *)alphabet {
    NSMutableArray *newAlphabet = [alphabet mutableCopy];

    for (NSUInteger i = 0, j = newAlphabet.count - 1; j > 0; i++, j--) {
        NSUInteger r = (i * j + [newAlphabet[i] characterAtIndex:0] + [newAlphabet[j] characterAtIndex:0]) % newAlphabet.count;
        [newAlphabet exchangeObjectAtIndex:i withObjectAtIndex:r];
    }

    return newAlphabet;
}

- (NSSet<NSString *> *)cleanedUpBlocklist:(NSSet<NSString *> *)blocklist alphabet:(NSString *)alphabet {
    NSMutableSet *cleanedUpBlocklist = [NSMutableSet setWithCapacity:blocklist.count];
    NSCharacterSet *nonAlphabetCharacterSet =
        [NSCharacterSet characterSetWithCharactersInString:alphabet.lowercaseString].invertedSet;

    for (NSString *word in blocklist) {
        if (word.length >= 3) {
            NSString *lowercasedWord = word.lowercaseString;
            if ([lowercasedWord rangeOfCharacterFromSet:nonAlphabetCharacterSet].location == NSNotFound) {
                [cleanedUpBlocklist addObject:lowercasedWord];
            }
        }
    }

    return cleanedUpBlocklist;
}

- (NSString *)toId:(NSNumber *)number alphabet:(NSArray<NSString *> *)alphabet {
    NSMutableArray *id_ = [NSMutableArray array];
    NSUInteger result = number.unsignedIntegerValue;

    do {
        [id_ insertObject:alphabet[result % alphabet.count] atIndex:0];
        result /= alphabet.count;
    } while (result > 0);

    return [id_ componentsJoinedByString:@""];
}

-(NSNumber *)toNumber:(NSString *)id_ alphabet:(NSArray<NSString *> *)alphabet {
    NSUInteger number = 0;

    for (NSString *character in [id_ componentsSeparatedByCharacter]) {
        number = number * alphabet.count + [alphabet indexOfObject:character];
    }

    return @(number);
}

- (BOOL)isBlockedId:(NSString *)id_ {
    NSString *lowercasedId = id_.lowercaseString;

    for (NSString *word in self.blocklist) {
        if (word.length <= lowercasedId.length) {
            if (lowercasedId.length <= 3 || word.length <= 3) {
                if ([lowercasedId isEqualToString:word]) {
                    return YES;
                }
            } else if ([word rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location != NSNotFound) {
                if ([lowercasedId hasPrefix:word] || [lowercasedId hasSuffix:word]) {
                    return YES;
                }
            } else if ([lowercasedId containsString:word]) {
                return YES;
            }
        }
    }

    return NO;
}

+ (NSUInteger)minLengthLimit {
    return UCHAR_MAX;
}

+ (NSString *)defaultAlphabet {
    return @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
}

+ (NSUInteger)defaultMinLength {
    return 0;
}

+ (NSSet<NSString *> *)defaultBlocklist {
    return [NSSet setWithArray:@[@"0rgasm", @"1d10t", @"1d1ot", @"1di0t", @"1diot", @"1eccacu10", @"1eccacu1o", @"1eccacul0", @"1eccaculo", @"1mbec11e", @"1mbec1le", @"1mbeci1e", @"1mbecile", @"a11upat0", @"a11upato", @"a1lupat0", @"a1lupato", @"aand", @"ah01e", @"ah0le", @"aho1e", @"ahole", @"al1upat0", @"al1upato", @"allupat0", @"allupato", @"ana1", @"ana1e", @"anal", @"anale", @"anus", @"arrapat0", @"arrapato", @"arsch", @"arse", @"ass", @"b00b", @"b00be", @"b01ata", @"b0ceta", @"b0iata", @"b0ob", @"b0obe", @"b0sta", @"b1tch", @"b1te", @"b1tte", @"ba1atkar", @"balatkar", @"bastard0", @"bastardo", @"batt0na", @"battona", @"bitch", @"bite", @"bitte", @"bo0b", @"bo0be", @"bo1ata", @"boceta", @"boiata", @"boob", @"boobe", @"bosta", @"bran1age", @"bran1er", @"bran1ette", @"bran1eur", @"bran1euse", @"branlage", @"branler", @"branlette", @"branleur", @"branleuse", @"c0ck", @"c0g110ne", @"c0g11one", @"c0g1i0ne", @"c0g1ione", @"c0gl10ne", @"c0gl1one", @"c0gli0ne", @"c0glione", @"c0na", @"c0nnard", @"c0nnasse", @"c0nne", @"c0u111es", @"c0u11les", @"c0u1l1es", @"c0u1lles", @"c0ui11es", @"c0ui1les", @"c0uil1es", @"c0uilles", @"c11t", @"c11t0", @"c11to", @"c1it", @"c1it0", @"c1ito", @"cabr0n", @"cabra0", @"cabrao", @"cabron", @"caca", @"cacca", @"cacete", @"cagante", @"cagar", @"cagare", @"cagna", @"cara1h0", @"cara1ho", @"caracu10", @"caracu1o", @"caracul0", @"caraculo", @"caralh0", @"caralho", @"cazz0", @"cazz1mma", @"cazzata", @"cazzimma", @"cazzo", @"ch00t1a", @"ch00t1ya", @"ch00tia", @"ch00tiya", @"ch0d", @"ch0ot1a", @"ch0ot1ya", @"ch0otia", @"ch0otiya", @"ch1asse", @"ch1avata", @"ch1er", @"ch1ng0", @"ch1ngadaz0s", @"ch1ngadazos", @"ch1ngader1ta", @"ch1ngaderita", @"ch1ngar", @"ch1ngo", @"ch1ngues", @"ch1nk", @"chatte", @"chiasse", @"chiavata", @"chier", @"ching0", @"chingadaz0s", @"chingadazos", @"chingader1ta", @"chingaderita", @"chingar", @"chingo", @"chingues", @"chink", @"cho0t1a", @"cho0t1ya", @"cho0tia", @"cho0tiya", @"chod", @"choot1a", @"choot1ya", @"chootia", @"chootiya", @"cl1t", @"cl1t0", @"cl1to", @"clit", @"clit0", @"clito", @"cock", @"cog110ne", @"cog11one", @"cog1i0ne", @"cog1ione", @"cogl10ne", @"cogl1one", @"cogli0ne", @"coglione", @"cona", @"connard", @"connasse", @"conne", @"cou111es", @"cou11les", @"cou1l1es", @"cou1lles", @"coui11es", @"coui1les", @"couil1es", @"couilles", @"cracker", @"crap", @"cu10", @"cu1att0ne", @"cu1attone", @"cu1er0", @"cu1ero", @"cu1o", @"cul0", @"culatt0ne", @"culattone", @"culer0", @"culero", @"culo", @"cum", @"cunt", @"d11d0", @"d11do", @"d1ck", @"d1ld0", @"d1ldo", @"damn", @"de1ch", @"deich", @"depp", @"di1d0", @"di1do", @"dick", @"dild0", @"dildo", @"dyke", @"encu1e", @"encule", @"enema", @"enf01re", @"enf0ire", @"enfo1re", @"enfoire", @"estup1d0", @"estup1do", @"estupid0", @"estupido", @"etr0n", @"etron", @"f0da", @"f0der", @"f0ttere", @"f0tters1", @"f0ttersi", @"f0tze", @"f0utre", @"f1ca", @"f1cker", @"f1ga", @"fag", @"fica", @"ficker", @"figa", @"foda", @"foder", @"fottere", @"fotters1", @"fottersi", @"fotze", @"foutre", @"fr0c10", @"fr0c1o", @"fr0ci0", @"fr0cio", @"fr0sc10", @"fr0sc1o", @"fr0sci0", @"fr0scio", @"froc10", @"froc1o", @"froci0", @"frocio", @"frosc10", @"frosc1o", @"frosci0", @"froscio", @"fuck", @"g00", @"g0o", @"g0u1ne", @"g0uine", @"gandu", @"go0", @"goo", @"gou1ne", @"gouine", @"gr0gnasse", @"grognasse", @"haram1", @"harami", @"haramzade", @"hund1n", @"hundin", @"id10t", @"id1ot", @"idi0t", @"idiot", @"imbec11e", @"imbec1le", @"imbeci1e", @"imbecile", @"j1zz", @"jerk", @"jizz", @"k1ke", @"kam1ne", @"kamine", @"kike", @"leccacu10", @"leccacu1o", @"leccacul0", @"leccaculo", @"m1erda", @"m1gn0tta", @"m1gnotta", @"m1nch1a", @"m1nchia", @"m1st", @"mam0n", @"mamahuev0", @"mamahuevo", @"mamon", @"masturbat10n", @"masturbat1on", @"masturbate", @"masturbati0n", @"masturbation", @"merd0s0", @"merd0so", @"merda", @"merde", @"merdos0", @"merdoso", @"mierda", @"mign0tta", @"mignotta", @"minch1a", @"minchia", @"mist", @"musch1", @"muschi", @"n1gger", @"neger", @"negr0", @"negre", @"negro", @"nerch1a", @"nerchia", @"nigger", @"orgasm", @"p00p", @"p011a", @"p01la", @"p0l1a", @"p0lla", @"p0mp1n0", @"p0mp1no", @"p0mpin0", @"p0mpino", @"p0op", @"p0rca", @"p0rn", @"p0rra", @"p0uff1asse", @"p0uffiasse", @"p1p1", @"p1pi", @"p1r1a", @"p1rla", @"p1sc10", @"p1sc1o", @"p1sci0", @"p1scio", @"p1sser", @"pa11e", @"pa1le", @"pal1e", @"palle", @"pane1e1r0", @"pane1e1ro", @"pane1eir0", @"pane1eiro", @"panele1r0", @"panele1ro", @"paneleir0", @"paneleiro", @"patakha", @"pec0r1na", @"pec0rina", @"pecor1na", @"pecorina", @"pen1s", @"pendej0", @"pendejo", @"penis", @"pip1", @"pipi", @"pir1a", @"pirla", @"pisc10", @"pisc1o", @"pisci0", @"piscio", @"pisser", @"po0p", @"po11a", @"po1la", @"pol1a", @"polla", @"pomp1n0", @"pomp1no", @"pompin0", @"pompino", @"poop", @"porca", @"porn", @"porra", @"pouff1asse", @"pouffiasse", @"pr1ck", @"prick", @"pussy", @"put1za", @"puta", @"puta1n", @"putain", @"pute", @"putiza", @"puttana", @"queca", @"r0mp1ba11e", @"r0mp1ba1le", @"r0mp1bal1e", @"r0mp1balle", @"r0mpiba11e", @"r0mpiba1le", @"r0mpibal1e", @"r0mpiballe", @"rand1", @"randi", @"rape", @"recch10ne", @"recch1one", @"recchi0ne", @"recchione", @"retard", @"romp1ba11e", @"romp1ba1le", @"romp1bal1e", @"romp1balle", @"rompiba11e", @"rompiba1le", @"rompibal1e", @"rompiballe", @"ruff1an0", @"ruff1ano", @"ruffian0", @"ruffiano", @"s1ut", @"sa10pe", @"sa1aud", @"sa1ope", @"sacanagem", @"sal0pe", @"salaud", @"salope", @"saugnapf", @"sb0rr0ne", @"sb0rra", @"sb0rrone", @"sbattere", @"sbatters1", @"sbattersi", @"sborr0ne", @"sborra", @"sborrone", @"sc0pare", @"sc0pata", @"sch1ampe", @"sche1se", @"sche1sse", @"scheise", @"scheisse", @"schlampe", @"schwachs1nn1g", @"schwachs1nnig", @"schwachsinn1g", @"schwachsinnig", @"schwanz", @"scopare", @"scopata", @"sexy", @"sh1t", @"shit", @"slut", @"sp0mp1nare", @"sp0mpinare", @"spomp1nare", @"spompinare", @"str0nz0", @"str0nza", @"str0nzo", @"stronz0", @"stronza", @"stronzo", @"stup1d", @"stupid", @"succh1am1", @"succh1ami", @"succhiam1", @"succhiami", @"sucker", @"t0pa", @"tapette", @"test1c1e", @"test1cle", @"testic1e", @"testicle", @"tette", @"topa", @"tr01a", @"tr0ia", @"tr0mbare", @"tr1ng1er", @"tr1ngler", @"tring1er", @"tringler", @"tro1a", @"troia", @"trombare", @"turd", @"twat", @"vaffancu10", @"vaffancu1o", @"vaffancul0", @"vaffanculo", @"vag1na", @"vagina", @"verdammt", @"verga", @"w1chsen", @"wank", @"wichsen", @"x0ch0ta", @"x0chota", @"xana", @"xoch0ta", @"xochota", @"z0cc01a", @"z0cc0la", @"z0cco1a", @"z0ccola", @"z1z1", @"z1zi", @"ziz1", @"zizi", @"zocc01a", @"zocc0la", @"zocco1a", @"zoccola"]];
}

@end

NS_ASSUME_NONNULL_END
