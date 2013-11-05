//
//  MP4Atom.m
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "MP4Atom.h"
#import "MP4Record.h"
#import "NSData+Hex.h"
#import "IFBytesData.h"
#import "MP4Descriptor.h"

@interface MP4Atom () {
  
}

- (NSUInteger)readIdentification:(IFBytesData *)data;

- (NSUInteger)readWide:(IFBytesData *)data;

- (NSUInteger)readMDat:(IFBytesData *)data;

/**
 @abstract
  Loads MovieHeader atom from the input stream.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readMovieHeader:(IFBytesData *)data;

/**
 @abstract
  Loads the composite atom from the input stream.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)createCompositeAtom:(IFBytesData *)data;

/**
 @abstract
  Loads the version of the full atom from the input stream.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)loadVeresionAndFlags:(IFBytesData *)data;

/**
 @abstract
  Loads MP4SampleToChunkAtom atom from the input stream.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readSampleToChunkAtom:(IFBytesData *)data;

/**
 @abstract
  Loads MP4SampleSizeAtom atom from the input stream.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readSampleSizeAtom:(IFBytesData *)data;

/**
 @abstract
  Loads AVCC atom from the input stream.
 
 <pre>
 8+ bytes ISO/IEC 14496-10 or 3GPP AVC decode config box
 = long unsigned offset + long ASCII text string 'avcC'
 -> 1 byte version = 8-bit hex version  (current = 1)
 -> 1 byte H.264 profile = 8-bit unsigned stream profile
 -> 1 byte H.264 compatible profiles = 8-bit hex flags
 -> 1 byte H.264 level = 8-bit unsigned stream level
 -> 1 1/2 nibble reserved = 6-bit unsigned value set to 63
 -> 1/2 nibble NAL length = 2-bit length byte size type
 - 1 byte = 0 ; 2 bytes = 1 ; 4 bytes = 3
 -> 1 byte number of SPS = 8-bit unsigned total
 -> 2+ bytes SPS length = short unsigned length
 -> + SPS NAL unit = hexdump
 -> 1 byte number of PPS = 8-bit unsigned total
 -> 2+ bytes PPS length = short unsigned length
 -> + PPS NAL unit = hexdump
 </pre>
 
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readAvcConfigAtom:(IFBytesData *)data;

/**
 @abstract
  Loads SampleDescription atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readSampleDescriptionAtom:(IFBytesData *)data;

/**
 @abstract
   Loads MP4VideoSampleEntryAtom atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readVideoSampleEntryAtom:(IFBytesData *)data;

/**
 @abstract
  Loads M4ESDAtom atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readEsdAtom:(IFBytesData *)data;

/**
 @abstract
  Creates the decompression param (wave) atom.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readDecompressionParamAtom:(IFBytesData *)data;

/**
 @abstract
  Loads AudioSampleEntry atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readAudioSampleEntryAtom:(IFBytesData *)data;

/**
 @abstract
  Loads ChunkOffset atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readChunkOffsetStom:(IFBytesData *)data;

/**
 @abstract
  Loads Handler atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readHandlerAtom:(IFBytesData *)data;

/**
 @abstract
  Loads MP4TimeToSampleAtom atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readTimeToSampleAtom:(IFBytesData *)data;

/**
 @abstract
  Loads MP4SyncSampleAtom atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readSyncSampleAtom:(IFBytesData *)data;

/**
 @abstract
  Loads MediaHeader atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readMediaHeaderAtom:(IFBytesData *)data;

/**
 @abstract
  Loads composition time to sample atom from the input data.
 @param data
 @return the number of bytes which was being loaded.
 */
- (NSUInteger)readCompositionTimeToSampleAtom:(IFBytesData *)data;

@property (atomic, assign) NSUInteger read;

@end

@implementation MP4Atom

@synthesize size;
@synthesize type;
@synthesize children;
@synthesize version;
@synthesize flags;
@synthesize graphicsMode;
@synthesize opColorBlue;
@synthesize opColorGreen;
@synthesize opColorRed;
@synthesize records;
@synthesize samples;
@synthesize sampleSize;
@synthesize entryCount;
@synthesize read;
@synthesize width;
@synthesize height;
@synthesize avcLevel;
@synthesize avcProfile;
@synthesize videoConfigBytes;
@synthesize timeScale;
@synthesize channelCount;
@synthesize esdDescriptor;
@synthesize chunks;
@synthesize handlerType;
@synthesize timeToSamplesRecords;
@synthesize syncSamples;
@synthesize comptimeToSamplesRecords;

