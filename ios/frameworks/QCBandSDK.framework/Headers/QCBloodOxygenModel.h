//
//  BloodOxygenModel.h
//  OudmonBandV1
//
//  Created by ZongBill on 16/5/23.
//  Copyright © 2016年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 @enum BloodOxygenTypeLow 低氧
 @enum BloodOxygenTypeNormal 正常
 @enum BloodOxygenTypeHigh 偏高
 */
typedef enum : NSUInteger {
    BloodOxygenTypeLow = 0,
    BloodOxygenTypeNormal,
    BloodOxygenTypeHigh,
} BloodOxygenType;

extern NSString *const OdmBandRealTimeBloodOxygenFinish;


@interface QCBloodOxygenModel : NSObject

@property (assign, nonatomic) CGFloat maxSoa2;           //最大血氧饱和度
@property (assign, nonatomic) CGFloat minSoa2;           //最小血氧饱和度
@property (assign, nonatomic) CGFloat soa2;             //血氧饱和度
@property (strong, nonatomic) NSDate *date;             //测量时间
@property (assign, nonatomic) BloodOxygenType soa2Type; //血氧饱和度类型:低氧/正常/**
@property (assign, nonatomic) NSInteger sourceType;     //血氧数据类型:0:定时数据，1:手动测量数据
@property (assign, nonatomic) BOOL isSubmit;            //是否已提交服务器
@property (strong, nonatomic) NSString *device;         //设备名称

+ (instancetype)bloodOxygenWithSoa2:(CGFloat)soa2;

+ (instancetype)bloodOxygenWithSoa2:(CGFloat)soa2 testDate:(NSDate *)date;

+ (instancetype)bloodOxygenModelFromResponseObject:(NSDictionary *)dict;

@end
