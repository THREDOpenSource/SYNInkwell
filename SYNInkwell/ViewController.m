//
//  ViewController.m
//  SYNInkwell
//
//  Created by Lauren Winter on 12/18/14.
//  Copyright (c) 2014 Syntertainment. Released under the MIT license.
//

#import "ViewController.h"
#import "SYNInkwellFilter.h"
#import "SYNPencilSketchFilter.h"
#import "SYNGPUImageColorHalftoneFilter.h"
#import "SYNGPUImageLaplaceEdgeDetectionFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet GPUImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UILabel *sigmaEValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sigmaRValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sigmaSSTValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sigmaMValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *tauValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *phiValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *epsilonValueLabel;

@property (weak, nonatomic) IBOutlet UISlider *sigmaESlider;
@property (weak, nonatomic) IBOutlet UISlider *sigmaRSlider;
@property (weak, nonatomic) IBOutlet UISlider *sigmaSSTSlider;
@property (weak, nonatomic) IBOutlet UISlider *sigmaMSlider;
@property (weak, nonatomic) IBOutlet UISlider *tauSlider;
@property (weak, nonatomic) IBOutlet UISlider *phiSlider;
@property (weak, nonatomic) IBOutlet UISlider *epsilonSlider;

- (IBAction)sigmaESliderContinuousAction:(id)sender;
- (IBAction)sigmaRSliderContinuousAction:(id)sender;
- (IBAction)sigmaSSTSliderContinuousAction:(id)sender;
- (IBAction)sigmaMSliderContinuousAction:(id)sender;
- (IBAction)tauSliderContinuousAction:(id)sender;
- (IBAction)phiSliderContinuousAction:(id)sender;
- (IBAction)epsilonSliderContinuousAction:(id)sender;

- (IBAction)loadPhotoButtonAction:(id)sender;
- (IBAction)resetButtonAction:(id)sender;

@end

@implementation ViewController {
    GPUImagePicture *sourceImage;
    GPUImageHistogramEqualizationFilter *equalization;
    SYNInkwellFilter *inkwell;
    SYNPencilSketchFilter *pencilSketch;
    GPUImagePicture *pencilShading;
    GPUImagePicture *paper;
    GPUImageMultiplyBlendFilter *paperBlend;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"TestImage1.jpg"];
    image = [self normalizedImage:image];
    sourceImage = [GPUImagePicture.alloc initWithImage:image];
    [sourceImage forceProcessingAtSizeRespectingAspectRatio:_photoImageView.frame.size];
    
    GPUImageSaturationFilter *saturation = GPUImageSaturationFilter.new;
    saturation.saturation = 1.2;
    
    equalization = [GPUImageHistogramEqualizationFilter.alloc initWithHistogramType:kGPUImageHistogramLuminance];
    
    UIImage *pencilShadingImg = [UIImage imageNamed:@"pencil-shading-01.jpg"];
    UIImage *imagePaper = [UIImage imageNamed:@"paper-01.jpg"];
    pencilShading = [GPUImagePicture.alloc initWithImage:pencilShadingImg];
    paper = [GPUImagePicture.alloc initWithImage:imagePaper];
    
    paperBlend = GPUImageMultiplyBlendFilter.new;
    
    inkwell = [SYNInkwellFilter.alloc initWithImageSize:image.size];
    pencilSketch = [SYNPencilSketchFilter.alloc initWithImageSize:image.size pencilTexture:pencilShading];
    
    [sourceImage addTarget:saturation];
    [saturation addTarget:equalization];
    [equalization addTarget:inkwell];
    [inkwell addTarget:_photoImageView];
    
//    [equalization addTarget:pencilSketch];
//    [pencilSketch addTarget:paperBlend atTextureLocation:0];
//    [paper addTarget:paperBlend atTextureLocation:1];
//    [paperBlend addTarget:_photoImageView];
    
    [self resetButtonAction:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self render];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self render];
}


- (IBAction)sigmaESliderContinuousAction:(id)sender {
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    inkwell.sigmaE = _sigmaESlider.value;
    pencilSketch.sigmaE = _sigmaESlider.value;
    [self render];
}

