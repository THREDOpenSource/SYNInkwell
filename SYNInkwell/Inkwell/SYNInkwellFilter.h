//
//  SYNInkwellFilter.h
//  Thred
//
//  Created by John Hurliman on 12/17/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

@interface SYNInkwellFilter : GPUImageFilterGroup

- (id)initWithImageSize:(CGSize)imageSize;

- (void)setImageSize:(CGSize)imageSize;
- (void)setSigmaE:(CGFloat)sigmaE;
- (void)setSigmaR:(CGFloat)sigmaR;
- (void)setSigmaSST:(CGFloat)sigmaSST;
- (void)setSigmaM:(CGFloat)sigmaM;
- (void)setP:(CGFloat)p;
- (void)setPhi:(CGFloat)phi;
- (void)setEpsilon:(CGFloat)epsilon;

+ (GPUTextureOptions)twoChannelFloatTexture;

@end
