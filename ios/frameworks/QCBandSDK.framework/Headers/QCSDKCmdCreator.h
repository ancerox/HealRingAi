//
//  QCSDKCmdCreator.h
//  QCBandSDK
//
//  Created by steve on 2021/7/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QCBandSDK/OdmBleConstants.h>
#import <QCBandSDK/QCDFU_Utils.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QCSleepProcotolVersion) {
    QCSleepProcotolVersion1 = 0,   //睡眠协议版本1
    QCSleepProcotolVersion2,    //睡眠协议版本2
    QCSleepProcotolVersionCount,
};

@class QCSportModel;
@class QCSleepModel;
@class QCHeartRateModel;
@class QCExerciseModel;
@class QCBloodPressureModel;
@class QCSchedualHeartRateModel;
@class OdmGeneralExerciseSummaryModel;
@class OdmGeneralExerciseDetailModel;
@class QCDialParameterModel;
@class QCAlarmModel;
@class QCSimpleDialFileModel;
@class QCManualHeartRateModel;
@class QCDimingTimeInfo;

@interface QCSDKCmdCreator : NSObject
+ (instancetype)shareInstance;

/**
 *  Set the time of the watch
 *  设置手环的时间（传参）
 *
 *   @param suc featureList: The feature list of watch
 *          key:
 *          QCBandFeatureTemperature ==> value: @"1": YES
 *          QCBandFeatureDialMarket;==> value: @"1": YES
 *          QCBandFeatureMenstr; // 生理周期==> value: @"1": YES
 *          QCBandFeatureBloodOxygen; // 血氧==> value: @"1": YES
 *          QCBandFeatureDialCoordinate; // 支持壁纸表盘设置坐标==> value: @"1": YES
 *          QCBandFeatureBloodPressure; // 血压==> value: @"1": YES
 *          QCBandFeatureDrowsiness; // 疲劳度==> value: @"1": YES
 *          QCBandFeatureOneKeyMeasure; // 一键测量==> value: @"1": YES
 *          QCBandFeatureWeather;//天气 ==> value: @"1": YES
 *          QCBandFeatureQRCodeQQ; //绑定QQ，wechat二维码  value: @"1": YES
 *          QCBandFeatureDeviceWidth; // 宽度    ==> 预留位，暂无无数据返回
 *          QCBandFeatureDeviceHeight; // 高度   ==> 预留位，暂无无数据返回
 *          QCBandFeatureNewSleepProtocol; // 睡眠协议  value: @"1": YES
 *          QCBandFeatureMaxDial; // 最大表盘数据  ==> value: @"3"
 *          QCBandFeatureContact; //通讯录  ==>  value: @"1"
 *          QCBandFeatureMaxContacts;//最大通讯录个数 ==>  value: @"500"
 *          QCBandFeatureManualHeartRate; //手动心率  value: @"1": YES
 *          QCBandFeatureCard; // 名片功能  value: @"1": YES
 *          QCBandFeatureLocation; //定位功能  value: @"1": YES
 *          QCBandFeaturePointerDial; //指针表盘  value: @"1": YES
 *          QCBandFeatureMusic; //音乐  value: @"1": YES
 *          QCBandFeatureShowAutoBT;  value: @"1": YES
 *          QCBandFeatureEBook; //电子书  value: @"1": YES
 */
+ (void)setTime:(NSDate *)date success:(void (^)(NSDictionary *featureList))suc failed:(void (^)(void))fail;

/**
 *  Read device battery
 *  读取设备电量
 *
 *  @param suc battery: Power level
 */
+ (void)readBatterySuccess:(void (^)(int battery))suc failed:(void (^)(void))fail;

/**
 *  绑定震动
 */
+ (void)alertBindingSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Set the ANCS flag.So that the device can recognize if a match option pops up
 *  设置ANCS标志, 以便设备可以识别是否弹出匹配选项
 */
+ (void)setANCSFlagSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Set watch time base/user personal information
 *  设置手环时间进制/用户个人信息
 *
 *  @param twentyfourHourFormat   : YES 24 hour system; NO 12 hour system
 *  @param metricSystem                     : YES metric system; NO British system
 *  @param gender                                  : Gender (0=Male，1=Female)
 *  @param age                                         : Age（years）
 *  @param height                                  : Height（cm）
 *  @param weight                                  : Weight（kg）
 *  @param sbpBase                                : systolic blood pressure base（mmhg）(reserved value, default 0)
 *  @param dbpBase                                : Diastolic blood pressure base（mmhg）(reserved value, default 0)
 *  @param hrAlarmValue                     : Heart rate alarm value（bpm）(reserved value, default 0)
 */
+ (void)setTimeFormatTwentyfourHourFormat:(BOOL)twentyfourHourFormat
                             metricSystem:(BOOL)metricSystem
                                   gender:(NSInteger)gender
                                      age:(NSInteger)age
                                   height:(NSInteger)height
                                   weight:(NSInteger)weight
                                  sbpBase:(NSInteger)sbpBase
                                  dbpBase:(NSInteger)dbpBase
                             hrAlarmValue:(NSInteger)hrAlarmValue
                                  success:(void (^)(BOOL, BOOL, NSInteger, NSInteger, NSInteger, NSInteger, NSInteger, NSInteger, NSInteger))success fail:(void (^)(void))fail;

/**
 *  Get watch time base/user personal information
 *  获取手环时间进制/用户个人信息
 *
 *  @param success  callback
 *  @note               isTwentyfour: YES 24 hour system; NO 12 hour system
 *  @note               isMetricSystem: YES metric system; NO British system
 *  @note               gender: Gender (0=Male，1=Female)
 *  @note               age: Age（years）
 *  @note               height: Height（cm）
 *  @note               weight: Weight（kg）
 *  @note               sbpBase: blood pressure base（mmhg）(reserved value, default 0)
 *  @note               dbpBase: Diastolic blood pressure base（mmhg）(reserved value, default 0)
 *  @note               hrAlarmValue: Heart rate alarm value（bpm）(reserved value, default 0)
 *
 *  @param fail callback
 */
