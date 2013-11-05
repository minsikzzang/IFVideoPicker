//
//  FLVHeader.h
//  protos
//
//  Created by Min Kim on 10/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLVHeader : NSObject

@property (atomic, assign) BOOL flagAudio;
@property (atomic, assign) BOOL flagVideo;
@property (atomic, assign) Byte version;

- (NSData *)write;
- (NSString *)toString;

@end
