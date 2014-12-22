//
//  ViewController.m
//  SYNInkwell
//
//  Created by Lauren Winter on 12/18/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import "ViewController.h"
#import "SYNInkwellFilter.h"
#import "SYNPencilSketchFilter.h"
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
    GPUImagePicture *textureLight;
    GPUImagePicture *textureDark;
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
    
    UIImage *imageLight = [UIImage imageNamed:@"pencil-shading-02.jpg"];
    UIImage *imageDark = [UIImage imageNamed:@"pencil-shading-01.jpg"];
    UIImage *imagePaper = [UIImage imageNamed:@"paper-01.jpg"];
    textureLight = [GPUImagePicture.alloc initWithImage:imageLight];
    textureDark = [GPUImagePicture.alloc initWithImage:imageDark];
    paper = [GPUImagePicture.alloc initWithImage:imagePaper];
    
    paperBlend = GPUImageMultiplyBlendFilter.new;
    
    inkwell = [SYNInkwellFilter.alloc initWithImageSize:image.size];
    pencilSketch = [SYNPencilSketchFilter.alloc initWithImageSize:image.size
                                                     lightTexture:textureLight
                                                      darkTexture:textureDark];
    
    [sourceImage addTarget:saturation];
    [saturation addTarget:equalization];
//    [equalization addTarget:inkwell];
//    [inkwell addTarget:_photoImageView];
    
    [equalization addTarget:pencilSketch];
    [pencilSketch addTarget:paperBlend atTextureLocation:0];
    [paper addTarget:paperBlend atTextureLocation:1];
    [paperBlend addTarget:_photoImageView];
    
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
    [textureLight processImage];
    [textureDark processImage];
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
    [sourceImage addTarget:pencilSketch];
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

@end
