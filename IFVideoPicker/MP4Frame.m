//
//  MP4Frame.m
//  protos
//
//  Created by Min Kim on 10/12/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "MP4Frame.h"

@implementation MP4Frame

@synthesize size;
@synthesize offset;
@synthesize timestamp;
@synthesize type;
@synthesize keyFrame;
@synthesize timeOffset;

- (NSComparisonResult)compareMP4Frame:(MP4Frame *)otherObject {
  if (timestamp > otherObject.timestamp) {
    return 1;
  } else if (timestamp < otherObject.timestamp) {
    return -1;
  } else if (timestamp == otherObject.timestamp && offset > otherObject.offset) {
    return 1;
  } else if (timestamp == otherObject.timestamp && offset < otherObject.offset) {
    return -1;
  }
  
  return 0;
}

@end
