//
//  UIImage+QCTransparent.h
//  QCBandSDK
//
//  Created by steve on 2022/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QCTransparency)

/// 修改图片的亮度
///
/// @param transparency 亮度(0-100) 0:全黑，100-最亮
- (UIImage*)qc_imageToTransparency:(int)transparency;

@end

NS_ASSUME_NONNULL_END
