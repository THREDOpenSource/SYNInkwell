//
//  SYNGPUImageLaplaceEdgeDetectionFilter.h
//  Thred
//
//  Created by John Hurliman on 9/6/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface SYNGPUImageLaplaceEdgeDetectionFilter : GPUImageFilter

- (void)setImageSize:(CGSize)imageSize;

/**
 * All edges below this value will be removed. Default value is 4.0/255.0.
 */
- (void)setThreshold:(CGFloat)threshold;

/**
 * Shift the luminance of the output edges by this amount. Default value is 0.4.
 */
- (void)setLuminanceOffset:(CGFloat)luminanceOffset;

@end
