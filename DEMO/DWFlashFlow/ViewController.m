//
//  ViewController.m
//  DWFlashFlow
//
//  Created by Wicky on 2018/3/27.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWFlashFlow.h"
#import "DWFlashFlowCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self singleRequest];
//    [self addRequestDependency];
//    [self batchRequest];
//    [self requestChain];
    [self requestCache];
}

-(void)singleRequest {
    DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    };
    [r start];
}

-(void)requestCache {
    DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.cachePolicy = DWFlashFlowCachePolicyLocalElseLoad;
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    };
    [r start];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self requestCache];
}

-(void)addRequestDependency {
    DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    };
    NSBlockOperation * bP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"The request complete.");
    }];
    
    [bP addDependency:r];
    [[NSOperationQueue new] addOperations:@[bP,r] waitUntilFinished:NO];
}

-(void)sendWithManager {
    DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"completion");
    };
    [DWFlashFlowManager sendRequest:r completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"finish");
    }];
}

-(void)batchRequest {
    DWFlashFlowRequest * r1 = [DWFlashFlowRequest new];
    r1.cachePolicy = DWFlashFlowCachePolicyLocalOnly;
    r1.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r1.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r1 finish");
    };
    DWFlashFlowRequest * r2 = [DWFlashFlowRequest new];
    r2.fullURL = @"http://ozi0yn414.bkt.clouddn.com/MKJ-Time.mp3";
    r2.requestProgress = ^(NSProgress *progress) {
        NSLog(@"%@",progress);
    };
    r2.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r2 finish");
    };
    r2.requestType = DWFlashFlowRequestTypeDownload;
    DWFlashFlowBatchRequest * bR = [[DWFlashFlowBatchRequest alloc] initWithRequests:@[r1,r2]];
    [DWFlashFlowManager sendRequest:bR completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    }];
}

-(void)requestChain {
    DWFlashFlowRequest * r1 = [DWFlashFlowRequest new];
    r1.cachePolicy = DWFlashFlowCachePolicyLocalOnly;
    r1.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r1.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r1 finish");
    };
    DWFlashFlowRequest * r2 = [DWFlashFlowRequest new];
    r2.fullURL = @"http://ozi0yn414.bkt.clouddn.com/MKJ-Time.mp3";
    r2.requestProgress = ^(NSProgress *progress) {
        NSLog(@"%@",progress);
    };
    r2.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"r2 finish");
    };
    r2.requestType = DWFlashFlowRequestTypeDownload;
    DWFlashFlowChainRequest * cR = [[DWFlashFlowChainRequest alloc] initWithRequests:@[r1,r2]];
    [DWFlashFlowManager sendRequest:cR completion:^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        NSLog(@"%@",response);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
