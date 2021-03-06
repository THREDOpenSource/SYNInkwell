//
//  SYNGPUImageColorHalftoneFilter.m
//  Thred
//
//  Created by John Hurliman on 9/6/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import "SYNGPUImageColorHalftoneFilter.h"

@implementation SYNGPUImageColorHalftoneFilter

NSString *const kSYNGPUImageColorHalftoneFragmentShader = SHADER_STRING(
precision highp float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

const float DOT_SIZE = 0.3;
const float STEP_THRESHOLD = 0.888;
const float STEP_THRESHOLD_HALF_DELTA = 0.288;
const float SCALE = 0.1 / 10.0;

highp vec4 rgb2CMYK(highp vec4 c)
{
    float k = max(max(c.r, c.g), c.b);
    return min(vec4(c.rgb / k, k), 1.0);
}

highp vec4 cmyk2RGB(highp vec4 c)
{
    return vec4(c.rgb * c.a, 1.0);
}

highp vec2 grid(highp vec2 p)
{
    return p - mod(p, SCALE);
}

highp mat2 rotateMatrix(float r)
{
    float cr = cos(r);
    float sr = sin(r);
    return mat2(cr, -sr, sr, cr);
}

highp vec2 mod289(highp vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
highp vec3 mod289(highp vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
highp vec3 permute(highp vec3 x) { return mod289((( x * 34.0) + 1.0) * x); }

float snoise(highp vec2 v)
{
    const highp vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                                0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                                -0.577350269189626, // -1.0 + 2.0 * C.x
                                0.024390243902439); // 1.0 / 41.0
    // First corner
    highp vec2 i = floor(v + dot(v, C.yy) );
    highp vec2 x0 = v - i + dot(i, C.xx);
    // Other corners
    highp vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    highp vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    highp vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                             + i.x + vec3(0.0, i1.x, 1.0 ));
    highp vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
                                    dot(x12.zw,x12.zw)), 0.0);
    m = m*m; m = m*m;
    // Gradients
    highp vec3 x = 2.0 * fract(p * C.www) - 1.0;
    highp vec3 h = abs(x) - 0.5;
    highp vec3 a0 = x - floor(x + 0.5);
    // Normalise gradients implicitly by scaling m
    m *= 1.792843 - 0.853735 * ( a0*a0 + h*h );
    // Compute final noise value at P
    highp vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

float aastep(float threshold, float value)
{
    const float afwidth = 0.3; // NOTE: This could be improved, especially with dFdx/dFdy
    return smoothstep(threshold - afwidth, threshold + afwidth, value);
}

highp vec4 smoothstepCMYK(highp vec4 v)
{
    return smoothstep(STEP_THRESHOLD - STEP_THRESHOLD_HALF_DELTA,
                      STEP_THRESHOLD + STEP_THRESHOLD_HALF_DELTA, v);
}

highp vec4 halftone(highp vec2 p, highp mat2 m, highp vec4 sampleColor, float noise)
{
    highp vec2 smp = (grid(m * p) + 0.5 * SCALE) * m;
    float s = min((length(p - smp) + noise) / (DOT_SIZE * SCALE), 1.1);
    highp vec4 c = rgb2CMYK(sampleColor);
    return c + s;
}

void main()
{
    highp vec2 p = textureCoordinate;
    
    // Generate rotation matrices for each color dot (CMYK)
    highp mat2 mc = rotateMatrix(radians(15.0));
    highp mat2 mm = rotateMatrix(radians(75.0));
    highp mat2 my = rotateMatrix(0.0);
    highp mat2 mk = rotateMatrix(radians(55.0));
    
    // Determine the nearest grid cell and sample it
    highp vec2 smp = grid(p) + 0.5 * SCALE;
    highp vec4 sampleColor = texture2D(inputImageTexture, smp);
    
    // Disable halftone dots in dark areas to mimic classic comic printing
    if (length(sampleColor.rgb) < 0.5) {
        gl_FragColor = vec4(1.0);
        return;
    }
    
    // Generate three scales of noise
    float n = 0.00075 * snoise(p * 200.0);
    n += 0.00050 * snoise(p * 400.0);
    n += 0.00025 * snoise(p * 800.0);
    n *= 0.25;
    
    // Construct the CMYK value for the current pixel based on our halftone dot
    // pattern
    float c = aastep(0.7, halftone(p, mc, sampleColor, n).x);
    float m = aastep(0.7, halftone(p, mm, sampleColor, n).y);
    float y = aastep(0.7, halftone(p, my, sampleColor, n).z);
    float k = aastep(0.7, halftone(p, mk, sampleColor, n).w);
    
    // CMYK -> RGB
    gl_FragColor = cmyk2RGB((vec4(c, m, y, k)));
    gl_FragColor.a = sampleColor.a;
}
);

- (id)init
{
    if (self = [super initWithFragmentShaderFromString:kSYNGPUImageColorHalftoneFragmentShader]) {
    }
    
    return self;
}

@end
