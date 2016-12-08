//
//  ConventToMp3Tool.h
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/21.
//  Copyright © 2016年 Zebra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface ConventToMp3Tool : NSObject

+ (void)conventToMp3WithPath:(NSString *)path andRecorder:(AVAudioRecorder *)recorder;

@end
