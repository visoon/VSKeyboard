//
//  VSKeyboard.m
//  vison
//
//  Created by vison on 16/8/22.
//  Copyright © 2016年 jp.co.sample. All rights reserved.
//

#import "VSKeyboard.h"

#define SELF [VSKeyboard defaultKeyboard]

static float during = 0.2f;
static NSString *observeKeyPath = @"contentSize";

@interface VSKeyboard ()
@property (nonatomic, copy) HeightChangeBlock block;
@property (nonatomic, weak) UIView *inputView;

@property (nonatomic, weak) UIView *affectView;

//if affectView is a scroll view, mark the original contentSize and contentOffset
@property (nonatomic, assign) CGSize originalContentSize;
@property (nonatomic, assign) CGPoint originalOffset;

//if affectView is a UIView, mark the original frame
@property (nonatomic, assign) CGRect orignalFrame;

@property (nonatomic, assign) BOOL isShowKeyboard;
@property (nonatomic, assign) float keyboardHeight;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation VSKeyboard
+ (instancetype)defaultKeyboard {
    static VSKeyboard *keyboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      keyboard = [[VSKeyboard alloc] init];
    });
    return keyboard;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textBeginEdit:) name:UITextFieldTextDidBeginEditingNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textBeginEdit:) name:UITextViewTextDidBeginEditingNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

#pragma mark - notification

