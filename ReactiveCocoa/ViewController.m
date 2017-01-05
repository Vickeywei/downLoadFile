//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by 魏琦 on 17/1/4.
//  Copyright © 2017年 com.drcacom.com. All rights reserved.
//

#import "ViewController.h"
#import "DownLoadManager.h"
#import <ReactiveCocoa.h>
@interface ViewController ()<DownLoadFileDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 80, 200, 200)];
    [self.view addSubview:imageView];
    DownLoadManager *manager = [[DownLoadManager alloc] init];
    
    NSString *cachePath=[[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"User"] stringByAppendingPathComponent:@"10086"];
    //rac下载小文件
    RACSignal *signal =  [manager downLoadFileWithUrl:@"http://42.121.255.86:6080/group1/M00/3E/E7/F_Wj2JzfU4nAMBFpTm.epub" parameters:nil filePath:cachePath];
    [signal subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        
    }] ;
    
//rac下载大文件
    RACSubject *subject = [RACSubject subject];
    
    manager.downLoadSubject = subject;
    
    [manager downLoadMaxFileWithUrl:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg" filePath:cachePath mimeType:@"dmg" fileName:@"1993" delegate:(id)self];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
       
        
    } error:^(NSError *error) {
        NSLog(@"%@",error);
        
    }];
    //使用句柄下载大文件
     [manager downLoadMaxFileWithUrl:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg" filePath:cachePath mimeType:@"dmg" fileName:@"1993" delegate:(id)self];
    //使用NSOutputStrem下载大文件
    [manager downLoadMaxFileWithUrl:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg" filePath:cachePath mimeType:@"dmg" fileName:@"1993" delegate:(id)self];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)downLoadFileProgress:(float)progress {
    NSLog(@"%f",progress);
}

- (void)downLoadFileFinshedFilePath:(NSString *)filePath {
    NSLog(@"%@",filePath);
}

- (void)downLoadFileError:(NSError *)error {
    NSDictionary *userInfo = error.userInfo;
    NSLog(@"%@",userInfo[NSLocalizedDescriptionKey]);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
