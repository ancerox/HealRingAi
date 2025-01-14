//
//  QCSDKManager.h
//  QCBandSDK
//
//  Created by steve on 2021/7/7.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import <QCBandSDK/QCDFU_Utils.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @discussion Service IDs supported by the device
 */

extern NSString *const QCBANDSDKSERVERUUID1;
extern NSString *const QCBANDSDKSERVERUUID2;


typedef NS_ENUM(NSInteger, QCMeasuringType) {
    QCMeasuringTypeHeartRate = 0,   //Heart rate measurement
    QCMeasuringTypeBloodPressue,    //blood pressure measurement
    QCMeasuringTypeBloodOxygen,     //blood oxygen measurement
    QCMeasuringTypeOneKeyMeasure,   //One-click measurement
    QCMeasuringTypeCount,
};

@class QCSimpleDialFileModel;
@interface QCSDKManager : NSObject

/*
 *  Receive notifications from watch, find phone
 *  status:1->Start，2->End
 */
@property(nonatomic,copy)void(^findPhone)(NSInteger status);

/**
 *  Receive notifications from watch, enter camera
 */
@property(nonatomic,copy)void(^switchToPicture)(void);

/**
 *  Receive the watch, take a picture of the callback
 */
@property(nonatomic,copy)void(^takePicture)(void);

/**
 *  Receive the watch and end the callback of taking pictures
 */
@property(nonatomic,copy)void(^stopTakePicture)(void);

/**
 *  Receive the watch, measure the callback of heart rate value
 *
 *  App Send single measuring cmd to watch.(Some watches support)
 */
@property(nonatomic,copy)void(^hrMeasuring)(NSInteger hr);

/**
 *  Receive the watch and measure the callback of blood pressure value
 *
 *  App Send single measuring cmd to watch.(Some watches support)
 *
 *  @param sbp Diastolic blood pressure
 *  @param dbp systolic blood pressure
 */
@property(nonatomic,copy)void(^bpMeasuring)(NSInteger sbp,NSInteger dbp);

/**
 *  Receive the watch, measure the callback of blood oxygen value
 *
 *  App Send single measuring cmd to watch.(Some watches support)
 *
 *  @param so2 :blood oxygen
 */
@property(nonatomic,copy)void(^boMeasuring)(CGFloat so2);

/**
 *  When the watch is received, the measurement data fails to be called back (for example, the bracelet is not properly worn, etc.)
 *
 *  App Send single measuring cmd to watch.(Some watches support)
 */
@property(nonatomic,copy)void(^measuringFail)(void);

/**
 *  Receive the watch, measure the callback of real time value
 *
 *  App Send RealTime HeartRate measuring cmd to watch.
 */
@property(nonatomic,copy)void(^realTimeHeartRate)(NSInteger hr);

/**
 *  Receive notifications when watch switches dial index numbers
 *
 *  @param dailIndex:  index-->dial Index number(0-N),0:wallpaper
 */
@property(nonatomic,copy)void(^dailIndex)(NSInteger index);

/**
 *  Receive notifications when watch switch low battery mode
 *
 *  @param lowerPower:  status-->YES:ON,NO:OFF
 */
@property(nonatomic,copy)void(^lowerPower)(BOOL status);

/**
 *  Receive notifications when the watch's current step count increases (steps, calories, distance), supported by some watches
 *  当手表当前步数增加时接收通知（步数，卡路里，距离），部分手表支持
 *  @param currentStepInfo:  step: unit: step, calorie: unit: calorie, distance: unit: meter
 */
@property(nonatomic,copy)void(^currentStepInfo)(NSInteger step,NSInteger calorie,NSInteger distance);

/**
 *  Receive notifications when watch data is updated
 *  当手表数据更新时接收通知
 *  @param watchDataUpdateReport: dataType:data type,dataValue:data detail
 */
@property(nonatomic,copy)void(^watchDataUpdateReport)(QCDeviceDataUpdateReport dataType,NSInteger dataValue);

// 单例类实例
+ (instancetype)shareInstance;


#pragma mark - 外围设备(手环)相关

/// Add peripherals
///
/// @param peripheral     :peripheral equipment
/// @param finished         :add completion callback
- (void)addPeripheral:(CBPeripheral *)peripheral finished:(void (^)(BOOL))finished;

/// remove peripherals
///
/// @param peripheral peripheral equipment
- (void)removePeripheral:(CBPeripheral *)peripheral;

/// remove all peripherals
- (void)removeAllPeripheral;

#pragma mark - Server相关

/// 获取表盘列表
/// @param finished 结果回调
//- (void)queryDialList:(void(^)(BOOL isSuccess,NSArray <QCSimpleDialFileModel*>*serverDatas,NSError *error))handle;


#pragma mark - 测量数据

/// Send measurement order
/// @param type         :Measurement type
/// @param handle    :Measurement result callback (error code: -1: failed to send start command, -2: failed to send end command, -3: bracelet is not properly worn)
- (void)startToMeasuringWithOperateType:(QCMeasuringType)type completedHandle:(void(^)(BOOL isSuccess,id _Nullable result,NSError * _Nullable error))handle;

/// Send measurement order
/// @param type             :Measurement type
/// @param timeout      :Measurement timeout (when less than or equal to 0, use the default value of 30s)
/// @param handle        :Measurement result callback (error code: -1: failed to send start command, -2: failed to send end command, -3: bracelet is not properly worn)
- (void)startToMeasuringWithOperateType:(QCMeasuringType)type timeout:(NSInteger)timeout completedHandle:(void(^)(BOOL isSuccess,id _Nullable result,NSError * _Nullable error))handle;

/// stop measurement command
/// @param type             :Measurement type
/// @param handle        :Measurement result callback (error code:-1: Failed to send end command)
- (void)stopToMeasuringWithOperateType:(QCMeasuringType)type completedHandle:(void(^)(BOOL isSuccess,NSError *error))handle;
@end

NS_ASSUME_NONNULL_END
