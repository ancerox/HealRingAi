//
//  QCBleCentralManager.h
//  QCLightBle
//
//  Created by 李锋 on 15/8/10.
//  Copyright (c) 2015年 X. All rights reserved.
//

/*!
 *  @class   OdmBleCentralManager
 *  @discussion ___面向用户:负责蓝牙的搜索,连接等Central业务,用户需调用相关代理查看操作结果。
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OdmBleConstants.h"

#define kQCCentralManager [QCBleCentralManager shareInstance]

@interface QCPeripheral : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString *mac;

@end

@protocol OdmCentralManagerDelegate <NSObject>

@optional
/*!
 *  @discussion 为Peripheral注册一个周边解析类型
 *
 *  @para   peripheral  需要被解析的周边
 *
 *  @return 解析peripheral的类名     if 'nil'-> default peripheral
 */
- (NSString *)registeClassForPeripheral:(CBPeripheral *)peripheral;
/*!
 *  @discussion 当前中央设备的蓝牙状体
 */
- (void)centerManagerState:(CBManagerState)state;
- (void)didScanPeripherals:(NSArray *)peripheralArr; //带过滤功能
- (void)didConnected:(CBPeripheral *)peripheral;     //用户可以返回设备类型
- (void)didDisconnecte:(CBPeripheral *)peripheral;
- (void)didFailConnected:(CBPeripheral *)peripheral;

@end


@interface QCBleCentralManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, weak) id<OdmCentralManagerDelegate> delegate;
///*!
// *  @discussion 允许同时连接多台设备YES：允许 NO:不允许.默认NO
// */
//@property (nonatomic, assign) BOOL allocMultiConnection;
/*!
 *  @discussion 最后连接的周边信息
 */
@property (nonatomic, strong) CBPeripheral *lastPeripheral;
/*!
 *  @discussion 注册周边的类
 */
@property (nonatomic, strong) NSString *registerPeripheralName;
/*!
 *  @discussion 当前中央的状态
 */
@property (nonatomic, assign) CBManagerState centralState;
/*!
 *  @discussion 连接状态
 */
@property (nonatomic, assign) BLECONNECTSTATE bleConnectState;
/*!
 *  @discussion 当前是否处于切换解析器状态, YES: 准备切换; NO: 切换完成
 */
@property (nonatomic, readonly, assign) BOOL isSwitchingPeripheralDispatcher;

+ (instancetype)shareInstance;
/*!
 *  @discussion 根据特定Service UUID 扫描设备
 *  
 *  @para   serviceUUIDStrings  UUID的String数组
 */
- (void)scanWithServices:(NSArray *)serviceUUIDStrings;
/*!
 *  @discussion 停止当前的扫描操作
 */
- (void)stopScan;
/*!
 *  @discussion 连接制定peripheral
 */
- (void)connect:(CBPeripheral *)peripheral;
/*!
 * @disucssion 断开指定设备
 */
- (void)disconnect:(CBPeripheral *)peripheral;
/*!
 * @discussion 不超时的重连
 * @note 慎用阻塞
 */
- (void)reconnectWithoutTimeOutSuc:(void (^)(void))suc fail:(void (^)(void))fail;
/*!
 *  @discussion 开始重连
 */
- (void)startReconnectSuc:(void (^)(void))suc faile:(void (^)(void))fail;
/*!
 *  断开当前连接
 */
- (void)disconnectCurentPeripheral;
/*!
 *  检测断开连接
 */
- (void)obserVeDisconnect:(void (^)(void))disconnect;
/**
 *  使用服务和名称检索并连接设备
 *  @param name        设备名称
 *  @param serviceUUID 检索服务UUID字符串
 *  @param finish      完成后的回调
 */
- (void)connectDeviceName:(NSString *)name serviceUUIDs:(NSArray<NSString *> *)serviceUUIDs connectTimeoutSeconds:(NSTimeInterval)timeout finish:(void (^)(BOOL finish, NSError *error))finish;

@end
