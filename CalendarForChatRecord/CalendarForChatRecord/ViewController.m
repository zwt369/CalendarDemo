//
//  ViewController.m
//  CalendarForChatRecord
//
//  Created by Tony Zhang on 2018/2/2.
//  Copyright © 2018年 Tony Zhang. All rights reserved.
//

#import "ViewController.h"
#import "WWWeekNoteHeader.h"
#import "WWMessageCalendarModel.h"
#import "WWMessageCalendarTableViewCell.h"
#import "WWTimestampDetailInfoModel.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/**mainTable*/
@property(nonatomic,strong)UITableView *mainTable;

/**数据*/
@property(nonatomic,strong)NSMutableDictionary *calendarDict;

/**key*/
@property(nonatomic,strong)NSMutableArray *calendakey;

/**聊天消息时间戳*/
@property(nonatomic,strong)NSMutableArray<WWMessageCalendarModel *> *chatModelArray;

/** 第一条消息的时间戳 */
@property(nonatomic,strong)NSString *firstMessageTimeStamp;
/**第一条消息的date model*/
@property(nonatomic,strong)WWTimestampDetailInfoModel *firstMessageDateModel ;
/**当前时间date model*/
@property(nonatomic,strong)WWTimestampDetailInfoModel *currentDateModel ;

/** 数据处理队列 */
@property(nonatomic,strong)dispatch_group_t group;

@end

@implementation ViewController

-(WWTimestampDetailInfoModel *)firstMessageDateModel{
    if (_firstMessageDateModel == nil) {
        _firstMessageDateModel = [self weekdayInMonthWithTimestamp:self.firstMessageTimeStamp.integerValue];
    }
    return _firstMessageDateModel;
}

-(WWTimestampDetailInfoModel *)currentDateModel{
    if (_currentDateModel == nil) {
        _currentDateModel =  [self weekdayInMonthWithTimestamp:time(NULL)];;
    }
    return _currentDateModel;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"按日期查找";
    self.view.backgroundColor = [UIColor whiteColor];
    WWWeekNoteHeader *haderView = [[WWWeekNoteHeader alloc]initWithFrame:CGRectMake(0, 20, WWScreenWidth, 35)];
    [self.view addSubview:haderView];
    self.mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(haderView.frame), WWScreenWidth, WWScreenHeight-55) style:(UITableViewStyleGrouped)];
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainTable];
    self.mainTable.rowHeight = UITableViewAutomaticDimension;
    self.mainTable.estimatedSectionHeaderHeight = 0;
    self.mainTable.estimatedSectionFooterHeight = 0;
    [self.mainTable registerClass:[WWMessageCalendarTableViewCell class] forCellReuseIdentifier:@"cell"];
    self.mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self dealDateCalendar];
}

-(NSMutableDictionary *)calendarDict{
    if (_calendarDict == nil) {
        _calendarDict = [[NSMutableDictionary alloc]init];
    }
    return _calendarDict;
}

-(NSMutableArray *)calendakey{
    if (_calendakey == nil) {
        _calendakey = [[NSMutableArray alloc]init];
    }
    return _calendakey;
}

-(NSMutableArray<WWMessageCalendarModel *> *)chatModelArray{
    if (_chatModelArray == nil) {
        _chatModelArray = [[NSMutableArray alloc]init];
    }
    return _chatModelArray;
}

-(void)dealDateCalendar{
    NSArray *timeStamp = @[@"1510243200",@"1513699200",@"1513872000",@"1516550400"];
    [self dealTimeStapmArray:timeStamp];
}

