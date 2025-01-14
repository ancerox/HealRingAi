//
//  BloodPressureModel.h
//  OudmonBandV1
//
//  Created by ZongBill on 16/5/16.
//  Copyright © 2016年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @enum BloodPressureTypeLow 偏低
 @enum BloodPressureTypeNormal 正常
 @enum BloodPressureTypeHigh 偏高
 */
typedef enum : NSUInteger {
    BloodPressureTypeLow = 0,
    BloodPressureTypeNormal,
    BloodPressureTypeHigh,
} BloodPressureType;

extern NSString *const OdmBandRealTimeBloodPressureFinish;


@interface QCBloodPressureModel : NSObject

@property (assign, nonatomic) NSInteger systolicPressure;     //收缩压
@property (assign, nonatomic) NSInteger diastolicPressure;    //舒张压
@property (strong, nonatomic) NSDate *date;                   //测量时间
@property (assign, nonatomic) BloodPressureType pressureType; //血压类型
@property (assign, nonatomic) BOOL isSubmit;                  //是否提交
@property (strong, nonatomic) NSString *device;               //关联的设备

/**
 *  通过收缩压/舒张压生成实例
 *  @param systolic  收缩压
 *  @param diastolic 舒张压
 *  @return 血压模型实例
 */
+ (instancetype)bloodPressureModelWithSystolicPressure:(NSInteger)systolic diastolicPressure:(NSInteger)diastolic;
/**
 *  通过后台返回对象生成实例
 *  @param dict json对象
 *  @return 血压模型实例
 */
+ (instancetype)bloodPressureModelFromResponseObject:(NSDictionary *)dict;
/**
 *  通过收缩压/舒张压获取血压类型
 *  @param systolic  收缩压
 *  @param diastolic 舒张压
 *  @return 血压类型
 */
+ (BloodPressureType)getBloodPressureTypeWithSystolicPressure:(NSInteger)systolic diastolicPressure:(NSInteger)diastolic;

/**
 *  校正收缩压
 *  @param systolic  收缩压
 */
+ (NSInteger)calibrationSystolicPressure:(NSInteger)systolic;

/**
 *  舒张压
 *  @param diastolic 舒张压
 */
+ (NSInteger)calibrationDiastolicPressure:(NSInteger)diastolic;

/**
 *  校正收缩压/舒张压
 */
- (void)adjustBP;
@end
