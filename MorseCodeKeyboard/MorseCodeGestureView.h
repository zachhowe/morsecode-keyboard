//
//  MorseCodeGestureView.h
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorseCodeGestureView;

@protocol MorseCodeGestureViewDelegate <NSObject>

@optional

- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView didRecognizeCharacter:(unichar)character;

@end

@interface MorseCodeGestureView : UIView

@property (nonatomic, weak) id<MorseCodeGestureViewDelegate> delegate;

@end