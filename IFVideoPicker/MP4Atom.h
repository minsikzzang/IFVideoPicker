//
//  MP4Atom.h
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MKTAG(a,b,c,d) ((a) | ((b) << 8) | ((c) << 16) | ((unsigned)(d) << 24))
#define MKBETAG(a,b,c,d) ((d) | ((c) << 8) | ((b) << 16) | ((unsigned)(a) << 24))

@class MP4Descriptor;
@class IFBytesData;

@interface MP4Atom : NSObject

+ (MP4Atom *)createAtomFromData:(IFBytesData *)data;
+ (NSString *)intToType:(int)type;

/**
 @abstract
  Lookups for a child atom with the specified <code>type</code>,
 skips the <code>number</code> children with the same type before
 finding a result.
 @param type the type of the atom.
 @param number the number of atoms to skip
 @return the atom which was being searched.
 */
- (MP4Atom *)lookup:(long)type number:(long)number;

@property (atomic, assign) int64_t size;
@property (atomic, assign) long type;
@property (atomic, assign) int version;
@property (atomic, assign) int flags;
@property (atomic, assign) int graphicsMode;
@property (atomic, assign) int opColorRed;
@property (atomic, assign) int opColorGreen;
@property (atomic, assign) int opColorBlue;
@property (atomic, retain) NSMutableArray *children;
@property (atomic, retain) NSArray *records;
@property (atomic, retain) NSArray *samples;
@property (atomic, assign) int sampleSize;
@property (atomic, assign) int entryCount;
@property (atomic, assign) int width;
@property (atomic, assign) int height;
@property (atomic, assign) int avcLevel;
@property (atomic, assign) int avcProfile;
@property (atomic, assign) int timeScale;
@property (atomic, assign) int channelCount;
@property (atomic, assign) int handlerType;
@property (atomic, retain) NSData *videoConfigBytes;
@property (atomic, retain) MP4Descriptor *esdDescriptor;
@property (atomic, retain) NSArray *chunks;
@property (atomic, retain) NSArray *timeToSamplesRecords;
@property (atomic, retain) NSArray *syncSamples;
@property (atomic, retain) NSArray *comptimeToSamplesRecords;

@end
