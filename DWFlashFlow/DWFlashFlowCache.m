//
//  DWFlashFlowCache.m
//  DWFlashFlow
//
//  Created by MOMO on 2018/4/25.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWFlashFlowCache.h"
#import "DWFlashFlowManager.h"

#pragma mark --- Tool method ---

///校验容器类内部元素是否合法（NSString/NSNumber/NSDictionary/NSArray）
NS_INLINE BOOL validateContainer(id container) {
    NSArray * allValues = nil;
    if ([container isKindOfClass:[NSDictionary class]]) {
        allValues = ((NSDictionary *)container).allValues;
    } else if ([container isKindOfClass:[NSArray class]]) {
        allValues = container;
    } else {
        return NO;
    }
    __block BOOL validate = YES;
    [allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]] ||
            [obj isKindOfClass:[NSNumber class]] ||
            [obj isKindOfClass:[NSDictionary class]] ||
            [obj isKindOfClass:[NSArray class]]) {
            if ([obj isKindOfClass:[NSDictionary class]] ||
                [obj isKindOfClass:[NSArray class]]) {
                BOOL temp = validateContainer(obj);
                if (!temp) {
                    validate = NO;
                    *stop = YES;
                }
            }
        } else {
            validate = NO;
            *stop = YES;
        }
    }];
    return validate;
}

///校验缓存数据类型是否合法（NSData/NSString/合法的NSDictionary和NSArray）
NS_INLINE BOOL validateCachedResponseType(id cachedResponse) {
    if ([cachedResponse isKindOfClass:[NSData class]] ||
        [cachedResponse isKindOfClass:[NSString class]] ||
        [cachedResponse isKindOfClass:[NSDictionary class]] ||
        [cachedResponse isKindOfClass:[NSArray class]]) {
        if ([cachedResponse isKindOfClass:[NSDictionary class]] || [cachedResponse isKindOfClass:[NSArray class]]) {
            return validateContainer(cachedResponse);
        } else {
            return YES;
        }
    }
    return NO;
}

///容器类转为NSData
NS_INLINE NSData * container2Data(id container) {
    return [NSJSONSerialization dataWithJSONObject:container options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
}

///NSData转为容器
NS_INLINE id jsonData2Container(NSData * jsonData) {
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
}

///返回内容的类型字符串
NS_INLINE NSString * cacheType(id cacheResponse) {
    if ([cacheResponse isKindOfClass:[NSData class]]) {
        return @"NSData";
    }
    if ([cacheResponse isKindOfClass:[NSString class]]) {
        return @"NSString";
    }
    if ([cacheResponse isKindOfClass:[NSDictionary class]]) {
        return @"NSDictionary";
    }
    if ([cacheResponse isKindOfClass:[NSArray class]]) {
        return @"NSArray";
    }
    return nil;
}

///将缓存内容转换为NSData
NS_INLINE NSData * dataFromCachedResponse(id cachedResponse) {
    if ([cachedResponse isKindOfClass:[NSData class]]) {
        return cachedResponse;
    } else if ([cachedResponse isKindOfClass:[NSString class]]) {
        return [((NSString *)cachedResponse) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([cachedResponse isKindOfClass:[NSArray class]] || [cachedResponse isKindOfClass:[NSDictionary class]]) {
        return container2Data(cachedResponse);
    }
    return nil;
}

///将NSData转换为缓存的数据
NS_INLINE id objectFromDataWithType(NSString * type,NSData * data) {
    if ([type isEqualToString:@"NSData"]) {
        return data;
    } else if ([type isEqualToString:@"NSString"]) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else if ([type isEqualToString:@"NSDictionary"] || [type isEqualToString:@"NSArray"]) {
        return jsonData2Container(data);
    }
    return nil;
}

@implementation DWFlashFlowDefaultCache

-(void)storeCachedResponse:(id)cachedResponse forKey:(NSString *)key request:(DWFlashFlowRequest *)request {
    if (!cachedResponse || !key.length || !request || !request.task.response) {
        return;
    }
    if (!validateCachedResponseType(cachedResponse)) {
        return;
    }
    NSData * data = dataFromCachedResponse(cachedResponse);
    if (!data) {
        return;
    }
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString * type = cacheType(cachedResponse);
    
    if (!type.length) {
        return;
    }
    userInfo[@"cacheType"] = type;
    NSCachedURLResponse * response = [[NSCachedURLResponse alloc] initWithResponse:request.task.response data:data userInfo:userInfo storagePolicy:(NSURLCacheStorageAllowed)];
    [[NSURLCache sharedURLCache] storeCachedResponse:response forRequest:requestForKey(key)];
}

-(id)cachedResponseForKey:(NSString *)key {
    if (!key.length) {
        return nil;
    }
    NSCachedURLResponse * response = [[NSURLCache sharedURLCache] cachedResponseForRequest:requestForKey(key)];
    if (!response || !response.data || !response.userInfo) {
        return nil;
    }
    NSData * data = response.data;
    NSString * type = response.userInfo[@"cacheType"];
    if (!type) {
        return nil;
    }
    id cachedResponse = objectFromDataWithType(type, data);
    return cachedResponse;
}

-(void)removeCachedResponseForKey:(NSString *)key {
    if (!key.length) {
        return ;
    }
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:requestForKey(key)];
}

-(BOOL)validateCacheResponese:(id)cachedResponse forKey:(NSString *)key {
    if ([self cachedResponseForKey:key]) {
        return YES;
    }
    return NO;
}

#pragma mark --- inline method ---
NS_INLINE NSString * URLForKey(NSString * key) {
    return key;
}

NS_INLINE NSURLRequest * requestForKey(NSString * key) {
    if (!key.length) {
        return nil;
    }
    return [NSURLRequest requestWithURL:[NSURL URLWithString:URLForKey(key)]];
}

@end

@interface DWFlashFlowAdvancedCache ()<NSSecureCoding>

@property (nonatomic ,strong) id cachedResponse;

@property (nonatomic ,copy) NSString * cachePath;

@property (nonatomic ,copy) NSString * cacheType;

@property (nonatomic ,assign) NSInteger appVersion;

@property (nonatomic ,strong) NSDate * createTime;

@property (nonatomic ,assign) NSTimeInterval expiredInterval;

@end

@implementation DWFlashFlowAdvancedCache

-(void)storeCachedResponse:(id)cachedResponse forKey:(NSString *)key request:(DWFlashFlowRequest *)request {
    if (!cachedResponse || !key.length) {
        return;
    }
    if (!validateCachedResponseType(cachedResponse)) {
        return;
    }
    NSTimeInterval expiredInterval = request.expiredInterval;
    if (expiredInterval == 0) {
        expiredInterval = [DWFlashFlowManager manager].globalExpiredInterval;
    }
    NSString * cachePath = cacheFilePathWithKey(key);
    DWFlashFlowAdvancedCache * cache = [DWFlashFlowAdvancedCache new];
    cache.cachedResponse = cachedResponse;
    cache.cachePath = cachePath;
    cache.cacheType = cacheType(cachedResponse);
    cache.appVersion = [DWFlashFlowManager manager].appVersion;
    cache.createTime = [NSDate date];
    cache.expiredInterval = expiredInterval;
    [NSKeyedArchiver archiveRootObject:cache toFile:metaPathWithKey(key)];
    writeFile2Path(cachedResponse, cacheFilePathWithKey(key));
}

-(id)cachedResponseForKey:(NSString *)key {
    DWFlashFlowAdvancedCache * cache = [NSKeyedUnarchiver unarchiveObjectWithFile:metaPathWithKey(key)];
    if (![self validateCacheResponese:cache forKey:key]) {
        return nil;
    }
    return cache.cachedResponse;
}

-(void)removeCachedResponseForKey:(NSString *)key {
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePathWithKey(key)]) {
        [[NSFileManager defaultManager] removeItemAtPath:savePathWithKey(key) error:nil];
    }
}