+ (void)getTimeFormatInfo:(nullable void (^)(BOOL isTwentyfour, BOOL isMetricSystem, NSInteger gender, NSInteger age, NSInteger height, NSInteger weight, NSInteger sbpBase, NSInteger dbpBase, NSInteger hrAlarmValue))success fail:(nullable void (^)(void))fail;

/**
 *  Get the version number of the device firmware
 *  获取设备固件(Application)的版本号
 *
 *  @param success Software and hardware version numbers are in the format "x.x.x"
 */
+ (void)getDeviceSoftAndHardVersionSuccess:(void (^)(NSString *_Nonnull, NSString *_Nonnull))success fail:(void (^)(void))fail;

/**
 *  Get the type of received push message
 *  查找接收推送消息
 *
 *  @param  suc filters :Supported push message types  0:telephone 1:SMS; 2:QQ 3:wechat 4:FaceBook 5:WhatsApp 6:twitter 7:skype 8:line 9:linkedin 10:instagram 11:tim 12:snapchat 13:reserved space 14:reserved space 15:other
 *          Fx ->@[@"1",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0 ",@"0",@"0",@"0",@"0",@"0"] means to receive incoming call alerts
 */
+ (void)getFilterSuccess:(void (^)(NSArray<NSNumber *> *filters))suc failed:(void (^)(void))fail;

/**
 *  Set the type of received push message
 *   设置接收推送消息
 *
 *  @param  filters :Supported push message types  0:telephone 1:SMS; 2:QQ 3:wechat 4:FaceBook 5:WhatsApp 6:twitter 7:skype 8:line 9:linkedin 10:instagram 11:tim 12:snapchat 13:reserved space 14:reserved space 15:other
 *          Fx ->@[@"1",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0 ",@"0",@"0",@"0",@"0",@"0"] means to receive incoming call alerts
 */
+ (void)setFilter:(NSArray *)filters success:(void (^)(void))suc failed:(void (^)(void))fail;

/**
 *  Get the current step information (you can synchronize the latest records, the summary statistics of the day)
 *  获取当前计步信息(可以同步最新纪录,当天的汇总统计数据)
 */
+ (void)getCurrentSportSucess:(void (^)(QCSportModel *sport))suc failed:(void (^)(void))fail;

/**
 *  Get the aggregated step counting data of a certain day (not recommended, and will not be maintained in the future, the summary of a certain day needs to be calculated by yourself)
 *  获取某天汇总的计步数据(不建议使用，以后不维护，某天的汇总需要自己计算)
 */
+ (void)getOneDaySportBy:(NSInteger)index success:(void (^)(QCSportModel *model))suc fail:(void (^)(void))fail;

/**
 *  Get detailed exercise data for a day
 *  获取某天的详细运动数据
 *
 *  @param items  sports:return all sports models
 */
+ (void)getSportDetailDataByDay:(NSInteger)dayIndex sportDatas:(nullable void (^)(NSArray<QCSportModel *> *sports))items fail:(nullable void (^)(void))fail;

/**
 *  Get detailed exercise data for a specified time period on a certain day
 *  获取某天指定时间段详细运动数据
 *
 *  @param  minuteInterval      minute interval for each index
 *  @param  beginIndex               time period start index
 *  @param  endIndex                   time period end index
 *  @param  items                          sports:return all sports models
 */
+ (void)getSportDetailDataByDay:(NSInteger)dayIndex minuteInterval:(NSInteger)minuteInterval beginIndex:(NSInteger)beginIndex endIndex:(NSInteger)endIndex sportDatas:(nullable void (^)(NSArray<QCSportModel *> *sports))items fail:(nullable void (^)(void))fail;


/**
 *  Get detailed sleep data for a day
 *  获取某天的详细睡眠数据
 *
 *  @discussion The time period corresponding to each sleep type, please see the returned content for details
 *  @param items    sleeps: returns all sleep models
 */
+ (void)getSleepDetailDataByDay:(NSInteger)dayIndex sleepDatas:(nullable void (^)(NSArray<QCSleepModel *> *sleeps))items fail:(nullable void (^)(void))fail;

/**
 *  Get all sleep data from a certain day to today
 *  获取从某天到今天的所有睡眠数据
 *
 *  @param  fromDayIndex    The number of days from today, (0: means today, 1: means yesterday)
 *  @param  items                   Returned sleep data (key: days from today, value: corresponding sleep data)
 *  @param  fail                     Failed callback
 */
+ (void)getSleepDetailDataFromDay:(NSInteger)fromDayIndex sleepDatas:(nullable void (^)(NSDictionary <NSString*,NSArray<QCSleepModel*>*>*_Nonnull))items fail:(nullable void (^)(void))fail;

/**
 *  Get all sleep data from a certain day to today (new protocol)
 *  获取从某天到今天的所有睡眠数据(新版协议)
 *
 *  @param dayIndex     :0->today, 1: yesterday, 2: the day before yesterday
 *  @param items            :NSDictionary, key is sleep date, value corresponds to all sleep models of that day
 */
+ (void)getSleepDetailDataV2ByDay:(NSInteger)dayIndex sleepDatas:(nullable void (^)(NSDictionary <NSString*,NSArray<QCSleepModel*>*>*_Nonnull))items fail:(nullable void (^)(void))fail;