+ (MP4Atom *)createAtomFromData:(IFBytesData *)data {
  int64_t size = [data getInt32];
  if (size == 0) {
    return nil;
  }
  int type = [data getInt32];
  int read = 8;
  NSString *uuid = @"";
  
  // if atom is 'uuid' (extended atom type) read the uuid
  if (type == MKBETAG('u', 'u', 'i', 'd')) {
    uuid = [data getString:16];
    read += 16;
  }
  
  // large size
  if (size == 1) {
    size = [data getInt64];
    read += 8;
  }
  
  MP4Atom *atom = [[MP4Atom alloc] initWithType:type size:size uuid:uuid];
  NSLog(@"Atom: type = %@, size = %lld", [MP4Atom intToType:type], size);
  switch (type) {
    case MKBETAG('f', 't', 'y', 'p'): // ftyp - file identification
      read += [atom readIdentification:data];
      break;
    case MKBETAG('w', 'i', 'd', 'e'): // wide
      read += [atom readWide:data];
      break;
    case MKBETAG('m', 'o', 'o', 'v'): // moov
    case MKBETAG('t', 'r', 'a', 'k'): // trak
    case MKBETAG('m', 'd', 'i', 'a'): // mdia
    case MKBETAG('m', 'i', 'n', 'f'): // minf
    case MKBETAG('s', 't', 'b', 'l'): // stbl
    case MKBETAG('d', 'i', 'n', 'f'): // dinf
      read += [atom createCompositeAtom:data];
      break;
    case MKBETAG('m', 'v', 'h', 'd'): // mvhd
      read += [atom readMovieHeader:data];
      break;
    case MKBETAG('s', 't', 's', 'c'): // stsc
      read += [atom readSampleToChunkAtom:data];
      break;
    case MKBETAG('s', 't', 's', 'z'): // stsz
      read += [atom readSampleSizeAtom:data];
      break;
    case MKBETAG('s', 't', 'c', 'o'): // stco
      read += [atom readChunkOffsetStom:data];
      break;
    case MKBETAG('a', 'v', 'c', '1'): // avc1
      read += [atom readVideoSampleEntryAtom:data];
      break;
    case MKBETAG('a', 'v', 'c', 'C'): // avcC
      read += [atom readAvcConfigAtom:data];
      break;
    case MKBETAG('s', 't', 's', 'd'): // stsd
      read += [atom readSampleDescriptionAtom:data];
      break;
    case MKBETAG('e', 's', 'd', 's'): // esds
      read += [atom readEsdAtom:data];
      break;
    case MKBETAG('w', 'a', 'v', 'e'): // wave
      read += [atom readDecompressionParamAtom:data];
      break;
    case MKBETAG('m', 'p', '4', 'a'): // mp4a
      read += [atom readAudioSampleEntryAtom:data];
      break;
    case MKBETAG('h', 'd', 'l', 'r'): // hdlr
      read += [atom readHandlerAtom:data];
      break;
    case MKBETAG('s', 't', 't', 's'): // stts
      read += [atom readTimeToSampleAtom:data];
      break;
    case MKBETAG('s', 't', 's', 's'): // stss
      read += [atom readSyncSampleAtom:data];
      break;
    case MKBETAG('m', 'd', 'h', 'd'): // mdhd
      read += [atom readMediaHeaderAtom:data];
      break;
    case MKBETAG('c', 't', 't', 's'): // ctts
      read += [atom readCompositionTimeToSampleAtom:data];
      break;
  }
  
  // NSLog(@"Atom: type = %@, size = %lld", [MP4Atom intToType:type], size);
  [data skip:(int)size - read];
  return [atom autorelease];
}

