//
//  WWMessageCalendarTableViewCell.m
//  WoWo
//
//  Created by Tony Zhang on 2018/1/24.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import "LCMonthCalendarView.h"
#import "LCCalendarDayCollectionViewCell.h"


@interface LCMonthCalendarView ()<UICollectionViewDelegate,UICollectionViewDataSource>

/**collectionView*/
@property(nonatomic,strong)UICollectionView *colleciontView;
/**数据源*/
@property(nonatomic,strong)NSMutableArray<LCCalendarDetailInfoModel *> *modelArray;
/** 当前月份 */
@property (nonatomic, strong)UILabel *currentMonthLabel;
/** 当前显示date */
@property (nonatomic, strong)NSDate *currentDate;
/** 当前选中date */
@property (nonatomic, strong)NSDate *selectedDate;
/** 当前选中model */
@property (nonatomic, strong)LCCalendarDetailInfoModel *selectedModel;
/** 标题 */
@property (nonatomic, strong)UILabel *titleLabel;

@end


@implementation LCMonthCalendarView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


-(void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.size.mas_equalTo(CGSizeMake(WWScreenWidth, 30));
    }];
    
    CGFloat width = (WWScreenWidth-30)/7;
    NSArray *titleArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i < titleArray.count; i ++) {
        UILabel *weekNo = [[UILabel alloc]initWithFrame:CGRectMake(15+width*i, 30, width, 30)];
        weekNo.textColor = WWDarkGrayColor;
        weekNo.font = [UIFont systemFontOfSize:14];
        weekNo.textAlignment = NSTextAlignmentCenter;
        weekNo.text = titleArray[i];
        [self addSubview:weekNo];
    }
    
    self.currentMonthLabel = [[UILabel alloc] init];
    self.currentMonthLabel.textColor = [UIColor blueColor];
    self.currentMonthLabel.font = [UIFont systemFontOfSize:300 weight:(UIFontWeightMedium)];
    [self addSubview:self.currentMonthLabel];
    [self.currentMonthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    CGFloat itemWidth = (WWScreenWidth-30)/7;
    CGFloat itemHeight = 50;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
//    [collectionView setCollectionViewLayout:layout animated:YES];
    collectionView.scrollEnabled = NO;
    [self addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.top.offset(60);
        make.left.offset(15);
        make.width.mas_equalTo(WWScreenWidth-30);
        make.height.mas_equalTo(100);
    }];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    self.colleciontView = collectionView;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[LCCalendarDayCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipeD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    swipeD.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeD];
    self.currentDate = [self getMonthFirstDay:[self timestampStringFroDate:[NSDate date]]];
    self.titleLabel.text = [self timestampStringFroDate:self.currentDate];
    self.selectedDate = [NSDate date];
    [self dealDateCalendarWithDate:self.currentDate];
}

-(NSMutableArray<LCCalendarDetailInfoModel *> *)modelArray{
    if (_modelArray == nil) {
        _modelArray = [[NSMutableArray alloc]init];
    }
    return _modelArray;
}

-(void)leftSwipe:(UISwipeGestureRecognizer *)sender{
    /**  右扫下一个月  */
    NSDate *nextMonthDate = [NSDate dateWithTimeInterval:31*24*3600 sinceDate:self.currentDate];
    self.currentDate = [self getMonthFirstDay:[self timestampStringFroDate:nextMonthDate]];
    [self dealDateCalendarWithDate:self.currentDate];
    self.titleLabel.text = [self timestampStringFroDate:self.currentDate];
}


-(void)rightSwipe:(UISwipeGestureRecognizer *)sender{
    /**  左扫上一个月  */
    NSDate *lastMonthDate = [NSDate dateWithTimeInterval:-24*3600 sinceDate:self.currentDate];
    self.currentDate = [self getMonthFirstDay:[self timestampStringFroDate:lastMonthDate]];
    [self dealDateCalendarWithDate:self.currentDate];
    self.titleLabel.text = [self timestampStringFroDate:self.currentDate];
}

