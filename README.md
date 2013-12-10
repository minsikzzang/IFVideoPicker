# IFVideoPicker

Library iOS video picker using AVCapturexxxx libraries

## Features

- 264 / AAC video and audio hardware accelerated encoding
- return mp4 frames
- including flv packetizer

## Getting Started

### Install the Prerequisites

* OS X is requried for all iOS development
* [XCODE](https://developer.apple.com/xcode/) from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12).
* [GIT](http://git-scm.com/download/mac) is required.
* [CocoaPods](http://beta.cocoapods.org/) is required for the iOS dependency management. You should have [ruby](http://www.interworks.com/blogs/ckaukis/2013/03/05/installing-ruby-200-rvm-and-homebrew-mac-os-x-108-mountain-lion) installed on your machine before install CocoaPods

### Install the library

Source code for the SDK is available on [GitHub](git@github.com:ifactorylab/IFVideoPicker.git)
```
$ git clone git@github.com:ifactorylab/IFVideoPicker.git
```

### Run CocoaPods

CocoaPods installs all dependencies for the library project
```
$ cd IFVideoPicker
$ pods install
$ open IFVideoPicker.xcodeproj
```

### Add IFVideoPicker to your project

Create a Podfile if not exist, add the line below
```
pod 'IFVideoPicker',   '~> 1.0.2'
```

### Demo

IFVideoPickerDemo demonstrates how the library works.

### Capture video
```
#import "IFVideoPicker.h"
#import "MP4Reader.h"

// Create Audio AAC codec with 64kbps and samplerate 44100
IFAudioEncoder *ae = 
  [IFAudioEncoder createAACAudioWithBitRate:64000 sampleRate:44100];
    
// Create Video H264 codec with 500kbps and 512x288
CMVideoDimensions dimensions;
dimensions.width = 512;
dimensions.height = 288;

IFVideoEncoder *ve =
  [IFVideoEncoder createH264VideoWithDimensions:dimensions
                                        bitRate:500000
                                    maxKeyFrame:200];
                                    
[videoPicker_ startCaptureWithEncoder:ve
                                audio:ae
                         captureBlock:^(NSArray *frames, NSData *buffer) {
                        // Captured MP4 frames are coming
                        NSLog(@"buffer: %d bytes, with %d frames", [buffer length], [frames count]);
                    } metaHeaderBlock:^(MP4Reader *reader) {}
                        // MP4 moov header coming
                       } failureBlock:^(NSError *error) {
                        // Failed to capture video / audio chunk
                    }];
                                      
```

## Contact

minsikzzang@gmail.com
