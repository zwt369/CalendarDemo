//
//  CalendarDetailInfoModel.m
//  WoWo
//
//  Created by Tony Zhang on 2018/1/25.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import "CalendarDetailInfoModel.h"

@implementation CalendarDetailInfoModel

+(CalendarDetailInfoModel *)modelInMonthWithDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:date];
    CalendarDetailInfoModel *model = [[CalendarDetailInfoModel alloc]init];
    model.year = components.year;
    model.day = components.day;
    model.month = components.month;
    model.weekday = components.weekday;
    NSCalendar *chineseCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *components1 = [chineseCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:date];
    model.chineseDay = components1.year;
    model.chineseDay = components1.day;
    model.chineseMonth = components1.month;
    return model;
}

-(void)setChineseValue{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat : @"yyyy年MM月dd日"];
    NSDate *dateTime = [formatter dateFromString:self.description];
    NSCalendar *chineseCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *components1 = [chineseCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:dateTime];
    self.chineseYear = components1.year;
    self.chineseDay = components1.day;
    self.chineseMonth = components1.month;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%ld年%ld月%ld日",self.year,self.month,self.day];
}

-(NSDate *)dateValue{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat : @"yyyy年MM月dd日"];
    NSDate *dateTime = [formatter dateFromString:self.description];
    return dateTime;
}

@end
