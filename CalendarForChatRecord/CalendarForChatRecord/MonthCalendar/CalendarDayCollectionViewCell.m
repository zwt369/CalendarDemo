//
//  CalendarDayCollectionViewCell.m
//  WoWo
//
//  Created by Tony Zhang on 2018/1/24.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import "CalendarDayCollectionViewCell.h"

@interface CalendarDayCollectionViewCell ()

/**  日期  */
@property (nonatomic , strong) UILabel *dateLabel;
/** 农历 */
@property (nonatomic, strong)UILabel *chineseDateLabel;
/** 选中backView */
@property (nonatomic, strong)UIView *backView;


@end



@implementation CalendarDayCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
    }
    return self;
}


-(void)addViews{
    self.backgroundColor = [UIColor clearColor];
    
    self.backView = [[UIView alloc] init];
    [self.contentView addSubview:self.backView];
    self.backView.backgroundColor = [UIColor lightGrayColor];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    self.backView.hidden = YES;
    self.backView.layer.cornerRadius = 20;
    self.backView.layer.masksToBounds = YES;

    
    _dateLabel = [[UILabel alloc]init];
    [_dateLabel setFont:[UIFont systemFontOfSize:14 weight:(UIFontWeightMedium)]];
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(8);
    }];
    
    self.chineseDateLabel = [[UILabel alloc]init];
    [self.chineseDateLabel setFont:[UIFont systemFontOfSize:12]];
    [self.contentView addSubview:self.chineseDateLabel];
    [self.chineseDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-8);
        make.centerX.offset(0);
    }];
    
}

-(void)setModel:(CalendarDetailInfoModel *)model{
    _model = model;
    self.dateLabel.text = [NSString stringWithFormat:@"%ld",model.day];
    if (!model.chineseDay) {
        [model setChineseValue];
    }
    if (model.chineseDay == 1) {
        NSArray *chinese_numerals = @[@"十二",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二"];
        
        self.chineseDateLabel.text = [NSString stringWithFormat:@"%@月",chinese_numerals[model.chineseMonth]];
    }else{
        self.chineseDateLabel.text = [NSString stringWithFormat:@"%@",[self translationNumber:model.chineseDay]];
    }
    if (model.isCurrentMonth) {
        self.dateLabel.textColor = [UIColor blackColor];
        self.chineseDateLabel.textColor = [UIColor blackColor];
    }else{
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.chineseDateLabel.textColor = [UIColor lightGrayColor];
    }
    if (model.isToday) {
        self.dateLabel.text = @"今";
        self.dateLabel.textColor = [UIColor cyanColor];
        self.chineseDateLabel.textColor = [UIColor cyanColor];
    }
    self.backView.hidden = (!model.isSelected || !model.isCurrentMonth);
}



-(NSString *)translationNumber:(NSInteger )number{
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十"];
    if (number<=10) {
        return [NSString stringWithFormat:@"初%@",chinese_numerals[number-1]];
    }else if (number<20){
        return [NSString stringWithFormat:@"十%@",chinese_numerals[number%10-1]];
    }else if (number<30){
        if (number == 20) {
            return @"廿十";
        }
        return [NSString stringWithFormat:@"廿%@",chinese_numerals[number%20-1]];
    }
    if (number == 30) {
        return @"卅十";
    }
    return [NSString stringWithFormat:@"卅%@",chinese_numerals[number%30-1]];
}


@end