-(void)dealTimeStapmArray:(NSArray *)dataArray{
    
    dispatch_group_t group = dispatch_group_create();
    self.group = group;
    // 2. 队列
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    dispatch_group_enter(group);
    dispatch_group_async(group, q, ^{
        if (dataArray.count == 0) {
            [self didNotHaveChatMessage];
        }else{
            /** 第一条消息的时间戳 */
            self.firstMessageTimeStamp = dataArray.firstObject;
            /** 获取第一条消息到当前时间总月份 */
            NSInteger monthNumber = [self monthNumberFromDateModel1:self.firstMessageDateModel toModel2:self.currentDateModel];
            if (monthNumber == 0) {
                [self onlyCurrentMonthHaveMessage];
            }else{
                [self manyMonthHaveMessageWithMonthCount:monthNumber];
            }
        }
    });
    
    if (dataArray.count != 0) {
        NSMutableArray *ymdTimeStam = [[NSMutableArray alloc]init];
        dispatch_group_enter(group);
        dispatch_group_async(group, q, ^{
            for (NSString *time in dataArray) {
                NSString *ymdString = [self ymdtimestampStringFrotimestamp:time.integerValue];
                if (![ymdTimeStam containsObject:ymdString]) {
                    WWTimestampDetailInfoModel *dateModel = [self weekdayInMonthWithTimestamp:time.integerValue];
                    WWMessageCalendarModel *calendar = [[WWMessageCalendarModel alloc]init];
                    calendar.timeModel = dateModel;
                    calendar.timeStamp = time.integerValue;
                    calendar.ymTimeNote = [ymdString substringToIndex:8];
                    [ymdTimeStam addObject:ymdString];
                    [self.chatModelArray addObject:calendar];
                }else{
                    continue;
                }
            }
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (dataArray.count  == 0) {
            [self.mainTable reloadData];
        }else{
            for (WWMessageCalendarModel *x in self.chatModelArray) {
                NSArray *dataArray = self.calendarDict[x.ymTimeNote];
                for (WWMessageCalendarModel *model in dataArray) {
                    if (model.blankItem) {
                        continue;
                    }
                    if (model.timeModel.year == x.timeModel.year && model.timeModel.month == x.timeModel.month && model.timeModel.day == x.timeModel.day) {
                        model.hadMessage = YES;
                        model.timeStamp = x.timeStamp;
                    }
                }
            }
            [self.mainTable reloadData];
        }
    });
}


/** 聊天消息为空 */
-(void)didNotHaveChatMessage{
    NSMutableArray *dayArray = [[NSMutableArray alloc]init];
    NSString *monthStr = [self   dealMessageCalendarWithTimeNmber:time(NULL)];
    if (self.currentDateModel.weekday != 7) {
        for (NSInteger i = 0; i < self.currentDateModel.weekday; i++) {
            WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
            if (i == self.currentDateModel.weekday-1) {
                model.isToday = YES;
                model.timeModel = self.currentDateModel;
            }else{
                model.blankItem = YES;
            }
            [dayArray addObject:model];
        }
    }else{
        WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
        model.isToday = YES;
        model.timeModel = self.currentDateModel;
        [dayArray addObject:model];
    }
    [self.calendakey addObject: monthStr];
    [self.calendarDict setValue:dayArray forKey:monthStr];
    dispatch_group_leave(self.group);
}

/** 仅当前月有消息 */
-(void)onlyCurrentMonthHaveMessage{
    NSMutableArray *dayArray = [[NSMutableArray alloc]init];
    if (self.firstMessageDateModel.weekday != 7) {
        for (NSInteger i = 0; i < self.firstMessageDateModel.weekday-1; i++) {
            WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
            model.blankItem = YES;
            [dayArray addObject:model];
        }
    }
    for (NSInteger i = self.firstMessageDateModel.day; i < self.currentDateModel.day+1; i ++) {
        WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
        if (i == self.currentDateModel.day) {
            model.isToday = YES;
        }else{
            model.isToday = NO;
        }
        model.blankItem = NO;
        model.hadMessage = NO;
        WWTimestampDetailInfoModel *timeModel = [[WWTimestampDetailInfoModel alloc]init];
        timeModel.year = self.currentDateModel.year;
        timeModel.month = self.currentDateModel.month;
        timeModel.day = i;
        model.timeModel = timeModel;
        [dayArray addObject:model];
    }
    [self.calendakey addObject: [self   dealMessageCalendarWithTimeNmber:self.firstMessageTimeStamp.integerValue]];
    [self.calendarDict setValue:dayArray forKey: [self   dealMessageCalendarWithTimeNmber:self.firstMessageTimeStamp.integerValue]];
    dispatch_group_leave(self.group);
}


/** 多个月有消息 */
-(void)manyMonthHaveMessageWithMonthCount:(NSInteger)count{
    NSString *monthKey = [self   dealMessageCalendarWithTimeNmber:self.firstMessageTimeStamp.integerValue];
    NSString *monthStr = [self  dealMessageCalendarWithTimeNmber:time(NULL)];
    for (NSInteger i = 0; i < count+1; i ++) {
        /** 获取当前月的总天数 */
        NSInteger monthDay = [self totaldaysInThisMonthOfTimestamp:monthKey];
//        NSLog(@"%@++++++%f",monthKey,monthDay);
        
        /** 当前月的第一天model */
        WWTimestampDetailInfoModel *firstModel ;
        if (i == 0) {
            firstModel = self.firstMessageDateModel;
        }else{
            firstModel = [self weekdayInMonthWithTimestamp:[self getMonthFirstDay:monthKey].timeIntervalSince1970];
        }
        NSMutableArray *dayArray = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < firstModel.weekday-1; i++) {
            WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
            model.blankItem = YES;
            [dayArray addObject:model];
        }
        if (![monthKey isEqualToString:monthStr]) {
            for (NSInteger j = firstModel.day; j <monthDay+1; j++) {
                WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
                model.isToday = NO;
                model.blankItem = NO;
                model.hadMessage = NO;
                WWTimestampDetailInfoModel *timeModel = [[WWTimestampDetailInfoModel alloc]init];
                timeModel.year = firstModel.year;
                timeModel.month = firstModel.month;
                timeModel.day = j;
                model.timeModel = timeModel;
                [dayArray addObject:model];
            }
        }else{
            for (NSInteger i = firstModel.day; i < self.currentDateModel.day+1; i ++) {
                WWMessageCalendarModel *model = [[WWMessageCalendarModel alloc]init];
                if (i == self.currentDateModel.day) {
                    model.isToday = YES;
                }else{
                    model.isToday = NO;
                }
                model.blankItem = NO;
                model.hadMessage = NO;
                WWTimestampDetailInfoModel *timeModel = [[WWTimestampDetailInfoModel alloc]init];
                timeModel.year = firstModel.year;
                timeModel.month = firstModel.month;
                timeModel.day = i;
                model.timeModel = timeModel;
                [dayArray addObject:model];
            }
        }
        [self.calendakey addObject:monthKey];
        [self.calendarDict setValue:dayArray forKey: monthKey];
        
        monthKey =  [self lastMonthFirstDayString:monthKey];
    }
    dispatch_group_leave(self.group);
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.calendakey.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WWMessageCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *key = self.calendakey[indexPath.section];
    NSArray *dataArray = self.calendarDict[key];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataArray = dataArray;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WWScreenWidth, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, WWScreenWidth-15, 35)];
    monthLabel.backgroundColor = [UIColor whiteColor];
    monthLabel.textColor = [UIColor darkGrayColor];
    monthLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:monthLabel];
    monthLabel.text =  self.calendakey[section];
    UIView *grayLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WWScreenHeight, 1)];
    grayLine.backgroundColor = [UIColor grayColor];
    [headerView addSubview:grayLine];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = self.calendakey[indexPath.section];
    NSArray *dataArray = self.calendarDict[key];
    NSInteger count = dataArray.count;
    return  (WWScreenWidth/7+10)*ceilf(count/7.0);
}

