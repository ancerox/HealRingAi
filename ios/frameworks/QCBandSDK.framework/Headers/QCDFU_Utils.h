//
//  OdmDFU_Utils.h
//  OudmonBandV2
//
//  Created by ZongBill on 16/9/26.
//  Copyright © 2016年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @discussion 本接口适用于所有芯片在正常模式下的DFU升级功能, 如有其它nRF系列芯片需要使用, 请查阅芯片SDK文档, 确认是否适用, 在此不做保障
 */
@interface QCDFU_Utils : NSObject

extern NSString *const ODM_DFU_UUID_Service;              //服务UUID
extern NSString *const ODM_DFU_UUID_WriteCharacteristic;  //写入特征ID
extern NSString *const ODM_DFU_UUID_NotifyCharacteristic; //通知特征ID

extern NSString *const QCBandFeatureTemperature;
extern NSString *const QCBandFeatureDialMarket;
extern NSString *const QCBandFeatureMenstr; // menstrual cycle
extern NSString *const QCBandFeatureBloodOxygen; // blood oxygen
extern NSString *const QCBandFeatureDialCoordinate; // Support wallpaper dial setting coordinates
extern NSString *const QCBandFeatureBloodPressure; // 支持血压
extern NSString *const QCBandFeatureDrowsiness; // 支持疲劳度
extern NSString *const QCBandFeatureOneKeyMeasure; // 支持一键测量
extern NSString *const QCBandFeatureWeather;//支持天气
extern NSString *const QCBandFeatureQRCodeQQ; //不支持支持绑定QQ，wechat二维码
extern NSString *const QCBandFeatureDeviceWidth; // 宽度
extern NSString *const QCBandFeatureDeviceHeight; // 高度
extern NSString *const QCBandFeatureNewSleepProtocol; // 支持睡眠协议
extern NSString *const QCBandFeatureMaxDial; // 支持最大表盘数据
extern NSString *const QCBandFeatureContact; //支持通讯录
extern NSString *const QCBandFeatureMaxContacts;//支持最大通讯录个数
extern NSString *const QCBandFeatureManualHeartRate; //支持手动心率
extern NSString *const QCBandFeatureCard; // 支持名片功能
extern NSString *const QCBandFeatureLocation; //支持定位功能
extern NSString *const QCBandFeaturePointerDial; //指支持针表盘
extern NSString *const QCBandFeatureMusic; //支持音乐
extern NSString *const QCBandFeatureShowAutoBT;//支持自动连接
extern NSString *const QCBandFeatureEBook; //支持电子书
extern NSString *const QCBandFeatureAppManual;//App发起的手动测量
extern NSString *const QCBandFeatureBloodGlucose;//血糖
extern NSString *const QCBandFeatureMusicLRC; //歌词同步功能
extern NSString *const QCBandFeatureAblum; //相册功能
extern NSString *const QCBandFeatureMapNavi; //地图导航功能
extern NSString *const QCBandFeatureManualBloodOxygen; //手动血氧
extern NSString *const QCBandFeatureLowPower; //省电模式
extern NSString *const QCBandFeatureYaWei; //yawei手表(支持省电和表盘切换)
extern NSString *const QCBandFeatureUserProfile; //用户信息(用户名称+用户头像)
extern NSString *const QCBandFeatureDisableRecrod;

extern int const ODM_DEFAULT_DFU_PACKET_SIZE;
extern int ODM_DFU_PACKET_SIZE;

typedef enum {
    ODM_DFU_FileExtensionHex,
    ODM_DFU_FileExtensionBin,
    ODM_DFU_FileExtensionZip
} ODM_DFU_FileExtension;

