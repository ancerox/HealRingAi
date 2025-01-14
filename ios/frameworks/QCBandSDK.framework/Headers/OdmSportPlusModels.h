//
//  OdmSportPlusModels.h
//  OudmonBandV2
//
//  Created by ZongBill on 2018/6/21.
//  Copyright © 2018年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

///运动+模式类型
typedef NS_ENUM(NSInteger, OdmSportPlusExerciseModelType) {
    ///GPS跑步, 手环/手机
    OdmSportPlusExerciseModelTypeGpsRun = 1,        //gps跑步
    OdmSportPlusExerciseModelTypeGpsBike = 2,       //gps骑行
    OdmSportPlusExerciseModelTypeGpsWalk = 3,       //gps步行
    OdmSportPlusExerciseModelTypeIndoorRun = 4,     //手环走路
    OdmSportPlusExerciseModelTypeRopeSkipping = 5,  //手环跳绳
    OdmSportPlusExerciseModelTypeSwimming = 6,      //手环游泳
    OdmSportPlusExerciseModelTypeRun = 7,           //手环跑步-室外
    OdmSportPlusExerciseModelTypeWalk = 8,          //手环徒步
    OdmSportPlusExerciseModelTypeBike = 9,      //手环骑行
    OdmSportPlusExerciseModelTypeExercise = 10, //手环锻炼
    OdmSportPlusExerciseModelTypeSwing = 11,    //手环挥拍
    OdmSportPlusExerciseModelTypeClimb = 20,    // 手环爬山
    OdmSportPlusExerciseModelTypeBadminton = 21, // 手环羽毛球
    OdmSportPlusExerciseModelTypeYoga = 22, // 手环瑜伽
    OdmSportPlusExerciseModelTypeAerobics = 23, // 手环健身操
    OdmSportPlusExerciseModelTypeSpinningBike = 24, // 手环动感单车
    OdmSportPlusExerciseModelTypeKayaking = 25, // 手环皮划艇
    OdmSportPlusExerciseModelTypeEllipticalMachine = 26, // 手环椭圆机
    OdmSportPlusExerciseModelTypeRowingMachine = 27, // 手环划船机
    OdmSportPlusExerciseModelTypePingpong = 28, // 手环乒乓球
    OdmSportPlusExerciseModelTypeTennis = 29, // 手环网球
    OdmSportPlusExerciseModelTypeGolf = 30, // 手环高尔夫球
    OdmSportPlusExerciseModelTypeBasketball = 31, // 手环篮球
    OdmSportPlusExerciseModelTypeFootball = 32, // 手环足球
    OdmSportPlusExerciseModelTypeVolleyball = 33, // 手环排球
    OdmSportPlusExerciseModelTypeRockClimbing = 34, // 手环攀岩
    OdmSportPlusExerciseModelTypeDance = 35, // 手环舞蹈
    OdmSportPlusExerciseModelTypeRollerSkating = 36, // 手环轮滑
    
    OdmSportPlusExerciseModelTypeTreadmill = 40,        // 跑步运动-跑步机
    OdmSportPlusExerciseModelTypeIndoorWalking = 41,    // 跑步运动-室内步行
    OdmSportPlusExerciseModelTypeTrailRunning = 42,     //  跑步运动-越野跑
    OdmSportPlusExerciseModelTypeRaceWalk = 43,         //  跑步运动-竞走
    OdmSportPlusExerciseModelTypePlaygroundRunning = 44,         //  跑步运动-操场跑步
    OdmSportPlusExerciseModelTypeFatLossRunning= 45,         //  跑步运动-减脂跑步
    
    OdmSportPlusExerciseModelTypeOutdoorCycling = 50,           //  骑行运动-户外骑行
    OdmSportPlusExerciseModelTypeIndoorCycling = 51,            //  骑行运动-室内骑行
    OdmSportPlusExerciseModelTypeMountainBiking = 52,           //  骑行运动-山地骑行
    OdmSportPlusExerciseModelTypeBMX = 53,                      //  骑行运动-小轮车
    
    OdmSportPlusExerciseModelTypeSwimmingPool = 55,                      //  游泳运动-泳池游泳
    OdmSportPlusExerciseModelTypeOutdoorSwimming = 56,                      //  游泳运动-室外游泳
    OdmSportPlusExerciseModelTypeFinSwimming = 57,                      //  游泳运动-蹼泳
    OdmSportPlusExerciseModelTypeSynchronizedSwimming = 58,                      //  游泳运动-花样游泳
    
    OdmSportPlusExerciseModelTypeOutdoorHiking = 60,                      //  户外运动-户外徒步
    OdmSportPlusExerciseModelTypeOrienteering = 61,                      //  户外运动-定向越野
    OdmSportPlusExerciseModelTypeFishing = 62,                      //  户外运动-钓鱼
    OdmSportPlusExerciseModelTypeHunt= 63,                      //  户外运动-打猎
    OdmSportPlusExerciseModelTypeSkateboard = 64,                      //  户外运动-滑板
    OdmSportPlusExerciseModelTypeParkour = 65,                      //  户外运动-跑酷
    OdmSportPlusExerciseModelTypeATV = 66,                      //  户外运动-沙滩车
    OdmSportPlusExerciseModelTypeMotocross = 67,                      //  户外运动-越野摩托
    OdmSportPlusExerciseModelTypeRacing = 68,                      //  户外运动-赛车
    OdmSportPlusExerciseModelTypeHandCrank = 69,                      //  户外运动-手摇车
    OdmSportPlusExerciseModelTypeMarathon = 70,                      //  户外运动-手摇车
    OdmSportPlusExerciseModelTypeObstacleCourse = 71,                      //  户外运动-障碍赛
    
    OdmSportPlusExerciseModelTypeStairClimber = 80,                      //  室内运动-爬楼机
    OdmSportPlusExerciseModelTypeStairStepper = 81,                      //  室内运动-踏步机
    OdmSportPlusExerciseModelTypeMixedAerobic = 82,                      //  室内运动-混合有氧
    OdmSportPlusExerciseModelTypeKickboxing = 83,                      //  室内运动-搏击操
    OdmSportPlusExerciseModelTypeCoreTraining = 84,                      //  室内运动-核心训练
    OdmSportPlusExerciseModelTypeCrossTraining = 85,                      //  室内运动-交叉训练
    OdmSportPlusExerciseModelTypeIndoorFitness = 86,                      //  室内运动-室内健身
    OdmSportPlusExerciseModelTypeGroupGymnastics = 87,                      //  室内运动-团体操
    OdmSportPlusExerciseModelTypeStrengthTraining = 88,                      //  室内运动-力量训练
    OdmSportPlusExerciseModelTypeGapTraining = 89,                      //  室内运动-间隙训练
    OdmSportPlusExerciseModelTypeFreeTraining = 90,                      //  室内运动-自由训练
    OdmSportPlusExerciseModelTypeFlexibilityTraining = 91,                //  室内运动-柔韧训练
    OdmSportPlusExerciseModelTypeGymnastics = 92,                //  室内运动-体操
    OdmSportPlusExerciseModelTypeStretch = 93,                //  室内运动-拉伸
    OdmSportPlusExerciseModelTypePilates = 94,                //  室内运动-普拉提
    OdmSportPlusExerciseModelTypeHorizontalBar = 95,                //  室内运动-单杠
    OdmSportPlusExerciseModelTypeParallelBars = 96,                //  室内运动-双杠
    OdmSportPlusExerciseModelTypeBattleRope = 97,                //  室内运动-战绳
    OdmSportPlusExerciseModelTypeFitness = 98,                //  室内运动-健身运动
    OdmSportPlusExerciseModelTypeBalanceTraining = 99,                //  室内运动-平衡训练
    OdmSportPlusExerciseModelTypeStepTraining = 100,                //  室内运动-踏步训练
    
    OdmSportPlusExerciseModelTypeSquareDance = 110,                //  舞蹈运动-广场舞
    OdmSportPlusExerciseModelTypeBallroomDancing = 111,                //  舞蹈运动-交际舞
    OdmSportPlusExerciseModelTypeBellyDance = 112,                //  舞蹈运动-肚皮舞
    OdmSportPlusExerciseModelTypeBallet = 113,                //  舞蹈运动-芭蕾舞
    OdmSportPlusExerciseModelTypeStreetDance = 114,                //  舞蹈运动-街舞
    OdmSportPlusExerciseModelTypeZumba = 115,                //  舞蹈运动-尊巴
    OdmSportPlusExerciseModelTypeLatinDance = 116,                //  舞蹈运动-拉丁舞
    OdmSportPlusExerciseModelTypeLatinJazz = 117,                //  舞蹈运动-爵士舞
    OdmSportPlusExerciseModelTypeHipHopDance = 118,                //  舞蹈运动-嘻哈舞
    OdmSportPlusExerciseModelTypePoleDancing = 119,                //  舞蹈运动-钢管舞
    OdmSportPlusExerciseModelTypeBreakDance = 120,                //  舞蹈运动-霹雳舞
    OdmSportPlusExerciseModelTypeFolkDance = 121,                //  舞蹈运动-民族舞
    OdmSportPlusExerciseModelTypeNewDance = 122,                //  舞蹈运动-舞蹈
    OdmSportPlusExerciseModelTypeModernDance = 123,                //  舞蹈运动-现代舞
    OdmSportPlusExerciseModelTypeDisco = 124,                //  舞蹈运动-迪斯科
    OdmSportPlusExerciseModelTypeTapDance = 125,                //  舞蹈运动-踢踏舞
    OdmSportPlusExerciseModelTypeOtherDance = 126,                //  舞蹈运动-其他舞蹈
    
    OdmSportPlusExerciseModelTypeBoxing = 130,                //  搏击运动-拳击
    OdmSportPlusExerciseModelTypeWrestling = 131,                //  搏击运动-摔跤
    OdmSportPlusExerciseModelTypeMartialArts= 132,                //  搏击运动-武术
    OdmSportPlusExerciseModelTypeTaiChi= 133,                //  搏击运动-太极
    OdmSportPlusExerciseModelTypeMuayThai= 134,                //  搏击运动-泰拳
    OdmSportPlusExerciseModelTypeJudo= 135,                //  搏击运动-柔道
    OdmSportPlusExerciseModelTypeTaekwondo= 136,                //  搏击运动-跆拳道
    OdmSportPlusExerciseModelTypeKarate= 137,                //  搏击运动-空手道
    OdmSportPlusExerciseModelTypeFreeSparring= 138,                //  搏击运动-自由搏击
    OdmSportPlusExerciseModelTypeSwordsmanship= 139,                //  搏击运动-剑术
    OdmSportPlusExerciseModelTypeJujitsu= 140,                //  搏击运动-柔术
    OdmSportPlusExerciseModelTypeFencing= 141,                //  搏击运动-击剑
    OdmSportPlusExerciseModelTypeKendo= 142,                //  搏击运动-剑道
    
    OdmSportPlusExerciseModelTypeBeachFootball=150,                //!<150球类运动-沙滩足球
    OdmSportPlusExerciseModelTypeBeachVolleyball=151,                    //!<151球类运动-沙滩排球
    OdmSportPlusExerciseModelTypeBaseball=152,                            //!<152球类运动-棒球
    OdmSportPlusExerciseModelTypeSoftball=153,                            //!<153球类运动-垒球
    OdmSportPlusExerciseModelTypeNewFootball=154,                            //!<154球类运动-橄榄球
    OdmSportPlusExerciseModelTypeHockey=155,                            //!<155球类运动-曲棍球
    OdmSportPlusExerciseModelTypeSquash=156,                            //!<156球类运动-壁球
    OdmSportPlusExerciseModelTypeDoorKick=157,                            //!<157球类运动-门球
    OdmSportPlusExerciseModelTypeCricket=158,                            //!<158球类运动-板球
    OdmSportPlusExerciseModelTypeHandball=159,                            //!<159球类运动-手球
    OdmSportPlusExerciseModelTypeBowling=160,                            //!<160球类运动-保龄球
    OdmSportPlusExerciseModelTypePolo=161,                                //!<161球类运动-马球
    OdmSportPlusExerciseModelTypeRacquetball=162,                        //!<162球类运动-墙球
    OdmSportPlusExerciseModelTypeBilliards=163,                            //!<163球类运动-桌球
    OdmSportPlusExerciseModelTypeTakraw=164,                            //!<164球类运动-藤球
    OdmSportPlusExerciseModelTypeDodgeBall=165,                        //!<165球类运动-躲避球
    OdmSportPlusExerciseModelTypeWaterPolo=166,                        //!<166球类运动-水球
    OdmSportPlusExerciseModelTypePuck=167,                                //!<167球类运动-冰球
    OdmSportPlusExerciseModelTypeShuttlecock=168,                        //!<168球类运动-毽球
    OdmSportPlusExerciseModelTypeIndoorSoccer=169,                        //!<169球类运动-室内足球
    OdmSportPlusExerciseModelTypeSandbag=170,                            //!<170球类运动-沙包球
    OdmSportPlusExerciseModelTypeBocce=171,                                //!<171球类运动-地掷球
    OdmSportPlusExerciseModelTypeJaiBall=172,                            //!<172球类运动-回力球
    OdmSportPlusExerciseModelTypeFloorBall=173,                        //!<173球类运动-地板球
    OdmSportPlusExerciseModelTypeAustralianRulesFootball=174,            //!<174球类运动-澳式足球
    OdmSportPlusExerciseModelTypePickering=175,                            //!<175球类运动-皮克林
    
    
    OdmSportPlusExerciseModelTypeOutdoorBoating=180,                //!<180水上运动-户外划船
    OdmSportPlusExerciseModelTypeSailing=181,                            //!<181水上运动-帆船运动
    OdmSportPlusExerciseModelTypeDragonBoat=182,                        //!<182水上运动-龙舟
    OdmSportPlusExerciseModelTypeSurf=183,                                //!<183水上运动-冲浪
    OdmSportPlusExerciseModelTypeKitesurfing=184,                        //!<184水上运动-风筝冲浪
    OdmSportPlusExerciseModelTypePaddling=185,                            //!<185水上运动-划水
    OdmSportPlusExerciseModelTypePaddleboard=186,                        //!<186水上运动-浆板冲浪
    OdmSportPlusExerciseModelTypeIndoorSurfing=187,                    //!<187水上运动-室内冲浪
    OdmSportPlusExerciseModelTypeDrifting=188,                            //!<188水上运动-漂流
    OdmSportPlusExerciseModelTypeSnorkeling=189,                        //!<189水上运动-浮潜

    OdmSportPlusExerciseModelTypeSkis=190,                        //!<190冰雪运动-双板滑雪
    OdmSportPlusExerciseModelTypeSnowboard=191,                            //!<191冰雪运动-单板滑雪
    OdmSportPlusExerciseModelTypeAlpineSkiing=192,                        //!<192冰雪运动-高山滑雪
    OdmSportPlusExerciseModelTypeCrossCountrySkiing=193,                //!<193冰雪运动-越野滑雪
    OdmSportPlusExerciseModelTypeSkiOrientserlng=194,                    //!<194冰雪运动-定向滑雪
    OdmSportPlusExerciseModelTypeBiathlon=195,                            //!<195冰雪运动-冬季两项
    OdmSportPlusExerciseModelTypeOutdoorSkating=196,                    //!<196冰雪运动-户外滑冰
    OdmSportPlusExerciseModelTypeIndoorSkating=197,                    //!<197冰雪运动-室内滑冰
    OdmSportPlusExerciseModelTypeCurling=198,                            //!<198冰雪运动-冰壶
    OdmSportPlusExerciseModelTypeBobsleigh=199,                            //!<199冰雪运动-雪车
    OdmSportPlusExerciseModelTypeSled=200,                                //!<200冰雪运动-雪橇
    OdmSportPlusExerciseModelTypeSnowmobile=201,                        //!<201冰雪运动-雪地摩托
    OdmSportPlusExerciseModelTypeSnowshoeing=202,                        //!<202冰雪运动-雪鞋健行

    OdmSportPlusExerciseModelTypeHulaHoop=210,                    //!<210休闲运动-呼啦圈
    OdmSportPlusExerciseModelTypeFrisbee=211,                            //!<211休闲运动-飞盘
    OdmSportPlusExerciseModelTypeDarts=212,                                //!<212休闲运动-飞镖
    OdmSportPlusExerciseModelTypeFlyAKite=213,                        //!<213休闲运动-放风筝
    OdmSportPlusExerciseModelTypeTugOfWar=214,                        //!<214休闲运动-拔河
    OdmSportPlusExerciseModelTypeEsports=215,                            //!<215休闲运动-电子竞技
    OdmSportPlusExerciseModelTypeStroller=216,                            //!<216休闲运动-漫步机
    OdmSportPlusExerciseModelTypeNewSwing=217,                                //!<217休闲运动-秋千
    OdmSportPlusExerciseModelTypeShuffleboard=218,                        //!<218休闲运动-沙狐球
    OdmSportPlusExerciseModelTypeTableSoccer=219,                        //!<219休闲运动-桌上足球
    OdmSportPlusExerciseModelTypeSomatosensoryGame=220,                //!<220休闲运动-体感游戏
    OdmSportPlusExerciseModelTypeBungeeJumping=221,                    //!<221休闲运动-蹦极
    OdmSportPlusExerciseModelTypeParachute=222,                            //!<222休闲运动-跳伞
    OdmSportPlusExerciseModelTypeAnusara=223,                            //!<223休闲运动-阿奴萨拉
    OdmSportPlusExerciseModelTypeYinYoga=224,                            //!<224休闲运动-阴瑜伽
    OdmSportPlusExerciseModelTypePregnancyYoga=225,                    //!<225休闲运动-孕瑜伽

    OdmSportPlusExerciseModelTypeInternationalChess=230,            //!<230棋盘运动-国际象棋
    OdmSportPlusExerciseModelTypeGo=231,                                //!<231棋盘运动-围棋
    OdmSportPlusExerciseModelTypeCheckers=232,                            //!<232棋盘运动-国际跳棋
    OdmSportPlusExerciseModelTypeBoardGame=233,                        //!<233棋盘运动-桌游
    OdmSportPlusExerciseModelTypeBridge=234,                            //!<234棋盘运动-桥牌

    OdmSportPlusExerciseModelTypeTriathlon=235,                    //!<235其他运动-铁人三项
    OdmSportPlusExerciseModelTypeArchery=236,                            //!<236其他运动-射箭
    OdmSportPlusExerciseModelTypeCompoundMovement=237,                    //!<237其他运动-复合运动
    OdmSportPlusExerciseModelTypeDrive=238,                                //!<238其他运动-驾车
    OdmSportPlusExerciseModelTypeOtherExtension = 10086,
};

