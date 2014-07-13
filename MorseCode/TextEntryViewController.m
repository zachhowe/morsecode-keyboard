//
//  ViewController.m
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import "TextEntryViewController.h"

#import "KeyboardViewController.h"

@interface TextEntryViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation TextEntryViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
