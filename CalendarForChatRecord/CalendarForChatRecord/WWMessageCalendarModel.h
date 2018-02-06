//
//  WWMessageCalendarModel.h
//  WoWo
//
//  Created by Tony Zhang on 2018/1/24.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWTimestampDetailInfoModel.h"

@interface WWMessageCalendarModel : NSObject

/**第一条消息时间戳*/
@property(nonatomic,assign)NSInteger timeStamp;

/**是否有消息*/
@property(nonatomic,assign)BOOL hadMessage;

/**显示空白*/ // 优先设置是否为空白
@property(nonatomic,assign)BOOL blankItem;

/**当天*/
@property(nonatomic,assign)BOOL isToday;

/**model*/
@property(nonatomic,strong)WWTimestampDetailInfoModel *timeModel;

/**年月标识*/
@property(nonatomic,copy)NSString *ymTimeNote;

@end
