//
//  LCWeekCalendarView.m
//  CalendarForChatRecord
//
//  Created by Tony.Zhang on 2019/8/1.
//  Copyright © 2019 Tony Zhang. All rights reserved.
//

#import "LCWeekCalendarView.h"
#import "LCCalendarDayCollectionViewCell.h"

@interface LCWeekCalendarView ()<UICollectionViewDelegate,UICollectionViewDataSource>

/**collectionView*/
@property(nonatomic,strong)UICollectionView *colleciontView;
/**数据源*/
@property(nonatomic,strong)NSMutableArray<LCCalendarDetailInfoModel *> *modelArray;
/** 当前显示周的第一天 */
@property (nonatomic, strong)NSDate *currentFirstDate;
/** 当前选中date */
@property (nonatomic, strong)NSDate *selectedDate;
/** 当前选中model */
@property (nonatomic, strong)LCCalendarDetailInfoModel *selectedModel;

@end

@implementation LCWeekCalendarView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


-(void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = (WWScreenWidth-30)/7;
    NSArray *titleArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i < titleArray.count; i ++) {
        UILabel *weekNo = [[UILabel alloc]initWithFrame:CGRectMake(15+width*i, 0, width, 30)];
        weekNo.textColor = WWDarkGrayColor;
        weekNo.font = [UIFont systemFontOfSize:14];
        weekNo.textAlignment = NSTextAlignmentCenter;
        weekNo.text = titleArray[i];
        [self addSubview:weekNo];
    }
    
    CGFloat itemWidth = (WWScreenWidth-30)/7;
    CGFloat itemHeight = 50;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.scrollEnabled = NO;
    [self addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.top.offset(30);
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
    
    self.currentFirstDate = [self getFirstWeekDateDate:[NSDate date]];
    self.selectedDate = [NSDate date];
    [self dealWeekDateCalendar];
}

-(NSMutableArray<LCCalendarDetailInfoModel *> *)modelArray{
    if (_modelArray == nil) {
        _modelArray = [[NSMutableArray alloc]init];
    }
    return _modelArray;
}

-(void)leftSwipe:(UISwipeGestureRecognizer *)sender{
    /**  右扫下一周  */
    self.currentFirstDate = [NSDate dateWithTimeInterval:7*24*3600 sinceDate:self.currentFirstDate];
    [self dealWeekDateCalendar];
}


-(void)rightSwipe:(UISwipeGestureRecognizer *)sender{
    /**  左扫上一周  */
    self.currentFirstDate = [NSDate dateWithTimeInterval:-7*24*3600 sinceDate:self.currentFirstDate];
    [self dealWeekDateCalendar];
}

-(void)dealWeekDateCalendar{
    /**  今天  */
    LCCalendarDetailInfoModel *todayModel = [LCCalendarDetailInfoModel modelInMonthWithDate:[NSDate date]];
    /**  当前选中的日期  */
    LCCalendarDetailInfoModel *selectedModel = [LCCalendarDetailInfoModel modelInMonthWithDate:self.selectedDate];
    [self.modelArray removeAllObjects];
    for (int i = 0; i < 7; i++) {
        NSDate *modelDate = [NSDate dateWithTimeInterval:i*24*3600 sinceDate:self.currentFirstDate];
        LCCalendarDetailInfoModel *model = [LCCalendarDetailInfoModel modelInMonthWithDate:modelDate];
        model.isCurrentMonth = YES;
        if (model.year == todayModel.year && model.month == todayModel.month && model.day == todayModel.day) {
            model.isToday = YES;
        }
        if (model.year == selectedModel.year && model.month == selectedModel.month && model.day == selectedModel.day) {
            model.isSelected = YES;
            self.selectedModel = model;
        }
        [self.modelArray addObject:model];
    }
    [self.colleciontView reloadData];
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



/**  获取显示周第一天  */
-(NSDate*)getFirstWeekDateDate:(NSDate *)date{
    NSInteger weekDay  = [self weekdayInMonthWithDate:date];
    return [NSDate dateWithTimeInterval:-24*3600*(weekDay-1) sinceDate:date];
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
