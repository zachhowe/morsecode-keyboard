//
//  KeyboardViewController.m
//  MorseCodeKeyboard
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "KeyboardViewController.h"

#import "MorseCodeGestureView.h"

@interface KeyboardViewController () <MorseCodeGestureViewDelegate>

@property (nonatomic, strong) MorseCodeGestureView *gestureView;
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic) BOOL capsOn;

@end

@implementation KeyboardViewController

- (void)loadView {
    [super loadView];
    
    self.gestureView = [[MorseCodeGestureView alloc] initWithFrame:CGRectZero];
    self.gestureView.backgroundColor = [UIColor clearColor];
    self.gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gestureView.delegate = self;
    
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextKeyboardButton setTitle:@"Next Keyboard" forState:UIControlStateNormal];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextKeyboardButton];
    
    self.gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.inputView addSubview:self.gestureView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSLayoutConstraint *gestureViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-44.0];
    
    NSLayoutConstraint *nextKeyboardButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.gestureView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *nextKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *nextKeyboardButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.gestureView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *nextKeyboardButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0];
    
    [NSLayoutConstraint activateConstraints:@[gestureViewTopConstraint,
                                              gestureViewLeftConstraint,
                                              gestureViewWidthConstraint,
                                              gestureViewHeightConstraint,
                                              nextKeyboardButtonTopConstraint,
                                              nextKeyboardButtonBottomConstraint,
                                              nextKeyboardButtonWidthConstraint,
                                              nextKeyboardButtonHeightConstraint]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)selectionWillChange:(id <UITextInput>)textInput {
}

- (void)selectionDidChange:(id <UITextInput>)textInput {
}

- (void)textWillChange:(id<UITextInput>)textInput {
}

- (void)textDidChange:(id<UITextInput>)textInput {
}

#pragma mark - Morse Code Gesture View Delegate

- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView didRecognizeCharacter:(unichar)character {
    [self.textDocumentProxy insertText:[NSString stringWithFormat:@"%c", character]];
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
