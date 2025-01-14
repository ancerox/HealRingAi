//
//  AlarmModel.h
//  OudmonBandV2
//
//  Created by steve on 2021/6/26.
//  Copyright © 2021 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OdmBleConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCAlarmModel : NSObject

@property(nonatomic,assign) ALARMTYPE type; //闹钟类型：1-，2-，
@property(nonatomic,assign) NSInteger time; //闹钟时间，如：08:30
@property(nonatomic,strong) NSString *name; //闹钟名称，最多30个Byte
@property(nonatomic,strong) NSArray<NSString*>* weekDays; //周日到周六，状态，0:关闭，1:开启

- (NSData*)toCmd;

@end

NS_ASSUME_NONNULL_END
