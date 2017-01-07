//
//  Model.h
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/7.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import <NSObject+YYModel.h>

@interface Model : NSObject
@property (nonatomic, strong) NSArray *tList;
@end

@interface ListModel : NSObject
@property (nonatomic, strong) NSString *templateName;
@property (nonatomic, strong) NSString *topicid;
@property (nonatomic, assign) NSInteger hasCover;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *subnum;
@property (nonatomic, assign) NSInteger recommendOrder;
@property (nonatomic, assign) NSInteger isNew;
@property (nonatomic, assign) NSInteger hashead;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, assign) NSInteger isHot;
@property (assign, nonatomic) NSInteger hasIcon;
@property (nonatomic, strong) NSString *cid;
@property (nonatomic, strong) NSString *recommend;
@property (nonatomic, assign) NSInteger headLine;
@property (nonatomic, assign) NSInteger hasAD;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *tname;
@property (assign, nonatomic) NSInteger bannerOrder;
@property (nonatomic, strong) NSString *ename;
@property (nonatomic, strong) NSString *showType;
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, assign) NSInteger special;
@property (nonatomic, assign) NSInteger ad_type;
@end
