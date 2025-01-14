//
//  DialParameterModel.h
//  OudmonBandV2
//
//  Created by steve on 2021/6/15.
//  Copyright © 2021 ODM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DialParameterType) {
    DialParameterTypeTime = 1,
    DialParameterTypeDate = 2,
    DialParameterTypeValue = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface QCDialParameterModel : NSObject
@property(nonatomic,assign) DialParameterType type;
@property(nonatomic,assign) NSInteger x;
@property(nonatomic,assign) NSInteger y;
@property(nonatomic,assign) NSInteger r;
@property(nonatomic,assign) NSInteger g;
@property(nonatomic,assign) NSInteger b;

- (NSData*)toCmd;

@end

NS_ASSUME_NONNULL_END
