//
//  MorseCodeGestureView.m
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "MorseCodeGestureView.h"

#import "RNTimer.h"

@interface MorseCodeGestureView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) RNTimer *evaluateTimer;
@property (nonatomic, strong) NSMutableString *currentCode;

@property (nonatomic, strong) UILabel *currentCodeLabel;
@property (nonatomic, strong) NSMutableDictionary *morseCodeMap;

@end

@implementation MorseCodeGestureView {
    NSMutableArray *_possibleResults;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        self.longPressGestureRecognizer.minimumPressDuration = 0.25;
        self.longPressGestureRecognizer.numberOfTapsRequired = 0;
        self.longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapGestureRecognizer.numberOfTapsRequired = 1;
        self.tapGestureRecognizer.numberOfTouchesRequired = 1;
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        self.evaluateTimer = [RNTimer repeatingTimerWithTimeInterval:1.2 block:^{
            [self attemptDetectionOfMorseCode:self.currentCode];
        }];
        
        self.currentCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.currentCodeLabel.textAlignment = NSTextAlignmentCenter;
        self.currentCodeLabel.font = [UIFont fontWithName:@"Menlo" size:16.0];
        self.currentCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.currentCodeLabel.numberOfLines = 3;
        [self.currentCodeLabel sizeToFit];
        [self addSubview:self.currentCodeLabel];
        
        NSLayoutConstraint *labelTopConstraint = [NSLayoutConstraint constraintWithItem:self.currentCodeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *labelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.currentCodeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *labelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.currentCodeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
        NSLayoutConstraint *labelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.currentCodeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        
        [self addConstraints:@[labelTopConstraint, labelLeftConstraint, labelWidthConstraint, labelHeightConstraint]];
    }
    return self;
}

- (void)setup {
    _possibleResults = [NSMutableArray array];
    self.morseCodeMap = [NSMutableDictionary dictionary];
    
    NSString *map = @".- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --..";
    NSArray *map_s = [map componentsSeparatedByString:@" "];
    
    for (unichar c = 'a'; c <= 'z'; c++) {
        self.morseCodeMap[[NSString stringWithFormat:@"%c", c]] = map_s[c - 'a'];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer == self.tapGestureRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer == self.longPressGestureRecognizer;
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (!self.currentCode) {
        self.currentCode = [NSMutableString string];
    }
    [self.currentCode appendString:@"."];
    [self detectPossibleCharacters:self.currentCode];
    [self updateCurrentCodeLabel];
    
    UIColor *oldColor = self.backgroundColor;
    self.backgroundColor = [UIColor redColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backgroundColor = oldColor;
    });
    
    [self.evaluateTimer suspend];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.evaluateTimer resume];
    });
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.currentCode) {
            self.currentCode = [NSMutableString string];
        }
        [self.currentCode appendString:@"-"];
        [self detectPossibleCharacters:self.currentCode];
        [self updateCurrentCodeLabel];
        
        UIColor *oldColor = self.backgroundColor;
        self.backgroundColor = [UIColor blueColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = oldColor;
        });
        
        [self.evaluateTimer suspend];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.evaluateTimer resume];
        });
    }
}

- (void)attemptDetectionOfMorseCode:(NSString *)morse {
    __block NSString *result = nil;
    
    if (morse.length > 0) {
        [self.morseCodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqualToString:morse]) {
                *stop = YES;
                result = key;
            }
        }];
    }
    
    if (morse.length > 4 && !result) {
        self.currentCode = nil;
    }
    
    if (result) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
            [self.delegate morseCodeGestureView:self didRecognizeCharacter:[result characterAtIndex:0]];
        }
        self.currentCode = nil;
    }
    
    [self updateCurrentCodeLabel];
}

- (void)detectPossibleCharacters:(NSString *)morse {
    [_possibleResults removeAllObjects];
    
    if (morse.length > 0) {
        [self.morseCodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *commonPrefix = [morse commonPrefixWithString:obj options:NSLiteralSearch];
            if (commonPrefix.length == morse.length) {
                [_possibleResults addObject:key];
            }
        }];
    }
}

- (void)updateCurrentCodeLabel {
    NSMutableString *status = [NSMutableString string];
    
    if (self.currentCode.length > 0) {
        [status appendFormat:@"%@", self.currentCode];
        
        if (_possibleResults.count > 0) {
            [status appendFormat:@"\n\n[%@]", [_possibleResults componentsJoinedByString:@", "]];
        }
    }
    
    self.currentCodeLabel.text = status;
}

@end
