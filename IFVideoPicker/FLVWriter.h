//
//  FLVWriter.h
//  protos
//
//  Created by Min Kim on 10/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLVMetadata;
@class FLVTag;

@interface FLVWriter : NSObject

@property (atomic, readonly) NSMutableData *packet;
@property (atomic, assign) BOOL debug;

- (void)writeHeader;
- (void)writeTag:(FLVTag *)tag;
- (void)writeMetaTag:(FLVMetadata *)metaTag;
- (void)writeVideoPacket:(NSData *)data timestamp:(unsigned long)timestamp keyFrame:(BOOL)keyFrame;
- (void)writeAudioPacket:(NSData *)data timestamp:(unsigned long)timestamp;
- (void)writeAudioDecoderConfRecord:(NSData *)decoderBytes;
- (void)writeVideoDecoderConfRecord:(NSData *)decoderBytes;
- (void)reset;

@end
