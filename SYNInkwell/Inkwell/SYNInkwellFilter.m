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
    GPUImageGrayscaleFilter *grayscale;
    SYNGPUImageStructureTensorFilter *st;
    GPUImageGaussianBlurFilter *sst;
    SYNGPUImageEdgeTangentFlowFilter *etf;
    SYNGPUImageFlowDifferenceOfGaussiansFilter0 *fdog0;
    SYNGPUImageFlowDifferenceOfGaussiansFilter1 *fdog1;
}

- (id)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        grayscale = GPUImageGrayscaleFilter.new;
        [self addFilter:grayscale];
        
        st = SYNGPUImageStructureTensorFilter.new;
        [self addFilter:st];
        
        sst = GPUImageGaussianBlurFilter.new;
        sst.outputTextureOptions = SYNInkwellFilter.twoChannelFloatTexture;
        [self addFilter:sst];
        
        etf = SYNGPUImageEdgeTangentFlowFilter.new;
        [self addFilter:etf];
        
        fdog0 = SYNGPUImageFlowDifferenceOfGaussiansFilter0.new;
        [self addFilter:fdog0];
        
        fdog1 = SYNGPUImageFlowDifferenceOfGaussiansFilter1.new;
        [self addFilter:fdog1];
        
        [grayscale addTarget:st];
        [st addTarget:sst];
        [sst addTarget:etf];
        
        [grayscale addTarget:fdog0 atTextureLocation:0];
        [etf addTarget:fdog0 atTextureLocation:1];
        
        [fdog0 addTarget:fdog1 atTextureLocation:0];
        [etf addTarget:fdog1 atTextureLocation:1];
        
        self.initialFilters = @[ grayscale ];
        self.terminalFilter = fdog1;
        
        self.imageSize = imageSize;
        self.sigmaE = 1.39;
        self.sigmaR = 2.87;
        self.sigmaSST = 2.5;
        self.sigmaM = 3.0;
        self.p = 39.0;
        self.phi = 0.17;
        self.epsilon = 0.15;
    }
    return self;
}

- (void)setImageSize:(CGSize)imageSize
{
    st.imageSize = imageSize;
    fdog0.imageSize = imageSize;
    fdog1.imageSize = imageSize;
}

- (void)setSigmaE:(CGFloat)sigmaE { fdog0.sigmaE = sigmaE; }
- (void)setSigmaR:(CGFloat)sigmaR { fdog0.sigmaR = sigmaR; }
- (void)setSigmaSST:(CGFloat)sigmaSST { sst.blurRadiusInPixels = sigmaSST; }
- (void)setSigmaM:(CGFloat)sigmaM { fdog1.sigmaM = sigmaM; }
- (void)setP:(CGFloat)p { fdog0.p = p; }
- (void)setPhi:(CGFloat)phi { fdog1.phi = phi; }
- (void)setEpsilon:(CGFloat)epsilon { fdog1.epsilon = epsilon; }

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
