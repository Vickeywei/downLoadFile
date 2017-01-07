//
//  Model.m
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/7.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import "Model.h"

@implementation Model
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"tList" : [ListModel class]
             
             };
}
@end

@implementation ListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"templateName" : @"template"
             
             };
}
@end
