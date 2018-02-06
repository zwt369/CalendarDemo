//
//  WWTimestampDetailInfoModel.h
//  WoWo
//
//  Created by Tony Zhang on 2018/1/25.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WWTimestampDetailInfoModel : NSObject

/**年*/
@property(nonatomic,assign)NSInteger year;
/**月*/
@property(nonatomic,assign)NSInteger month;
/**日*/
@property(nonatomic,assign)NSInteger day;
/**周几*/
@property(nonatomic,assign)NSInteger weekday;

@end
