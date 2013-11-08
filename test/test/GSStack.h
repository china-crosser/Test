//
//  GSStack.h
//  test
//
//  Created by crosser on 13-11-8.
//  Copyright (c) 2013年 crosser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSStack : NSObject

+ (id)stack;
- (BOOL)empty;
- (id)top;
- (id)pop;
- (void)push:(id)obj;
- (void)removeAllObjects;

@end
