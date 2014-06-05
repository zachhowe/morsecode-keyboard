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

@end

@implementation KeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Perform custom initialization work here
    }
    return self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Perform custom UI setup here
    self.gestureView = [[MorseCodeGestureView alloc] initWithFrame:CGRectZero];
    self.gestureView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.gestureView.delegate = self;
    self.gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
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

- (void)didRecognizePossibleCharacters:(NSArray *)characters {
}

@end
