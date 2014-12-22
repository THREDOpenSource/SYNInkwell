//
//  SYNPencilSketchFilter.m
//  SYNInkwell
//
//  Created by John Hurliman on 12/20/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import "SYNPencilSketchFilter.h"
#import "SYNGPUImageFlowBilateralFilter.h"
#import "SYNGPUImageRGBToLABFilter.h"
#import "SYNGPUImageStructureTensorFilter.h"
#import "SYNGPUImageEdgeTangentFlowFilter.h"
#import "SYNGPUImageFlowDifferenceOfGaussiansFilter0.h"
#import "SYNGPUImageFlowDifferenceOfGaussiansFilter1MultiThreshold.h"
#import <GPUImageThreeInputFilter.h>

@implementation SYNPencilSketchFilter {
    SYNGPUImageRGBToLABFilter *rgb2lab;
    SYNGPUImageStructureTensorFilter *st;
    SYNGPUImageEdgeTangentFlowFilter *etf;
    SYNGPUImageFlowBilateralFilter *bfe;
    SYNGPUImageFlowDifferenceOfGaussiansFilter0 *fdog0;
    SYNGPUImageFlowDifferenceOfGaussiansFilter1MultiThreshold *masks;
    GPUImageGaussianBlurFilter *maskSmooth;
    GPUImageThreeInputFilter *layerBlend;
    GPUImageTwoInputFilter *lineBlend;
}

- (id)initWithImageSize:(CGSize)imageSize
           lightTexture:(GPUImagePicture *)lightTexture
            darkTexture:(GPUImagePicture *)darkTexture
{
    if (self = [super init]) {
        rgb2lab = SYNGPUImageRGBToLABFilter.new;
        [self addFilter:rgb2lab];
        
        st = SYNGPUImageStructureTensorFilter.new;
        [self addFilter:st];
        
        etf = SYNGPUImageEdgeTangentFlowFilter.new;
        [self addFilter:etf];
        
        bfe = SYNGPUImageFlowBilateralFilter.new;
        [self addFilter:bfe];
        
        fdog0 = SYNGPUImageFlowDifferenceOfGaussiansFilter0.new;
        [self addFilter:fdog0];
        
        masks = SYNGPUImageFlowDifferenceOfGaussiansFilter1MultiThreshold.new;
        [self addFilter:masks];
        
        maskSmooth = GPUImageGaussianBlurFilter.new;
        [self addFilter:maskSmooth];
        
        layerBlend = [GPUImageThreeInputFilter.alloc initWithFragmentShaderFromString:SHADER_STRING(
            varying highp vec2 textureCoordinate;
            varying highp vec2 textureCoordinate2;
            varying highp vec2 textureCoordinate3;
            
            uniform sampler2D inputImageTexture;
            uniform sampler2D inputImageTexture2;
            uniform sampler2D inputImageTexture3;
            
            void main()
            {
                mediump vec2 darkUV = textureCoordinate3;
                mediump vec2 lightUV = textureCoordinate3;
                lightUV.x = 1.0 - lightUV.x;
                
                mediump vec4 masks = texture2D(inputImageTexture, textureCoordinate);
                mediump vec4 dark = texture2D(inputImageTexture3, darkUV);
                mediump vec4 light = texture2D(inputImageTexture3, lightUV);
                
                mediump float g = masks.x*1.0 + masks.y*(1.0-dark.x) + masks.z*(1.0-light.x);
                gl_FragColor = vec4(vec3(1.0 - g), 1.0);
            }
        )];
        [self addFilter:layerBlend];
        
        lineBlend = [GPUImageTwoInputFilter.alloc initWithFragmentShaderFromString:SHADER_STRING
           (
            varying highp vec2 textureCoordinate;
            varying highp vec2 textureCoordinate2;
            
            uniform sampler2D inputImageTexture;
            uniform sampler2D inputImageTexture2;
            
            void main()
            {
                mediump vec4 tones = texture2D(inputImageTexture, textureCoordinate);
                mediump vec4 edges = texture2D(inputImageTexture2, textureCoordinate2);
                
                gl_FragColor = vec4(vec3(tones.x * (1.0-edges.x)), 1.0);
            }
        )];
        [self addFilter:lineBlend];
        
        self.initialFilters = @[ st, rgb2lab ];
        
        [st addTarget:etf];
        
        [rgb2lab addTarget:bfe atTextureLocation:0];
        [etf addTarget:bfe atTextureLocation:1];
        
        [bfe addTarget:fdog0 atTextureLocation:0];
        [etf addTarget:fdog0 atTextureLocation:1];
        
        [fdog0 addTarget:masks atTextureLocation:0];
        [etf addTarget:masks atTextureLocation:1];
        
        [masks addTarget:maskSmooth];
        
        [maskSmooth addTarget:layerBlend atTextureLocation:0];
        [darkTexture addTarget:layerBlend atTextureLocation:1];
        [lightTexture addTarget:layerBlend atTextureLocation:2];
        
        [layerBlend addTarget:lineBlend atTextureLocation:0];
        [masks addTarget:lineBlend atTextureLocation:1];
        
        self.terminalFilter = lineBlend;
        
        // Default tuning
        st.imageSize = imageSize;
        bfe.imageSize = imageSize;
        fdog0.imageSize = imageSize;
        fdog0.sigmaE = 0.5;
        fdog0.sigmaR = 3.5;
        fdog0.p = 35.0;
        masks.imageSize = imageSize;
        masks.sigmaM = 0.5;
        masks.phi = 0.08;
        masks.epsilonX = 0.0;
        masks.epsilonY = 30.0;
        masks.epsilonZ = 60.0;
        maskSmooth.blurRadiusInPixels = 2.0;
    }
    return self;
}

- (void)setImageSize:(CGSize)imageSize
{
    st.imageSize = imageSize;
    bfe.imageSize = imageSize;
    fdog0.imageSize = imageSize;
    masks.imageSize = imageSize;
}

- (void)setSigmaE:(CGFloat)sigmaE { fdog0.sigmaE = sigmaE; }
- (void)setSigmaR:(CGFloat)sigmaR { fdog0.sigmaR = sigmaR; }
- (void)setSigmaM:(CGFloat)sigmaM { masks.sigmaM = sigmaM; }
- (void)setP:(CGFloat)p { fdog0.p = p; }
- (void)setPhi:(CGFloat)phi { masks.phi = phi; }
- (void)setEpsilonX:(CGFloat)epsilon { masks.epsilonX = epsilon; }
- (void)setEpsilonY:(CGFloat)epsilon { masks.epsilonY = epsilon; }
- (void)setEpsilonZ:(CGFloat)epsilon { masks.epsilonZ = epsilon; }
- (void)setSigmaBFD:(CGFloat)sigmaBFD { bfe.sigmaD = sigmaBFD; }
- (void)setSigmaBFR:(CGFloat)sigmaBFR { bfe.sigmaR = sigmaBFR; }
- (void)setBfeNumPasses:(int)numPasses { bfe.numBlurPasses = numPasses; }

@end
