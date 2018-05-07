//
//  UITextView+LimitTextViewNum.h
//  LimitTextField
//
//  Created by wzc on 2018/5/2.
//  Copyright © 2018年 WZC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (LimitTextViewNum)

/**
 限制textView输入字数 包括表情

 @param textView textview
 @param text 输入的txt
 @param maxLenght 最大输入字数
 @param range range
 @param label 输入的字数/总字数
 @return YES or NO
 */
- (BOOL)limitTextViewNum:(UITextView *)textView
                    text:(NSString *)text
               maxLenght:(NSInteger)maxLenght
             textInRange:(NSRange)range
         appearTextLabel:(UILabel *)label;

/**
 设置textView的默认文字

 @param placeholder 默认文字txt
 */
- (void)setTextViewPlaceholde:(NSString*)placeholder;

@end