typedef enum {
    ODM_DFU_Operation_StartDfuRequest = 0x01,                    //启动固件升级
    ODM_DFU_Operation_InitializeDfuParametersRequest = 0x02,     //发送固件信息
    ODM_DFU_Operation_ReceiveFirmwareImageRequest = 0x03,        //接收固件
    ODM_DFU_Operation_ValidateFirmwareRequest = 0x04,            //校验固件
    ODM_DFU_Operation_ActivateAndResetRequest = 0x05,            //激活固件并重启
    ODM_DFU_Operation_CheckStatus = 0x06,                        //检查固件升级状态
    ODM_DFU_Operation_InitializeResourceParameterRequest = 0x21, //发送资源信息
    ODM_DFU_Operation_ReceiveResourceDataRequest = 0x22,         //接收资源数据
    ODM_DFU_Operation_ValidateResourceRequest = 0x23,            //校验资源内容
    ODM_DFU_Operation_DeleteResourceRequest = 0x24,              //删除指定资源
    ODM_DFU_Operation_TemperatureListRequest = 0x25,             //获取定时体温数据
    ODM_DFU_Operation_ManualTemperatureListRequest = 0x26,       //获取手动体温数据
    ODM_DFU_Operation_SleepList = 0x27,                         //获取睡眠数据
    ODM_DFU_Operation_ManualHeartRate = 0x28,                   //获取手动心率
    ODM_DFU_Operation_LongContacts = 0x29,                      //设置长通讯录(20个以上)
    ODM_DFU_Operation_BloodOxygenListRequest = 0x2A,            //获取手动血氧数据
    ODM_DFU_Operation_AlarmResponse = 0xFF,                      //获取和设置闹钟
    ODM_DFU_Operation_Location = 0x20,                         //设置经纬度
    ODM_DFU_Operation_AlarmInfo = 0x2C,                         //获取和设置闹钟
    ODM_DFU_Operation_Contacts = 0x2D,                         //获取和设置通讯录
    ODM_DFU_Operation_PhoneBindName = 0x2E,                      //获取电话绑定的设备名称
    ODM_DFU_Operation_QRCodeInfo = 0x2F,                        //设置(获取)名片二维码的URL
    ODM_DFU_Operation_FileRequest = 0x30,                        //查询缺失文件
    ODM_DFU_Operation_FileInit = 0x31,                           //启动缺失文件传输
    ODM_DFU_Operation_FilePacket = 0x32,                         //发送缺失文件
    ODM_DFU_Operation_FileCheck = 0x33,                          //校验缺失文件
    ODM_DFU_Operation_DialFileList = 0x35,                           //表盘文件列表
    ODM_DFU_Operation_DialFileInit = 0x36,                           //启动表盘文件传输
    ODM_DFU_Operation_DialFilePacket = 0x37,                         //发送表盘文件
    ODM_DFU_Operation_DialFileCheck = 0x38,                          //校验表盘文件
    ODM_DFU_Operation_DialFileDelete = 0x39,                         //删除表盘文件
    ODM_DFU_Operation_DialParameter = 0x3A,                       //壁纸表盘设置参数
    ODM_DFU_Operation_DataSummaryRequest = 0x41,                 //获取运动+概要请求
    ODM_DFU_Operation_DataSummaryResponse = 0x42,                //获取运动+概要回复
    ODM_DFU_Operation_DataRequest = 0x43,                        //获取运动+数据请求
    ODM_DFU_Operation_DataDetailSummaryResponse = 0x44,          //获取运动+数据概要回复
    ODM_DFU_Operation_DataDetailResponse = 0x45,                 //获取运动+数据细节回复
    ODM_DFU_Operation_DataDetailChecked = 0x46,                  //运动+数据接收确认
    ODM_DFU_Operation_BloodGlucoseListRequest = 0x47,            //获取手动血糖数据
    ODM_DFU_Operation_MapNavi = 0x48,                           //上报导航数据
    ODM_DFU_Operation_ManualBloodOxygen = 0x49,                  //手动血氧
    ODM_DFU_Operation_SetUserProfile = 0x4A,                    //设置用户信息(用户名称+用户头像)
    ODM_DFU_Operation_OnlineAGPSRequest = 0x54,                  //请求在线AGPS数据
    ODM_DFU_Operation_ECGListRequest = 0x70,                    //心电数据列表请求
    ODM_DFU_Operation_ECGListResponse = 0x71,                   //心电数据列表回复
    ODM_DFU_Operation_ECGDataRequest = 0x72,                    //心电详细数据请求
    ODM_DFU_Operation_ECGDataResponse = 0x73,                   //心电详细数据回复
    ODM_DFU_Operation_QueryFiles = 0x80,                        //文件(音乐，电子书)列表查询
    ODM_DFU_Operation_DeleteFile = 0x81,                        //删除文件(音乐，电子书)列表
    ODM_DFU_Operation_GetAudio = 0x82,                        //获取音频文件
} ODM_DFU_Operation;