- (id)initWithType:(int)aType size:(int64_t)aSize uuid:(NSString *)uuid {
  self = [super init];
  if (self) {
    size = aSize;
    type = aType;
    children = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [children release];
  if (records)
    [records release];
  if (samples)
    [samples release];
  if (timeToSamplesRecords)
    [timeToSamplesRecords release];
  [super dealloc];
}

+ (NSString *)intToType:(int)type {
  NSMutableString *st = [[NSMutableString alloc] init];
  unichar uc = (unichar)((type >> 24) & 0xff);
  [st appendString:[NSString stringWithCharacters:&uc length:1]];
  uc = (unichar)((type >> 16) & 0xff);
  [st appendString:[NSString stringWithCharacters:&uc length:1]];
  uc = (unichar)((type >> 8) & 0xff);
  [st appendString:[NSString stringWithCharacters:&uc length:1]];
  uc = (unichar)(type & 0xff);
  [st appendString:[NSString stringWithCharacters:&uc length:1]];
  return st;
}

- (NSUInteger)readIdentification:(IFBytesData *)data {
  NSLog(@"Major Brand%@ v%d", [data getString:4], [data getInt32]);
  return 8;
}

// this atom should be null (from specs), but some buggy files put the 'moov'
// atom inside it...
// like the files created with Adobe Premiere 5.0, for samples see
// http://graphics.tudelft.nl/~wouter/publications/soundtests/
- (NSUInteger)readWide:(IFBytesData *)data {
  if (size < 8) {
    return 0;
  }
  
  if ([data getInt32] != 0) {
    return 4;
  }
  
  type = [data getInt32];
  size -= 8;
  if (self.type != MKBETAG('m', 'd', 'a', 't')) {
    return -8;
  }
  return [self readMDat:data];
}

// this atom contains actual media data
- (NSUInteger)readMDat:(IFBytesData *)data {
  if (size == 0) { // wrong one (mp4) {
    return 0;
  }
  return 0;
}

- (NSUInteger)createCompositeAtom:(IFBytesData *)data {
   while (read + 8 < size) {
    MP4Atom *child = [MP4Atom createAtomFromData:data];
    if (child) {
      [children addObject:child];
      read += child.size;
    } else {
      break;
    }
  }
  return read;
}

- (NSUInteger)readMovieHeader:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];
  // Because we've already read 8 bytes for type and size
  if (size - read == 16) {
    graphicsMode = (int)[data getInt16];
    opColorRed = (int)[data getInt16];
    opColorGreen = (int)[data getInt16];
    opColorBlue = (int)[data getInt16];
  }
  return read;
}

- (NSUInteger)readSampleToChunkAtom:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];
  NSMutableArray *newRecords = [[NSMutableArray alloc] init];
  entryCount = [data getInt32];
  read += 4;
  for (int i = 0; i < entryCount; ++i) {
    MP4Record *r = [[MP4Record alloc] init];
    r.firstChunk = [data getInt32];
    r.samplePerChunk = [data getInt32];
    r.sampleDescription = [data getInt32];
    [newRecords addObject:r];
    [r release];
    read += 12;
  }
  
  self.records = newRecords;
  [newRecords release];
  return read;
}

- (NSUInteger)readSampleSizeAtom:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];
  NSMutableArray *newSamples = [[NSMutableArray alloc] init];
  sampleSize = (int)[data getInt32];
  int sampleCount = (int)[data getInt32];
  read += 8;
  if (sampleSize == 0) {
    for (int i = 0; i < sampleCount; i++) {
      int len = (int)[data getInt32];
      [newSamples addObject:[NSNumber numberWithInt:len]];
      read += 4;
    }
  }
  self.samples = newSamples;
  [newSamples release];
  return read;
}

- (NSUInteger)readAvcConfigAtom:(IFBytesData *)data {
  NSLog(@"AVC config");
  NSLog(@"Offset: %d", [data position]);
  NSUInteger configSize = (NSUInteger)size - 8; // We've alread read tag and size.
  // NSLog(@"AVCc: %@", [[NSData dataWithBytes:[data bytes] + [data position] length:configSize] hexString]);
  // store the decoder config bytes
  NSMutableData *newVideoConfigBytes =
        [[NSMutableData alloc] initWithCapacity:(NSUInteger)configSize];
  for (int b = 0; b < configSize; b++) {
    int8_t c = [data getInt8];
    [newVideoConfigBytes appendBytes:(char *)&c length:1];
    
    switch (b) {
        //0 / version
      case 1: //profile
        avcProfile = c;
        NSLog(@"AVC profile: %d", avcProfile);
        break;
      case 2: { //compatible profile {
        int avcCompatProfile = c;
        NSLog(@"AVC compatible profile: %d", avcCompatProfile);
        break;
      }
      case 3: //avc level
        avcLevel = c;
        NSLog(@"AVC level: %d", avcLevel);
        break;
      case 4: {// NAL length
        int nalLength = c;
        NSLog(@"NAL length: %d", nalLength);
        break;
      }
      case 5: { //SPS number
        int numberSPS = c;
        NSLog(@"Number of SPS: %d", numberSPS);
        break;
      }
      default:
        break;
    }
    read++;
  }
  self.videoConfigBytes = newVideoConfigBytes;
  [newVideoConfigBytes release];
  NSLog(@"copied AVCc: %@", [[NSData dataWithBytes:[videoConfigBytes bytes] length:[videoConfigBytes length]] hexString]);
  return read;
}

