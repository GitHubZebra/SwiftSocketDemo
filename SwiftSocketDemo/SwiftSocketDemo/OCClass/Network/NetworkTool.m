//
//  NetworTool.m
//  Seller-iOS
//
//  Created by SKiNN on 16/1/12.
//  Copyright © 2016年 Zebra. All rights reserved.
//

#import "NetworkTool.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>
#import <UIKit/UIKit.h>
#import <JKit/JKit.h>
#import "JLoadingTool.h"


static NSString * const HintNetworkError = @"网络状况不佳\n请检查后再试";

static NSString * const HintNetworkNull = @"数据异常";

static const NSInteger SuccessCode = 222;

static const NSInteger NoLoginCode = 444;

static const NSInteger ErrorCode = 2003;

@interface NetworkTool (){
    
}

@property (nonatomic, assign) NSInteger time;


@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) SuccessBlock successBlock;
@property (nonatomic, strong) FailureBlock failureBlock;
@property (nonatomic, strong) ProgressBlock progressBlock;
@property (nonatomic, strong) ErrorBlock errorBlock;

@end

@implementation NetworkTool

+ (NSString *)getMianHttp{
    
    NSString *releaseHttp = @"http://www.heleyuezi.com/Yuehu/";
    
    NSString *testHttp = @"http://test.heleyuezi.com/Yuehu/";
    
    return testHttp;
}

#pragma mark -快速创建manager
+ (NetworkTool *)sharedClient {
   static NetworkTool *_sharedClient = nil;
   static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [NetworkTool manager];
        _sharedClient.requestSerializer.timeoutInterval = 10.0f;
        [_sharedClient setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [_sharedClient setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [[_sharedClient responseSerializer] setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg", nil]];
    });
    return _sharedClient;
}

#pragma mark -get请求
+ (void)Get:(NSString *)url parameters:(NSDictionary *)dic
           andProgress:(ProgressBlock)progressBlock
             andSucces:(SuccessBlock)successBlock
            andFailure:(FailureBlock)failureBlock
              andError:(ErrorBlock)errorBlock{
    
    NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
//    [mainDic setValuesForKeysWithDictionary:[NetworkTool getTokenDic]];
    [mainDic setValuesForKeysWithDictionary:dic];
    NetworkTool *manager = [NetworkTool manager];
    manager.successBlock = successBlock;
    manager.failureBlock = failureBlock;
    manager.progressBlock = progressBlock;
    manager.errorBlock = errorBlock;
    
    [manager getRequestWithUrl:url andParameters:mainDic];
}

- (void)getRequestWithUrl:(NSString *)url andParameters:(NSDictionary *)dic{
    JLog(@"************baseUrl************\n%@\n\n************parameters************\n%@\n",url,dic);
    NSString *encoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self GET:encoded parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        JLog(@"%f", (CGFloat)downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self analysisData:responseObject];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *title;
        if([self networkReachability]){
            title = HintNetworkNull;
        }else{
            title = @"糟糕！网络连接失败";
        }
        JBlock(_errorBlock, HintNetworkError);
    }];

}


#pragma mark -post请求
+ (void)Post:(NSString *)url parameters:(NSDictionary *)dic
            andProgress:(ProgressBlock)progressBlock
              andSucces:(SuccessBlock)successBlock
             andFailure:(FailureBlock)failureBlock
               andError:(ErrorBlock)errorBlock{

    NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
//    [mainDic setValuesForKeysWithDictionary:[NetworkTool getTokenDic]];
    [mainDic setValuesForKeysWithDictionary:dic];
    NetworkTool *manager = [NetworkTool manager];
    manager.successBlock = successBlock;
    manager.failureBlock = failureBlock;
    manager.progressBlock = progressBlock;
    manager.errorBlock = errorBlock;
    
    [manager postRequestWithUrl:url andParameters:mainDic];
    
    

}

- (void)postRequestWithUrl:(NSString *)url  andParameters:(NSDictionary *)dic{
    
    JLog(@"---------------------------------->\n************baseUrl************\n%@\n\n************parameters************\n%@\n\n************url************\n%@%@\n<----------------------------------",url,dic,url,[dic j_urlValue]);
    
    NSString *encoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[NetworkTool sharedClient] POST:encoded parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        JLog(@"%f", (CGFloat)uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [self analysisData:responseObject];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *title;
        if([self networkReachability]){
            title = HintNetworkNull;
        }else{
            title = @"糟糕！网络连接失败";
        }
//        [JLoadingTool j_stopLoading];
        JBlock(_errorBlock, HintNetworkError);
    }];
}

