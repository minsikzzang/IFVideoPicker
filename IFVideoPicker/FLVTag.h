//
//  FLVTag.h
//  protos
//
//  Created by Min Kim on 10/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//
// https://code.google.com/p/red5/source/browse/java/server/trunk/src/org/red5/io/flv/impl/FLVWriter.java?r=4204
// https://code.google.com/p/red5/source/browse/java/server/trunk/src/org/red5/io/flv/impl/Tag.java?r=4204
// https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFByteOrderUtils/Reference/reference.html
#import <Foundation/Foundation.h>

enum {
  kFLVTagTypeAudio = 0x08,
  kFLVTagTypeVideo = 0x09,
  kFLVTagTypeMeta  = 0x12
};

#define FLV_AUDIO_SAMPLESSIZE_OFFSET 1
#define FLV_AUDIO_SAMPLERATE_OFFSET  2
#define FLV_VIDEO_FRAMETYPE_OFFSET   4
#define FLV_AUDIO_CODECID_OFFSET     4

enum {
  kFLVCodecIdH263    = 2,
  kFLVCodecIdScreen  = 3,
  kFLVCodecIdVP6     = 4,
  kFLVCodecIdVP6A    = 5,
  kFLVCodecIdScreen2 = 6,
  kFLVCodecIdH264    = 7,
  kFLVCodecIdRealH263= 8,
  kFLVCodecIdMpeg4   = 9,
};

enum {
  kAVCSequenceHeader = 0,
  kAVCNALU,
  kAVCEndOfSequence
};

enum {
  kAACSequenceHeader = 0,
  kAACRaw
};

enum {
  FLV_SAMPLERATE_SPECIAL = 0, /**< signifies 5512Hz and 8000Hz in the case of NELLYMOSER */
  FLV_SAMPLERATE_11025HZ = 1 << FLV_AUDIO_SAMPLERATE_OFFSET,
  FLV_SAMPLERATE_22050HZ = 2 << FLV_AUDIO_SAMPLERATE_OFFSET,
  FLV_SAMPLERATE_44100HZ = 3 << FLV_AUDIO_SAMPLERATE_OFFSET,
};

enum {
  FLV_MONO   = 0,
  FLV_STEREO = 1,
};

enum {
  FLV_SAMPLESSIZE_8BIT  = 0,
  FLV_SAMPLESSIZE_16BIT = 1 << FLV_AUDIO_SAMPLESSIZE_OFFSET,
};

enum {
  FLV_FRAME_KEY            = 1 << FLV_VIDEO_FRAMETYPE_OFFSET, ///< key frame (for AVC, a seekable frame)
  FLV_FRAME_INTER          = 2 << FLV_VIDEO_FRAMETYPE_OFFSET, ///< inter frame (for AVC, a non-seekable frame)
  FLV_FRAME_DISP_INTER     = 3 << FLV_VIDEO_FRAMETYPE_OFFSET, ///< disposable inter frame (H.263 only)
  FLV_FRAME_GENERATED_KEY  = 4 << FLV_VIDEO_FRAMETYPE_OFFSET, ///< generated key frame (reserved for server use only)
  FLV_FRAME_VIDEO_INFO_CMD = 5 << FLV_VIDEO_FRAMETYPE_OFFSET, ///< video info/command frame
};

enum {
  FLV_CODECID_PCM                  = 0,
  FLV_CODECID_ADPCM                = 1 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_MP3                  = 2 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_PCM_LE               = 3 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_NELLYMOSER_16KHZ_MONO = 4 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_NELLYMOSER_8KHZ_MONO = 5 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_NELLYMOSER           = 6 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_PCM_ALAW             = 7 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_PCM_MULAW            = 8 << FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_AAC                  = 10<< FLV_AUDIO_CODECID_OFFSET,
  FLV_CODECID_SPEEX                = 11<< FLV_AUDIO_CODECID_OFFSET,
};

@interface FLVTag : NSObject

// Tag Type
@property (atomic, assign) Byte type;

// Tag data type
@property (atomic, assign) Byte dataType;

// Timestamp
@property (atomic, assign) unsigned long timestamp;

// Tag body size
@property (atomic, assign) int bodySize;

// Tag body as NSData
@property (atomic, retain) NSData *body;

// Previous tag size
@property (atomic, assign) int previuosTagSize;

// Bit flags
@property (atomic, assign) Byte bitflags;

@property (atomic, assign) int flagsSize;


- (NSString *)toString;

@end
