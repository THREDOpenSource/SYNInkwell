//
//  SYNInkwellColorFilter.m
//  SYNInkwell
//
//  Created by John Hurliman on 12/20/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import "SYNInkwellColorFilter.h"
#import "SYNInkwellFilter.h"
#import "SYNGPUImageStructureTensorFilter.h"
#import "SYNGPUImageEdgeTangentFlowFilter.h"
#import "SYNGPUImageFlowBilateralFilter.h"
#import "SYNGPUImageFlowDifferenceOfGaussiansFilter0.h"
#import "SYNGPUImageFlowDifferenceOfGaussiansFilter1.h"
#import "SYNGPUImageLABToRGBFilter.h"
#import "SYNGPUImageRGBToLABFilter.h"

@implementation SYNInkwellColorFilter {
    SYNGPUImageRGBToLABFilter *rgb2lab;
    SYNGPUImageLABToRGBFilter *lab2rgb;
    SYNGPUImageStructureTensorFilter *st;
    GPUImageGaussianBlurFilter *sst;
    SYNGPUImageEdgeTangentFlowFilter *etf;
    SYNGPUImageFlowBilateralFilter *bfe;
    SYNGPUImageFlowBilateralFilter *bfa;
    SYNGPUImageFlowDifferenceOfGaussiansFilter0 *fdog0;
    SYNGPUImageFlowDifferenceOfGaussiansFilter1 *fdog1;
    GPUImageTwoInputFilter *lineBlend;
}

- (id)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        rgb2lab = SYNGPUImageRGBToLABFilter.new;
        [self addFilter:rgb2lab];
        
        st = SYNGPUImageStructureTensorFilter.new;
        [self addFilter:st];
        
        sst = GPUImageGaussianBlurFilter.new;
        sst.outputTextureOptions = SYNInkwellFilter.twoChannelFloatTexture;
        [self addFilter:sst];
        
        etf = SYNGPUImageEdgeTangentFlowFilter.new;
        [self addFilter:etf];
        
        bfe = SYNGPUImageFlowBilateralFilter.new;
        [self addFilter:bfe];
        
        bfa = SYNGPUImageFlowBilateralFilter.new;
        [self addFilter:bfa];
        
        fdog0 = SYNGPUImageFlowDifferenceOfGaussiansFilter0.new;
        [self addFilter:fdog0];
        
        fdog1 = SYNGPUImageFlowDifferenceOfGaussiansFilter1.new;
        [self addFilter:fdog1];
        
        lab2rgb = SYNGPUImageLABToRGBFilter.new;
        [self addFilter:lab2rgb];
        
        lineBlend = [GPUImageTwoInputFilter.alloc initWithFragmentShaderFromString:SHADER_STRING(
            varying highp vec2 textureCoordinate;
            varying highp vec2 textureCoordinate2;
            
            uniform sampler2D inputImageTexture;
            uniform sampler2D inputImageTexture2;
            
            void main()
            {
                mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
                mediump vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
                mediump vec4 blackColor = vec4(vec3(0.0), 1.0);
                
                gl_FragColor = mix(blackColor, textureColor, textureColor2);
            }
        )];
        [self addFilter:lineBlend];
        
        self.initialFilters = @[ st, rgb2lab ];
        
        // Original image is fed into structure tensor calculation
        [st addTarget:sst];
        // Gaussian blur is applied to structure tensor to get a smoothed
        // structure tensor
        [sst addTarget:etf];
        
        // LAB colorspace image and flow map are fed into flow bilateral filter
        // pre-processing for black & white output (FDoG)
        [rgb2lab addTarget:bfe atTextureLocation:0];
        [etf addTarget:bfe atTextureLocation:1];
        
        // LAB colorspace image and flow map are fed into flow bilateral filter
        // for color output
        [rgb2lab addTarget:bfa atTextureLocation:0];
        [etf addTarget:bfa atTextureLocation:1];
        
        // Blurred source image (in LAB) and flow map are fed into the first
        // step of the flow difference of Gaussians (FDoG)
        [bfe addTarget:fdog0 atTextureLocation:0];
        [etf addTarget:fdog0 atTextureLocation:1];
        
        // Output from the first step and the flow map are fed into the second
        // step of the flow difference of Gaussians (FDoG)
        [fdog0 addTarget:fdog1 atTextureLocation:0];
        [etf addTarget:fdog1 atTextureLocation:1];
        
        // Blurred color output is converted from LAB back to RGB
        [bfa addTarget:lab2rgb];
        
        // Blend color and black & white into the final output
        [lab2rgb addTarget:lineBlend atTextureLocation:0];
        [fdog1 addTarget:lineBlend atTextureLocation:1];
        
        self.terminalFilter = lineBlend;
        
        self.imageSize = imageSize;
        self.sigmaE = 1.39;
        self.sigmaR = 2.87;
        self.sigmaSST = 2.5;
        self.sigmaM = 3.0;
        self.p = 39.0;
        self.phi = 0.17;
        self.epsilon = 0.15;
        self.sigmaBFD = 3.0;
        self.sigmaBFR = 0.0425;
        self.bfeNumPasses = 1;
        self.bfaNumPasses = 4;
    }
    return self;
}

- (void)setImageSize:(CGSize)imageSize
{
    st.imageSize = imageSize;
    bfe.imageSize = imageSize;
    bfa.imageSize = imageSize;
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
- (void)setSigmaBFD:(CGFloat)sigmaBFD
{
    bfe.sigmaD = sigmaBFD;
    bfa.sigmaD = sigmaBFD;
}
- (void)setSigmaBFR:(CGFloat)sigmaBFR
{
    bfe.sigmaR = sigmaBFR;
    bfa.sigmaR = sigmaBFR;
}
- (void)setBfeNumPasses:(int)numPasses { bfe.numBlurPasses = numPasses; }
- (void)setBfaNumPasses:(int)numPasses { bfa.numBlurPasses = numPasses; }

@end