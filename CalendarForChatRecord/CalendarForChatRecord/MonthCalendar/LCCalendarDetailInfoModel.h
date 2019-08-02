//
//  LCCalendarDetailInfoModel.h
//  WoWo
//
//  Created by Tony Zhang on 2018/1/25.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCCalendarDetailInfoModel : NSObject

/**年*/
@property(nonatomic,assign)NSInteger year;
/**月*/
@property(nonatomic,assign)NSInteger month;
/**日*/
@property(nonatomic,assign)NSInteger day;
/**周几*/
@property(nonatomic,assign)NSInteger weekday;


/**农历年*/
@property(nonatomic,assign)NSInteger chineseYear;
/**农历月*/
@property(nonatomic,assign)NSInteger chineseMonth;
/**农历日*/
@property(nonatomic,assign)NSInteger chineseDay;

/**是否为当前显示月分*/
@property(nonatomic,assign)BOOL isCurrentMonth;

/**当天*/
@property(nonatomic,assign)BOOL isToday;

/**是否选中*/
@property(nonatomic,assign)BOOL isSelected;

/** date转模型 */
+(LCCalendarDetailInfoModel *)modelInMonthWithDate:(NSDate *)date;

-(NSDate *)dateValue;

-(void)setChineseValue;


@end
