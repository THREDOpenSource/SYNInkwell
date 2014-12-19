//
//  SYNGPUImageFlowDifferenceOfGaussiansFilter0.h
//  Thred
//
//  Created by John Hurliman on 9/6/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

@interface SYNGPUImageFlowDifferenceOfGaussiansFilter0 : GPUImageTwoInputFilter

- (void)setImageSize:(CGSize)imageSize;

- (void)setSigmaE:(CGFloat)sigmaE;

- (void)setSigmaR:(CGFloat)sigmaR;

- (void)setP:(CGFloat)p;

@end
