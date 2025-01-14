//
//  OdmBandNotifyCenter.h
//  Band
//
//  Created by ZongBill on 16/1/5.
//  Copyright © 2016年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const OdmBandSwitchToPictureNotification;
extern NSString *const OdmBandTakePictureNotification;
extern NSString *const OdmBandStopTakingPictureNotification;
extern NSString *const OdmBandRealTimeHeartRate;
extern NSString *const OdmBandRealTimeSBP_DBP;
extern NSString *const OdmBandRealTimeSBPKey;
extern NSString *const OdmBandRealTimeDBPKey;
extern NSString *const OdmBandRealTimeSO2;
extern NSString *const OdmBandLookupPhone;
extern NSString *const OdmBandTurnMinuteHandDoneNotification;
extern NSString *const OdmBandRealTimeHeartRateNoDataNowNotification;
extern NSString *const OdmBandRealTimeHeartRateTerminateNotification;
extern NSString *const OdmBandRequestOnlineAGPSNotification;
extern NSString *const OdmBandRealTimeECGNotification;//实时ECG
extern NSString *const OdmBandRealTimePPGNotification;//实时PPG
extern NSString *const OdmBandECGPPGLeadStateNotication;//导联状态
extern NSString *const OdmBandECGTerminatedNotification;//测量被中断
extern NSString *const OdmBandECGTimerTickNotification;//手环返回倒计时
extern NSString *const QCBandFindPhoneNotification; // 查找手机
extern NSString *const QCBandBatteryNotification; // 手环电量
extern NSString *const OdmBandANCSSwitchNotification; //手环ANCS功能开关项
extern NSString *const OdmBandMenstrSwitchNotification; //手环月经提醒（姨妈提醒）
extern NSString *const QCBandRealTimeHeartRateNotification; // 实时心率
extern NSString *const QCBandDataUpdateReportNotification; //设备数据更新

@interface OdmBandNotifyCenter : NSObject

+ (instancetype)registerNotify;

@end
