//
//  FLVAudioTag.h
//  protos
//
//  Created by Min Kim on 10/18/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLVTag.h"

@interface FLVAudioTag : FLVTag

@property (atomic, assign) int soundFormat;
@property (atomic, assign) int soundRate;
@property (atomic, assign) int soundSize;
@property (atomic, assign) int packetType;
@property (atomic, assign) int soundType;
@property (atomic, retain) NSData *body;

@end
