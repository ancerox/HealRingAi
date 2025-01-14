//
//  HeartRateModel.h
//  Band
//
//  Created by panguo on 16/1/15.
//  Copyright © 2016年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const OdmBandRealTimeHeartRateFinish;


@interface QCHeartRateModel : NSObject

@property (assign, nonatomic) NSInteger hrId;      ///< 心率id
@property (strong, nonatomic) NSDate *date;        ///< 测量时间
@property (assign, nonatomic) NSInteger heartrate; ///< 心率值

+ (instancetype)heartRateModelWithHeartRate:(NSInteger)hr;

@end