/**
 * Get sedentary reminders
 * 获取久坐提醒
 *
 * @note beginTime Start movement time (format "HH:mm")
 * @note endTime End exercise time (format "HH:mm")
 * @note repeat Reminder repeat cycle (array order is Sunday-Saturday, such as @[@0, @1, @0, @0, @0, @0, @0], which means repeat every Monday)
 * @note interval Reminder interval/period (unit: minutes, range: 1-255)
 */
+ (void)getSitLongRemindResult:(void (^)(NSString *beginTime, NSString *endTime, NSArray *repeat, NSUInteger interval))remind fail:(void (^)(void))fail;

/**
 * Set sedentary reminders
 *
 * 设置久坐提醒
 *
 * @param beginTime Start movement time (format "HH:mm")
 * @param endTime End exercise time (format "HH:mm")
 * @param repeat Reminder repeat cycle (note that the array order should be modified to Sunday-Saturday, such as: @[@0, @1, @0, @0, @0, @0, @0], which means repeat every Monday)
 * @param interval Reminder interval/period (unit: minutes, range: 1-255)
 */
+ (void)setBeginTime:(NSString *)beginTime endTime:(NSString *)endTime repeatModel:(NSArray *)repeat timeInterval:(NSUInteger)interval success:(void (^)(void))suc fail:(void (^)(void))fail;

/**
 *  Find watch
 *  查找手环
 */
+ (void)lookupDeviceSuccess:(void (^)(void))suc fail:(void (^)(void))fail;

/**
 *  Start real-time heart rate
 *  开始实时心率
 */
+ (void)beginRealTimeHeartRateSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Pause real-time heart rate
 *  暂停实时心率
 */
+ (void)pauseRealTimeHeartRateSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Continue real-time heart rate
 *  继续实时心率
 */
+ (void)continueRealTimeHeartRateSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  End real-time heart rate
 *  结束实时心率
 */
+ (void)endRealTimeHeartRateSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Start heart rate measurement
 *  开始心率测量
 */
+ (void)startHeartRateMeasuringWithSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  End heart rate measurement
 *  结束心率测量
 *  @param hr :The measured heart rate value (the watch needs to display the measurement result based on this value)
 */
+ (void)endHeartRateMeasuringWithHR:(NSInteger)hr success:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Start blood pressure measurement
 *  开始血压测量
 */
+ (void)startBloodPressureMeasuringSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  End blood pressure measurement
 *  结束血压测量
 *  @param sbp  :systolic blood pressure
 *  @param dbp  :diastolic blood pressure
 */
+ (void)endBloodPressureMeasuringWithSbp:(NSInteger)sbp dbp:(NSInteger)dbp success:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  start blood oxygen
 *  开始血氧测量
 */
+ (void)startBloodOxygenMeasuringWithSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  end blood oxygen
 *  结束血氧测量
 *  @param soa2 :blood oxygen
 */
+ (void)endBloodOxygenMeasuringWithSoa2:(CGFloat)soa2 success:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;


/**
 *  Start one-key measurement
 *  @func 打开一键体检测量的开关
 */
+ (void)openOneKeyExaminationSwitchWithSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;
/*!
 *  @func 关闭一键体检测量的开关
 */
+ (void)closeOneKeyExaminationSwitchSuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Set a reminder to drink water
 *
 *  设置喝水提醒
 *
 *  @param index        : reminder number
 *  @param type          : alarm type
 *  @param time          :Format: HH:mm
 *  @param cycle        :The time is Sunday-Saturday, the format: such as @[@0, @1, @0, @0, @0, @0, @0], it means repeat every Monday
 */
+ (void)setDrinkWaterRemindIndex:(NSUInteger)index type:(ALARMTYPE)type time:(NSString *)time cycle:(NSArray<NSNumber *> *)cycle success:(nullable void (^)(void))suc failed:(nullable void (^)(void))fail;

/**
 * Get water reminders
 *
 * 获取喝水提醒
 *
 * @param index         : reminder number
 * @note type               :alarm type
 * @note time               :Format: HH:mm
 * @note cycle              :The time is Sunday-Saturday, the format: such as @[@0, @1, @0, @0, @0, @0, @0], it means repeat every Monday
 */
+ (void)getDrinkWaterRemindWithIndex:(NSUInteger)index remind:(nullable void (^)(NSUInteger index, ALARMTYPE type, NSString *time, NSArray<NSNumber *> *cycle))remind fail:(nullable void (^)(void))fail;

/**
 *  Get information about the wrist flip feature
 *
 *  获取翻腕亮屏功能的信息
 *
 *  @param success callback
 *  @note           isOn: whether the function is turned on;
 *  @note           leftHandWear: whether the left hand is worn
 *  @param fail callback
 */
+ (void)getFlipWristInfo:(nullable void (^)(BOOL isOn, NSUInteger flipType))success fail:(void (^)(void))fail;

/**
 *  Set information about the wrist flip feature
 *
 *  设置翻腕亮屏功能的信息
 *
 *  @param on                       :Whether the function is enabled
 *  @param flipType          :Whether to wear on the left hand
 */
+ (void)setFlipWristOn:(BOOL)on flipType:(NSUInteger)flipType success:(nullable void (^)(BOOL featureOn, NSUInteger flipType))success fail:(nullable void (^)(void))fail;

/**
 *  Get information about the Do Not Disturb feature
 *
 *  获取勿扰模式功能的信息
 *
 *  @param success       callback
 *  @note               isOn: whether the function is enabled;
 *  @note               begin: start time, the format is HH:mm;
 *  @note               end: end time, the format is HH: mm
 */
+ (void)getDontDisturbInfo:(nullable void (^)(BOOL isOn, NSString *begin, NSString *end))success fail:(void (^)(void))fail;

