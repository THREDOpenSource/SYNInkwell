//
//  SYNInkwellFilter.m
//  Thred
//
//  Created by John Hurliman on 12/17/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import "SYNInkwellFilter.h"
#import "SYNGPUImageStructureTensorFilter.h"
#import "SYNGPUImageEdgeTangentFlowFilter.h"
#import "SYNGPUImageFlowDifferenceOfGaussiansFilter0.h"
#import "SYNGPUImageFlowDifferenceOfGaussiansFilter1.h"
#import <GPUImage.h>

@implementation SYNInkwellFilter {
    SYNGPUImageStructureTensorFilter *st;
    GPUImageGaussianBlurFilter *sst;
    SYNGPUImageEdgeTangentFlowFilter *etf;
    SYNGPUImageFlowDifferenceOfGaussiansFilter0 *fdog0;
    SYNGPUImageFlowDifferenceOfGaussiansFilter1 *fdog1;
}

- (id)initWithImageSize:(CGSize)imageSize
                 sigmaE:(CGFloat)sigmaE
                 sigmaR:(CGFloat)sigmaR
               sigmaSST:(CGFloat)sigmaSST
                 sigmaM:(CGFloat)sigmaM
                    tau:(CGFloat)tau
                    phi:(CGFloat)phi
                epsilon:(CGFloat)epsilon
{
    if (self = [super init]) {
        st = SYNGPUImageStructureTensorFilter.new;
        st.imageSize = imageSize;
        
        sst = GPUImageGaussianBlurFilter.new;
        sst.outputTextureOptions = SYNInkwellFilter.twoChannelFloatTexture;
        sst.blurRadiusInPixels = sigmaSST;
        
        etf = SYNGPUImageEdgeTangentFlowFilter.new;
        
        fdog0 = SYNGPUImageFlowDifferenceOfGaussiansFilter0.new;
        fdog0.imageSize = imageSize;
        fdog0.sigmaE = sigmaE;
        fdog0.sigmaR = sigmaR;
        fdog0.tau = tau;
        
        fdog1 = SYNGPUImageFlowDifferenceOfGaussiansFilter1.new;
        fdog1.imageSize = imageSize;
        fdog1.sigmaM = sigmaM;
        fdog1.phi = phi;
        fdog1.epsilon = epsilon;
    }
    return self;
}

- (void)connectWithInput:(GPUImageOutput *)input
                  output:(id<GPUImageInput>)output
       atTextureLocation:(NSInteger)location
{
    [input addTarget:st];
    [st addTarget:sst];
    [sst addTarget:etf];
    
    [input addTarget:fdog0 atTextureLocation:0];
    [etf addTarget:fdog0 atTextureLocation:1];
    
    [fdog0 addTarget:fdog1 atTextureLocation:0];
    [etf addTarget:fdog1 atTextureLocation:1];
    
    [fdog1 addTarget:output atTextureLocation:location];
}

+ (GPUTextureOptions)twoChannelFloatTexture
{
    GPUTextureOptions opts = {
        .minFilter = GL_NEAREST,
        .magFilter = GL_NEAREST,
        .wrapS = GL_CLAMP_TO_EDGE,
        .wrapT = GL_CLAMP_TO_EDGE,
        .internalFormat = GL_RG_EXT,
        .format = GL_RG_EXT,
        .type = GL_HALF_FLOAT_OES,
    };
    return opts;
}

@end
