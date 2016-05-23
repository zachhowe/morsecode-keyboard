//
//  ViewController.m
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "TextEntryViewController.h"

#import "MorseCodeGestureView.h"
#import "KeyboardViewController.h"

@interface TextEntryViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) KeyboardViewController *keyboardViewController;
@property (nonatomic, strong) MorseCodeGestureView *morseCodeGestureView;

@end

@implementation TextEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.keyboardViewController = [[KeyboardViewController alloc] init];
    self.keyboardViewController.nextKeyboardButtonHidden = YES;
    
    self.keyboardViewController.inputView.frame = CGRectMake(0, 0, self.view.frame.size.width, 224.0);
    self.textView.inputView = self.keyboardViewController.inputView;
    self.textView.inputDelegate = self.keyboardViewController;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

@end
