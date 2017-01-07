//
//  DownLoadManager.m
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/5.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import "DownLoadManager.h"
NSInteger const KurlNotFoundErrorCode  = 6004;
NSInteger const KcreatFileSavePathFialure = 5004;
NSInteger const KsaveDownloadFileFialure = 4004;

@interface DownLoadManager ()<NSURLConnectionDataDelegate>
@end
@implementation DownLoadManager
{
    RACSignal *_downLoadSignal;
    NSURLConnection *_downLoadConnect;
    NSOutputStream *_outPutStrem;
    NSString *_cacheFilePath;
    NSString *_mimeType;
    NSString *_fileName;
    long long _totalLength;
    long long _currentLegth;
    NSFileHandle *_fileHandle;
    
}
- (RACSignal *)downLoadFileWithUrl:(id)url parameters:(NSDictionary *)parameters filePath:(NSString*)filePath{
    __block NSError *error;
    __block NSURL *baseUrl;
    _downLoadSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (url == (id)kCFNull) {
            error = [NSError errorWithDomain:NSURLErrorDomain code:KurlNotFoundErrorCode userInfo:@{NSLocalizedDescriptionKey :@"url为空"}];
            [subscriber sendError:error];
        }
        else if ([url isKindOfClass:[NSURL class]]) {
            baseUrl = url;
        }
        else if ([url isKindOfClass:[NSString class]]){
            baseUrl = [NSURL URLWithString:url];
        }
        NSURLSession * session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:baseUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscriber sendError:error];
                });
            }
            else {
                if (filePath) {
                    NSFileManager *manager = [NSFileManager defaultManager];
                    
                    if (![manager fileExistsAtPath:filePath]) {
                       BOOL creatResult = [manager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
                        if (creatResult) {
                            NSLog(@"creat file save path success");
                        }
                        else {
                            error = [NSError errorWithDomain:NSURLErrorDomain code:KcreatFileSavePathFialure userInfo:@{NSLocalizedDescriptionKey :@"创建保存文件目录失败"}];
                            [subscriber sendError:error];
                        }
                    }
                    NSString *savePath =[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",response.suggestedFilename]];
                    NSURL *saveUrl=[NSURL fileURLWithPath:savePath];
                    BOOL saveResult = [manager createFileAtPath:saveUrl.path contents:[NSData dataWithContentsOfURL:location] attributes:nil];
                    if (saveResult) {
                        NSLog(@"save sucess.");
                    }else{
                        error = [NSError errorWithDomain:NSURLErrorDomain code:KsaveDownloadFileFialure userInfo:@{NSLocalizedDescriptionKey :@"保存下载文件失败"}];
                        [subscriber sendError:error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [subscriber sendNext:saveUrl];
                        [subscriber sendCompleted];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [subscriber sendNext:location];
                        [subscriber sendCompleted];
                    });
                }
            }
        }];
        [task resume];
        return [RACDisposable disposableWithBlock:^{
            if (task.state != NSURLSessionTaskStateCompleted) {
                [task cancel];
            }
        }];
    }];
    
   
    return _downLoadSignal;
}

- (void)downLoadMaxFileWithUrl:(id)url
                      filePath:(NSString *)filePath
                      mimeType:(NSString *)mimeType
                      fileName:(NSString*)fileName
                      delegate:(id <DownLoadFileDelegate>)delegate{
    _cacheFilePath = filePath;
    _mimeType = mimeType;
    _fileName = fileName;
    self.delegate = delegate;
    NSURL *baseUrl;
    //判断文件下载地址
    if (url == (id)kCFNull) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:KurlNotFoundErrorCode userInfo:@{NSLocalizedDescriptionKey :@"文件地址不存在"}];
        if (self.delegate) {
            [self.delegate downLoadFileError:error];
        }
    }
    else if ([url isKindOfClass:[NSURL class]]) {
        baseUrl = url;
    }
    else if ([url isKindOfClass:[NSString class]]){
        baseUrl = [NSURL URLWithString:url];
    }
    //创建request
    NSURLRequest *request = [NSURLRequest requestWithURL:baseUrl];
    //利用request创建connect,并设置代理对象
    _downLoadConnect = [NSURLConnection connectionWithRequest:request delegate:self];
}
/* 使用delegate下载
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [_outPutStrem write:[data bytes] maxLength:data.length];
//    _currentLegth += data.length;
//    float downLoadProgress = (float) _currentLegth / _totalLength;
//    if (self.delegate) {
//        [self.delegate downLoadFileProgress:downLoadProgress];
//    }
//    
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
//    if (response.statusCode != 200) {
//        [_downLoadConnect cancel];
//        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:@"请求错误"}];
//        if (self.delegate) {
//            [self.delegate downLoadFileError:error];
//        }
//    }
//    else {
//        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheFilePath]) {
//            BOOL creatResult = [[NSFileManager defaultManager] createDirectoryAtPath:_cacheFilePath withIntermediateDirectories:YES attributes:nil error:nil];
//            if (creatResult) {
//                _cacheFilePath = [_cacheFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_fileName,_mimeType]];
//            }
//            else {
//               NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:KcreatFileSavePathFialure userInfo:@{NSLocalizedDescriptionKey :@"创建保存文件目录失败"}];
//                [self.delegate downLoadFileError:error];
//            }
//            
//        }
//        else {
//            _cacheFilePath = [_cacheFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_fileName,_mimeType]];
//        }
//        _outPutStrem = [[NSOutputStream alloc] initToFileAtPath:_cacheFilePath append:YES];
//        [_outPutStrem scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//        [_outPutStrem open];
//        _totalLength = response.expectedContentLength;
//    }
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    [connection cancel];
//    [_outPutStrem close];
//    if (![NSThread isMainThread]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.delegate) {
//                [self.delegate downLoadFileFinshedFilePath:_cacheFilePath];
//            }
//        });
//    }
//    else {
//        if (self.delegate) {
//            [self.delegate downLoadFileFinshedFilePath:_cacheFilePath];
//        }
//    }
//}

*/