- (NSUInteger)readSampleDescriptionAtom:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];
  entryCount = (int)[data getInt32];
  NSLog(@"stsd entry count: %d", entryCount);
  read += 4;
  for (int i = 0; i < entryCount; ++i) {
    MP4Atom *child = [MP4Atom createAtomFromData:data];
    [children addObject:child];
    read += child.size;
  }
  return read;
}

- (NSUInteger)readVideoSampleEntryAtom:(IFBytesData *)data {
  NSLog(@"Video entry atom contains wxh");
  [data skip:6];
  int dataReferenceIndex = [data getInt16];
  [data skip:2];
  [data skip:2];
  [data skip:12];
  width = [data getInt16];
  NSLog(@"Width: %d", width);
  height = [data getInt16];
  NSLog(@"Height: %d", height);
  int horizontalRez = [data getInt32] >> 16;
  NSLog(@"H Resolution: %d", horizontalRez);
  int verticalRez = [data getInt32] >> 16;
  NSLog(@"V Resolution: %d", verticalRez);
  [data skip:4];
  int frameCount = [data getInt16];
  NSLog(@"Frame to sample count: %d", frameCount);
  int stringLen = [data getInt8];
  NSLog(@"String length (cpname): %d", stringLen);
  NSString *compressorName = [data getString:31];
  NSLog(@"Compressor name: %@", compressorName);
  int depth = [data getInt16];
  NSLog(@"Depth: %d", depth);
  [data skip:2];
  read += 78;
  NSLog(@"Bytes read: %ud", read);
  MP4Atom *child = [MP4Atom createAtomFromData:data];
  [children addObject:child];
  read += child.size;
  return read;
}

- (NSUInteger)readEsdAtom:(IFBytesData *)data {
  NSLog(@"Elementary stream descriptor atom");
  read += [self loadVeresionAndFlags:data];
  self.esdDescriptor = [MP4Descriptor createDescriptor:data];

  read += esdDescriptor.read;
  NSLog(@"Read for descriptor: %d", esdDescriptor.read);
  
  while (read < size) {
    MP4Atom *child = [MP4Atom createAtomFromData:data];
    [children addObject:child];
    read += child.size;
  }
  return read;
}

- (NSUInteger)loadVeresionAndFlags:(IFBytesData *)data {
  long value = [data getInt32];
  version = (int) value >> 24;
  flags = (int) value & 0xffffff;
  return 4;
}

- (NSUInteger)readDecompressionParamAtom:(IFBytesData *)data {
  NSLog(@"Decompression param");
  NSLog(@"%@", [NSData dataWithBytes:[data bytes] + [data position] length:size]);
  return read;
}

- (NSUInteger)readAudioSampleEntryAtom:(IFBytesData *)data {
  // qtff page 117
  NSLog(@"Audio sample entry");
  [data skip:6];
  int dataReferenceIndex = [data getInt16];
  version = [data getInt16]; // version
  NSLog(@"Sample description version: %d", version);
  [data skip:6];
  channelCount = [data getInt16];
  NSLog(@"Channels: %d", channelCount);
  sampleSize = [data getInt16];
  NSLog(@"Sample size (bits): %d", sampleSize);
  [data skip:4];
  timeScale = [data getInt16];
  NSLog(@"Time scale: %d", timeScale);
  [data skip:2];
  read += 28;
  // version 1 contains 4 additional fields
  if (version == 1) {
    int samplesPerPacket = [data getInt32];
    int bytesPerPacket = [data getInt32];
    int bytesPerFrame = [data getInt32];
    int bytesPerSample = [data getInt32];
    read += 16;
  }
  // version 2 contains 8 more
  if (version == 2) {
    // TODO add support for v2
  }
  MP4Atom *child = [MP4Atom createAtomFromData:data];
  [children addObject:child];
  read += child.size;
  NSLog(@"Child: %@", [MP4Atom intToType:child.type]);
  return read;
}

