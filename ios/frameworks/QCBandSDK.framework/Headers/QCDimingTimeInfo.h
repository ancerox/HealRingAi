//
//  QCDimingTimeInfo.h
//  Pubu
//
//  Created by steve on 2023/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface QCDimingTimeInfo : NSObject

/**
 *  Screen-on duration, unit: seconds.
 *  亮屏时长, 单位: 秒.
 *
 */
@property(nonatomic,assign)NSInteger lightingSeconds;

/**
 *  Optional display data type on home page (0=invalid, 1=number of steps, 2=calories, 3=weather, 4=heart rate)
 *  首页可选显示数据类型（0=无效，1=步数，2=卡路里， 3=天气，4=心率）
 */
@property(nonatomic,assign)NSInteger homePageType;

/**
 *  Mask transparency setting on the homepage (0~100, 0=the mask is opaque/the base image is not displayed, 100=the mask is fully transparent/the base image is displayed)
 *  首页的蒙板透明度设置（0~100,0=蒙板不透明/底图不显示，100=蒙板全透明/底图显示）
 */
@property(nonatomic,assign)NSInteger transparency;
/**
 *  0=default home page image, 1=user configured home page image (only for reading, invalid when writing))
 *  0=默认的首页图片，1=用户配置的首页图片（读取专用，写的时候无效））
 */
@property(nonatomic,assign)NSInteger pictureType;

/**
 *  Number of pointer dials (only for reading, invalid when writing)
 *  指针表盘的个数（读取专用，写的时候无效）
 */
@property(nonatomic,assign)NSInteger pointerDials;

/**
 *  The style of the currently displayed pointer dial
 *  当前显示指针表盘的样式
 */
@property(nonatomic,assign)NSInteger pointerStyle;

/**
 *  Minimum screen on time(unit: seconds.)
 *  最小亮屏时长单位: 秒.
 */
@property(nonatomic,assign)NSInteger minScreenTime;

/**
 *  Maximum screen on time(unit: seconds.)
 *  最大亮屏时长(单位: 秒.)
 */
@property(nonatomic,assign)NSInteger maxScreenTime;

/**
 *  Screen on time interval(unit: seconds.)
 *  亮屏时间间隔单位: 秒.
 */
@property(nonatomic,assign)NSInteger intervalScreenTime;

/**
 *  Always on screen status, 1=off, 2=on
 *  常亮屏状态，1=关闭，2=打开
 */
@property(nonatomic,assign)NSInteger allTimeScreen;

/**
 *  Whether to support always-on screen (only for reading, invalid when writing)
 *  是否支持常亮屏（读取专用，写的时候无效）
 */
@property(nonatomic,assign)BOOL allTimeScreenEnable;

@end

NS_ASSUME_NONNULL_END