-(BOOL)validateCacheResponese:(DWFlashFlowAdvancedCache *)cachedResponse forKey:(NSString *)key {
    if (!cachedResponse) {
        return NO;
    }
    if (![cachedResponse isKindOfClass:[DWFlashFlowAdvancedCache class]]) {
        return NO;
    }
    ///版本不对
    if (cachedResponse.appVersion < [DWFlashFlowManager manager].appVersion) {
        return NO;
    }
    ///超时
    if (cachedResponse.expiredInterval > 0 && [[NSDate date] timeIntervalSince1970] - [cachedResponse.createTime timeIntervalSince1970] > cachedResponse.expiredInterval) {
        return NO;
    }
    ///响应数据
    if (!cachedResponse.cachedResponse) {
        return NO;
    }
    return YES;
}

#pragma mark --- 归档 ---
+ (BOOL)supportsSecureCoding {
    return YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.expiredInterval forKey:@"expiredInterval"];
    [aCoder encodeObject:self.createTime forKey:@"createTime"];
    [aCoder encodeInteger:self.appVersion forKey:@"appVersion"];
    [aCoder encodeObject:self.cachePath forKey:@"cachePath"];
    [aCoder encodeObject:self.cacheType forKey:@"cacheType"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    self.expiredInterval = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"expiredInterval"] doubleValue];
    self.createTime = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"createTime"];
    self.appVersion = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"appVersion"] integerValue];
    self.cachePath = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"cachePath"];
    self.cacheType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"cacheType"];
    if (self.cachePath.length && self.cacheType.length) {
        NSData * data = [NSData dataWithContentsOfFile:self.cachePath];
        self.cachedResponse = objectFromDataWithType(self.cacheType, data);
    }
    return self;
}

#pragma mark --- inline method ---

NS_INLINE NSString * savePathWithKey(NSString * key) {
    NSString * cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * path = [cache stringByAppendingPathComponent:@"DWFlashFlow"];
    path = [path stringByAppendingPathComponent:@"ResponseCache"];
    path = [path stringByAppendingPathComponent:key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

NS_INLINE NSString * cacheFilePathWithKey(NSString * key) {
    return [savePathWithKey(key) stringByAppendingPathComponent:[key stringByAppendingPathExtension:@"data"]];
}

NS_INLINE NSString * metaPathWithKey(NSString * key) {
    return [savePathWithKey(key) stringByAppendingPathComponent:@"response.meta"];
}

NS_INLINE void writeFile2Path(id file,NSString * path) {
    NSData * data = dataFromCachedResponse(file);
    [data writeToFile:path atomically:YES];
}

@end
