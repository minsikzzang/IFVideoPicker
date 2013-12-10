//
//  ViewController.m
//  IFVideoPickerDemo
//
//  Created by Min Kim on 11/5/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "ViewController.h"
#import "IFVideoPicker.h"
#import "FLVTag.h"
#import "FLVMetadata.h"
#import "FLVWriter.h"
#import "MP4Reader.h"
#import "MP4Frame.h"

@interface ViewController () {
  IFVideoPicker *videoPicker_;
  BOOL flvMetadataSent_;
  FLVWriter *flvWriter_;
  double lastTimestamp_;
  NSMutableData *buffer_;
}

@property (retain, nonatomic) IBOutlet UIButton *recordButton;
@property (retain, atomic) IFVideoEncoder *videoEncoder;
@property (retain, atomic) IFAudioEncoder *audioEncoder;
@property (atomic, retain) NSFileHandle *outputFileHandle;

@end

@implementation ViewController

@synthesize recordButton;
@synthesize audioEncoder;
@synthesize videoEncoder;
@synthesize outputFileHandle;

- (FLVMetadata *)getFLVMetadata:(IFVideoEncoder *)video
                          audio:(IFAudioEncoder *)audio {
  FLVMetadata *metadata = [[FLVMetadata alloc] init];
  // set video encoding metadata
  metadata.width = video.dimensions.width;
  metadata.height = video.dimensions.height;
  metadata.videoBitrate = video.bitRate / 1024.0;
  metadata.framerate = 25;
  metadata.videoCodecId = kFLVCodecIdH264;
  
  // set audio encoding metadata
  metadata.audioBitrate = audio.bitRate / 1024.0;
  metadata.sampleRate = audio.sampleRate;
  metadata.sampleSize = 16;// * 1024; // 16K
  metadata.stereo = YES;
  metadata.audioCodecId = kFLVCodecIdAAC;
  
  return [metadata autorelease];
}

- (void)mp4MetaHeaderHandler:(MP4Reader *)reader {
  FLVMetadata *metadata = [self getFLVMetadata:videoEncoder audio:audioEncoder];
  // If we haven't sent header and metadata yet, let's create and send together
  // with H264/AAC video and audio decoder configurations.
  if (!flvMetadataSent_) {
    flvWriter_.debug = NO;
    [flvWriter_ writeHeader];
    [flvWriter_ writeMetaTag:metadata];
  }
  
  [flvWriter_ writeVideoDecoderConfRecord:reader.videoDecoderBytes];
  [flvWriter_ writeAudioDecoderConfRecord:reader.audioDecoderBytes];
  
  // [outputFileHandle seekToEndOfFile];
  [outputFileHandle writeData:flvWriter_.packet];
  // [buffer_ appendData:flvWriter_.packet];
  
  /*
  int byteSent = [rtmp_ rtmpWrite:flvWriter_.packet];
  if (byteSent <= 0) {
    NSLog(@"Failed to send rtmp packet!!! byteSent:%d", byteSent);
  } else {
    if (!flvMetadataSent_) {
      flvMetadataSent_ = YES;
    }
  }*/
  if (!flvMetadataSent_) {
    flvMetadataSent_ = YES;
  }
  
  [flvWriter_ reset];
}

- (void)captureHandleByCompletedMP4Frames:(NSArray *)frames
                                   buffer:(NSData *)buffer {
  double tsOffset = lastTimestamp_;
  for (MP4Frame *f in frames) {
    NSData *chunk = [NSData dataWithBytes:(char *)[buffer bytes] + f.offset
                                   length:f.size];
    NSLog(@"captureHandleByCompletedMP4Frames: timestamp: %ul, type: %@",
          (unsigned int)(lastTimestamp_ * 1000),
          (f.type == kFrameTypeAudio ? @"audio" : @"video"));
    // lastTimestamp_ = f.timestamp + tsOffset;
    if (f.type == kFrameTypeAudio) {
      [flvWriter_ writeAudioPacket:chunk timestamp:(unsigned long)(lastTimestamp_ * 1000)];
    } else if (f.type == kFrameTypeVideo) {
      [flvWriter_ writeVideoPacket:chunk timestamp:(unsigned long)(lastTimestamp_ * 1000) keyFrame:f.keyFrame];
    }
    lastTimestamp_ = f.timestamp + tsOffset;
  }
  
  if (lastTimestamp_ > 10)
    lastTimestamp_ -= 10;
  
  // [outputFileHandle seekToEndOfFile];
  [outputFileHandle writeData:flvWriter_.packet];
  // [buffer_ appendData:flvWriter_.packet];
  
  /*
  int byteSent = [rtmp_ rtmpWrite:flvWriter_.packet];
  if (byteSent <= 0) {
    NSLog(@"Failed to send rtmp packet!!! byteSent:%d", byteSent);
  } else {
    if (!flvMetadataSent_) {
      flvMetadataSent_ = YES;
    }
  }
   */
  [flvWriter_ reset];
}

NSString *const kIFFLVOutputWithRandom = @"ifflvout-%05d.flv";

- (IBAction)recordButtonPushed:(id)sender {
  if (videoPicker_.isCapturing) {
    [videoPicker_ stopCapture];
    
    if (buffer_)
      [buffer_ release];
    if (flvWriter_)
      [flvWriter_ release];
    
    [outputFileHandle closeFile];
    [recordButton setTitle:@"REC" forState:UIControlStateNormal];
  } else {
    [recordButton setTitle:@"STOP" forState:UIControlStateNormal];
    buffer_ = [[NSMutableData alloc] init];
    flvWriter_ = [[FLVWriter alloc] init];
    
    NSString *path = NSTemporaryDirectory();
    NSString *filePath =  [path stringByAppendingPathComponent:
                           [NSString stringWithFormat:kIFFLVOutputWithRandom, rand() % 99999]];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    // [[NSFileManager defaultManager] createFileAtPath:filePath contents:buffer_ attributes:nil];
    
    self.outputFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    NSLog(@"filePath: %@", filePath);
        
    // audio 64kbos, samplerate 44100
    self.audioEncoder =
      [IFAudioEncoder createAACAudioWithBitRate:256000 sampleRate:44100];
    
    // video 800kbps, 720x404
    CMVideoDimensions dimensions;
    dimensions.width = 1024;
    dimensions.height = 576;
    
    self.videoEncoder =
      [IFVideoEncoder createH264VideoWithDimensions:dimensions
                                            bitRate:1500000
                                        maxKeyFrame:200];
    [videoPicker_ startCaptureWithEncoder:videoEncoder
                                    audio:audioEncoder
                             captureBlock:^(NSArray *frames, NSData *buffer) {
                               NSLog(@"buffer: %d bytes, with %d frames",
                                     [buffer length], [frames count]);
                               if (buffer != nil && frames.count > 0) {
                                 [self captureHandleByCompletedMP4Frames:frames buffer:buffer];
                               }
                             } metaHeaderBlock:^(MP4Reader *reader) {
                               [self mp4MetaHeaderHandler:reader];
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