#pragma mark -post上传图片
+ (void)Post:(NSString *)url parameters:(NSDictionary *)dic
             uploadImage:(id)images
                    size:(CGSize)size
                  sizeKB:(CGFloat)sizeKB
             andProgress:(ProgressBlock)progressBlock
               andSucces:(SuccessBlock)successBlock
              andFailure:(FailureBlock)failureBlock
                andError:(ErrorBlock)errorBlock {

    
    NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
//    [mainDic setValuesForKeysWithDictionary:[NetworkTool getTokenDic]];
    [mainDic setValuesForKeysWithDictionary:dic];
    NetworkTool *manager = [NetworkTool manager];
    manager.successBlock = successBlock;
    manager.failureBlock = failureBlock;
    manager.progressBlock = progressBlock;
    manager.errorBlock = errorBlock;
    
    if (![images isKindOfClass:[NSArray class]] && images) {
        images = @[images];
    }
    
    [manager postRequestWithUrl:url andParameters:mainDic loadingImage:images size:size sizeKB:sizeKB];
}
- (void)postRequestWithUrl:(NSString *)url
             andParameters:(NSDictionary *)dic
              loadingImage:(NSArray *)images
                      size:(CGSize)size
                    sizeKB:(CGFloat)sizeKB {
    
    JLog(@"************baseUrl************\n%@\n\n************parameters************\n%@\n\n************url************\n%@%@\n",url,dic,url,[dic j_urlValue]);
    NSString *encoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NetworkTool sharedClient] POST:encoded parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        int i = 0;
        NSString *imgKey;
        //根据当前系统时间生成图片名称
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *dateString = [formatter stringFromDate:date];
        
        for (UIImage *image in images) {
            
            i++;
            imgKey = [NSString stringWithFormat:@"picture%d",i];
            NSString *fileName;
            NSData *imageData;
            if (sizeKB) {
                fileName = [NSString stringWithFormat:@"%@%d.jpg",dateString,i];
                if (size.height) {
                    UIImage *img = [image j_imageWithscaledToSize:size];
                    imageData = (NSData *)[img j_pressImageWithLessThanSizeKB:sizeKB];
                }else{
                    imageData = (NSData *)[image j_pressImageWithLessThanSizeKB:sizeKB];
                }
            }else{
                fileName = [NSString stringWithFormat:@"%@%d.png",dateString,i];
                imageData = UIImagePNGRepresentation(image);
            }
            
            [formData appendPartWithFileData:imageData name:imgKey fileName:fileName mimeType:@"image/jpg/png/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        JLog(@"%f", (CGFloat)uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self analysisData:responseObject];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *title;
        if([self networkReachability]){
            title = HintNetworkNull;
        }else{
            title = @"糟糕！网络连接失败";
        }
        
//        [JLoadingTool j_stopLoading];

        JBlock(_errorBlock, HintNetworkError);
    }];
}

#pragma mark -post上传文件
+ (void)Post:(NSString *)url parameters:(NSDictionary *)dic
  uploadingMp3Url:(NSURL *)mp3Url
 andProgress:(ProgressBlock)progressBlock
   andSucces:(SuccessBlock)successBlock
  andFailure:(FailureBlock)failureBlock
    andError:(ErrorBlock)errorBlock {
    
    
    NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
    //    [mainDic setValuesForKeysWithDictionary:[NetworkTool getTokenDic]];
    [mainDic setValuesForKeysWithDictionary:dic];
    NetworkTool *manager = [NetworkTool manager];
    manager.successBlock = successBlock;
    manager.failureBlock = failureBlock;
    manager.progressBlock = progressBlock;
    manager.errorBlock = errorBlock;
    
    [manager postRequestWithUrl:url andParameters:mainDic uploadingMp3Url:mp3Url];
}

- (void)postRequestWithUrl:(NSString *)url
             andParameters:(NSDictionary *)dic
              uploadingMp3Url:(NSURL *)mp3Url {
    
    JLog(@"************baseUrl************\n%@\n\n************parameters************\n%@\n\n************url************\n%@%@\n",url,dic,url,[dic j_urlValue]);
    NSString *encoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NetworkTool sharedClient] POST:encoded parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        //根据当前系统时间生成图片名称
        NSDate *date = [NSDate date];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        
        NSString *dateString = [formatter stringFromDate:date];
        
        [formData appendPartWithFileURL:mp3Url name:@"video" fileName:@"video.mp3" mimeType:@"audio/mpeg3" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        JLog(@"%f", (CGFloat)uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self analysisData:responseObject];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *title;
        if([self networkReachability]){
            title = HintNetworkNull;
        }else{
            title = @"糟糕！网络连接失败";
        }
        
//        [JLoadingTool j_stopLoading];
        
        JBlock(_errorBlock, HintNetworkError);
    }];
}


- (void)analysisData:(id  _Nullable)responseObject {
    
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

    
    JLog(@"************responseObject************\n%@\n",[dic j_description]);
    
    
//    if ([[dic objectForKey:@"code"] integerValue] == NoLoginCode) {
//        [self alertViewWithMessage:(NSString *)[dic j_objectForKey:@"message"]];
//        [JLoadingTool j_stopLoading];
//        return ;
//    }
    
    if ([[dic objectForKey:@"code"] integerValue] == ErrorCode) {
        [JLoadingTool j_showInfoWithStatus:(NSString *)[dic j_objectForKey:@"message"]];
        return ;
    }
    
    if ([[dic objectForKey:@"code"] integerValue] == SuccessCode) {
        JBlock(self.successBlock, dic);
    }else{
        
        if (JIsEmpty([dic objectForKey:@"message"])) {
            [dic setValue:@"数据异常" forKey:@"message"];
        }
        JBlock(self.failureBlock, dic);
    }
}



#pragma mark -判断网络是否可用
- (BOOL)networkReachability
{
    struct sockaddr_in initAddress;
    bzero(&initAddress, sizeof(initAddress));
    initAddress.sin_len = sizeof(initAddress);
    initAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef readRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&initAddress);
    SCNetworkReachabilityFlags flags;
    BOOL getRetrieveFlags = SCNetworkReachabilityGetFlags(readRouteReachability, &flags);
    CFRelease(readRouteReachability);
    
    if (!getRetrieveFlags) {
        return NO;
    }
    
    BOOL flagsReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    
    return (flagsReachable && !connectionRequired) ? YES : NO;
}

@end

