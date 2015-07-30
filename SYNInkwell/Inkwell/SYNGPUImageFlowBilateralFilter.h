//
//  SYNGPUImageFlowBilateralFilter.h
//  SYNInkwell
//
//  Created by John Hurliman on 12/19/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import "GPUImage.h"

@interface SYNGPUImageFlowBilateralFilter : GPUImageTwoInputFilter

- (void)setImageSize:(CGSize)imageSize;

- (void)setSigmaD:(CGFloat)sigmaD;

- (void)setSigmaR:(CGFloat)sigmaR;

- (void)setNumBlurPasses:(int)passes;

@end
