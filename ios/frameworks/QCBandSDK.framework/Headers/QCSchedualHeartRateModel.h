//
//  SchedualHeartRateModel.h
//  OudmonBandV2
//
//  Created by ZongBill on 2017/11/8.
//  Copyright © 2017年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QCSchedualHeartRateModel : NSObject

@property (nonatomic, strong) NSString *date;                  // 日期, 格式为"yyyy-MM-dd"
@property (nonatomic, strong) NSArray<NSNumber *> *heartRates; // 心率数组, 每N分钟1条
@property (nonatomic, assign) NSInteger secondInterval;        // 数据时间间隔, 单位为秒
@property (nonatomic, assign) NSInteger serverID;              // 服务器ID
@property (nonatomic, assign) NSInteger updateTime;            // 服务器更新时间, 单位毫秒
@property (nonatomic, assign) BOOL isSync;                     // 是否同步了服务器
@property (nonatomic, strong) NSString *deviceID;              // 设备ID, 一般为Mac地址
@property (nonatomic, strong) NSString *deviceType;            // 设备类型, i.e. T90H_V1_0/

@end
