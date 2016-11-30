//
//  VSKeyboard.h
//  vison
//
//  Created by vison on 16/8/22.
//  Copyright © 2016年 jp.co.sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^HeightChangeBlock)(float height);

@interface VSKeyboard : NSObject

/**
 *  this method must be called in `ViewWillAppear` or `viewDidAppear`, otherwise it will not work sometimes.
 *
 *  @param affectView : set the view than can move to fit the keyboard, better is a UIScrollView or it's subclass
 */
+ (void)keyboardAffectOnView:(UIView *)affectView;


/**
 *  return current height of keyboard
 */
+ (float)keyboardHeight;


/**
 *  will call the block when height of keyboard changed. Better be called in `ViewWillAppear` or `viewDidAppear`
 */
+ (void)keyboardHeightChanged:(HeightChangeBlock)block;


/**
 *  let keyboard won't shelt UITextField/UITextView in target view.
 */
+ (void)fixKeyboardSheltInView:(UIScrollView *)targetView;

@end
