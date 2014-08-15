//
//  MorseCodeHelper.m
//  MorseCode
//
//  Created by Zach Howe on 8/15/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "MorseCodeHelper.h"

#import "Constants.h"

@implementation MorseCodeHelper {
    NSMutableDictionary *_morseCodeMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *morseCodes = [kMorseCodeMapString componentsSeparatedByString:@" "];
        _morseCodeMap = [NSMutableDictionary dictionaryWithCapacity:morseCodes.count];
        for (unichar c = 'a'; c <= 'z'; c++) {
            _morseCodeMap[[NSString stringWithFormat:@"%c", c]] = morseCodes[c - 'a'];
        }
    }
    return self;
}

- (NSString *)translateMorseCode:(NSString *)morse {
    __block NSString *result = nil;
    if (morse.length > 0) {
        [_morseCodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqualToString:morse]) {
                *stop = YES;
                result = key;
            }
        }];
    }
    return result;
}

- (NSArray *)detectPossibleCharacters:(NSString *)morse {
    __block NSMutableOrderedSet *possibleResults = [NSMutableOrderedSet orderedSet];
    if (morse.length > 0) {
        [_morseCodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *commonPrefix = [morse commonPrefixWithString:obj options:NSLiteralSearch];
            if (commonPrefix.length == morse.length) {
                if ([obj isEqualToString:morse]) {
                    [possibleResults insertObject:key atIndex:0];
                } else {
                    [possibleResults addObject:key];
                }
            }
        }];
    }
    return possibleResults.array;
}

@end
