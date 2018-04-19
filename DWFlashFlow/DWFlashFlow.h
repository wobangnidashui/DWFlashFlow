//
//  DWFlashFlow.h
//  DWFlashFlow
//
//  Created by Wicky on 2018/3/26.
//  Copyright © 2018年 Wicky. All rights reserved.
//

/**
 DWFlashFlow
 数据请求框架
 
 提供Operation行为的请求任务，以及批量请求和链请求的支持。
 默认提供AFN作为核心请求组件，可通过重写DWFlashFlowManager中+classForLinker属性改变核心请求组件。
 提供数据请求的全局配置，但请求对象非单例对象。
 
 version 1.0.0
 Operation行为实现
 普通、批量、链请求实现
 提供核心请求组件更换接口
 提供全局配置管理类
 
 */

#ifndef DWFlashFlow_h
#define DWFlashFlow_h

#import "DWFlashFlowManager.h"
#import "DWFlashFlowBaseLinker.h"
#import "DWFlashFlowAFNLinker.h"
#import "DWFlashFlowAbstractRequest.h"
#import "DWFlashFlowRequest.h"
#import "DWFlashFlowBatchRequest.h"
#import "DWFlashFlowChainRequest.h"


#endif /* DWFlashFlow_h */