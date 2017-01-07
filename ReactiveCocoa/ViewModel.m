//
//  ViewModel.m
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/7.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import "ViewModel.h"
#import <objc/runtime.h>


@implementation ListModel (CellHeight)

- (void)contentHeight {
    //加入文本是:一下这些
    NSString *content = @"编程思想上的一些改变。原创的一个可能也不大恰当的比喻：原来的编程思想像是“走迷宫”，RAC的编程思想是“建迷宫”。意思是，之前的编程思路是命令式，大概都是“程序启动时执行xxxx，在用户点击后的回调函数执行xxx，收到一个Notification后执行xxx”等等，如同走迷宫一样，走出迷宫需要在不同时间段记住不同状态根据不同情况而做出一系列反应，继而走出迷宫；相比下，RAC的思想是建立联系，像钟表中的齿轮组一样，一个扣着一个，从转动发条到指针走动，一个齿轮一个齿轮的传导（Reactive），复杂但完整而自然。如同迷宫的建造者，在设计时早已决定了哪里是通路，哪里是死路或是哪个路口指向了出口，当一个挑战者（Event）走入迷宫时（Signal），他一定会在设置好的迷宫中的某个路线行走（传递），继而走到终点（Completion）或困死在里面（Error）。";
    
    
    //现在计算这个文本的高度并返回字体大小用默认字体大小"
    CGRect rect  = [content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width,80) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:[UIFont systemFontSize] weight:18]} context:nil];
    self.cellHeight = rect.size.height;
}


static char height;

- (void)setCellHeight:(CGFloat)cellHeight {
    
    objc_setAssociatedObject(self, &height, @(cellHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)cellHeight {
    NSNumber *number = objc_getAssociatedObject(self, &height);
    return number.floatValue;
}


@end
@implementation ViewModel
- (RACSignal *)requeData{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RequestManager *manager = [RequestManager manager];
        [[manager requestJsonWithUrl:@"http://c.m.163.com/nc/topicset/ios/subscribe/manage/listspecial.html" ModelClass:[Model class]]subscribeNext:^(id x) {
            //这里可以将model进行处理,例如时间戳转换,计算cell高度等
            Model *model = x;
            for (ListModel *list in model.tList) {
                [list contentHeight];
            }
            [subscriber sendNext:model];
            [subscriber sendCompleted];
            
            
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [subscriber sendCompleted];
        }];
    }];
    return signal;
   
}
@end


