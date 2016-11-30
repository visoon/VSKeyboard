//
//  ViewController.m
//  VSKeyboardDemo
//
//  Created by 王翔 on 11/30/16.
//  Copyright © 2016 vison. All rights reserved.
//

#import "ViewController.h"
#import "VSKeyboard.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *inputTextFields;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [VSKeyboard keyboardAffectOnView:self.mainScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UITextField *textField in self.inputTextFields) {
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyNext;
    }
}

#pragma mark - delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger textFieldIndex = [self.inputTextFields indexOfObject:textField];
    NSInteger nextIndex = textFieldIndex + 1;
    nextIndex = (nextIndex > self.inputTextFields.count - 1) ? 0 : nextIndex;
    [self.inputTextFields[nextIndex] becomeFirstResponder];
    return YES;
}
@end
