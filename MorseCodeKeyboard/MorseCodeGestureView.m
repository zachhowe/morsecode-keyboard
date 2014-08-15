//
//  MorseCodeGestureView.m
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "MorseCodeGestureView.h"

#import "MorseCodeHelper.h"

@interface MorseCodeGestureView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *downSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *upSwipeGestureRecognizer;

@property (nonatomic, strong) NSTimer *evaluateTimer;
@property (nonatomic, strong) NSMutableString *currentCode;

@property (nonatomic, strong) MorseCodeHelper *morseCodeHelper;

@property (nonatomic, strong, readwrite) UILabel *currentCodeLabel;

@end

@implementation MorseCodeGestureView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.morseCodeHelper = [[MorseCodeHelper alloc] init];
        
        [self restartEvaluateTimer];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapGestureRecognizer.numberOfTapsRequired = 1;
        self.tapGestureRecognizer.numberOfTouchesRequired = 1;
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        self.longPressGestureRecognizer.minimumPressDuration = 0.20;
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
        
        self.currentCodeLabel = [[UILabel alloc] initWithFrame:frame];
        self.currentCodeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.currentCodeLabel.textAlignment = NSTextAlignmentCenter;
        self.currentCodeLabel.font = [UIFont fontWithName:@"Menlo" size:16.0];
        self.currentCodeLabel.translatesAutoresizingMaskIntoConstraints = YES;
        self.currentCodeLabel.numberOfLines = 3;
        [self.currentCodeLabel sizeToFit];
        [self addSubview:self.currentCodeLabel];
        
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)updateConstraints
{
    NSLayoutConstraint *labelTopConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.currentCodeLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *labelLeftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.currentCodeLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *labelWidthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.currentCodeLabel attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *labelHeightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.currentCodeLabel attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[labelTopConstraint,
                                              labelLeftConstraint,
                                              labelWidthConstraint,
                                              labelHeightConstraint]];
    
    [super updateConstraints];
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
        [self updateCurrentCodeLabel];
        
        [self provideFeedbackForKeyEvent:MorseCodeEventDot];
        [self restartEvaluateTimer];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.currentCode) {
            self.currentCode = [NSMutableString string];
        }
        [self.currentCode appendString:@"-"];
        [self updateCurrentCodeLabel];
        
        [self provideFeedbackForKeyEvent:MorseCodeEventDash];
        [self restartEvaluateTimer];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    if (swipeGestureRecognizer == self.upSwipeGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
            [self.delegate morseCodeGestureViewDidRecognizeCapsToggleEvent:self];
        }
        [self updateCurrentCodeLabel];
        [self restartEvaluateTimer];
    } else {
        if (self.currentCode.length > 0) {
            self.currentCode = [NSMutableString string];
            [self updateCurrentCodeLabel];
        }
        
        if (swipeGestureRecognizer == self.leftSwipeGestureRecognizer) {
            if ([self.delegate respondsToSelector:@selector(morseCodeGestureViewDidRecognizeBackspaceEvent:)]) {
                [self.delegate morseCodeGestureViewDidRecognizeBackspaceEvent:self];
            }
        } else if (swipeGestureRecognizer == self.rightSwipeGestureRecognizer) {
            if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
                [self.delegate morseCodeGestureView:self didRecognizeCharacter:' '];
            }
        } else if (swipeGestureRecognizer == self.downSwipeGestureRecognizer) {
            if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
                [self.delegate morseCodeGestureViewDidRecognizeReturnKeyEvent:self];
            }
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
    NSString *translation = [self.morseCodeHelper translateMorseCode:morse];
    
    if (morse.length >= 4 && !translation) {
        self.currentCode = nil;
    } else if (translation) {
        if ([self.delegate respondsToSelector:@selector(morseCodeGestureView:didRecognizeCharacter:)]) {
            [self.delegate morseCodeGestureView:self didRecognizeCharacter:[translation characterAtIndex:0]];
        }
        self.currentCode = nil;
    }
    
    [self updateCurrentCodeLabel];
}

- (void)provideFeedbackForKeyEvent:(MorseCodeEvent)keyEvent {
    // TODO: Implement feedback
    switch (keyEvent) {
        case MorseCodeEventDot:
            break;
        case MorseCodeEventDash:
            break;
        default:
            break;
    }
}

- (void)updateCurrentCodeLabel {
    [self.delegate morseCodeGestureView:self displayShouldUpdateWithMorseCode:self.currentCode];
}

@end