- (NSUInteger)readChunkOffsetStom:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];
  entryCount = [data getInt32];
  
  NSMutableArray *newChunks =
      [[NSMutableArray alloc] initWithCapacity:entryCount];
  read += 4;
  for (int i = 0; i < entryCount; i++) {
    long chunkOffset = [data getInt32];
    [newChunks addObject:[NSNumber numberWithLong:chunkOffset]];
    read += 4;
  }
     
  self.chunks = newChunks;
  [newChunks release];
  return read;
}

- (NSUInteger)readHandlerAtom:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];

  int qtComponentType = [data getInt32];
  handlerType = [data getInt32];
  int qtComponentManufacturer = [data getInt32];
  int qtComponentFlags = [data getInt32];
  int qtComponentFlagsMask = [data getInt32];
  read += 20;
  int length = (int) (size - read - 1);
  NSString *trackName = [data getString:length];
  NSLog(@"Track name: %@", trackName);
  read += length;

  return read;
}

- (NSUInteger)readTimeToSampleAtom:(IFBytesData *)data {
  NSLog(@"Time to sample atom");
  read += [self loadVeresionAndFlags:data];  
  NSMutableArray *newTimeToSampleRecords = [[NSMutableArray alloc] init];
  
  entryCount = [data getInt32];
  NSLog(@"Time to sample entries: %d", entryCount);
  read += 4;
  for (int i = 0; i < entryCount; i++) {
    int sampleCount = [data getInt32];
    int sampleDuration = [data getInt32];
    MP4TimeSampleRecord *r = [[MP4TimeSampleRecord alloc] init];
    r.sampleDuration = sampleDuration;
    r.consecutiveSamples = sampleCount;
    [newTimeToSampleRecords addObject:r];
    [r release];
    read += 8;
  }
  self.timeToSamplesRecords = newTimeToSampleRecords;
  [newTimeToSampleRecords release];
  return read;
}

- (NSUInteger)readSyncSampleAtom:(IFBytesData *)data {
  NSLog(@"Sync sample atom contains keyframe info");
  read += [self loadVeresionAndFlags:data];
  NSMutableArray *newSyncSamples = [[NSMutableArray alloc] init];
  entryCount = [data getInt32];
  NSLog(@"Sync entries: %d", entryCount);
  read += 4;
  for (int i = 0; i < entryCount; i++) {
    int sample = [data getInt32];
    [newSyncSamples addObject:[NSNumber numberWithInt:sample]];
    read += 4;
  }
  self.syncSamples = newSyncSamples;
  [newSyncSamples release];
  return read;
}

- (NSUInteger)readMediaHeaderAtom:(IFBytesData *)data {
  read += [self loadVeresionAndFlags:data];
  if (version == 1) {
    // creationTime = createDate([data getInt64]);
    // modificationTime = createDate([data getInt64]);
    [data skip:16];
    timeScale = [data getInt32];
    // duration = [data getInt64];
    [data skip:8];
    read += 28;
  } else {
    // creationTime = createDate([data getInt32]);
    // modificationTime = createDate([data getInt32]);
    [data skip:8];
    timeScale = [data getInt32];
    // duration = [data getInt32];
    [data skip:4];
    read += 16;
  }
  int packedLanguage = [data getInt16];
  int qtQuality = [data getInt16];
  read += 4;
  return read;
}

- (NSUInteger)readCompositionTimeToSampleAtom:(IFBytesData *)data {
  NSLog(@"Composition time to sample atom");
  read += [self loadVeresionAndFlags:data];
  NSMutableArray *newComptimeToSamplesRecords = [[NSMutableArray alloc] init];
                                                 
  entryCount = [data getInt32];
  NSLog(@"Composition time to sample entries: %d", entryCount);
  read += 4;
  for (int i = 0; i < entryCount; i++) {
    int sampleCount = [data getInt32];
    int sampleOffset = [data getInt32];
    MP4CompositionTimeSampleRecord *r =
        [[MP4CompositionTimeSampleRecord alloc] init];
    r.consecutiveSamples = sampleCount;
    r.sampleOffset = sampleOffset;
    [newComptimeToSamplesRecords addObject:r];
    [r release];
    read += 8;
  }
  self.comptimeToSamplesRecords = newComptimeToSamplesRecords;
  [newComptimeToSamplesRecords release];
  return read;
}

- (MP4Atom *)lookup:(long)aType number:(long)number {
  int position = 0;
  for (MP4Atom *atom in children) {
    if (atom.type == aType) {
      if (position >= number) {
        return atom;
      }
      position++;
    }
  }
  return nil;
}

@end
