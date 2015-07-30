//
//  SYNGPUImageFlowDifferenceOfGaussiansFilter1MultiThreshold.h
//  Thred
//
//  Created by John Hurliman on 9/6/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface SYNGPUImageFlowDifferenceOfGaussiansFilter1MultiThreshold : GPUImageTwoInputFilter

- (void)setImageSize:(CGSize)imageSize;

- (void)setSigmaM:(CGFloat)sigmaM;

- (void)setPhi:(CGFloat)phi;

- (void)setEpsilonX:(CGFloat)epsilon;

- (void)setEpsilonY:(CGFloat)epsilon;

- (void)setEpsilonZ:(CGFloat)epsilon;

@end
