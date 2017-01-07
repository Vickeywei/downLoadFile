//
//  RequestManager.h
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/7.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
@interface RequestManager : NSObject
+ (instancetype)manager;
- (RACSignal *)requestJsonWithUrl:(NSString *)url ModelClass:(Class)modelClass;

@end
