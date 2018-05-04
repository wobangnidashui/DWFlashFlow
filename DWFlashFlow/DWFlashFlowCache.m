//
//  DWFlashFlowCache.m
//  DWFlashFlow
//
//  Created by MOMO on 2018/4/25.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWFlashFlowCache.h"

@implementation DWFlashFlowCache

-(void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forKey:(NSString *)key {
    if (!cachedResponse || !key.length) {
        return;
    }
    [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:requestForKey(key)];
}

-(NSCachedURLResponse *)cachedResponseForKey:(NSString *)key {
    if (!key.length) {
        return nil;
    }
    return [[NSURLCache sharedURLCache] cachedResponseForRequest:requestForKey(key)];
}

-(void)removeCachedResponseForKey:(NSString *)key {
    if (!key.length) {
        return ;
    }
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:requestForKey(key)];
}

-(BOOL)validateCacheResponese:(NSCachedURLResponse *)cacheResponse forKey:(NSString *)key {
    return YES;
}

#pragma mark --- inline method ---
NS_INLINE NSString * URLForKey(NSString * key) {
    return key;
}

NS_INLINE NSURLRequest * requestForKey(NSString * key) {
    if (key.length) {
        return nil;
    }
    return [NSURLRequest requestWithURL:[NSURL URLWithString:URLForKey(key)]];
}

@end
