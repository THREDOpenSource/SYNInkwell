//
//  SYNGPUImageLaplaceEdgeDetectionFilter.m
//  Thred
//
//  Created by John Hurliman on 9/6/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import "SYNGPUImageLaplaceEdgeDetectionFilter.h"

@implementation SYNGPUImageLaplaceEdgeDetectionFilter {
    GLuint _imageSizeUniform, _thresholdUniform, _luminanceOffsetUniform;
    CGSize _imageSize;
    CGFloat _threshold;
    CGFloat _luminanceOffset;
}

NSString *const kSYNGPUImageLaplaceFragmentShader = SHADER_STRING(
precision mediump float;

varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform mediump vec2 imageSize;
uniform float threshold;
uniform float luminanceOffset;

float lookup(mediump vec2 p, float dx, float dy)
{
    mediump vec2 uv = p + (vec2(dx, dy) / imageSize);
    mediump vec4 c = texture2D(inputImageTexture, uv);
    
    // return as luma
    return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
}

float lookup(mediump vec2 p)
{
    return lookup(p, 0.0, 0.0);
}

float laplace(mediump vec2 p)
{
    float d = 0.0;
    
    d += lookup(p,  0.0, -1.0);
    d += lookup(p, -1.0,  0.0);
    d += lookup(p,  1.0,  0.0);
    d += lookup(p,  0.0,  1.0);
    
    return 4.0 * lookup(p) - d;
}

float laplaceSketch()
{
    float l = laplace(textureCoordinate);
    
    // TODO: Simplify this logic
    if (l > -threshold && l < 0.0) l = 0.0;
    else if (l < 0.0) l = abs(l);
    else l = 0.0;
    
    if (l > 0.0) l = luminanceOffset - l;
    else l = 1.0;
    
    return l;
}

void main()
{
    float gray = 1.0 - laplaceSketch();
    gl_FragColor = vec4(vec3(gray), 1.0);
}
);

- (id)init
{
    if (self = [super initWithFragmentShaderFromString:kSYNGPUImageLaplaceFragmentShader]) {
        _imageSizeUniform = [filterProgram uniformIndex:@"imageSize"];
        _thresholdUniform = [filterProgram uniformIndex:@"threshold"];
        _luminanceOffsetUniform = [filterProgram uniformIndex:@"luminanceOffset"];
        self.imageSize = CGSizeMake(640.0, 800.0);
        self.threshold = 4.0/255.0;
        self.luminanceOffset = 0.48;
    }
    
    return self;
}

- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    [self setSize:imageSize forUniform:_imageSizeUniform program:filterProgram];
}

- (void)setThreshold:(CGFloat)threshold
{
    _threshold = threshold;
    [self setFloat:threshold forUniform:_thresholdUniform program:filterProgram];
}

- (void)setLuminanceOffset:(CGFloat)luminanceOffset
{
    _luminanceOffset = luminanceOffset;
    [self setFloat:luminanceOffset forUniform:_luminanceOffsetUniform program:filterProgram];
}

@end
