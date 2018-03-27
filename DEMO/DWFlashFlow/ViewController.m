//
//  ViewController.m
//  DWFlashFlow
//
//  Created by Wicky on 2018/3/27.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWFlashFlow.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.fullURL = @"https://www.easy-mock.com/mock/5ab8d2273838ca14983dc100/zdwApi/test";
    r.requestCompletion = ^(BOOL success, id response, NSError *error, DWFlashFlowAbstractRequest *request) {
        
    };
    [r start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
