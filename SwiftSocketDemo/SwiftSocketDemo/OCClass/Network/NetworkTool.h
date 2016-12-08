//
//  NetworTool.h
//  Seller-iOS
//
//  Created by SKiNN on 16/1/12.
//  Copyright © 2016年 Zebra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


#define MainHttp [NetworkTool getMianHttp]


/**
 *  @param progressValue 进度Block
 *  @param successValue  成功Block
 *  @param failureValue  失败Block
 *  @param errorValue    错误Block
 */
typedef void(^ProgressBlock)(id progressValue);
typedef void(^SuccessBlock)(id successValue);
typedef void(^FailureBlock)(id failureValue);
typedef void(^ErrorBlock)(id errorValue);

@interface NetworkTool : AFHTTPSessionManager

/**
 *  创建 AFHTTPSessionManager
 *
 *  @return manager
 */
+ (instancetype)sharedClient;

/**
 *  获取主url
 *
 *  @return http
 */
+ (NSString *)getMianHttp;

/**
 *  afnetworking get 请求方法
 *
 *  @param url           url
 *  @param dic           parameters
 *  @param progressBlock 进度
 *  @param successBlock  成功 code == 1
 *  @param failureBlock       失败 code == 0
 *  @param errorBlock    错误
 */
+ (void)Get:(NSString *)url parameters:(NSDictionary *)dic
           andProgress:(ProgressBlock)progressBlock
             andSucces:(SuccessBlock)successBlock
            andFailure:(FailureBlock)failureBlock
              andError:(ErrorBlock)errorBlock;

/**
 *  afnetworking post 请求方法
 *
 *  @param url           url
 *  @param dic           parameters
 *  @param progressBlock 进度
 *  @param successBlock  成功 code == 1
 *  @param failureBlock       失败 code == 0
 *  @param errorBlock    错误
 */
+ (void)Post:(NSString *)url parameters:(NSDictionary *)dic
            andProgress:(ProgressBlock)progressBlock
              andSucces:(SuccessBlock)successBlock
             andFailure:(FailureBlock)failureBlock
               andError:(ErrorBlock)errorBlock;

/**
 *  afnetworking post 上传图片
 *
 *  @param url           url
 *  @param dic           parameters
 *  @param images        需要上传的图片 单张图片/图片数组
 *  @param size          图片大小 CGSize  长宽
 *  @param sizeKB        图片大小 Kb
 *  @param progressBlock 进度
 *  @param successBlock  成功 code == 1
 *  @param failureBlock  失败 code == 0
 *  @param errorBlock    错误
 */
+ (void)Post:(NSString *)url parameters:(NSDictionary *)dic
             uploadImage:(id)images
                    size:(CGSize)size
                  sizeKB:(CGFloat)sizeKB
             andProgress:(ProgressBlock)progressBlock
               andSucces:(SuccessBlock)successBlock
              andFailure:(FailureBlock)failureBlock
                andError:(ErrorBlock)errorBlock;

#pragma mark -post音频
+ (void)Post:(NSString *)url parameters:(NSDictionary *)dic
uploadingMp3Url:(NSURL *)mp3Url
 andProgress:(ProgressBlock)progressBlock
   andSucces:(SuccessBlock)successBlock
  andFailure:(FailureBlock)failureBlock
    andError:(ErrorBlock)errorBlock;


@end