- (IBAction)sigmaRSliderContinuousAction:(id)sender {
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    inkwell.sigmaR = _sigmaRSlider.value;
    pencilSketch.sigmaR = _sigmaRSlider.value;
    [self render];
}

- (IBAction)sigmaSSTSliderContinuousAction:(id)sender {
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%d", (int)_sigmaSSTSlider.value];
    inkwell.sigmaSST = _sigmaSSTSlider.value;
    // TODO: Pencil mask blur
    [self render];
}

- (IBAction)sigmaMSliderContinuousAction:(id)sender {
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    inkwell.sigmaM = _sigmaMSlider.value;
    pencilSketch.sigmaM = _sigmaMSlider.value;
    [self render];
}

// NOTE: Tau is actually P now
- (IBAction)tauSliderContinuousAction:(id)sender {
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    inkwell.p = _tauSlider.value;
    pencilSketch.p = _tauSlider.value;
    [self render];
}

- (IBAction)phiSliderContinuousAction:(id)sender {
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    inkwell.phi = _phiSlider.value;
    pencilSketch.phi = _phiSlider.value;
    [self render];
}

- (IBAction)epsilonSliderContinuousAction:(id)sender {
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    inkwell.epsilon = _epsilonSlider.value;
    pencilSketch.epsilonX = _epsilonSlider.value;
    [self render];
}


- (IBAction)loadPhotoButtonAction:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)resetButtonAction:(id)sender {
//    pencilSketch.sigmaE = inkwell.sigmaE = _sigmaESlider.value = 1.39;
//    pencilSketch.sigmaR = inkwell.sigmaR = _sigmaRSlider.value = 2.87;
//    pencilSketch.sigmaSST = inkwell.sigmaSST = _sigmaSSTSlider.value = 2.5;
//    pencilSketch.sigmaM = inkwell.sigmaM = _sigmaMSlider.value = 3.36;
//    pencilSketch.p = inkwell.p = _tauSlider.value = 39.0;
//    pencilSketch.phi = inkwell.phi = _phiSlider.value = 0.17;
//    pencilSketch.epsilonX = inkwell.epsilon = _epsilonSlider.value = 0.15;
    
    pencilSketch.sigmaE = inkwell.sigmaE = _sigmaESlider.value = 0.5;
    pencilSketch.sigmaR = inkwell.sigmaR = _sigmaRSlider.value = 3.5;
    inkwell.sigmaSST = _sigmaSSTSlider.value = 0.5; // TODO: Set pencil sketch mask blur
    pencilSketch.sigmaM = inkwell.sigmaM = _sigmaMSlider.value = 0.5;
    pencilSketch.p = inkwell.p = _tauSlider.value = 35.0;
    pencilSketch.phi = inkwell.phi = _phiSlider.value = 0.08;
    pencilSketch.epsilonX = inkwell.epsilon = _epsilonSlider.value = 0.0;
    
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%d", (int)_sigmaSSTSlider.value];
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    
    [self render];
}

- (void)render
{
    [sourceImage processImage];
    [pencilShading processImage];
    [paper processImage];
}

