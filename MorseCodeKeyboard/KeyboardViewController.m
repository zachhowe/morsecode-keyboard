//
//  KeyboardViewController.m
//  MorseCodeKeyboard
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "KeyboardViewController.h"

#import "MorseCodeGestureView.h"
#import "MorseCodeHelper.h"

@interface KeyboardViewController () <MorseCodeGestureViewDelegate>

@property (nonatomic, strong) MorseCodeGestureView *gestureView;
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *dismissKeyboardButton;
@property (nonatomic) BOOL capsOn;

@property (nonatomic, strong) MorseCodeHelper *morseCodeHelper;

@end

@implementation KeyboardViewController

- (void)loadView {
    [super loadView];
    
    self.gestureView = [[MorseCodeGestureView alloc] initWithFrame:CGRectZero];
    self.gestureView.backgroundColor = [UIColor clearColor];
    self.gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gestureView.delegate = self;
    
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextKeyboardButton.hidden = self.nextKeyboardButtonHidden;
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextKeyboardButton setTitle:@"Next Keyboard" forState:UIControlStateNormal];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextKeyboardButton];
    
    self.dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dismissKeyboardButton.hidden = self.dismissKeyboardButtonHidden;
    self.dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dismissKeyboardButton setTitle:@"Dismiss Keyboard" forState:UIControlStateNormal];
    [self.dismissKeyboardButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.dismissKeyboardButton];
    
    [self.inputView addSubview:self.gestureView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    CGFloat gestureViewHeightModifier = 0.0;
    
    if (!self.nextKeyboardButtonHidden) {
        gestureViewHeightModifier = -44.0;
    } else {
        gestureViewHeightModifier = 0.0;
    }
    
    NSLayoutConstraint *gestureViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:gestureViewHeightModifier];
    
    [NSLayoutConstraint activateConstraints:@[gestureViewTopConstraint,
                                              gestureViewLeftConstraint,
                                              gestureViewWidthConstraint,
                                              gestureViewHeightConstraint]];
    
    if (!self.nextKeyboardButtonHidden) {
        NSLayoutConstraint *nextKeyboardButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.gestureView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *nextKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *nextKeyboardButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.gestureView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
        NSLayoutConstraint *nextKeyboardButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0];
        
        [NSLayoutConstraint activateConstraints:@[nextKeyboardButtonTopConstraint,
                                                  nextKeyboardButtonBottomConstraint,
                                                  nextKeyboardButtonWidthConstraint,
                                                  nextKeyboardButtonHeightConstraint]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.morseCodeHelper = [[MorseCodeHelper alloc] init];
}

- (void)selectionWillChange:(id <UITextInput>)textInput {
}

- (void)selectionDidChange:(id <UITextInput>)textInput {
}

- (void)textWillChange:(id<UITextInput>)textInput {
}

- (void)textDidChange:(id<UITextInput>)textInput {
}

#pragma mark - Properties

- (void)setNextKeyboardButtonHidden:(BOOL)nextKeyboardButtonHidden {
    if (_nextKeyboardButtonHidden != nextKeyboardButtonHidden) {
        _nextKeyboardButtonHidden = nextKeyboardButtonHidden;
        self.nextKeyboardButton.hidden = self.nextKeyboardButtonHidden;
    }
}

#pragma mark - Morse Code Gesture View Delegate

- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView displayShouldUpdateWithMorseCode:(NSString *)currentMorseCode {
    NSMutableString *status = [NSMutableString string];
    if (currentMorseCode.length > 0) {
        [status appendFormat:@"%@", currentMorseCode];
        
        NSArray *possibleResults = [self.morseCodeHelper detectPossibleCharacters:currentMorseCode];
        if (possibleResults.count > 0) {
            NSString *possibleResultsList = [possibleResults componentsJoinedByString:@", "];
            if (self.capsOn) {
                possibleResultsList = [possibleResultsList uppercaseString];
            }
            [status appendFormat:@"\n\n[%@]", possibleResultsList];
        }
    }
    self.gestureView.currentCodeLabel.text = status;
}

- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView provideFeedbackForEvent:(MorseCodeEvent)morseCodeEvent {
}

- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView didRecognizeCharacter:(unichar)character {
    NSString *characterStr = [NSString stringWithFormat:@"%c", character];
    if (self.capsOn) {
        characterStr = [characterStr uppercaseString];
    }
    [self.textDocumentProxy insertText:characterStr];
}

- (void)morseCodeGestureViewDidRecognizeSpaceEvent:(MorseCodeGestureView *)morseCodeView {
    [self.textDocumentProxy insertText:@" "];
}

- (void)morseCodeGestureViewDidRecognizeBackspaceEvent:(MorseCodeGestureView *)morseCodeView {
    [self.textDocumentProxy deleteBackward];
}

- (void)morseCodeGestureViewDidRecognizeCapsToggleEvent:(MorseCodeGestureView *)morseCodeView {
    self.capsOn = !self.capsOn;
}

- (void)morseCodeGestureViewDidRecognizeReturnKeyEvent:(MorseCodeGestureView *)morseCodeView {
    [self.textDocumentProxy insertText:@"\n"];
}

- (void)morseCodeGestureViewDidRecognizeKeyboardShouldClose:(MorseCodeGestureView *)morseCodeView {
    [self dismissKeyboard];
}

- (void)morseCodeGestureViewDidRecognizeKeyboardShouldAdvance:(MorseCodeGestureView *)morseCodeView {
    [self advanceToNextInputMode];
}

@end
