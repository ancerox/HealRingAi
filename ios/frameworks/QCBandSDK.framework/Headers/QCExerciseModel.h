//
//  ExerciseModel.h
//  OudmonBandV2
//
//  Created by ZongBill on 2017/10/12.
//  Copyright © 2017年 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ExerciseType) {
    ExerciseTypeRun = 0,
    ExerciseTypeBike = 1,
    ExerciseTypeWeightLifting = 2,
    ExerciseTypeWalk = 3,
};


@interface QCExerciseModel : NSObject

@property (nonatomic, assign) NSInteger startTime;             // 发生时间, 单位毫秒, 主Key
@property (nonatomic, assign) NSInteger lastSeconds;           // 持续时间, 单位秒
@property (nonatomic, assign) ExerciseType type;               // 锻炼模式
@property (nonatomic, assign) NSInteger steps;                 // 步数
@property (nonatomic, assign) NSInteger meters;                // 里程, 单位米
@property (nonatomic, assign) NSInteger calories;              // 卡路里, 单位卡
@property (nonatomic, strong) NSArray<NSNumber *> *heartRates; // 心率数组, 每2分钟1条
@property (nonatomic, assign) NSInteger serverID;              // 服务器ID
@property (nonatomic, assign) NSInteger updateTime;            // 服务器更新时间, 单位毫秒
@property (nonatomic, assign) BOOL usable;                     // 是否可用, 本条记录是否显示/有效
@property (nonatomic, assign) BOOL isSync;                     // 是否同步了服务器

@end
