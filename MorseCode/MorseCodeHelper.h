//
//  MorseCodeHelper.h
//  MorseCode
//
//  Created by Zach Howe on 8/15/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MorseCodeHelper : NSObject

- (NSString *)translateMorseCode:(NSString *)morse;
- (NSArray *)detectPossibleCharacters:(NSString *)morse;

@end