/**
 *  Set information about the Do Not Disturb feature
 *
 *  设置勿扰模式功能的信息
 *  @param on               :whether the function is enabled
 *  @param begin        :start time, the format is HH:mm;
 *  @param end             :end time, the format is HH: mm
 */
+ (void)setDontDisturbOn:(BOOL)on beginTime:(NSString *)begin endTime:(NSString *)end success:(nullable void (^)(BOOL featureOn, NSString *begin, NSString *end))success fail:(nullable void (^)(void))fail;

/**
 *  Switch the watch to the camera interface
 *
 *  切换手表到拍照界面
 */
+ (void)switchToPhotoUISuccess:(nullable void (^)(void))success fail:(nullable void (^)(void))fail;

/**
 *  Keep watch camera interface
 *
 *  保持手表拍照界面
 */
+ (void)holdPhotoUISuccess:(nullable void (^)(void))success fail:(nullable void (^)(void))fail;

/**
 *  Stop the lower computer (watch) to take pictures
 *
 *  停止手表拍照
 */
+ (void)stopTakingPhotoSuccess:(nullable void (^)(void))success fail:(nullable void (^)(void))fail;

/**
 *  Hard restart the watch
 *
 *  硬重启手环
 */
+ (void)resetBandHardlySuccess:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 *  Get device Mac address
 *
 *  获取设备Mac地址
 *
 *  @param success      :The Mac address format is "AA:BB:CC:DD:EE:FF"
 */
+ (void)getDeviceMacAddressSuccess:(nullable void (^)(NSString *_Nullable macAddress))success fail:(nullable void (^)(void))fail;

/**
 *  Get information about the timed blood pressure measurement function
 *
 *  获取定时血压测量功能的信息
 *
 *  @param success  featureOn                 YES: ON; NO: OFF
 *                  beginTime              Start Time, Formart:"HH:mm"
 *                  endTime                 End Time, Formart:"HH:mm"
 *                  minuteInterval        Minute interval
 */
+ (void)getSchedualBPInfo:(nullable void (^)(BOOL featureOn, NSString *beginTime, NSString *endTime, NSInteger minuteInterval))success fail:(void (^)(void))fail;

/**
 *  Get information about the timed blood oxygen  measurement function
 *
 *  设置定时血氧测量功能的信息
 *  @param featureOn        YES: NO; NO: OFF
 */

+ (void)setSchedualBOInfoOn:(BOOL)featureOn success:(nullable void (^)(BOOL featureOn))success fail:(void (^)(void))fail;

/**
 *  Set information about the timed blood oxygen  measurement function
 *
 *  获取定时血氧测量功能的信息
 *
 *  @param success featureOn YES: NO; NO: OFF
 */

+ (void)getSchedualBOInfoSuccess:(nullable void (^)(BOOL featureOn))success fail:(void (^)(void))fail;

/**
 *  Set information about the timed blood pressure measurement function
 *
 *  设置定时血压测量功能的信息
 *
 *  @param featureOn                 :YES: ON; NO: OFF
 *  @param beginTime                 :Start Time, Formart:"HH:mm"
 *  @param endTime                      :End Time, Formart:"HH:mm"
 *  @param minuteInterval       :Minute interval
 */
+ (void)setSchedualBPInfoOn:(BOOL)featureOn beginTime:(NSString *)beginTime endTime:(NSString *)endTime minuteInterval:(NSInteger)minuteInterval success:(nullable void (^)(BOOL featureOn, NSString *beginTime, NSString *endTime, NSInteger minuteInterval))success fail:(void (^)(void))fail;

/**
 *  Obtain historical data of timed blood pressure measurement
 *
 *  获取定时血压测量的历史数据
 *
 *  @param userAge  :user age
 *  @param success  :blood pressure data
 */
+ (void)getSchedualBPHistoryDataWithUserAge:(NSInteger)userAge success:(nullable void (^)(NSArray<QCBloodPressureModel *> *data))success fail:(nullable void (^)(void))fail;

/**
 *  Obtain historical data for timed blood pressure measurements
 *
 *  获取定时血压测量的历史数据
 *  @param success  data    : blood pressure data
 */
+ (void)getSchedualBPHistoryDataWithSuccess:(nullable void (^)(NSArray<QCBloodPressureModel *> *data))success fail:(nullable void (^)(void))fail;

/**
 *  Reset the watch to factory settings
 *
 *  重置手环到出厂设置状态, 慎用
 */
+ (void)resetBandToFacotrySuccess:(nullable void (^)(void))success fail:(nullable void (^)(void))fail;

/**
 * Get workout history data
 *
 *  获取锻炼历史数据
 *
 *
 * @param lastUnixSeconds       :The time when the last exercise data occurred (seconds since 1970-01-01 00:00:00)
 * @note success                              :models Motion record data array
 */
+ (void)getExerciseDataWithLastUnixSeconds:(NSUInteger)lastUnixSeconds getData:(nullable void (^)(NSArray<QCExerciseModel *> *models))getData fail:(nullable void (^)(void))fail;


/**
 *  Get historical data for manual blood pressure measurements
 *
 *  获取手动测量血压测量的历史数据
 *
 * @param lastUnixSeconds       :The time when the last exercise data occurred (seconds since 1970-01-01 00:00:00)
 * @note success                              :models blood pressure data array
 */
+ (void)getManualBloodPressureDataWithLastUnixSeconds:(NSUInteger)lastUnixSeconds success:(nullable void (^)(NSArray<QCBloodPressureModel *> *data))success fail:(nullable void (^)(void))fail;

/**
 * Get timed heart rate historical data
 *
 * 获取定时心率历史数据
 *
 * @param dates            :List of dates for which historical data needs to be obtained
 * @note success            :models Timed heart rate data array
 */
