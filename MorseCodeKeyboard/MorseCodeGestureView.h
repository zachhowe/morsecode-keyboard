//
//  MorseCodeGestureView.h
//  MorseCode
//
//  Created by Zach Howe on 6/4/14.
//  Copyright (c) 2014 Zach Howe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorseCodeGestureView;

typedef NS_ENUM(NSUInteger, MorseCodeEvent) {
    MorseCodeEventDot,
    MorseCodeEventDash
};

@protocol MorseCodeGestureViewDelegate <NSObject>

- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView displayShouldUpdateWithMorseCode:(NSString *)currentMorseCode;
- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView provideFeedbackForEvent:(MorseCodeEvent)morseCodeEvent;

@optional

// Input events
- (void)morseCodeGestureView:(MorseCodeGestureView *)morseCodeView didRecognizeCharacter:(unichar)character;
- (void)morseCodeGestureViewDidRecognizeSpaceEvent:(MorseCodeGestureView *)morseCodeView;
- (void)morseCodeGestureViewDidRecognizeBackspaceEvent:(MorseCodeGestureView *)morseCodeView;
- (void)morseCodeGestureViewDidRecognizeCapsToggleEvent:(MorseCodeGestureView *)morseCodeView;
- (void)morseCodeGestureViewDidRecognizeReturnKeyEvent:(MorseCodeGestureView *)morseCodeView;

// Other keyboard events
- (void)morseCodeGestureViewDidRecognizeKeyboardShouldClose:(MorseCodeGestureView *)morseCodeView;
- (void)morseCodeGestureViewDidRecognizeKeyboardShouldAdvance:(MorseCodeGestureView *)morseCodeView;

@end

@interface MorseCodeGestureView : UIView

@property (nonatomic, weak) id<MorseCodeGestureViewDelegate> delegate;

@property (nonatomic, readonly) UILabel *currentCodeLabel;

@end
