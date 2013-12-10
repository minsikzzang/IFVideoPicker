//
//  IFVideoPicker.m
//  IFVideoPickerControllerDemo
//
//  Created by Min Kim on 3/25/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "IFVideoPicker.h"
#import "IFVideoEncoder.h"
#import "IFAudioEncoder.h"

@interface IFVideoPicker () <AVCaptureVideoDataOutputSampleBufferDelegate,
                             AVCaptureAudioDataOutputSampleBufferDelegate> {
  id deviceConnectedObserver;
  id deviceDisconnectedObserver;
  captureHandler sampleBufferHandler_;
  IFAVAssetEncoder *assetEncoder_;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)frontFacingCamera;
- (AVCaptureDevice *)backFacingCamera;
- (AVCaptureDevice *)audioDevice;
- (void)startCapture:(IFAVAssetEncoder *)encoder;

@end

// Safe release
#define SAFE_RELEASE(x) if (x) { [x release]; x = nil; }

#pragma mark -

@implementation IFVideoPicker

const char *kVideoBufferQueueLabel = "com.ifactorylab.ifvideopicker.videoqueue";
const char *kAudioBufferQueueLabel = "com.ifactorylab.ifvideopicker.audioqueue";

@synthesize videoInput;
@synthesize audioInput;
@synthesize videoBufferOutput;
@synthesize audioBufferOutput;
@synthesize captureVideoPreviewLayer;
@synthesize videoPreviewView;
@synthesize isCapturing;
@synthesize session;

- (id)init {
  self = [super init];
  if (self !=  nil) {
    self.isCapturing = NO;
    
    __block id weakSelf = self;
    void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
      AVCaptureDevice *device = [notification object];
      
      BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			if ([device hasMediaType:AVMediaTypeAudio]) {
        deviceMediaType = AVMediaTypeAudio;
      } else if ([device hasMediaType:AVMediaTypeVideo]) {
        deviceMediaType = AVMediaTypeVideo;
      }
      
      if (deviceMediaType != nil && session != nil) {
				for (AVCaptureDeviceInput *input in [self.session inputs]) {
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
					if ([self.session canAddInput:input])
						[self.session addInput:input];
				}
			}
			
      /**
       if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
       [delegate captureManagerDeviceConfigurationChanged:self];
       }
       */
      
    };
    
    void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
      AVCaptureDevice *device = [notification object];
			
			if ([device hasMediaType:AVMediaTypeAudio]) {
        if (self.session) {
          [self.session removeInput:[weakSelf audioInput]];
        }
        [weakSelf setAudioInput:nil];
			}
			else if ([device hasMediaType:AVMediaTypeVideo]) {
        if (self.session) {
          [self.session removeInput:[weakSelf videoInput]];
        }
				[weakSelf setVideoInput:nil];
			}
      /*
       if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
       [delegate captureManagerDeviceConfigurationChanged:self];
       }
       */
    };
    
    // Create capture device with video input
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    deviceConnectedObserver =
      [notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
                                      object:nil
                                       queue:nil
                                  usingBlock:deviceConnectedBlock];
    deviceDisconnectedObserver =
      [notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
                                      object:nil
                                       queue:nil
                                  usingBlock:deviceDisconnectedBlock];
  }
  return self;
}

- (void)dealloc {
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter removeObserver:deviceConnectedObserver];
  [notificationCenter removeObserver:deviceDisconnectedObserver];
  
  [self shutdown];
  SAFE_RELEASE(assetEncoder_);
  
  [super dealloc];
}

