//
//  SimpleDialFileModel.h
//  QCBand
//
//  Created by 曾聪聪 on 2020/4/20.
//  Copyright © 2020 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCSimpleDialFileModel : NSObject<NSCoding>

/*
 *  表盘文件是否可以删除,状态值来至手表，服务器返回默认为YES
 */
@property(assign, nonatomic) BOOL deletable;

/*
 *  变盘文件名称
 */
@property(strong, nonatomic) NSString *fileName;

/*
 *  表盘图片下载路径，来至服务器
 */
@property(strong, nonatomic) NSString *imageUrl;

/*
 *  表盘文件下载路径
 */
@property(strong, nonatomic) NSString *binUrl;


/*
 *  表盘价格(保留值)
 */
@property(assign, nonatomic) float price;

/*
 *  表盘版本号(保留值)
 */
@property(assign, nonatomic)NSInteger version;

+ (instancetype)initWithFileName:(NSString *)fileName deletable:(BOOL)deletable;

- (void)assignWithDic:(NSDictionary*)serverDic;

- (BOOL)isEqual:(_Nullable id)other;

@end

NS_ASSUME_NONNULL_END