- (void)textBeginEdit:(NSNotification *)notification {
    self.inputView = notification.object;
    [self vs_configTapGesture];
    [self vs_configOriginalFrame];
    self.isShowKeyboard = YES;
    [VSKeyboard vs_changeFrameWithView:SELF.affectView keyboardHeight:self.keyboardHeight];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self vs_configOriginalFrame];
    self.isShowKeyboard = YES;
    if (self.block) {
        CGSize size = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        self.keyboardHeight = size.height;
        self.block(size.height);
    }
    
    if (SELF.affectView && [SELF.affectView isKindOfClass:[UIScrollView class]]) {
        [self vs_removeTargetViewObserver];
        [SELF vs_addObserverForTargetView:(UIScrollView *)SELF.affectView];
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    if (self.block) {
        self.keyboardHeight = 0.0;
        self.block(0.0);
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    self.isShowKeyboard = YES;
}

- (void)keyboardDidHidden:(NSNotification *)notification {
    self.isShowKeyboard = NO;
    /**
     *  if the associate view is shown, do not clear data
     */
    if ([self.inputView isFirstResponder]) {
        return;
    }
    [self vs_removeTargetViewObserver];
    [self vs_clearPropertyData];
}

#pragma mark - response methods
- (void)windowTap:(UIGestureRecognizer *)recognizer {
    [self.inputView endEditing:YES];
}

#pragma mark - public methods
+ (void)keyboardChangedToHeight:(void (^)(float))change {
    SELF.block = ^(float height) {
      change(height);
    };
}

+ (void)keyboardAffectOnView:(UIView *)affectView {
    SELF.affectView = affectView;
    SELF.block = ^(float height) {
      [self vs_changeFrameWithView:affectView keyboardHeight:height];
    };
}

+ (float)keyboardHeight {
    return SELF.keyboardHeight;
}

+ (void)fixKeyboardSheltInView:(UIScrollView *)targetView {
    [self vs_changeFrameWithView:targetView keyboardHeight:SELF.keyboardHeight];
}

+ (void)keyboardHeightChanged:(HeightChangeBlock)block {
    SELF.block = ^(float height) {
        block(height);
    };
}

#pragma mark - private methods
/**
 *  observe the contentSize of scroll view when changed
 *
 *  @param targetView scrollview
 */
- (void)vs_addObserverForTargetView:(UIScrollView *)targetView {
    [targetView addObserver:SELF forKeyPath:observeKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)vs_removeTargetViewObserver {
#warning - prevent crash
    @try {
        [SELF.affectView removeObserver:SELF forKeyPath:observeKeyPath];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)vs_configTapGesture {
    [self.inputView.window addGestureRecognizer:self.tapGesture];
}

/**
 *  when the keyboard appear first time, mark the affect view orginal data.
 */
- (void)vs_configOriginalFrame {
    if ([self.affectView isKindOfClass:[UIScrollView class]] && !self.isShowKeyboard) {
        self.originalContentSize = [(UIScrollView *)self.affectView contentSize];
        self.originalOffset = [(UIScrollView *)self.affectView contentOffset];
    }

    if ([self.affectView isKindOfClass:[UIView class]] && !self.isShowKeyboard) {
        self.orignalFrame = self.affectView.frame;
    }
}

/**
 *  clear the last data to avoid infinte loop
 */
- (void)vs_clearPropertyData {
    if (self.inputView) {
        if (self.inputView.window) {
            [self.inputView.window removeGestureRecognizer:self.tapGesture];
        }
        [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.tapGesture];
        self.inputView = nil;
    }

    if (self.affectView && [VSKeyboard vs_controllerForView:self.affectView] == nil) {
        self.affectView = nil;
    }

    self.originalOffset = CGPointZero;
    self.originalContentSize = CGSizeZero;
}

+ (void)vs_changeFrameWithView:(UIView *)view
                keyboardHeight:(float)keyboardHeight {
    if (!SELF.inputView || !view) {
        return;
    }
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    CGRect frame = [keywindow convertRect:SELF.inputView.frame fromView:SELF.inputView.superview];

    float keyboardConvertY = keywindow.bounds.size.height - keyboardHeight;
    float viewConvertY = frame.origin.y + frame.size.height;
    float offset = viewConvertY - keyboardConvertY;
    if ([view isKindOfClass:[UIScrollView class]]) {
        if (keyboardHeight == 0) {
            [self vs_recoverToOriginalContentSizeWithScrollView:(UIScrollView *)view];
            return;
        }
        if (offset > 0) {
            [self vs_offsetScrollView:(UIScrollView *)view offset:offset keyboardHeight:keyboardHeight];
        } else {
            [self vs_offsetScrollView:(UIScrollView *)view offset:0.0 keyboardHeight:keyboardHeight];
        }
    } else if ([view isKindOfClass:[UIView class]]) {
        if (offset > 0) {
            [self vs_offsetView:view offset:offset keyboardHeight:keyboardHeight];
        }
        if (keyboardHeight == 0) {
            [self vs_offsetView:view offset:0 keyboardHeight:keyboardHeight];
        }
    }
}

+ (void)vs_recoverToOriginalContentSizeWithScrollView:(UIScrollView *)scrollView {
    scrollView.contentSize = SELF.originalContentSize;
}

+ (void)vs_offsetScrollView:(UIScrollView *)scrollView offset:(float)offset keyboardHeight:(float)keyboardHeight {
    float deltaspace = 3.0f;//add 3.0f space between the bottom of input view and top of keyboard
    float totalOffset = offset == 0 ? offset : offset + deltaspace;
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, SELF.originalContentSize.height + keyboardHeight);
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + totalOffset) animated:YES];
}

+ (void)vs_offsetView:(UIView *)view offset:(float)offset keyboardHeight:(float)keyboardHeight {
    [UIView animateWithDuration:during animations:^{
      view.frame = CGRectMake(view.frame.origin.x, SELF.orignalFrame.origin.y - offset, view.bounds.size.width, view.bounds.size.height);
    }];
}

/**
 *  get the controller base on target view
 *
 *  @param view target view
 *
 *  @return return the controller if the target view have, else return nil
 */
+ (UIViewController *)vs_controllerForView:(UIView *)view {
    UIView *targetView = view;
    UIResponder *responder = targetView.nextResponder;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [targetView.superview nextResponder];
        targetView = targetView.superview;
    }
    return (UIViewController *)responder;
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    float oldHeight = [change[@"old"] CGSizeValue].height;
    float newHeight = [change[@"new"] CGSizeValue].height;
    
    SELF.originalContentSize = CGSizeMake(SELF.originalContentSize.width, [change[@"new"] CGSizeValue].height - SELF.keyboardHeight);
    
    if (oldHeight != newHeight) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [VSKeyboard fixKeyboardSheltInView:object];
        });
    }
}

#pragma mark - getter
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTap:)];
    }
    return _tapGesture;
}
@end
