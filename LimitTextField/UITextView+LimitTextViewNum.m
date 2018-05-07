//
//  UITextView+LimitTextViewNum.m
//  LimitTextField
//
//  Created by wzc on 2018/5/2.
//  Copyright © 2018年 WZC. All rights reserved.
//

#import "UITextView+LimitTextViewNum.h"

@implementation UITextView (LimitTextViewNum)

static UILabel *placeHolderLabel;

- (BOOL)limitTextViewNum:(UITextView *)textView
                    text:(NSString *)text
               maxLenght:(NSInteger)maxLenght
             textInRange:(NSRange)range
         appearTextLabel:(UILabel *)label{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    //不支持系统表情输入
    if ([[textView textInputMode] primaryLanguage] == nil || [[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"]) {
        UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"提示" message:@"只允许输入文字" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alerController addAction:okAction];
        [[self superViewController:self] presentViewController:alerController animated:YES completion:nil];
        return NO;
    }
    UITextRange *selectedrange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedrange.start offset:0];
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedrange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedrange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedrange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        if (offsetRange.location < maxLenght) {
            return YES;
        }else{
            return NO;
        }
    }
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputlen = maxLenght - comcatstr.length;
    if (caninputlen >= 0) {
        return YES;
    }else{
        NSInteger len = text.length + caninputlen;
        NSRange rg = {0,MAX(len, 0)};
        if (rg.length > 0) {
            NSString *str = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                str = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }else{
                __block NSInteger idx = 0;
                __block NSString *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                          if (idx >= rg.length) {
                                              *stop =YES;//取出所需要就break，提高效率
                                              return ;
                                          }
                                          trimString = [trimString stringByAppendingString:substring];
                                          idx++;
                                      }];
                str = trimString;
            }
            //rang是指从当前光标处进行替换处理
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:str]];
            //既然是超出部分截取了，哪一定是最大限制了。
            label.text = [NSString stringWithFormat:@"%d/%ld",0,(long)maxLenght];
        }
        UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请输入小于%ld字符",(long)maxLenght] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alerController addAction:okAction];
        [[self superViewController:self] presentViewController:alerController animated:YES completion:nil];
        return NO;
    }
}

-(void)setTextViewPlaceholde:(NSString*)placeholder{
    placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 8,self.bounds.size.width - 10, 0)];
    placeHolderLabel.text = placeholder;
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.font = self.font;
    placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:placeHolderLabel];
    [placeHolderLabel sizeToFit];
    [self sendSubviewToBack:placeHolderLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}
- (void)textChanged:(NSNotification *)notification{
    UITextView*textView = (UITextView*)notification.object;
    if (textView.text.length == 0) {
        placeHolderLabel.hidden = NO;
    }else{
        placeHolderLabel.hidden = YES;
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


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
