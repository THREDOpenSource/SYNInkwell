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

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

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
    UIImage *sourceImage;
    
    CGFloat sigmaE;
    CGFloat sigmaR;
    CGFloat sigmaSST;
    CGFloat sigmaM;
    CGFloat tau;
    CGFloat phi;
    CGFloat epsilon;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sourceImage = [[UIImage alloc] initWithCGImage:[_photoImageView.image CGImage]];
    [self resetButtonAction:nil];
}

- (IBAction)sigmaESliderAction:(id)sender {
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    sigmaE = _sigmaESlider.value;
    [self filterImage];
}

- (IBAction)sigmaRSliderAction:(id)sender {
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    sigmaR = _sigmaRSlider.value;
    [self filterImage];
}

- (IBAction)sigmaSSTSliderAction:(id)sender {
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaSSTSlider.value];
    sigmaSST = _sigmaSSTSlider.value;
    [self filterImage];
}

- (IBAction)sigmaMSliderAction:(id)sender {
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    sigmaM = _sigmaMSlider.value;
    [self filterImage];
}

- (IBAction)tauSliderAction:(id)sender {
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    tau =_tauSlider.value;
    [self filterImage];
}

- (IBAction)phiSliderAction:(id)sender {
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    phi = _phiSlider.value;
    [self filterImage];
}

- (IBAction)epsilonSliderAction:(id)sender {
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    epsilon = _epsilonSlider.value;
    [self filterImage];
}



- (IBAction)sigmaESliderContinuousAction:(id)sender {
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];

}

- (IBAction)sigmaRSliderContinuousAction:(id)sender {
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];

}

- (IBAction)sigmaSSTSliderContinuousAction:(id)sender {
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaSSTSlider.value];

}

- (IBAction)sigmaMSliderContinuousAction:(id)sender {
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];

}

- (IBAction)tauSliderContinuousAction:(id)sender {
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];

}

- (IBAction)phiSliderContinuousAction:(id)sender {
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];

}

- (IBAction)epsilonSliderContinuousAction:(id)sender {
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];

}



- (IBAction)loadPhotoButtonAction:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)resetButtonAction:(id)sender {
    sigmaE = _sigmaESlider.value = 1.0;
    sigmaR = _sigmaRSlider.value = 1.6;
    sigmaSST = _sigmaSSTSlider.value = 2.0;
    sigmaM = _sigmaMSlider.value = 3.0;
    tau = _tauSlider.value = 0.99;
    phi = _phiSlider.value = 2.0;
    epsilon = _epsilonSlider.value = 0.0;
    
    _sigmaEValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaESlider.value];
    _sigmaRValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaRSlider.value];
    _sigmaSSTValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaSSTSlider.value];
    _sigmaMValueLabel.text = [NSString stringWithFormat:@"%0.2f", _sigmaMSlider.value];
    _tauValueLabel.text = [NSString stringWithFormat:@"%0.2f", _tauSlider.value];
    _phiValueLabel.text = [NSString stringWithFormat:@"%0.2f", _phiSlider.value];
    _epsilonValueLabel.text = [NSString stringWithFormat:@"%0.2f", _epsilonSlider.value];
    
    [self filterImage];
}

- (void)filterImage
{
    GPUImageGrayscaleFilter *grayscale = GPUImageGrayscaleFilter.alloc.init;

    SYNInkwellFilter *inkwell = [SYNInkwellFilter.alloc
                             initWithImageSize:sourceImage.size
                             sigmaE:sigmaE
                             sigmaR:sigmaR
                             sigmaSST:sigmaSST
                             sigmaM:sigmaM
                             tau:tau
                             phi:phi
                             epsilon:epsilon];

    GPUImageGrayscaleFilter *grayscale2 = GPUImageGrayscaleFilter.alloc.init;
    [inkwell connectWithInput:grayscale output:grayscale2 atTextureLocation:0];
    
    GPUImageFilterGroup *group = GPUImageFilterGroup.alloc.init;
    group.initialFilters = @[ grayscale ];
    group.terminalFilter = grayscale2;

    UIImage *outputImage = [group imageByFilteringImage:sourceImage];
    _photoImageView.image = outputImage;
}

#pragma mark - Image Picker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    sourceImage = [[UIImage alloc] initWithCGImage:[pickedImage CGImage]];
    [self filterImage];

    // Dismiss the imagePickerController and go back the the Editor view
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Request to save the image to camera roll
            ALAssetsLibrary *library = ALAssetsLibrary.new;
            [library writeImageToSavedPhotosAlbum:pickedImage.CGImage
                                      orientation:(ALAssetOrientation)pickedImage.imageOrientation
                                  completionBlock:^(NSURL *assetURL, NSError *error)
             {
             if (error) {
                 return;
             }
             
             // Photo was taken
             
             }];
        } else {
            // Camera roll image was selected
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
    }];
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


@end