typedef NS_ENUM(NSInteger, OdmSportPlusExerciseSourceType) {
    OdmSportPlusExerciseSourceTypeBand = 0,
    OdmSportPlusExerciseSourceTypeApp = 1,
};

typedef NS_ENUM(NSInteger, OdmSportPlusExerciseRecordType) {
    OdmSportPlusExerciseRecordTypeCard = 0,
    OdmSportPlusExerciseRecordTypeReport = 1,
};

@class OdmGeneralExerciseDetailModel;
///通用的概要模型
@interface OdmGeneralExerciseSummaryModel : NSObject

/// 运动类型
@property (assign, nonatomic) NSInteger exerciseType;
/// 数据源类型
@property (assign, nonatomic) NSInteger sourceType;
/// 记录类型
@property (assign, nonatomic) OdmSportPlusExerciseRecordType recordType;
/// 服务器ID
@property (assign, nonatomic) UInt64 serverID;
/// 服务器更新时间, 单位毫秒
@property (assign, nonatomic) UInt64 updateTime;
/// 是否可用, 本条记录是否显示/有效
@property (assign, nonatomic) BOOL usable;
/// 是否同步了服务器
@property (assign, nonatomic) BOOL isSync;
/// 开始时间, 单位秒. 主Key!
@property (assign, nonatomic) NSTimeInterval startTime;
/// 持续时长
@property (assign, nonatomic) NSInteger duration;
/// 采样秒数, 旧版本默认为2分钟, 新版本根据具体情况获取
@property (assign, nonatomic) NSInteger sampleRateSeconds;
///里程, 单位米
@property (assign, nonatomic) NSInteger distance;
///卡路里, 单位大卡
@property (assign, nonatomic) float calorie;
///平均速度, 单位m/s
@property (assign, nonatomic) float averageSpeed;
///最高速度, 单位m/s
@property (assign, nonatomic) float fastestSpeed;
///平均心率
@property (assign, nonatomic) NSInteger averageHR;
///最低心率
@property (assign, nonatomic) NSInteger lowestHR;
///最高心率
@property (assign, nonatomic) NSInteger highestHR;
///平均海拔, 单位米
@property (assign, nonatomic) float averageAltitude;
///累计爬坡, 单位米
@property (assign, nonatomic) float upHillDistance;
///累计下坡, 单位米
@property (assign, nonatomic) float downHillDistance;
///平均步频
@property (assign, nonatomic) NSInteger averageStepFrequency;
///运动次数
@property (assign, nonatomic) NSInteger numberOfActions;

///累积步数
@property (assign, nonatomic) NSInteger steps;

///心率数组
@property (strong, nonatomic) NSArray<NSNumber *> *hrs;

/// 心率等详情数据
@property (strong, nonatomic) OdmGeneralExerciseDetailModel* detail;
@end


///通用的详细数据模型
@interface OdmGeneralExerciseDetailModel : NSObject

/// 数据源类型
@property (assign, nonatomic) NSInteger sourceType;
/// 开始时间, 单位秒
@property (assign, nonatomic) NSTimeInterval startTime;
/// GPS轨迹数组
@property (strong, nonatomic) NSArray<CLLocation *> *gpsLocations;
///心率数组
@property (strong, nonatomic) NSArray<NSNumber *> *hrs;
///速度数据, 单位m/s.
@property (strong, nonatomic) NSArray<NSNumber *> *speeds;

@end