+ (void)getSchedualHeartRateDataWithDates:(NSArray<NSDate *> *)dates success:(nullable void (^)(NSArray<QCSchedualHeartRateModel *> *models))success fail:(nullable void (^)(void))fail;

/**
 * Get timed heart rate historical data
 *
 * 获取定时心率历史数据
 *
 * @param dayIndexs         :The number of days for which historical data needs to be obtained (0->today, 1->yesterday, 2->the day before yesterday, and so on)
 * @note success                  :models Timed heart rate data array
 */
+ (void)getSchedualHeartRateDataWithDayIndexs:(NSArray<NSNumber*> *)dayIndexs success:(void (^)(NSArray<QCSchedualHeartRateModel *> *_Nonnull))success fail:(void (^)(void))fail;

/**
 * Get manual heart rate  data
 *
 * 获取手动心率数据
 *
 * @param dayIndex         :The number of days for which historical data needs to be obtained (0->today, 1->yesterday, 2->the day before yesterday, and so on)
 * @param finished         :models Timed heart rate data array
 */
+ (void)getManualHeartRateDataByDayIndex:(NSInteger)dayIndex finished:(void (^)(NSArray <QCManualHeartRateModel *>* _Nullable, NSError * _Nullable))finished;

/**
 *  Information on setting the timed heart rate function
 *
 *  获取定时心率功能的信息
 *
 *  @param enable       :Whether the timed heart rate function is enabled. YES: enabled; NO: disabled
 */

+ (void)getSchedualHeartRateStatusWithCurrentState:(BOOL)enable success:(nullable void (^)(BOOL enable))success fail:(nullable void (^)(void))fail;

/**
 *  Information on setting the timed heart rate function
 *
 *  获取定时心率功能的信息
 *
 */
+ (void)getSchedualHeartRateStatusWithSuccess:(nullable void (^)(BOOL enable))success fail:(nullable void (^)(void))fail;

/**
 *  Get the on/off status and time interval of the scheduled heart rate function (only supported by some watches)
 *
 *  获取定时心率功能的开关状态以及时间间隔(仅部分手表支持)
 *
 */
+ (void)getSchedualHeartRateStatusAndIntervalWithSuccess:(nullable void (^)(BOOL enable,NSInteger interval))success fail:(nullable void (^)(void))fail;

/**
 *  Get information about the weather forecast feature
 *
 *  设置定时心率功能的信息
 *
 *  @param success  enable                  :Whether the weather Schedual HeartRate is enabled. YES: enabled; NO: disabled
 */
+ (void)setSchedualHeartRateStatus:(BOOL)enable success:(nullable void (^)(BOOL enable))success fail:(nullable void (^)(void))fail;

/**
 *  Set the timing heart rate function on and off status and time interval (only supported by some watches)
 *
 *  设置定时心率功能开关状态以及时间间隔(仅部分手表支持)
 *
 *  @param success  enable                  :Whether the weather Schedual HeartRate is enabled. YES: enabled; NO: disabled
 *  @param interval time interval        :Time interval for scheduled heart rate, unit: minutes
 */
+ (void)setSchedualHeartRateStatus:(BOOL)enable timeInterval:(NSInteger)interval success:(nullable void (^)(void))success fail:(nullable void (^)(void))fail;

/**
 *  Set the information of the weather forecast function
 *
 *  获取天气预报功能的信息
 *
 *  @param enable                                :Whether the weather forecast function is enabled. YES: enabled; NO: disabled
 *  @param success  temperatureUsingCelsius       :Whether to use Celsius. YES: Yes; NO: No, use Fahrenheit
 */
+ (void)getWeatherForecastStatusWithCurrentState:(BOOL)enable temperatureUsingCelsius:(BOOL)temperatureUsingCelsius success:(nullable void (^)(BOOL enable, BOOL usingCelsius))success fail:(nullable void (^)(void))fail;
/**
 *  设置天气预报功能的信息
 *  @param enable  天气预报功能是否开启. YES: 开启; NO: 关闭
 *  @param success  usingCelsius 是否使用摄氏度. YES: 是; NO: 否, 使用华氏温度
 */
+ (void)setWeatherForecastStatus:(BOOL)enable temperatureUsingCelsius:(BOOL)temperatureUsingCelsius success:(nullable void (^)(BOOL enable, BOOL usingCelsius))success fail:(nullable void (^)(void))fail;

/**
 *  Send the content of the weather forecast to the watch
 *
 *  发送天气预报的内容到手环
 *
 *  @param contents [{"time"                   :Date timestamp (note that it needs to be modified to the current time zone),
 *                  "type"                    :weather type,
 *                  "low-temp"            :temperature minimum,
 *                  "high-temp"           :temperature maximum,
 *                  "humidity"              :Humidity value,
 *                  "needUmbrella"      :whether to bring an umbrella}]
 *
 *  @note:     weather type:     0=unknown, 1=sunny, 2=partly cloudy, 3 =rain, 4=Snow, 5=smog, 6=thunderbolt
 *
 */
+ (void)sendWeatherContents:(NSArray<NSDictionary *> *)contents success:(nullable void (^)(void))success fail:(nullable void (^)(void))fail;

/**
 *  Get information about the device's brightness adjustment capabilities
 *
 *  获取设备亮度调节功能的信息
 *
 *  @param success lightLevel Brightness level, 1 - 10 => 10% - 100%
 */
+ (void)getDeviceLightLevelWithCurrentLevel:(NSInteger)lightLevel success:(nullable void (^)(NSInteger lightLevel))success fail:(nullable void (^)(void))fail;

/**
 *  Information on setting the device's brightness adjustment function
 *
 *  设置设备亮度调节功能的信息
 *
 *  @param lightLevel       :Brightness level, 1 - 10 => 10% - 100%
 */
