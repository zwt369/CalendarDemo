//
//  WWCalendarCollectionViewCell.m
//  WoWo
//
//  Created by Tony Zhang on 2018/1/24.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import "WWCalendarCollectionViewCell.h"

@interface WWCalendarCollectionViewCell ()

/**背景*/
@property(nonatomic,strong)UIView *blueBack;

/**今天*/
@property(nonatomic,strong)UILabel *todayNote;

@property (nonatomic , strong) UILabel *dateLabel;

@end



@implementation WWCalendarCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
    }
    return self;
}


-(void)addViews{
    self.backgroundColor = [UIColor whiteColor];
    self.blueBack = [[UIView alloc]init];
    self.blueBack.backgroundColor = WWThemeColor;
    [self.contentView addSubview:self.blueBack];
    [self.blueBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_equalTo(CGSizeMake(MM_Width(30), MM_Width(30)));
    }];
    self.blueBack.layer.cornerRadius = MM_Width(15);
    self.blueBack.layer.masksToBounds = YES;
    
    _dateLabel = [[UILabel alloc]init];
    [_dateLabel setFont:[UIFont systemFontOfSize:16]];
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
  
    self.todayNote = [[UILabel alloc]init];
    self.todayNote.text = @"今天";
    self.todayNote.font = [UIFont systemFontOfSize:11];
    self.todayNote.textColor = WWThemeColor;
    [self.contentView addSubview:self.todayNote];
    [self.todayNote mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.blueBack.mas_bottom).offset(2);
    }];
}

-(void)setModel:(WWMessageCalendarModel *)model{
    _model = model;
//    NSSLog(@"xxxxxxx%ld ++++ %ld ++++ %d",model.timeModel.day,model.timeStamp,model.hadMessage);
    self.dateLabel.text = [NSString stringWithFormat:@"%ld",model.timeModel.day];
//    NSSLog(@"+++%@",model.dateString);
    if (model.blankItem) {
        self.todayNote.hidden = YES;
        self.blueBack.hidden = YES;
        self.dateLabel.hidden = YES;
    }else{
        if (model.hadMessage) {
            self.dateLabel.textColor = WWBlackColor;
        }else{
            self.dateLabel.textColor = WWDarkGrayColor;
        }
        if (model.isToday) {
            self.todayNote.hidden = NO;
            self.blueBack.hidden = NO;
            self.dateLabel.textColor = [UIColor whiteColor];
        }else{
            self.todayNote.hidden = YES;
            self.blueBack.hidden = YES;
        }
         self.dateLabel.hidden = NO;
    }
}


@end