#pragma mark - Image Picker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    pickedImage = [self normalizedImage:pickedImage];
    
    inkwell.imageSize = pickedImage.size;
    pencilSketch.imageSize = pickedImage.size;
    
    sourceImage = [GPUImagePicture.alloc initWithImage:pickedImage];
    [sourceImage forceProcessingAtSizeRespectingAspectRatio:_photoImageView.frame.size];
    [sourceImage addTarget:inkwell];
    //[sourceImage addTarget:pencilSketch];
    [self render];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (sourceType == UIImagePickerControllerSourceTypeCamera &&
        (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
        {
        UIAlertView *alert = [UIAlertView.alloc
                              initWithTitle:@"Camera"
                              message:@"This device doesn't have a camera."
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        }
    
    UIImagePickerController *imagePickerController = UIImagePickerController.alloc.init;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
    }
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Helpers

- (UIImage *)normalizedImage:(UIImage *)image
{
    // Resize to clamp max height/width at 1024 (preserving aspect ratio, and
    // rotate if needed
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    CGFloat scaleFactor = 1024.0 / MAX(oldWidth, oldHeight);
    CGSize newSize = CGSizeMake(oldWidth * scaleFactor, oldHeight * scaleFactor);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, image.scale);
    [image drawInRect:(CGRect){ 0, 0, newSize }];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return normalizedImage;
}

+ (GPUImageFilterGroup *)sundayComic:(UIImage *)inputImage
{
    GPUImageFilterGroup *group = GPUImageFilterGroup.alloc.init;
    
    // Edge-preserving blur, remove as much texture detail as possible
    GPUImageBilateralFilter *bilateral = GPUImageBilateralFilter.alloc.init;
    bilateral.distanceNormalizationFactor = 4.0;
    
    //// Background Color //////////////////////////////////////////////////////
    
    GPUImageHistogramEqualizationFilter *equalization = [GPUImageHistogramEqualizationFilter.alloc
                                                         initWithHistogramType:kGPUImageHistogramLuminance];
    equalization.downsamplingFactor = 16;
    
    GPUImageSaturationFilter *saturation = GPUImageSaturationFilter.alloc.init;
    saturation.saturation = 2.0;
    
    [bilateral addTarget:equalization];
    [equalization addTarget:saturation];
    
    //// Halftone Dots /////////////////////////////////////////////////////////
    
    SYNGPUImageColorHalftoneFilter *halftone = SYNGPUImageColorHalftoneFilter.alloc.init;
    
    GPUImageLinearBurnBlendFilter *halftoneBlend = GPUImageLinearBurnBlendFilter.alloc.init;
    
    [saturation addTarget:halftone];
    [saturation addTarget:halftoneBlend atTextureLocation:0];
    [halftone addTarget:halftoneBlend atTextureLocation:1];
    
    //// Ink Lines /////////////////////////////////////////////////////////////
    
    // TODO: Should be using .pixelSize, not .size
    SYNInkwellFilter *inkwell = [SYNInkwellFilter.alloc initWithImageSize:inputImage.size];
    inkwell.sigmaE = 1.0;
    inkwell.sigmaR = 1.6;
    inkwell.sigmaSST = 1.0;
    inkwell.sigmaM = 2.0;
    inkwell.p = 100.0;
    inkwell.phi = 0.01;
    inkwell.epsilon = 0.0;
    inkwell.sigmaBFD = 3.0;
    inkwell.sigmaBFR = 0.0425;
    inkwell.bfeNumPasses = 1;
    
    GPUImageMedianFilter *median = GPUImageMedianFilter.alloc.init;
    
    GPUImageColorInvertFilter *invert = GPUImageColorInvertFilter.alloc.init;
    
    GPUImageSubtractBlendFilter *lineBlend = GPUImageSubtractBlendFilter.alloc.init;
    
    [inkwell addTarget:median];
    [median addTarget:invert];
    [halftoneBlend addTarget:lineBlend atTextureLocation:0];
    [invert addTarget:lineBlend atTextureLocation:1];
    
    //// Paper Texture Blending ////////////////////////////////////////////////
    
    UIImage *paperTexture = [UIImage imageNamed:@"texture-paper01"];
    GPUImagePicture *gpuTexture = [GPUImagePicture.alloc initWithImage:paperTexture smoothlyScaleOutput:NO];
    [gpuTexture processImage];
    
    GPUImageTwoInputFilter *paperBlend = [GPUImageTwoInputFilter.alloc initWithFragmentShaderFromString:SHADER_STRING(
      varying highp vec2 textureCoordinate;
      varying highp vec2 textureCoordinate2;
      
      uniform sampler2D inputImageTexture;
      uniform sampler2D inputImageTexture2;
      
      void main()
      {
          mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
          mediump vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
          mediump vec4 whiteColor = vec4(1.0);
          
          gl_FragColor = whiteColor - (whiteColor - textureColor) / textureColor2;
          gl_FragColor.a = textureColor2.a;
      }
    )];
    
    [gpuTexture addTarget:paperBlend atTextureLocation:0];
    [lineBlend addTarget:paperBlend atTextureLocation:1];
    // TODO: Should be using .pixelSize, not .size
    [paperBlend setInputSize:inputImage.size atIndex:0];
    
    group.initialFilters = @[ bilateral, inkwell ];
    group.terminalFilter = paperBlend;
    
    return group;
}

+ (GPUImageFilterGroup *)bradstreet:(UIImage *)inputImage isSticker:(BOOL)sticker
{
    GPUImageFilterGroup *group = GPUImageFilterGroup.alloc.init;
    
    //// Preprocessing /////////////////////////////////////////////////////////
    
    GPUImageSaturationFilter *saturation = GPUImageSaturationFilter.alloc.init;
    saturation.saturation = 1.3;
    
    GPUImageContrastFilter *contrast = GPUImageContrastFilter.alloc.init;
    contrast.contrast = 1.1;
    
    GPUImageBilateralFilter *bilateral = GPUImageBilateralFilter.alloc.init;
    bilateral.distanceNormalizationFactor = 2.0;
    
    //// Background ////////////////////////////////////////////////////////////
    
    CGFloat blurRadius = sticker ? 1.0 : 5.0;
    
    GPUImageGaussianBlurFilter *gaussian1 = GPUImageGaussianBlurFilter.alloc.init;
    gaussian1.blurRadiusInPixels = blurRadius;
    
    GPUImageGaussianBlurFilter *gaussian2 = GPUImageGaussianBlurFilter.alloc.init;
    gaussian2.blurRadiusInPixels = blurRadius;
    
    GPUImageGaussianBlurFilter *gaussian3 = GPUImageGaussianBlurFilter.alloc.init;
    gaussian3.blurRadiusInPixels = blurRadius;
    
    // Darken blend with alpha preservation
    GPUImageTwoInputFilter *background = [GPUImageTwoInputFilter.alloc initWithFragmentShaderFromString:SHADER_STRING(
      varying highp vec2 textureCoordinate;
      varying highp vec2 textureCoordinate2;
      
      uniform sampler2D inputImageTexture;
      uniform sampler2D inputImageTexture2;
      
      void main() {
          lowp vec4 base = texture2D(inputImageTexture, textureCoordinate);
          lowp vec4 overlayer = texture2D(inputImageTexture2, textureCoordinate2);
          
          gl_FragColor = vec4(min(overlayer.rgb * base.a, base.rgb * overlayer.a) + overlayer.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlayer.a), base.a);
      }
    )];
    
    [saturation addTarget:contrast];
    [contrast addTarget:bilateral];
    [bilateral addTarget:gaussian1];
    [gaussian1 addTarget:gaussian2];
    [gaussian2 addTarget:gaussian3];
    [gaussian3 addTarget:background atTextureLocation:0];
    [contrast addTarget:background atTextureLocation:1];
    
    //// Edges /////////////////////////////////////////////////////////////////
    
    GPUImageGaussianBlurPositionFilter *edgeGaussian = GPUImageGaussianBlurPositionFilter.alloc.init;
    edgeGaussian.blurSize = 0.3;
    
    SYNGPUImageLaplaceEdgeDetectionFilter *edge = SYNGPUImageLaplaceEdgeDetectionFilter.alloc.init;
    // TODO: Should be using .pixelSize, not .size
    edge.imageSize = inputImage.size;
    edge.threshold = 4.0/255.0;
    edge.luminanceOffset = 0.8;
    
    GPUImageGaussianBlurFilter *blurredEdge = GPUImageGaussianBlurFilter.alloc.init;
    blurredEdge.blurRadiusInPixels = 1.0;
    
    GPUImageUnsharpMaskFilter *unsharpEdge = GPUImageUnsharpMaskFilter.alloc.init;
    unsharpEdge.blurRadiusInPixels = 1.0;
    unsharpEdge.intensity = 3.0;
    
    [bilateral addTarget:edgeGaussian];
    [edgeGaussian addTarget:edge];
    [edge addTarget:blurredEdge];
    [blurredEdge addTarget:unsharpEdge];
    
    //// Final Blend ///////////////////////////////////////////////////////////
    
    GPUImageSubtractBlendFilter *finalBlend = GPUImageSubtractBlendFilter.alloc.init;
    
    [background addTarget:finalBlend atTextureLocation:0];
    [unsharpEdge addTarget:finalBlend atTextureLocation:1];
    
    group.initialFilters = @[ saturation ];
    group.terminalFilter = finalBlend;
    
    return group;
}

@end
