//
//  BloodGlucoseModel.h
//  QiFit
//
//  Created by steve on 2023/5/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @enum BloodGlucoseTypeBeforeMeals 饭前
 @enum BloodGlucoseTypeNormal 正常
 @enum BloodGlucoseTypeAfterMeals 饭后
 */
typedef enum : NSUInteger {
    QCBloodGlucoseTypeBeforeMeals = 0,
    QCBloodGlucoseTypeNormal,
    QCBloodGlucoseTypeAfterMeals,
} QCBloodGlucoseType;

typedef enum : NSUInteger {
    QCBloodGlucoseSourceTypeContinue = 0,
    QCBloodGlucoseSourceTypeRandom,
} QCBloodGlucoseModeType;

@interface QCBloodGlucoseModel : NSObject

@property (assign, nonatomic) CGFloat maxGlu;               //最大血糖
@property (assign, nonatomic) CGFloat minGlu;               //最小血糖
@property (assign, nonatomic) CGFloat glu;                  //血糖
@property (strong, nonatomic) NSDate *date;                 //时间
@property (assign, nonatomic) QCBloodGlucoseModeType type;    //数据类型(定时测量==>0/单次测量==>1)
@property (assign, nonatomic) QCBloodGlucoseType gluType;     //血糖类型:饭前/正常/饭后
@property (assign, nonatomic) BOOL isSubmit;                //是否已提交服务器
@property (strong, nonatomic) NSString *device;             //设备名称
@end

NS_ASSUME_NONNULL_END