+ (void)setDeviceLightLevel:(NSInteger)lightLevel success:(nullable void (^)(NSInteger lightLevel))success fail:(nullable void (^)(void))fail;

/**
 *  Get/set watch display time & user homepage parameter function information
 *
 *  获取/设置手环显示时长 & 用户首页参数 功能的信息
 *
 *  @param opType                       :0X01=read，0x02=Write ，0x03=The homepage picture is restored to default（BBCCDDEE is invalid when AA=0x03）
 *  @param lightingSeconds   :Bright screen time, unit: seconds. Legal value 4~10 (seconds)
 *  @param homePageType          :Home page optional display data type (0=invalid, 1=steps, 2=calories, 3=weather, 4=heart rate)
 *  @param transparency         :The mask transparency setting of the home page (0~100, 0=the mask is opaque/the base image is not displayed, 100=the mask is fully transparent/the base image is displayed)
 *  @param pictureType           :0=default homepage picture, 1=user-configured homepage picture (only for reading, invalid when writing)
 */
+ (void)setHomePageScreenOpType:(NSInteger)opType lightingSeconds:(NSInteger)lightingSeconds homePageType:(NSInteger)homePageType transparency:(NSInteger)transparency pictureType:(NSInteger)pictureType success:(nullable void (^)(NSInteger lightingSeconds, NSInteger homePageType, NSInteger transparency, NSInteger pictureType))suc fail:(nullable void (^)(void))fail;


/**
 *  Get/set watch display time & user homepage parameter function information
 *
 *  获取/设置手环显示时长 & 用户首页参数 功能的信息
 *
 *  @param opType                       :0X01=read，0x02=Write ，0x03=The homepage picture is restored to default（BBCCDDEE is invalid when AA=0x03）
 *  @param info                            :function information
 */
+ (void)setHomePageScreenOpType:(NSInteger)opType info:(nullable QCDimingTimeInfo*)info success:(nullable void (^)(QCDimingTimeInfo*))suc fail:(nullable void (^)(void))fail;

/**
 *  Set information on how long the watch will display
 *
 *  设置手环显示时长的信息
 *
 *  @param seconds      :Screen-on time, unit: second. The legal value is 4~10 (seconds).
 */

+ (void)setLightingSeconds:(NSInteger)seconds success:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;;

/**
 *  Get information about display duration
 *
 *  获取显示时长的信息
 *
 *  @param suc lightingSeconds      :Screen-on time, unit: second. The legal value is 4~10 (seconds).
 */
+ (void)getLightingSecondsWithSuccess:(nullable void (^)(NSInteger seconds))suc fail:(nullable void (^)(void))fail;

/**
 *  According to the specified timestamp, get the new version of Sports+ (V2) data summary information after the timestamp
 *
 *  根据指定时间戳, 获取该时间戳后的新版运动+(V2)数据概要信息
 *
 *  @param timestamp 时间戳
 *  @param finished spSummary - 运动+概要信息数组
 */
+ (void)getSportPlusSummaryFromTimestamp:(NSTimeInterval)timestamp finished:(nullable void (^)(NSArray *_Nullable spSummary, NSError *_Nullable error))finished;

/**
 *  Get part of the summary information and detailed data of the campaign according to the specified new version of the campaign + summary information
 *
 *  根据指定新版运动+概要信息, 获取该次运动的部分概要信息和详细数据
 *
 *  @param finished spSummary - Sports + summary information array
 */
+ (void)getSportPlusDetailsWithSummary:(OdmGeneralExerciseSummaryModel *)summary finished:(nullable void (^)(OdmGeneralExerciseSummaryModel *_Nullable summary, OdmGeneralExerciseDetailModel *_Nullable detail, NSError *_Nullable error))finished;

/**
 *  Get file requirements file list
 *
 *  获取文件需求文件列表
 */
+ (void)getNeededFileListFinished:(nullable void (^)(NSArray<NSString *> *_Nullable fileList, NSError *_Nullable error))finished;

/**
 *   获取用户目标信息
 *  @param suc stepTarget           :Step target
 *            calorieTarget         :Calorie goal, unit: cal
 *            distanceTarget      :Distance to target, unit: meter
 *            sportDuration        :Exercise duration target unit: minute (reserved value, default: 0)
 *            sleepDuration        :Sleep duration target unit: minute (reserved value, default: 0)
 */
+ (void)getStepTargetInfoWithSuccess:(nullable void (^)(NSInteger stepTarget,NSInteger calorieTarget,NSInteger distanceTarget,NSInteger sportDuration,NSInteger sleepDuration))suc fail:(nullable void (^)(void))fail;

/**
 *  Set user target information
 *
 *  设置用户目标信息
 *
 * @param stepTarget                    :Step target
 * @param calorieTarget             : Calorie Goal, Unit: Calories
 * @param distanceTarget           :Distance to target, unit: meters
 * @param sportDuration             :Exercise duration target Unit: minutes (reserved value, default: 0)
 * @param sleepDuration             :Sleep duration target unit: minutes (reserved value, default: 0)
 */
+ (void)setStepTarget:(NSInteger)stepTarget calorieTarget:(NSInteger)calorieTarget distanceTarget:(NSInteger)distanceTarget sportDurationTarget:(NSInteger)sportDuration sleepDurationTarget:(NSInteger)sleepDuration success:(nullable void (^)(void))suc fail:(nullable void (^)(void))fail;

/**
 * Get a list of dial files
 *
 * 获取表盘文件列表
*/
+ (void)listDialFileFinished:(nullable void (^)(NSArray <QCSimpleDialFileModel *>*_Nullable dialFiles, NSError *_Nullable error))finished;

/**
 *  Delete watch face file
 *
 *  删除表盘文件
 *
 *  @param fileName             :watch face file name
 *  @param force                    :The default is NO, YES is used for debugging, use with caution
 */
