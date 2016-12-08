//
//  ConventToMp3Tool.m
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/21.
//  Copyright © 2016年 Zebra. All rights reserved.
//

#import "ConventToMp3Tool.h"
#include "lame.h"

@implementation ConventToMp3Tool

+ (void)conventToMp3WithPath:(NSString *)path andRecorder:(AVAudioRecorder *)recorder {
    
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    NSString *mp3FilePath = [path stringByAppendingString:@".mp3"];
    
    NSLog(@"%@",mp3FilePath);
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([path cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
//        self.audioFileSavePath = mp3FilePath;
//        NSLog(@"MP3生成成功: %@",self.audioFileSavePath);
    }

}




@end
