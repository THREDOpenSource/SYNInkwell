//
//  SYNGPUImageEdgeTangentFlowFilter.m
//  Thred
//
//  Created by John Hurliman on 12/17/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import "SYNGPUImageEdgeTangentFlowFilter.h"
#import "SYNInkwellFilter.h"

@implementation SYNGPUImageEdgeTangentFlowFilter

NSString *const kSYNGPUImageEdgeTangentFlowFragmentShader = SHADER_STRING(
precision highp float;

varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    highp vec2 st = texture2D(inputImageTexture, textureCoordinate).xy;
    float E = st.x*st.x;
    float G = st.y*st.y;
    float F = st.x*st.y;
    
    float diffGE = G - E;
    float lambda1 = 0.5 * (E + G + sqrt(diffGE*diffGE + 4.0*F*F));
    highp vec2 v = vec2(E - lambda1, F);
    
    v = (length(v) > 0.0) ? normalize(v) : vec2(0.0, 1.0);
    gl_FragColor = vec4(v, 0.0, 1.0);
}
);

- (id)init
{
    if (self = [super initWithFragmentShaderFromString:kSYNGPUImageEdgeTangentFlowFragmentShader]) {
        self.outputTextureOptions = SYNInkwellFilter.twoChannelFloatTexture;
    }
    return self;
}

@end
