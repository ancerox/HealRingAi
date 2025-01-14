//
//  QCManualHeartRateModel.h
//  QCBandPro
//
//  Created by steve on 2022/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCManualHeartRateModel : NSObject

@property (nonatomic, strong) NSString *date;                  // 日期, 格式为"yyyy-MM-dd"
@property (nonatomic, strong) NSArray<NSNumber *> *heartRates; // 心率数组, 每N分钟1条
@property (nonatomic, strong) NSArray<NSNumber *> *hrTimes;    // 心率对应当天时间数组, 单位分钟
@end

NS_ASSUME_NONNULL_END
