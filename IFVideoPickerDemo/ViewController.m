//
//  ViewController.m
//  IFVideoPickerDemo
//
//  Created by Min Kim on 11/5/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "ViewController.h"
#import "IFVideoPicker.h"

@interface ViewController () {
  IFVideoPicker *videoPicker_;
}

@property (retain, nonatomic) IBOutlet UIButton *recordButton;

@end

@implementation ViewController

@synthesize recordButton;

- (IBAction)recordButtonPushed:(id)sender {
  if (videoPicker_.isCapturing) {
    [videoPicker_ stopCapture];
    [recordButton setTitle:@"REC" forState:UIControlStateNormal];
  } else {
    [recordButton setTitle:@"STOP" forState:UIControlStateNormal];
    
    // audio 64kbos, samplerate 44100
    IFAudioEncoder *ae =
      [IFAudioEncoder createAACAudioWithBitRate:64000 sampleRate:44100];
    
    // video 500kbps, 512x288
    CMVideoDimensions dimensions;
    dimensions.width = 512;
    dimensions.height = 288;
    
    IFVideoEncoder *ve =
    [IFVideoEncoder createH264VideoWithDimensions:dimensions
                                          bitRate:500000
                                      maxKeyFrame:200];
    [videoPicker_ startCaptureWithEncoder:ve
                                    audio:ae
                             captureBlock:^(NSArray *frames, NSData *buffer) {
                               NSLog(@"buffer: %d bytes, with %d frames",
                                     [buffer length], [frames count]);
                             } metaHeaderBlock:^(MP4Reader *reader) {
                               
                             } failureBlock:^(NSError *error) {
                               [recordButton setTitle:@"REC" forState:UIControlStateNormal];
                             }];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view, typically from a nib.
  videoPicker_ = [[IFVideoPicker alloc] init];
  [videoPicker_ startup];
  [videoPicker_ startPreview:self.view];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  if (videoPicker_ != nil) {
    [videoPicker_ release];
  }

}

- (void)dealloc {
  [recordButton release];
  [super dealloc];
}
@end
