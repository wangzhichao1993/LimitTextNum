//
//  UITextField+LimitTextNum.m
//  LimitTextField
//
//  Created by wzc on 2018/5/2.
//  Copyright © 2018年 WZC. All rights reserved.
//

#import "UITextField+LimitTextNum.h"
#import <objc/runtime.h>

static const void *limitNumKey = &limitNumKey;

@implementation UITextField (LimitTextNum)

@dynamic maxLenght;

- (void)limitTextFieldLenght{
    [self addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldEditChanged:(UITextField *)field{
    NSString *toBeString = field.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {//中文
        UITextRange *seleRange = [field markedTextRange];//获取高亮
        UITextPosition *position = [field positionFromPosition:seleRange.start offset:0];
        if (!position) {
            if (toBeString.length > self.maxLenght) {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.maxLenght];
                if (rangeIndex.length == 1){
                    field.text = [toBeString substringToIndex:self.maxLenght];
                    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能输入%ld个字符",self.maxLenght] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                    [alerController addAction:okAction];
                    [[self superViewController:self] presentViewController:alerController animated:YES completion:nil];
                    [field resignFirstResponder];
                }else{
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.maxLenght)];
                    field.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }else{
        //非中文
        if (toBeString.length > self.maxLenght) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.maxLenght];
            if (rangeIndex.length == 1) {
                field.text = [toBeString substringToIndex:self.maxLenght];
                UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能输入%ld个字符",self.maxLenght] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alerController addAction:okAction];
                [[self superViewController:self] presentViewController:alerController animated:YES completion:nil];
                [field resignFirstResponder];
            }else{
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.maxLenght)];
                field.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}
#pragma mark -- 获取上层控制器
- (UIViewController *)superViewController:(UIView *)view{
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
#pragma mark -- 重写属性的get和set方法

- (NSInteger)maxLenght{
    NSNumber *number = objc_getAssociatedObject(self, limitNumKey);
    return [number integerValue];
}

- (void)setMaxLenght:(NSInteger)maxLenght{
    objc_setAssociatedObject(self, limitNumKey, @(maxLenght), OBJC_ASSOCIATION_ASSIGN);
    [self limitTextFieldLenght];
}

@end
