//
//  SportModel.h
//  OdmLightBle
//
//  Created by ZongBill on 15/8/11.
//  Copyright (c) 2015年 X. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class FMResultSet;


@interface QCSportModel : NSObject

@property (nonatomic, assign) NSInteger totalStepCount; //总步数, 单位步
@property (nonatomic, assign) NSInteger runStepCount;   //跑步/有氧运动
@property (nonatomic, assign) double calories;          //卡路里
@property (nonatomic, assign) NSInteger distance;       //距离, 单位米
@property (nonatomic, assign) NSInteger activeTime;     //运动时长, 单位分钟
@property (nonatomic, strong) NSString *happenDate;     //发生时间, 格式"yyyy-MM-dd HH:mm:ss"
@property (nonatomic, strong) NSString *device;         //设备标识
@property (nonatomic, assign) NSInteger isSubmit;       //database:是否提交
@property (nonatomic, assign) NSInteger autoId;         //自变id
/*!
 *  计步器解析
 */
+ (QCSportModel *)initWith:(long)totalStep runStep:(long)runStep calories:(long)cal distance:(long)dis sportTime:(NSInteger)time happenDate:(NSString *)happenDate;
//实时计步
+ (QCSportModel *)parsePedometerObjFromByte:(Byte *)byte;
//从数据库解析SportModel统计数据
//+ (SportModel *)parseSummary2Obj:(FMResultSet *)resultSet;


@end