+ (void)deleteDialFileName:(NSString *)fileName force:(BOOL)force finished:(nullable void (^)(NSError *_Nullable error))finished;

/**
 *  Delete watch face file
 *
 *  删除表盘文件
 *
 *  @param fileName     :watch face file name
 */
+ (void)deleteDialFileName:(NSString *)fileName finished:(nullable void (^)(NSError *_Nullable error))finished;

/**
*  Obtain historical data of timed body temperature measurement
*
*  获取定时体温测量的历史数据
*/
+ (void)getSchedualTemperatureDataByDayIndex:(NSInteger)dayIndex finished:(nullable void (^)(NSArray *_Nullable temperatureList, NSError *_Nullable error))finished;

/**
 *  Get historical data of manual body temperature measurement
 *
 *  获取手动体温测量的历史数据
 */
+ (void)getManualTemperatureDataByDayIndex:(NSInteger)dayIndex finished:(nullable void (^)(NSArray *_Nullable temperatureList, NSError *_Nullable error))finished;

/**
 *  Obtain historical data of blood oxygen measurement
 *
 *  获取血氧测量的历史数据
 */
+ (void)getBloodOxygenDataByDayIndex:(NSInteger)dayIndex finished:(void (^)(NSArray * _Nullable, NSError * _Nullable))finished;

/**
 *  Get custom dial parameters
 *
 *  获取自定义表盘参数
 */
+ (void)getDailParameterWithFinished:(void (^)(QCDialParameterModel * _Nullable time, QCDialParameterModel * _Nullable date, QCDialParameterModel * _Nullable value, NSError * _Nullable))finished;

/**
 *  Set custom dial parameters
 *
 *  设置自定义表盘参数
 */
+ (void)setDailParameter:(QCDialParameterModel * _Nullable)time date:(QCDialParameterModel * _Nullable)date value:(QCDialParameterModel * _Nullable)value finished:(void (^)(QCDialParameterModel * _Nullable time, QCDialParameterModel * _Nullable date, QCDialParameterModel * _Nullable value, NSError * _Nullable))finished;

/**
 *  Get the wristband alarm clock
 *
 *  获取手环闹钟
 */
+ (void)getBandAlarmsWithFinish:(void(^)(NSArray <QCAlarmModel*>* _Nullable,NSError * _Nullable))finished;

/**
 *  Set the wristband alarm clock
 *
 *  设置手环闹钟
 */
+ (void)setBandAlarms:(NSArray <QCAlarmModel*>*)alarms finish:(void(^)(NSArray * _Nullable,NSError * _Nullable))finished;


/**
 *
 *  Period reminder function setting: send the setting to the wristband
 *
 *  经期提醒功能设置：发送设置到手环
 *
 * @param open                                   :Switch 1=on, 0 off, 2=invalid (when the APP reads the configuration from the wristband, if this bit is 2, the wristband parameter is invalid)
 * @param durationday                   :Menstrual period duration, in days; (default 6 days)
 * @param intervalday                   :Menstrual cycle, unit day; (default 28 days)
 * @param startday                          :How many days ago was the last start, 0=starts today; (default 0 means, APP does not display)
 * @param endday                              :How many days ago was the last end, 0=end today; (the default value of 0 means that the APP does not display) (when endday is not equal to startday+durationday, it means that the user manually modified the end time)
 * @param remindOpen                    :Reminder switch 1=on, others off; (default off)
 * @param beforemenstrday         :How many days in advance to remind the menstrual period, 1 = one day in advance. 1~3. (default 2)
 * @param beforeovulateday      :How many days in advance to remind the ovulation period, 1~3. (default 2)
 * @param hour                                 :Reminder time point-Hour
 * @param minute                            :Reminder time point - minutes
 */
+ (void)setMenstrualFeature:(BOOL)open durationDay:(NSInteger)durationday intervalDay:(NSInteger)intervalday startDay:(NSInteger)startday endDay:(NSInteger)endday remindState:(BOOL)remindOpen menstrBeforeDay:(NSInteger)beforemenstrday ovulateBeforeDay:(NSInteger)beforeovulateday remindHour:(NSInteger)hour remindMinute:(NSInteger)minute finished:(void (^)(void))finished;

+ (void)sendMenstrSettingFeatures:(BOOL)open durationDay:(NSString*)durationday intervalDay:(NSString*)intervalday startDay:(NSString*)startday endDay:(NSString*)endday remindState:(BOOL)remindOpen menstrBeforeDay:(NSString*)beforemenstrday ovulateBeforeDay:(NSString*)beforeovulateday remindHour:(NSString*)hour remindMinute:(NSString*)minute finished:(void (^)(void))finished __attribute__((deprecated("Use setMenstrualFeature: method")));

/**
 
 *  Send the firmware file, request to use the bin file to upgrade, the result will be processed in the callback
 *
 *  发送固件文件，要求使用bin文件升级，结果会在回调里边处理
 *
 *  @param data                  :OTA binary character stream
 *  @param start                :start sending callback
 *  @param percentage     :progress callback
 *  @param success            :success callback
 *  @param failed              :failure callback
 */

+ (void)syncOtaBinData:(NSData *)data
                 start:(nullable void (^)(void))start
            percentage:(nullable void (^)(int percentage))percentage
               success:(nullable void (^)(int seconds))success
                failed:(nullable void (^)(NSError *_Nullable error))failed;

/**
 *  Send the watch face file and require the use of the bin file
 *
 *  发送表盘文件，要求使用bin文件
 *
 *  @param name                  :watch face file name
 *  @param data                  :Dial binary character stream
 *  @param start                :start sending callback
 *  @param percentage     :progress callback
 *  @param success            :success callback
 *  @param failed              :failure callback
 */
