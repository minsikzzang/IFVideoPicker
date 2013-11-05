//
//  IFAVAssetEncoder.h
//  IFVideoPickerControllerDemo
//
//  Created by Min Kim on 9/27/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class IFVideoEncoder;
@class IFAudioEncoder;
@class MP4Reader;

typedef enum {
  kBufferUnknown = 0,
  kBufferVideo,
  kBufferAudio
} IFCapturedBufferType;

typedef void (^encodedCaptureHandler)(NSArray *frames, NSData *buffer);
typedef void (^encodedBufferCaptureHandler)(IFCapturedBufferType type,
                                            NSData *buffer,
                                            double ts);
typedef void (^encodedProgressHandler)(NSString *outputPath);
typedef void (^encodingFailureHandler)(NSError *error);
typedef void (^encodingMetaHeaderHandler)(MP4Reader *reader);

/**
 @abstract
  Encoding video / audio data using AVAssetWriter brings special benefit, 
  hardware accelaration. However, AVAssetWriter supports only one output which 
  is file output. We need to write encoded data to file format to use data.
 */
@interface IFAVAssetEncoder : NSObject {
  
}

@property (atomic, retain) AVAssetWriter *assetWriter;
@property (atomic, retain) AVAssetWriter *assetMetaWriter;
@property (atomic, retain) NSURL *outputURL;
@property (nonatomic, retain) IFAudioEncoder *audioEncoder;
@property (nonatomic, retain) IFVideoEncoder *videoEncoder;
@property (atomic, retain) NSFileHandle *outputFileHandle;
@property (atomic, copy) encodedCaptureHandler captureHandler;
@property (atomic, copy) encodedProgressHandler progressHandler;
@property (atomic, copy) encodingFailureHandler failureHandler;
@property (atomic, copy) encodingMetaHeaderHandler metaHeaderHandler;
@property (atomic, copy) encodedBufferCaptureHandler bufferCaptureHandler;
@property (atomic, assign) UInt64 maxFileSize;

/**
 @abstract
  create encoder for Mpeg4 format file.
 */
+ (IFAVAssetEncoder *)mpeg4BaseEncoder;

/**
 @abstract
  create encoder for QuickTime Movie format file.
 */
+ (IFAVAssetEncoder *)quickTimeMovieBaseEncoder;

/**
 */
- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
                    ofType:(IFCapturedBufferType)mediaType;

- (void)stopWithSaveToAlbum:(BOOL)saveToAlbum;

@end