typedef enum {
    ODM_DFU_Operation_FileInit_Add = 0x01,
    ODM_DFU_Operation_FileInit_Delete = 0x02,
    ODM_DFU_Operation_FileInit_Music = 0x03,
    ODM_DFU_Operation_FileInit_ebook = 0x04
} ODM_DFU_Operation_FileInit_Code;

typedef enum {
    QC_Operation_File_Music = 0x01, //音乐
    QC_Operation_File_Ebook = 0x02, //电子书
    QC_Operation_File_Record = 0x03  //录音
} QC_Operation_File_Code; //文件操作类型

typedef enum {
    ODM_DFU_OperationStatus_SuccessfulResponse = 0x00,
    ODM_DFU_OperationStatus_WrongDataLengthResponse = 0X01,
    ODM_DFU_OperationStatus_InvalidDataResponse = 0x02,
    ODM_DFU_OperationStatus_WrongCommandStageResponse = 0x03,
    ODM_DFU_OperationStatus_InvalidCommandParameterResponse = 0x04,
    ODM_DFU_OperationStatus_DeviceInternalErrorResponse = 0x05,
    ODM_DFU_OperationStatus_NotEnoughPowerResponse = 0x06,
    ODM_DFU_OperationStatus_DialFileOverwhelmingResponse = 0x07
} ODM_DFU_OperationStatus;

typedef NS_ENUM(NSUInteger, ODM_DFU_Device_Process_Status) {
    ODM_DFU_Device_Process_Status_Free = 0x00,
    ODM_DFU_Device_Process_Status_ReadyToUpdate = 0x01,
    ODM_DFU_Device_Process_Status_ParameterInited = 0x02,
    ODM_DFU_Device_Process_Status_FirmwareReceiving = 0x03,
    ODM_DFU_Device_Process_Status_FirmwareValidated = 0x04,
    ODM_DFU_Device_Process_Status_NotKnown = 0x05
};

typedef enum {
    ODM_DFU_FirmwareType_Application = 0x01, //应用程序
    ODM_DFU_FirmwareType_Bootloader = 0x02,  //启动驱动
    ODM_DFU_FirmwareType_Softdevice = 0x03,  //硬件驱动
} ODM_DFU_FirmwareType;

typedef enum {
    ODM_DFU_BandType_TwoBand = 0x00, //"双页"升级模式
    ODM_DFU_BandType_OneBand = 0x01, //"单页"升级模式
} ODM_DFU_BandType;

typedef enum {
    ODM_RES_ResourceType_Default = 0x00, //默认, 即无资源
    ODM_RES_ResourceType_Image = 0x01,   //图片
    ODM_RES_ResourceType_Text = 0x02,    //文字
} ODM_RES_ResourceType;

typedef enum {
    ODM_RES_UIType_StandBy = 0x01,  //待机资源
    ODM_RES_UIType_Boot = 0x02,     //开机资源
    ODM_RES_UIType_ShutDown = 0x03, //关机资源
    ODM_RES_UIType_All = 0xFF       //全部资源
} ODM_RES_UIType;

