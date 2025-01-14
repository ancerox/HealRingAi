//
//  SleepModel.h
//  OdmLightBle
//
//  Created by ZongBill on 15/8/14.
//  Copyright (c) 2015年 X. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SLEEPTYPE) {
    SLEEPTYPENONE,    //无数据
    SLEEPTYPESOBER,   //清醒
    SLEEPTYPELIGHT,   //浅睡
    SLEEPTYPEDEEP,    //深睡
    SLEEPTYPEUNWEARED //未佩戴
};

typedef NS_ENUM(NSInteger, QCSleepDataType) {
    SleepDataTypeMainSleepBegin = 1,  //主睡眠起点
    SleepDataTypeMainSleepEnd = 2,    //主睡眠结束点
    SleepDataTypeOtherSleepBegin = 3, //普通睡眠起点
    SleepDataTypeOtherSleepEnd = 4,   //普通睡眠结束点
    SleepDataTypeSleeping = 5,        //睡眠中
    SleepDataTypeDefault = SleepDataTypeSleeping
};

@interface QCSleepModel : NSObject
@property (nonatomic, assign) SLEEPTYPE type;       //睡眠类型
@property (nonatomic, strong) NSString *happenDate; //发生时间 yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSString *endTime;    //结束时间.
@property (nonatomic, assign) NSInteger total;      //开始时间与结束时间的时间间隔(单位：分钟)




#pragma mark - 保留参数
@property (nonatomic, strong) NSString *sleepQa;    //睡眠质量(保留值)
@property (nonatomic, assign) QCSleepDataType dataType;     //数据类型(保留值)
@property (nonatomic, assign) NSInteger effectiveMinutes; //本时间段内有效睡眠分钟数(起点/结束点根据当前值获取精确的时间点)(保留值)

+ (SLEEPTYPE)typeWithQuality:(NSInteger)qa;

+ (NSInteger)sleepQualityFromRawValue:(NSInteger)qa;

+ (QCSleepDataType)sleepDataTypeFromRawValue:(NSInteger)qa;

+ (NSInteger)effetiveMinutesFromRawValue:(NSInteger)qa;

+ (BOOL)isRawQAValue:(NSInteger)qa;

- (NSString *)realBeginTime;

- (NSString *)realEndTime;

- (NSInteger)realEffectiveMinutes;

+ (SLEEPTYPE)typeForSleepV2:(NSInteger)val;
@end
