//
//  MorseCodeGestureView.m
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "MorseCodeGestureView.h"

@interface MorseCodeGestureView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *downSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *upSwipeGestureRecognizer;

@property (nonatomic, strong) NSTimer *evaluateTimer;
@property (nonatomic, strong) NSMutableString *currentCode;

@property (nonatomic, strong) UILabel *currentCodeLabel;

@end

@implementation MorseCodeGestureView {
    NSMutableDictionary *_morseCodeMap;
    NSMutableOrderedSet *_possibleResults;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapGestureRecognizer.numberOfTapsRequired = 1;
        self.tapGestureRecognizer.numberOfTouchesRequired = 1;
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        self.longPressGestureRecognizer.minimumPressDuration = 0.25;
        self.longPressGestureRecognizer.numberOfTapsRequired = 0;
        self.longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:self.leftSwipeGestureRecognizer];
        
        self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:self.rightSwipeGestureRecognizer];
        
        self.upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:self.upSwipeGestureRecognizer];
        
        self.downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:self.downSwipeGestureRecognizer];
        
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
    _possibleResults = [NSMutableOrderedSet orderedSet];
    _morseCodeMap = [NSMutableDictionary dictionary];
    
    NSArray *morseCodes = [@".- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --.." componentsSeparatedByString:@" "];
    
    for (unichar c = 'a'; c <= 'z'; c++) {
        _morseCodeMap[[NSString stringWithFormat:@"%c", c]] = morseCodes[c - 'a'];
    }
    
    [self restartEvaluateTimer];
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
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.currentCode) {
            self.currentCode = [NSMutableString string];
        }
        [self.currentCode appendString:@"."];
        [self detectPossibleCharacters:self.currentCode];
        [self updateCurrentCodeLabel];
        
        [self flashKeyboardColor:[UIColor redColor]];
        [self restartEvaluateTimer];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.currentCode) {
            self.currentCode = [NSMutableString string];
        }
        [self.currentCode appendString:@"-"];
        [self detectPossibleCharacters:self.currentCode];
        [self updateCurrentCodeLabel];
        
        [self flashKeyboardColor:[UIColor blueColor]];
        [self restartEvaluateTimer];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    if (swipeGestureRecognizer == self.leftSwipeGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureViewDidRecognizeBackspaceEvent:)]) {
            [self.delegate morseCodeGestureViewDidRecognizeBackspaceEvent:self];
        }
    } else if (swipeGestureRecognizer == self.rightSwipeGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
            [self.delegate morseCodeGestureView:self didRecognizeCharacter:' '];
        }
    } else if (swipeGestureRecognizer == self.upSwipeGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
            [self.delegate morseCodeGestureViewDidRecognizeCapsToggleEvent:self];
        }
    } else if (swipeGestureRecognizer == self.downSwipeGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
            [self.delegate morseCodeGestureViewDidRecognizeReturnKeyEvent:self];
        }
    }
}

- (void)restartEvaluateTimer {
    if (!self.evaluateTimer.isValid) {
        self.evaluateTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(evaluateTimerFire) userInfo:nil repeats:YES];
    } else {
        [self.evaluateTimer invalidate];
        dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
        dispatch_after(waitTime, dispatch_get_main_queue(), ^{
            [self restartEvaluateTimer];
        });
    }
}

- (void)evaluateTimerFire {
    [self evaluateMorseCode:self.currentCode];
}

- (void)evaluateMorseCode:(NSString *)morse {
    __block NSString *result = nil;
    
    if (morse.length > 0) {
        [_morseCodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqualToString:morse]) {
                *stop = YES;
                result = key;
            }
        }];
    }
    
    if (morse.length >= 4 && !result) {
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
        [_morseCodeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *commonPrefix = [morse commonPrefixWithString:obj options:NSLiteralSearch];
            if (commonPrefix.length == morse.length) {
                if ([obj isEqualToString:morse]) {
                    [_possibleResults insertObject:key atIndex:0];
                } else {
                    [_possibleResults addObject:key];
                }
            }
        }];
    }
}

- (void)flashKeyboardColor:(UIColor *)color {
    UIColor *oldColor = self.backgroundColor;
    self.backgroundColor = color;
    dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(waitTime, dispatch_get_main_queue(), ^{
        self.backgroundColor = oldColor;
    });
}

- (void)updateCurrentCodeLabel {
    NSMutableString *status = [NSMutableString string];
    
    if (self.currentCode.length > 0) {
        [status appendFormat:@"%@", self.currentCode];
        
        if (_possibleResults.count > 0) {
            [status appendFormat:@"\n\n[%@]", [[_possibleResults array] componentsJoinedByString:@", "]];
        }
    }
    
    self.currentCodeLabel.text = status;
}

@end
