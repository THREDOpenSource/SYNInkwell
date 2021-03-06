//
//  SYNInkwellColorFilter.h
//  SYNInkwell
//
//  Created by John Hurliman on 12/20/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface SYNInkwellColorFilter : GPUImageFilterGroup

- (id)initWithImageSize:(CGSize)imageSize;

- (void)setImageSize:(CGSize)imageSize;
- (void)setSigmaE:(CGFloat)sigmaE;
- (void)setSigmaR:(CGFloat)sigmaR;
- (void)setSigmaSST:(CGFloat)sigmaSST;
- (void)setSigmaM:(CGFloat)sigmaM;
- (void)setP:(CGFloat)p;
- (void)setPhi:(CGFloat)phi;
- (void)setEpsilon:(CGFloat)epsilon;
- (void)setSigmaBFD:(CGFloat)sigmaBFD;
- (void)setSigmaBFR:(CGFloat)sigmaBFR;
- (void)setBfeNumPasses:(int)numPasses;
- (void)setBfaNumPasses:(int)numPasses;

@end
