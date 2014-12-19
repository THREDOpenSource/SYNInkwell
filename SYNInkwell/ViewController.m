//
//  ViewController.m
//  SYNInkwell
//
//  Created by Lauren Winter on 12/18/14.
//  Copyright (c) 2014 Syntertainment. All rights reserved.
//

#import "ViewController.h"
#import "SYNInkwellFilter.h"
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

- (IBAction)sigmaESliderAction:(id)sender;
- (IBAction)sigmaRSliderAction:(id)sender;
- (IBAction)sigmaSSTSliderAction:(id)sender;
- (IBAction)sigmaMSliderAction:(id)sender;
- (IBAction)tauSliderAction:(id)sender;
- (IBAction)phiSliderAction:(id)sender;
- (IBAction)epsilonSliderAction:(id)sender;

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
    SYNInkwellFilter *inkwell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"TestImage1.jpg"];
    sourceImage = [GPUImagePicture.alloc initWithImage:image];
    [sourceImage forceProcessingAtSizeRespectingAspectRatio:_photoImageView.frame.size];
    
    inkwell = [SYNInkwellFilter.alloc initWithImageSize:image.size
                                                 sigmaE:1.0
                                                 sigmaR:1.6
                                               sigmaSST:2.0
                                                 sigmaM:3.0
                                                    tau:0.99
                                                    phi:2.0
                                                epsilon:0.0];
    
    [sourceImage addTarget:inkwell];
    [inkwell addTarget:_photoImageView];
    
    [self resetButtonAction:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [sourceImage processImage];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [sourceImage processImage];
}

- (IBAction)sigmaESliderAction:(id)sender {
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    inkwell.sigmaE = _sigmaESlider.value;
    [sourceImage processImage];
}

- (IBAction)sigmaRSliderAction:(id)sender {
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    inkwell.sigmaR = _sigmaRSlider.value;
    [sourceImage processImage];
}

- (IBAction)sigmaSSTSliderAction:(id)sender {
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%d", (int)_sigmaSSTSlider.value];
    inkwell.sigmaSST = _sigmaSSTSlider.value;
    [sourceImage processImage];
}

- (IBAction)sigmaMSliderAction:(id)sender {
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    inkwell.sigmaM = _sigmaMSlider.value;
    [sourceImage processImage];
}

- (IBAction)tauSliderAction:(id)sender {
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    inkwell.tau =_tauSlider.value;
    [sourceImage processImage];
}

- (IBAction)phiSliderAction:(id)sender {
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    inkwell.phi = _phiSlider.value;
    [sourceImage processImage];
}

- (IBAction)epsilonSliderAction:(id)sender {
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    inkwell.epsilon = _epsilonSlider.value;
    [sourceImage processImage];
}


- (IBAction)sigmaESliderContinuousAction:(id)sender {
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    inkwell.sigmaE = _sigmaESlider.value;
    [sourceImage processImage];
}

- (IBAction)sigmaRSliderContinuousAction:(id)sender {
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    inkwell.sigmaR = _sigmaRSlider.value;
    [sourceImage processImage];
}

- (IBAction)sigmaSSTSliderContinuousAction:(id)sender {
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%d", (int)_sigmaSSTSlider.value];
    inkwell.sigmaSST = _sigmaSSTSlider.value;
    [sourceImage processImage];
}

- (IBAction)sigmaMSliderContinuousAction:(id)sender {
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    inkwell.sigmaM = _sigmaMSlider.value;
    [sourceImage processImage];
}

- (IBAction)tauSliderContinuousAction:(id)sender {
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    inkwell.tau = _tauSlider.value;
    [sourceImage processImage];
}

- (IBAction)phiSliderContinuousAction:(id)sender {
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    inkwell.phi = _phiSlider.value;
    [sourceImage processImage];
}

- (IBAction)epsilonSliderContinuousAction:(id)sender {
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    inkwell.epsilon = _epsilonSlider.value;
    [sourceImage processImage];
}


- (IBAction)loadPhotoButtonAction:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)resetButtonAction:(id)sender {
    inkwell.sigmaE = _sigmaESlider.value = 1.0;
    inkwell.sigmaR = _sigmaRSlider.value = 1.6;
    inkwell.sigmaSST = _sigmaSSTSlider.value = 2.0;
    inkwell.sigmaM = _sigmaMSlider.value = 3.0;
    inkwell.tau = _tauSlider.value = 0.99;
    inkwell.phi = _phiSlider.value = 2.0;
    inkwell.epsilon = _epsilonSlider.value = 0.0;
    
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%d", (int)_sigmaSSTSlider.value];
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    
    [sourceImage processImage];
}

#pragma mark - Image Picker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    pickedImage = [self normalizedImage:pickedImage];
    
    inkwell.imageSize = pickedImage.size;
    
    sourceImage = [GPUImagePicture.alloc initWithImage:pickedImage];
    [sourceImage forceProcessingAtSizeRespectingAspectRatio:_photoImageView.frame.size];
    [sourceImage addTarget:inkwell];
    [sourceImage processImage];
    
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
