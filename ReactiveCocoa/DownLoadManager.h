//
//  DownLoadManager.h
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/5.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

FOUNDATION_EXTERN NSInteger const KurlNotFoundErrorCode;
FOUNDATION_EXTERN NSInteger const KcreatFileSavePathFialure;
FOUNDATION_EXTERN NSInteger const KsaveDownloadFileFialure;

@class DownLoadManager;

@protocol DownLoadFileDelegate <NSObject>

/**
 下载出现错误

 @param error 错误信息
 */
- (void)downLoadFileError:(NSError*)error;

/**
 下载进度

 @param progress 下载进度
 */
- (void)downLoadFileProgress:(float)progress;

/**
 下载完成

 @param filePath 下载完后后文件保存的路径
 */
- (void)downLoadFileFinshedFilePath:(NSString*)filePath;
@end

@interface DownLoadManager : NSObject

@property (nonatomic, assign) id <DownLoadFileDelegate> delegate;
@property (nonatomic, strong) RACSubject *downLoadSubject;

/**
 利用NSURLSession小文件下载

 @param url 文件下载地址
 @param parameters 下载文件时的参数
 @param filePath 保存文件路径
 @return downLoadSignal
 */
- (RACSignal *)downLoadFileWithUrl:(id)url
                        parameters:(NSDictionary *)parameters
                          filePath:(NSString*)filePath;
/**
 利用NSURLConnect大文件下载

 @param url 下载地址
 @param filePath 保存路径
 @param mimeType 文件后缀
 @param fileName 文件名称
 @param delegate DownloadManager的代理对象
 */
- (void)downLoadMaxFileWithUrl:(id)url
                             filePath:(NSString *)filePath
                             mimeType:(NSString *)mimeType
                      fileName:(NSString*)fileName
                      delegate:(id <DownLoadFileDelegate>)delegate;
@end


