//
//  WWWeekNoteHeader.m
//  WoWo
//
//  Created by Tony Zhang on 2018/1/24.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import "WWWeekNoteHeader.h"

@implementation WWWeekNoteHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
    }
    return self;
}


-(void)addViews{
    self.backgroundColor = WWWangGrayColor;
    UIView *grayLine = [[UIView alloc]init];
    grayLine.backgroundColor = lineViewColor;
    [self addSubview:grayLine];
    [grayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.left.offset(0);
        make.size.mas_equalTo(CGSizeMake(WWScreenWidth, 1/[UIScreen mainScreen].scale));
    }];
    CGFloat width = (WWScreenWidth-20)/7;
    for (int i = 0; i < 7; i ++) {
        UILabel *weekNo = [[UILabel alloc]initWithFrame:CGRectMake(10+width*i, 0, width, self.frame.size.height)];
        weekNo.textColor = WWDarkGrayColor;
        weekNo.font = [UIFont systemFontOfSize:14];
        weekNo.textAlignment = NSTextAlignmentCenter;
        [self addSubview:weekNo];
        if (i == 0) {
            weekNo.text = @"日";
        }else{
            NSString *time = [NSString stringWithFormat:@"%d",i];
            weekNo.text = [self translation:time];
        }
    }
    
}


-(NSString *)translation:(NSString *)arebic

{   NSString *str = arebic;
    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
    
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *a = [dictionary objectForKey:substr];
        NSString *b = digits[str.length -i-1];
        NSString *sum = [a stringByAppendingString:b];
        if ([a isEqualToString:chinese_numerals[9]])
        {
            if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
            {
                sum = b;
                if ([[sums lastObject] isEqualToString:chinese_numerals[9]])
                {
                    [sums removeLastObject];
                }
            }else
            {
                sum = chinese_numerals[9];
            }
            
            if ([[sums lastObject] isEqualToString:sum])
            {
                continue;
            }
        }
        
        [sums addObject:sum];
    }
    
    NSString *sumStr = [sums  componentsJoinedByString:@""];
    NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
    if ((chinese.length==2||chinese.length==3) && [[chinese substringToIndex:1] isEqualToString:@"一"]) {
        chinese = [chinese substringFromIndex:1];
    }
    
    NSLog(@"%@",str);
    NSLog(@"%@",chinese);
    return chinese;
}

@end
