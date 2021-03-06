//
//  SYNPencilSketchFilter.h
//  SYNInkwell
//
//  Created by John Hurliman on 12/20/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface SYNPencilSketchFilter : GPUImageFilterGroup

- (id)initWithImageSize:(CGSize)imageSize pencilTexture:(GPUImagePicture *)pencilTexture;

- (void)setImageSize:(CGSize)imageSize;
- (void)setSigmaE:(CGFloat)sigmaE;
- (void)setSigmaR:(CGFloat)sigmaR;
- (void)setSigmaM:(CGFloat)sigmaM;
- (void)setP:(CGFloat)p;
- (void)setPhi:(CGFloat)phi;
- (void)setEpsilonX:(CGFloat)epsilon;
- (void)setEpsilonY:(CGFloat)epsilon;
- (void)setEpsilonZ:(CGFloat)epsilon;
- (void)setSigmaBFD:(CGFloat)sigmaBFD;
- (void)setSigmaBFR:(CGFloat)sigmaBFR;
- (void)setBfeNumPasses:(int)numPasses;

@end
