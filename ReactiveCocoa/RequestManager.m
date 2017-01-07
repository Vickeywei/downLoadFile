//
//  RequestManager.m
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/7.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import "RequestManager.h"
#import <AFNetworking.h>
#import <NSObject+YYModel.h>
@implementation RequestManager
+(instancetype)manager {
    static RequestManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RequestManager alloc] init];
    });
    return instance;
}

- (RACSignal *)requestJsonWithUrl:(NSString *)url ModelClass:(Class)modelClass{
   
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            id resultObject = responseObject;
            if ([resultObject isKindOfClass:[NSDictionary class]]) {
                NSObject * obj = [modelClass modelWithDictionary:responseObject];
                resultObject = obj;
            }
            else if ([resultObject isKindOfClass:[NSArray class]]) {
                NSArray *resultArray = resultObject;
                resultObject = [NSMutableArray array];
                for (NSDictionary *dic in resultArray) {
                    NSObject *obj = [modelClass modelWithDictionary:dic];
                    [resultObject addObject:obj];
                }
            }
            [subscriber sendNext:resultObject];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [subscriber sendCompleted];
        }];
    }];
    return signal;
}



@end
