//
//  MP4Reader.h
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MP4Atom;
@class IFBytesData;

@interface MP4Reader : NSObject

@property (atomic, assign) long mdatOffset;
@property (atomic, assign) long moovOffset;
@property (atomic, assign) int avcLevel;
@property (atomic, assign) int avcProfile;
@property (atomic, assign) int width;
@property (atomic, assign) int height;
// Decoder bytes / configs
@property (atomic, retain) NSData *videoDecoderBytes;
@property (atomic, retain) NSData *audioDecoderBytes;
@property (atomic, retain) NSString *audioCodecId;
@property (atomic, retain) NSString *videoCodecId;
@property (atomic, assign) int audioChannels;
@property (atomic, assign) int audioCodecType;
@property (atomic, retain) NSArray *videoSamplesToChunks;
@property (atomic, retain) NSArray *audioSamplesToChunks;
@property (atomic, retain) NSArray *videoChunkOffsets;
@property (atomic, retain) NSArray *audioChunkOffsets;

//keyframe - sample numbers
@property (atomic, retain) NSArray *syncSamples;
@property (atomic, retain) NSArray *videoSamples;
@property (atomic, retain) NSArray *audioSamples;
@property (atomic, retain) NSArray *frames;
@property (atomic, retain) NSArray *compositionTimes;

@property (atomic, assign) int videoSampleDuration;
@property (atomic, assign) int videoSampleCount;
@property (atomic, assign) int audioSampleDuration;
@property (atomic, assign) BOOL hasVideo;
@property (atomic, assign) BOOL hasAudio;
// audio sample rate kHz
@property (atomic, assign) double audioTimeScale;
@property (atomic, assign) double videoTimeScale;

- (void)readData:(IFBytesData *)data;
- (NSArray *)readFrames;
- (NSArray *)readFrames:(IFBytesData *)data;

@end