- (BOOL)startup {
  if (session != nil) {
    // If session already exists, return NO.
    NSLog(@"Video session already exists, you must call shutdown current session first");
    return NO;
  }
  
  // Set torch and flash mode to auto
  // We use back facing camera by default
  AVCaptureDevice *backFacingCaemra = [self backFacingCamera];
  if ([backFacingCaemra hasFlash]) {
    if ([backFacingCaemra lockForConfiguration:nil]) {
			if ([backFacingCaemra isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[backFacingCaemra setFlashMode:AVCaptureFlashModeAuto];
			}
			[backFacingCaemra unlockForConfiguration];
		}
  }
  
  if ([backFacingCaemra hasTorch]) {
    if ([backFacingCaemra lockForConfiguration:nil]) {
			if ([backFacingCaemra isTorchModeSupported:AVCaptureTorchModeAuto]) {
				[backFacingCaemra setTorchMode:AVCaptureTorchModeAuto];
			}
			[backFacingCaemra unlockForConfiguration];
		}
  }
  
  if ([backFacingCaemra isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
    if ([backFacingCaemra lockForConfiguration:nil]) {
      [backFacingCaemra setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    [backFacingCaemra unlockForConfiguration];
  }
  
  // Init the device inputs
  AVCaptureDeviceInput *newVideoInput =
    [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCaemra
                                           error:nil];
  AVCaptureDeviceInput *newAudioInput =
    [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice]
                                           error:nil];
  
  // Set up the video YUV buffer output
  dispatch_queue_t videoCaptureQueue =
  dispatch_queue_create(kVideoBufferQueueLabel, DISPATCH_QUEUE_SERIAL);
  
  AVCaptureVideoDataOutput *newVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
  [newVideoOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
  
  // or kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ??
  NSDictionary *videoSettings =
  [NSDictionary dictionaryWithObjectsAndKeys:
   [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
   kCVPixelBufferPixelFormatTypeKey, nil];
  newVideoOutput.videoSettings = videoSettings;
  
  // Set up the audio buffer output
  dispatch_queue_t audioCaptureQueue =
  dispatch_queue_create(kAudioBufferQueueLabel, DISPATCH_QUEUE_SERIAL);
  
  AVCaptureAudioDataOutput *newAudioOutput = [[AVCaptureAudioDataOutput alloc] init];
  [newAudioOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
  
  // Create session (use default AVCaptureSessionPresetHigh)
  AVCaptureSession *newSession = [[AVCaptureSession alloc] init];
  // newSession.sessionPreset = AVCaptureSessionPreset640x480;
  // If you want to have HD quality output, use this code below
  // newSession.sessionPreset = AVCaptureSessionPresetiFrame960x540;
  newSession.sessionPreset = AVCaptureSessionPreset1920x1080;
  
  // Add inputs and output to the capture session
  if ([newSession canAddInput:newVideoInput]) {
    [newSession addInput:newVideoInput];
  }
  
  if ([newSession canAddInput:newAudioInput]) {
    [newSession addInput:newAudioInput];
  }
  
  [self setSession:newSession];
  [self setVideoInput:newVideoInput];
  [self setAudioInput:newAudioInput];
  [self setVideoBufferOutput:newVideoOutput];
  [self setAudioBufferOutput:newAudioOutput];
  
  [newSession release];
  [newVideoInput release];
  [newAudioInput release];
  [newVideoOutput release];
  [newAudioOutput release];
  
  return YES;
}

- (void)shutdown {
  [self stopCapture];
  [self stopPreview];
  
  SAFE_RELEASE(session)
  SAFE_RELEASE(videoBufferOutput)
  SAFE_RELEASE(audioBufferOutput)
  SAFE_RELEASE(videoInput)
  SAFE_RELEASE(audioInput)
}

- (void)startPreview:(UIView *)view {
  [self startPreview:view withFrame:[view bounds]
         orientation:AVCaptureVideoOrientationPortrait];
}

- (void)startPreview:(UIView *)view withFrame:(CGRect)frame
         orientation:(AVCaptureVideoOrientation)orientation {
  AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer =
  [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
  
  CALayer *viewLayer = [view layer];
  [viewLayer setMasksToBounds:YES];
  
  [newCaptureVideoPreviewLayer setFrame:frame];
  if ([newCaptureVideoPreviewLayer respondsToSelector:@selector(connection)]) {
    if ([newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
      [newCaptureVideoPreviewLayer.connection setVideoOrientation:orientation];
    }
  } else {
    // Deprecated in 6.0; here for backward compatibility
    if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
      [newCaptureVideoPreviewLayer setOrientation:orientation];
    }
  }
  
  [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  [viewLayer insertSublayer:newCaptureVideoPreviewLayer
                      below:[[viewLayer sublayers]
                             objectAtIndex:0]];
  
  [self setVideoPreviewView:view];
  [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
  [newCaptureVideoPreviewLayer release];
  
  // Start the session. This is done asychronously since -startRunning doesn't
  //mreturn until the session is running.
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [session startRunning];
  });
}

- (void)stopPreview {
  if (session == nil) {
    // Session has not created yet...
    return;
  }
  
  if (self.session.isRunning) {
    // There is no active session running...
    NSLog(@"You need to run startPreview first");
    return;
  }
  
  [session stopRunning];
  
  SAFE_RELEASE(captureVideoPreviewLayer)
  SAFE_RELEASE(videoPreviewView)
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if
// one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices) {
    if ([device position] == position) {
      return device;
    }
  }
  return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *)frontFacingCamera {
  return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera {
  return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *)audioDevice {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
  if ([devices count] > 0) {
    return [devices objectAtIndex:0];
  }
  return nil;
}

// Add video and audio output objects to the current session to capture video
// and audio stream from the session.
- (void)startCapture:(IFAVAssetEncoder *)encoder {
  [encoder start];
  
  // Add video and audio output to current capture session.
  if ([session canAddOutput:videoBufferOutput]) {
    [session addOutput:videoBufferOutput];
    
    for (AVCaptureConnection *c in videoBufferOutput.connections) {
      NSLog(@"Video stablization supported: %@",
            c.isVideoStabilizationSupported ? @"TRUE" : @"FALSE");
      NSLog(@"Video stablization enabled: %@",
            c.videoStabilizationEnabled ? @"TRUE" : @"FALSE");
      if (c.isVideoStabilizationSupported) {
        c.enablesVideoStabilizationWhenAvailable = YES;
      }
    }
  }
  
  if ([session canAddOutput:audioBufferOutput]) {
    [session addOutput:audioBufferOutput];
  }
  
  // Now, we are capturing
  [self setIsCapturing:YES];
}
/*
- (void)startCaptureWithBlock:(captureHandler)completionBlock {
  sampleBufferHandler_ = completionBlock;
  
  [self startCapture];
}
*/

- (void)startCaptureWithEncoder:(IFVideoEncoder *)video
                          audio:(IFAudioEncoder *)audio
                   captureBlock:(encodedCaptureHandler)captureBlock
                metaHeaderBlock:(encodingMetaHeaderHandler)metaHeaderBlock
                   failureBlock:(encodingFailureHandler)failureBlock {
  // In order to use hardware acceleration encoding, we need to use
  // AVAssetsWriter, and AVAssetsWriter only writes to file, so we need to
  // create a file to contain encoded buffer and notify to captureBlock when
  // change is detcted.
  if (assetEncoder_ == nil) {
    assetEncoder_ = [IFAVAssetEncoder mpeg4BaseEncoder];
    assetEncoder_.videoEncoder = video;
    assetEncoder_.audioEncoder = audio;
    assetEncoder_.captureHandler = captureBlock;
    assetEncoder_.failureHandler = failureBlock;
    assetEncoder_.metaHeaderHandler = metaHeaderBlock;
  }
  
  [self startCapture:assetEncoder_];
}
/*
- (void)startCaptureToFileWithEncoder:(IFVideoEncoder *)video
                                audio:(IFAudioEncoder *)audio
                              maxSize:(UInt64)maxSize
                        progressBlock:(encodedProgressHandler)progressBlock {
  // Write encoded buffer to random file as much as the give max size.
  // Once the file reaches max size, notity to progressBlock.
  if (assetEncoder_ == nil) {
    assetEncoder_ = [IFAVAssetEncoder mpeg4BaseEncoder];
    // assetEncoder_ =  [IFAVAssetEncoder quickTimeMovieBaseEncoder];
    assetEncoder_.videoEncoder = video;
    assetEncoder_.audioEncoder = audio;
    assetEncoder_.maxFileSize = maxSize;
    assetEncoder_.progressHandler = progressBlock;
  }
  
  [self startCapture];
}
*/
- (void)stopCapture {
  if (!isCapturing) {
    return;
  }
  
  // Clean up encoder objects which might have been set eariler.
  if (assetEncoder_ != nil) {
    // [assetEncoder_ stopWithSaveToAlbum:NO];
    [assetEncoder_ stop];
    [assetEncoder_ release];
    assetEncoder_ = nil;
  }
  
  // If needed, stop before changing in current session.
  // [self.session stopRunning];
  
  // Pull out video and audio output from current capture session.
  [session removeOutput:videoBufferOutput];
  [session removeOutput:audioBufferOutput];
  
  // If session has stopped before changing, start it again.
  // [self.session startRunning];
  // sampleBufferHandler_ = nil;
  
  // Now, we are not capturing
  [self setIsCapturing:NO];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void) captureOutput:(AVCaptureOutput *)captureOutput
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection {
  IFCapturedBufferType bufferType = kBufferUnknown;
  if (connection == [videoBufferOutput connectionWithMediaType:AVMediaTypeVideo]) {
    bufferType = kBufferVideo;
  } else if (connection == [audioBufferOutput connectionWithMediaType:AVMediaTypeAudio]) {
    // NSLog(@"Audio stream coming");
    bufferType = kBufferAudio;
  }
  
  if (assetEncoder_ != nil) {
    [assetEncoder_ encodeSampleBuffer:sampleBuffer ofType:bufferType];
  } else {
    if (sampleBufferHandler_ != nil) {
      sampleBufferHandler_(sampleBuffer, bufferType);
    } else {
      NSLog(@"No sample buffer capture handler exist");
    }
  }
}

@end