////使用RACSubject代替代理进行下载
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    //将数据流写入文件
//    [_outPutStrem write:[data bytes] maxLength:data.length];
//    //计算文件的下载进度
//    _currentLegth += data.length;
//    float downLoadProgress = (float) _currentLegth / _totalLength;
//    [self.downLoadSubject sendNext:[NSNumber numberWithFloat:downLoadProgress]];
//    
//
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
//    //判断当response的状态值不是200时提示错误
//    if (response.statusCode != 200) {
//        [_downLoadConnect cancel];
//        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:@"请求错误"}];
//         [self.downLoadSubject sendError:error];
//    }
//    else {
//        //判断保存文件路径是否已经创建,如果没有则创建
//        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheFilePath]) {
//            BOOL creatResult = [[NSFileManager defaultManager] createDirectoryAtPath:_cacheFilePath withIntermediateDirectories:YES attributes:nil error:nil];
//            if (creatResult) {
//                _cacheFilePath = [_cacheFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_fileName,_mimeType]];
//            }
//            else {
//               NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:KcreatFileSavePathFialure userInfo:@{NSLocalizedDescriptionKey :@"创建保存文件目录失败"}];
//                [self.downLoadSubject sendError:error];
//            }
//
//        }
//        else {
//            _cacheFilePath = [_cacheFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_fileName,_mimeType]];
//        }
//        //创建NSOutputStrem流对象,如果append设置为YES表示流数据会拼接到文件尾部.
//        _outPutStrem = [[NSOutputStream alloc] initToFileAtPath:_cacheFilePath append:YES];
//        //设置outputStrem对象的Runloop的Mode
//        [_outPutStrem scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//        //打开数据流
//        [_outPutStrem open];
//        //计算文件总大小
//        _totalLength = response.expectedContentLength;
//    }
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    //取消网络请求
//    [connection cancel];
//    //关闭数据流
//    [_outPutStrem close];
//    //判断是否主线程
//    if (![NSThread isMainThread]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.downLoadSubject sendNext:_cacheFilePath];
//            [self.downLoadSubject sendCompleted];
//        });
//    }
//    else {
//        
//            [self.downLoadSubject sendNext:_cacheFilePath];
//            [self.downLoadSubject sendCompleted];
//    }
//}

//使用句柄来进行文件下载并保证内存问题
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    _currentLegth += data.length;
    float downLoadProgress = (float) _currentLegth / _totalLength;
    if (self.delegate) {
        [self.delegate downLoadFileProgress:downLoadProgress];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    if (response.statusCode != 200) {
        [_downLoadConnect cancel];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:@"请求错误"}];
        if (self.delegate) {
            [self.delegate downLoadFileError:error];
        }
    }
    else {
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheFilePath]) {
            BOOL creatResult = [[NSFileManager defaultManager] createDirectoryAtPath:_cacheFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            if (creatResult) {
                _cacheFilePath = [_cacheFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_fileName,_mimeType]];
            }
            else {
               NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:KcreatFileSavePathFialure userInfo:@{NSLocalizedDescriptionKey :@"创建保存文件目录失败"}];
                [self.delegate downLoadFileError:error];
            }

        }
        else {
            _cacheFilePath = [_cacheFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_fileName,_mimeType]];
        }
        [[NSFileManager defaultManager] createFileAtPath:_cacheFilePath contents:nil attributes:nil];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_cacheFilePath];
        _totalLength = response.expectedContentLength;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection cancel];
    [_outPutStrem close];
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate) {
                [self.delegate downLoadFileFinshedFilePath:_cacheFilePath];
            }
        });
    }
    else {
        if (self.delegate) {
            [self.delegate downLoadFileFinshedFilePath:_cacheFilePath];
        }
    }
}



@end
