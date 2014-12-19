//
//  SYNInkwellFilter.h
//  Thred
//
//  Created by John Hurliman on 12/17/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

@interface SYNInkwellFilter : NSObject

- (id)initWithImageSize:(CGSize)imageSize
                 sigmaE:(CGFloat)sigmaE
                 sigmaR:(CGFloat)sigmaR
               sigmaSST:(CGFloat)sigmaSST
                 sigmaM:(CGFloat)sigmaM
                    tau:(CGFloat)tau
                    phi:(CGFloat)phi
                epsilon:(CGFloat)epsilon;

- (void)connectWithInput:(GPUImageOutput *)input
                  output:(id<GPUImageInput>)output
       atTextureLocation:(NSInteger)location;

+ (GPUTextureOptions)twoChannelFloatTexture;

@end