#pragma mark   日历处理

/** 获取当前时间戳为周几 */
-(WWTimestampDetailInfoModel *)weekdayInMonthWithTimestamp:(NSInteger)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:date];
    WWTimestampDetailInfoModel *model = [[WWTimestampDetailInfoModel alloc]init];
    model.year = components.year;
    model.day = components.day;
    model.month = components.month;
    model.weekday = components.weekday;
    return model;
}
/** 获取当前时间戳为周几 */
-(WWTimestampDetailInfoModel *)weekdayInMonthWithDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:date];
    WWTimestampDetailInfoModel *model = [[WWTimestampDetailInfoModel alloc]init];
    model.year = components.year;
    model.day = components.day;
    model.month = components.month;
    model.weekday = components.weekday;
    return model;
}

/** 获取两个时间点的月份差 */
-(NSInteger)monthNumberFromDateModel1:(WWTimestampDetailInfoModel *)model1 toModel2:(WWTimestampDetailInfoModel *)model2{
    NSInteger distance = model2.year-model1.year;
    return distance*12+(model2.month-model1.month);
}

/** 获取当前月总天数 */
- (NSInteger)totaldaysInThisMonthOfTimestamp:(NSString *)timeString{
    NSDate *date = [self getMonthFirstDay:timeString];
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

/** 获取下一个月开始时间 string*/
- (NSString *)lastMonthFirstDayString:(NSString *)monthString{
    NSDate *date = [self getMonthFirstDay:monthString];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return [self timestampStringFroDate:newDate];
}

-(NSDate*)getMonthFirstDay:(NSString *)time{
    time = [time stringByAppendingString:@"01日"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat : @"yyyy年MM月dd日"];
    NSDate *dateTime = [formatter dateFromString:time];
    return dateTime;
}

/** date 转时间 */
-(NSString*)timestampStringFroDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

/** date 转时间 年月日 */
-(NSString*)ymdtimestampStringFrotimestamp:(NSInteger )timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSString *)dealMessageCalendarWithTimeNmber:(NSInteger)time{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *_formatter = [[NSDateFormatter alloc]init];
    [_formatter setDateStyle:NSDateFormatterMediumStyle];
    [_formatter setTimeStyle:NSDateFormatterShortStyle];
    [_formatter setDateFormat:@"yyyy年MM月"];
    return [_formatter stringFromDate:date];
}



-(void)dealloc{}



@end
