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
@property (nonatomic) BOOL capsOn;

@end

@implementation KeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gestureView = [[MorseCodeGestureView alloc] initWithFrame:CGRectZero];
    self.gestureView.backgroundColor = [UIColor clearColor];
    self.gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gestureView.delegate = self;
    
    [self.view addSubview:self.gestureView];
    
    NSLayoutConstraint *gestureViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *gestureViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.gestureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    
    [self.view addConstraints:@[gestureViewTopConstraint,
                                gestureViewLeftConstraint,
                                gestureViewWidthConstraint,
                                gestureViewHeightConstraint]];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    UIColor *textColor = nil;
    
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
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

@end
