//
//  MorseCodeTests.m
//  MorseCodeTests
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MorseCodeHelper.h"

@interface MorseCodeTests : XCTestCase

@property (nonatomic, strong) MorseCodeHelper *morseCodeHelper;

@end

@implementation MorseCodeTests

- (void)setUp {
    [super setUp];
    self.morseCodeHelper = [[MorseCodeHelper alloc] init];
}

- (void)tearDown {
    self.morseCodeHelper = nil;
    [super tearDown];
}

- (void)testTranslateMorseCodeSuccess {
    NSString *morse = @".-";
    NSString *expectedTranslation = @"a";
    
    NSString *translation = [self.morseCodeHelper translateMorseCode:morse];
    
    XCTAssertEqualObjects(translation, expectedTranslation, @"Morse code '%@' should be translate to '%@'", morse, expectedTranslation);
}

- (void)testTranslateMorseCodeFailure {
    NSString *morse = @".--.-.-";
    
    NSString *translation = [self.morseCodeHelper translateMorseCode:morse];
    
    XCTAssertEqualObjects(translation, nil, @"Morse code '%@' should be translate to nil object", morse);
}

@end
