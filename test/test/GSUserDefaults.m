//
//  GSUserDefaults.m
//  ImageBrowserView
//
//  Created by crosser on 13-11-8.
//  Copyright (c) 2013年 crosser. All rights reserved.
//

#import "GSUserDefaults.h"

@interface Defaults()
{
    NSMutableDictionary *_defaults;
    NSMutableDictionary *_registerDefaults;
}

- (id)initWithContentsOfFile:(NSString *)path;
- (BOOL)writeToFile:(NSString *)path;

@property (readwrite, retain)NSMutableDictionary *defaults;
@property (readwrite, retain)NSMutableDictionary *registerDefaults;

@end

@implementation Defaults

@synthesize defaults = _defaults;
@synthesize registerDefaults = _registerDefaults;

- (id)objectForKey:(NSString *)defaultName
{
    id result = [self.defaults valueForKey:defaultName];
    if (!result) {
        return [self.registerDefaults valueForKey:defaultName];
    }
    
    return result;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [self.defaults setObject:value forKey:defaultName];
}

- (void)removeObjectForKey:(NSString *)defaultName
{
    [self.defaults removeObjectForKey:defaultName];
}

- (NSString *)stringForKey:(NSString *)defaultName
{
    return (NSString *)[self objectForKey:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName
{
    return (NSArray *)[self objectForKey:defaultName];
}
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
    return (NSDictionary *)[self objectForKey:defaultName];
}

- (NSData *)dataForKey:(NSString *)defaultName
{
    return (NSData *)[self objectForKey:defaultName];
}

- (NSURL *)URLForKey:(NSString *)defaultName
{
    return (NSURL *)[self objectForKey:defaultName];
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
    NSNumber *number = [self objectForKey:defaultName];
    return [number integerValue];
}

- (float)floatForKey:(NSString *)defaultName
{
    NSNumber *number = [self objectForKey:defaultName];
    return [number floatValue];
}

- (double)doubleForKey:(NSString *)defaultName
{
    NSNumber *number = [self objectForKey:defaultName];
    return [number doubleValue];
}

- (BOOL)boolForKey:(NSString *)defaultName
{
    NSNumber *number = [self objectForKey:defaultName];
    return [number boolValue];
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName
{
    [self setObject:url forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
    NSNumber *number = [NSNumber numberWithInteger:value];
    [self setObject:number forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
    NSNumber *number = [NSNumber numberWithFloat:value];
    [self setObject:number forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName
{
    NSNumber *number = [NSNumber numberWithDouble:value];
    [self setObject:number forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    NSNumber *number = [NSNumber numberWithBool:value];
    [self setObject:number forKey:defaultName];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    self = [super init];
    if (self) {
        self.defaults = [NSMutableDictionary dictionary];
        self.registerDefaults = [NSMutableDictionary dictionary];
        BOOL isDirectory = NO;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
            self.defaults = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.defaults = nil;
    self.registerDefaults = nil;
    [super dealloc];
}


- (void)registerDefaults:(NSDictionary *)registrationDictionary
{
    if (registrationDictionary) {
        self.registerDefaults = [NSMutableDictionary dictionaryWithDictionary:registrationDictionary];
    } else {
        self.registerDefaults = [NSMutableDictionary dictionary];
    }
    
    NSArray *keys = [self.registerDefaults allKeys];
    for (NSString *key in keys) {
        id value1 = [self.defaults valueForKey:key];
        if (!value1) {
            id value2 = [self.registerDefaults valueForKey:key];
            [self setObject:value2 forKey:key];
        }
    }
}

- (BOOL)writeToFile:(NSString *)path
{
    BOOL isDirectory = NO;
    NSString *directory = [path stringByDeletingLastPathComponent];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:directory isDirectory:&isDirectory]) {
        [fileMgr createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.defaults];
    NSArray *keys = [self.registerDefaults allKeys];
    for (NSString *key in keys) {
        id value1 = [self.defaults valueForKey:key];
        id value2 = [self.registerDefaults valueForKey:key];
        if (value1 && ((value1 == value2) || ([value1 isEqual:value2]))) {
            [dict removeObjectForKey:key];
        }
    }
    
    return [dict writeToFile:path atomically:NO];
}

@end

@interface GSUserDefaults ()
{
    NSString *_path;
}

@property (nonatomic, copy) NSString *path;

@end

@implementation GSUserDefaults

@synthesize path = _path;

- (id)initWithContentsOfFile:(NSString *)aPath
{
    self = [super initWithContentsOfFile:aPath];
    if (self) {
        self.path = aPath;
    }
    
    return self;
}

- (void)dealloc
{
    self.path = nil;
    [super dealloc];
}

- (BOOL)synchronize
{
    return [super writeToFile:self.path];
}

@end
