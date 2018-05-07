//
//  ViewController.m
//  LimitTextField
//
//  Created by wzc on 2018/5/2.
//  Copyright © 2018年 WZC. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+LimitTextNum.h"
#import "UITextView+LimitTextViewNum.h"

@interface ViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, assign) NSInteger maxNum;//textView最大输入限制
@property (nonatomic, strong) UILabel *textViewLb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textField.maxLenght = 5;
    _maxNum = 10;
    
    _textView.layer.borderColor = [UIColor blackColor].CGColor;
    _textView.layer.borderWidth = 0.5f;
    [_textView setTextViewPlaceholde:@"请输入文字"];
    
    ///限制字数文本
    _textViewLb = [[UILabel alloc] init];
    _textViewLb.textAlignment = NSTextAlignmentRight;
    _textViewLb.text = [NSString stringWithFormat:@"%ld/%ld",_maxNum,_maxNum];
    _textViewLb.frame = CGRectMake(CGRectGetMaxX(_textView.frame)-65, CGRectGetMaxY(_textView.frame)-20, 100, 15);
    _textViewLb.textColor = [UIColor lightGrayColor];
    _textViewLb.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_textViewLb];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -- UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    return [textView limitTextViewNum:textView text:text maxLenght:_maxNum textInRange:range appearTextLabel:_textViewLb];
    
}
//显示当前可输入字数/总字数

- (void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && position) {
        return;
    }
    NSString *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > _maxNum){
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:_maxNum];
        [textView setText:s];
    }
    //不显示负数
    self.textViewLb.text = [NSString stringWithFormat:@"%ld/%ld",MAX(0,_maxNum - existTextNum),(long)_maxNum];
}


@end
