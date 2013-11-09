//
//  GSImageSliceManager.h
//  test
//
//  Created by crosser on 13-11-9.
//  Copyright (c) 2013年 crosser. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    SliceStateNormal       = 0,       		//常态
    SliceStateHighlighted  = 1 << 0,  		//高亮
    SliceStateDisabled     = 1 << 1,  		//禁用
    SliceStateSelected     = 1 << 2,      	//选中
};


struct Margins {
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
};
typedef struct Margins Margins;

FOUNDATION_EXPORT const Margins ZeroMargins;

@interface GSImageSliceManager : NSObject

+ (id)defaultImageSliceManager;

- (NSImage *)imageOfSliceId:(NSString *)sliceId;

- (NSRect)rectOfSliceId:(NSString *)sliceId;

- (Margins)marginsOfSliceId:(NSString *)sliceId;

@end
