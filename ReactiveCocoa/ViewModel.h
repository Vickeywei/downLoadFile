//
//  ViewModel.h
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/7.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RACSignal.h>
#import "RequestManager.h"
#import "Model.h"
@interface ListModel (CellHeight)
@property (nonatomic, assign) CGFloat cellHeight;
- (void)contentHeight;


@end
@interface ViewModel : NSObject
- (RACSignal *)requeData;
@end