-(void)dealDateCalendarWithDate:(NSDate *)date{
    /**  当前显示月份的天数  */
    NSInteger totalCount = [self totaldaysInThisMonthOfTimestamp:[self timestampStringFroDate:date]];
    /**  获取显示月份第一天*/
    NSDate *currentFirstDate = [self getMonthFirstDay:[self timestampStringFroDate:date]];
    /**  获取显示月份第一天周几*/
    NSInteger weekDay = [self weekdayInMonthWithDate:currentFirstDate];
    /**  需要显示月份一共几周*/
    NSInteger totoalWeek = ceil((totalCount+weekDay-1)/7.0)+1;
    /**  获取需要绘制日历第一天  */
    NSDate *firstMonthDate = [NSDate dateWithTimeInterval:-(weekDay-1)*24*3600 sinceDate:currentFirstDate];
    /**  今天  */
    LCCalendarDetailInfoModel *todayModel = [LCCalendarDetailInfoModel modelInMonthWithDate:[NSDate date]];
    /**  当前选中的日期  */
    LCCalendarDetailInfoModel *selectedModel = [LCCalendarDetailInfoModel modelInMonthWithDate:self.selectedDate];
    LCCalendarDetailInfoModel *currentFirstModel = [LCCalendarDetailInfoModel modelInMonthWithDate:currentFirstDate];
    [self.modelArray removeAllObjects];
    for (int i = 0; i < totoalWeek*7; i++) {
        NSDate *modelDate = [NSDate dateWithTimeInterval:i*24*3600 sinceDate:firstMonthDate];
        LCCalendarDetailInfoModel *model = [LCCalendarDetailInfoModel modelInMonthWithDate:modelDate];
        if (model.month ==  currentFirstModel.month) {
            model.isCurrentMonth = YES;
        }
        if (model.year == todayModel.year && model.month == todayModel.month && model.day == todayModel.day) {
            model.isToday = YES;
        }
        if (model.year == selectedModel.year && model.month == selectedModel.month && model.day == selectedModel.day) {
            model.isSelected = YES;
            self.selectedModel = model;
        }
        [self.modelArray addObject:model];
    }
    [self.colleciontView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.modelArray.count/7*50);
    }];
   [self.colleciontView reloadData];
    self.currentMonthLabel.text = [NSString stringWithFormat:@"%ld",currentFirstModel.month];
}

/** date转模型 */
-(LCCalendarDetailInfoModel *)modelInMonthWithDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:date];
    LCCalendarDetailInfoModel *model = [[LCCalendarDetailInfoModel alloc]init];
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


/** 获取需要显示月份总天数 */
- (NSInteger)totaldaysInThisMonthOfTimestamp:(NSString *)timeString{
    NSDate *date = [self getMonthFirstDay:timeString];
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

/**  获取显示月份第一天  */
-(NSDate*)getMonthFirstDay:(NSString *)time{
    time = [time stringByAppendingString:@"01日"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat : @"yyyy年MM月dd日"];
    NSDate *dateTime = [formatter dateFromString:time];
    return dateTime;
}

/** date 转时间 到月 */
-(NSString*)timestampStringFroDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

/** date 转时间 到日 */
-(NSString*)fullTimestampStringFroDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

/**  获取当前日期是周几  */ // 从周日开始
-(NSInteger)weekdayInMonthWithDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    return components.weekday;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelArray.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LCCalendarDayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.modelArray[indexPath.row];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LCCalendarDetailInfoModel *model = self.modelArray[indexPath.row];
    if (model == self.selectedModel || !model.isCurrentMonth) {
        return;
    }
    if (self.selectedModel) {
        self.selectedModel.isSelected = NO;
    }
    model.isSelected = YES;
    self.selectedModel = model;
    self.selectedDate = [model dateValue];
    [collectionView reloadData];
}


@end