typedef enum {
    QC_QRCODE_INFO_WeChat = 0,
    QC_QRCODE_INFO_QQ,
    QC_QRCODE_INFO_Facebook,
    QC_QRCODE_INFO_Twitter,
    QC_QRCODE_INFO_Whatsapp,
    QC_QRCODE_INFO_Instagram,
    QC_QRCODE_INFO_Tiktok,
    QC_QRCODE_DELETE_WeChat = 0x80,
    QC_QRCODE_DELETE_QQ,
    QC_QRCODE_DELETE_Facebook,
    QC_QRCODE_DELETE_Twitter,
    QC_QRCODE_DELETE_Whatsapp,
    QC_QRCODE_DELETE_Instagram,
    QC_QRCODE_DELETE_Tiktok,
    QC_QRCODE_DELETE_Enable = 0xFF,
} QC_QRCODE_INFO_TYPE;

typedef enum {
    QCBandRealTimeHeartRateCmdTypeStart = 0x01,//Start real-time heart rate measurement
    QCBandRealTimeHeartRateCmdTypeEnd,//End real-time heart rate measurement
    QCBandRealTimeHeartRateCmdTypeHold,//Continuous heart rate test (for continuous measurement to keep alive)
} QCBandRealTimeHeartRateCmdType;

//错误相关
extern NSString *const kOdmDFUErrorDomain;
extern NSString *const kOdmDFUErrorMessageKey;
extern NSString *const kOdmDFUErrorStatusCodeKey;

typedef NS_ENUM(NSUInteger, ODM_DFU_Error_Code) {
    ODM_DFU_Error_Code_ChannelBusy = 1001,
    ODM_DFU_Error_Code_NotifyTimeOut,
    ODM_DFU_Error_Code_InvalidParameter,
    ODM_DFU_Error_Code_ResponseTypeNotCorrect
};

typedef NS_ENUM(NSUInteger, QC_File_Error_Code) {
    QC_File_Error_Code_Success = 0,
    QC_File_Error_Code_Size,
    QC_File_Error_Code_Data,
    QC_File_Error_Code_State,
    QC_File_Error_Code_Format,
    QC_File_Error_Code_Flash_Operate,
    QC_File_Error_Code_Lower_Power,
    QC_File_Error_Code_Memory_Full,
};

typedef NS_ENUM(NSInteger, QCDeviceDataUpdateReport) {
    QCDeviceDataUpdateHeartRate = 0x01,
    QCDeviceDataUpdateBloodPressure,
    QCDeviceDataUpdateBloodOxygen,
    QCDeviceDataUpdateStep,//旧版，已没有使用，请使用QCDeviceDataUpdateStepInfo
    QCDeviceDataUpdateTemperature,
    QCDeviceDataUpdateSleep,
    QCDeviceDataUpdateSportRecord,
    QCDeviceDataUpdateAlarm,
    QCDeviceDataUpdateDoNotDisturb,
    QCDeviceDataUpdateAudioRecord,
    QCDeviceDataUpdateHourly,
    QCDeviceDataUpdatePower,
    QCDeviceDataUpdateLowBloodSugar,
    QCDeviceDataUpdateDialIndex,
    QCDeviceDataUpdateLowPower,
    QCDeviceDataUpdateGoal,
    QCDeviceDataUpdateRaiseToWake,
    QCDeviceDataUpdateStepInfo,
};

+ (NSArray *)getFirmwareTypes;
+ (NSString *)stringFileExtension:(ODM_DFU_FileExtension)fileExtension;

+ (NSData *)packageData:(NSData *)data type:(UInt8)type;
+ (UInt16)packageDataLength:(NSData *)data;
+ (NSData *)unpackData:(NSData *)data;

+ (NSString *)errorWithRetType:(ODM_DFU_OperationStatus)typeCode;
+ (NSString *)getLocalizedTimeOutMessage;

@end
