//
//  DWFlashFlowCache.h
//  DWFlashFlow
//
//  Created by MOMO on 2018/4/25.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWFlashFlowRequest.h"

///支持数据类型NSArray/NSDictionary/NSString/NSData
@protocol DWFlashFlowCacheProtocol

@required


//Store response by key.
///按指定Key存储响应
-(void)storeCachedResponse:(id)cachedResponse forKey:(NSString *)key request:(DWFlashFlowRequest *)request;

//Fetch response cache by key.
///按指定key取出响应
-(id)cachedResponseForKey:(NSString *)key;

//Remove response cache by key.
///移除指定key的响应
-(void)removeCachedResponseForKey:(NSString *)key;

//Validate response cache by key.
///检验指定key的响应的有效性
-(BOOL)validateCacheResponese:(id)cachedResponse forKey:(NSString *)key;

@end

//Cache response via NSURLCache.
///以NSURLCache作缓存，此类中Key必为URL。
@interface DWFlashFlowDefaultCache : NSObject<DWFlashFlowCacheProtocol>

@end

//Control expired time and AppVersion.
///可以控制版本超时时间
@interface DWFlashFlowAdvancedCache : NSObject<DWFlashFlowCacheProtocol>

@end


