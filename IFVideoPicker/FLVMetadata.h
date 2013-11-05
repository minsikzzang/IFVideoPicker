//
//  FLVMetadata.h
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLV_AUDIO_CODECID_OFFSET     0

enum {
  kFLVCodecIdPCM                  = 0,
  kFLVCodecIdADPCM                = 1 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdMP3                  = 2 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdPCM_LE               = 3 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdNellyMoser16khzMono  = 4 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdNellyMoser8khzMono   = 5 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdNellyMoser           = 6 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdPCMAlaw              = 7 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdPCMMulaw             = 8 << FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdAAC                  = 10<< FLV_AUDIO_CODECID_OFFSET,
  kFLVCodecIdSpeex                = 11<< FLV_AUDIO_CODECID_OFFSET,
};

@interface FLVMetadata : NSObject

@property (atomic, assign) double duration;
@property (atomic, assign) double width;
@property (atomic, assign) double height;
@property (atomic, assign) double videoBitrate;
@property (atomic, assign) double framerate;
@property (atomic, assign) int videoCodecId;
@property (atomic, assign) double audioBitrate;
@property (atomic, assign) double sampleRate;
@property (atomic, assign) double sampleSize;
@property (atomic, assign) BOOL stereo;
@property (atomic, assign) int audioCodecId;

@end
