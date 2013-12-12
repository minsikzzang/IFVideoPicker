//
//  FLVVideoTag.h
//  protos
//
//  Created by Min Kim on 10/18/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLVTag.h"

@interface FLVVideoTag : FLVTag

@property (atomic, assign) int frameType;
@property (atomic, assign) int codecId;
@property (atomic, assign) int packetType;
@property (atomic, retain) NSData *body;
@property (atomic, assign) int cts;

@end