+ (void)syncDialFileName:(NSString *)name
                 binData:(NSData *)data
                   start:(nullable void (^)(void))start
              percentage:(nullable void (^)(int percentage))percentage
                 success:(nullable void (^)(int seconds))success
                  failed:(nullable void (^)(NSError *_Nullable error))failed;

/**
 *
 *  Send files missing from the watch
 *
 *  @param name                  :watch missing file name
 *  @param data                  :watch missing file binary character stream
 *  @param start                :start sending callback
 *  @param percentage     :progress callback
 *  @param success            :success callback
 *  @param failed              :failure callback
 */
+ (void)syncResourceFileName:(NSString *)name
                     binData:(NSData *)data
                       start:(nullable void (^)(void))start
                  percentage:(nullable void (^)(int percentage))percentage
                     success:(nullable void (^)(int seconds))success
                      failed:(nullable void (^)(NSError *_Nullable error))failed;

/**
 
 *  Send the picture dial file, and request the (pixel) size to be cropped to the size of the current bracelet (the watch will verify the width and height of the picture)
 *
 *  发送图片表盘文件，要求（像素）尺寸裁剪为当前手环的尺寸(手表会校验图片的宽高)
 *
 *  @param img                     :Dial picture
 *  @param start                 :Start sending callbacks
 *  @param percentage      :progress callback
 *  @param success            :success callback
 *  @param failed              :failure callback
 */
+ (void)syncImage:(UIImage *)img
            start:(nullable void (^)(void))start
       percentage:(nullable void (^)(int percentage))percentage
          success:(nullable void (^)(int seconds))success
           failed:(nullable void (^)(NSError *_Nullable error))failed;

/**
 *  Send the picture dial file, and request the (pixel) size to be cropped to the size of the current watch (the watch will verify the width and height of the picture)
 *
 *  @param img                    :watch face image
 *  @param start                :start sending callback
 *  @param percentage     :progress callback
 *  @param success            :success callback
 *  @param failed              :failure callback
 */
+ (void)syncImage:(UIImage *)img
     transparency:(int)transparency
             start:(nullable void (^)(void))start
        percentage:(nullable void (^)(int percentage))percentage
           success:(nullable void (^)(int seconds))success
            failed:(nullable void (^)(NSError *_Nullable error))failed;


/**
 *  Get Sport records
 *  获取运动记录
 *
 *  @param timeStamp                    :watch face image
 *  @param finish                           :finish callback
 */
+ (void)getSportRecordsFromLastTimeStamp:(NSTimeInterval)timeStamp finish:(void (^)(NSArray<OdmGeneralExerciseSummaryModel *> * _Nullable summaries,NSError * _Nullable error))finish;

/**
 *  Get Watch Call BT Name
 *   获取通话手表的BT名称
 *
 *  @param finish                           :finish callback ==> btInfo: @{@"name":@"BTName",@"mac":@"aa:bb:cc"}
 */
+ (void)getWatchCallBTName:(void (^)(NSDictionary * _Nullable btInfo,NSError * _Nullable error))finish;


/**
 *  Set Contacts (Some Support)
 *   设置通讯录
 *
 *  @param contacts                      :   [ ["name":"allen","phone":"123546"],["name":"allen","phone":"123546"]]
 *  @param finish                           :finish callback
 */
+ (void)setContacts:(NSArray<NSDictionary*>*)contacts percentage:(nullable void (^)(int percentage))percentage finish:(void (^)(NSError * _Nullable error))finish;

/**
 *  RealTime HeartRate Measuring
 *   实时心率测量
 *
 *  @param type                      :  commond type
 *  @param finished                           :finish callback
 */
+ (void)realTimeHeartRateWithCmd:(QCBandRealTimeHeartRateCmdType)type finished:(nullable void (^)(BOOL))finished;

/// Get Dial Index
/// 获取表盘显示索引号
/// 
/// - Parameter finished: index--> 0 - N,0:壁纸
+ (void)getDialIndexWithFinshed:(nullable void (^)(NSInteger,NSError *_Nullable error))finished;


/// Set Dial Index (Some Support)
/// 设置表盘显示索引号
///
/// - Parameters:
///   - index: Dial Index：0-N,0:WallPaper
///   - finished: Callback
+ (void)setDialIndexWith:(NSInteger)index finshed:(nullable void (^)(NSError *_Nullable error))finished;


/// Get Low Power Mode (Some Support)
/// 获取低电量开关状态
///
/// - Parameter finished: isON: NO->关闭，YES:开启
+ (void)getLowPowerWithFinshed:(nullable void (^)(BOOL,NSError *_Nullable error))finished;

/// Set Low Power Mode (Some Support)
/// 设置低电量状态
///
/// - Parameters:
///   - isOn: NO:OFF，YES：ON
///   - finished:Callback
+ (void)setLowPowerWith:(BOOL)isOn finshed:(nullable void (^)(NSError *_Nullable error))finished;

/// Get Blood Glucose Data(Some Support)
///
/// - Parameters:
///   - dayIndex: day Index:0-6,0:today,1:yesterday....
///   - finished: finished callback
+ (void)getBloodGlucoseDataByDayIndex:(NSInteger)dayIndex finished:(void (^)(NSArray * _Nullable, NSError * _Nullable))finished;


/// Get Manual Blood Oxygen Data(Some Support)
///
/// - Parameters:
///   - dayIndex: day Index:0-6,0:today,1:yesterday....
///   - finished: finished callback
+ (void)getManualBloodOxygenDataByDayIndex:(NSInteger)dayIndex finished:(void (^)(NSArray * _Nullable, NSError * _Nullable))finished;
@end

NS_ASSUME_NONNULL_END
