//
//  MP4Record.m
//  protos
//
//  Created by Min Kim on 10/15/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "MP4Record.h"

/**
 @abstract
  MP4Record
 */
@implementation MP4Record

@synthesize firstChunk;
@synthesize sampleDescription;
@synthesize samplePerChunk;

@end

/**
 @abstract
  MP4TimeSampleRecord
 */
@implementation MP4TimeSampleRecord

@synthesize consecutiveSamples;
@synthesize sampleDuration;

@end

/**
 @abstract
  MP4CompositionTimeSampleRecord
 */
@implementation MP4CompositionTimeSampleRecord

@synthesize consecutiveSamples;
@synthesize sampleOffset;

@end