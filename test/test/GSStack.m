//
//  GSStack.m
//  test
//
//  Created by crosser on 13-11-8.
//  Copyright (c) 2013年 crosser. All rights reserved.
//

#import "GSStack.h"

@interface GSStack ()
{
    NSMutableArray *_stack;
}

@property (nonatomic, retain)NSMutableArray *stack;

@end

@implementation GSStack

@synthesize stack = _stack;

+ (id)stack
{
    return [[[GSStack alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.stack = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    self.stack = nil;
    [super dealloc];
}

- (BOOL)empty
{
    return [self.stack count] == 0;
}


- (id)pop
{
    id lastObject = [[self.stack lastObject] retain];
    if (lastObject) {
        [self.stack removeLastObject];
    }
    return [lastObject autorelease];
}

- (void)push:(id)obj
{
    if (obj) {
        [self.stack addObject: obj];
    }
}

- (id)top
{
    id lastObject = [self.stack lastObject];
    return lastObject;
}

- (void)removeAllObjects
{
    [self.stack removeAllObjects];
}

@end
