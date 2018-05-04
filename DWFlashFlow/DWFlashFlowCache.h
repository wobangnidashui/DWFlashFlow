//
//  DWFlashFlowCache.h
//  DWFlashFlow
//
//  Created by MOMO on 2018/4/25.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DWFlashFlowCacheProtocol

@required

-(void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forKey:(NSString *)key;

-(NSCachedURLResponse *)cachedResponseForKey:(NSString *)key;

-(void)removeCachedResponseForKey:(NSString *)key;

-(BOOL)validateCacheResponese:(NSCachedURLResponse *)cacheResponse forKey:(NSString *)key;

@end

@interface DWFlashFlowCache : NSObject<DWFlashFlowCacheProtocol>

@end
