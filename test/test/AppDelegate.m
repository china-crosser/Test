//
//  AppDelegate.m
//  test
//
//  Created by crosser on 13-11-8.
//  Copyright (c) 2013年 crosser. All rights reserved.
//

#import "AppDelegate.h"
#import "GSImageSliceManager.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    GSImageSliceManager *mgr = [GSImageSliceManager defaultImageSliceManager];
    NSImage *image = [mgr imageOfSliceId:@"ButtonStateSelected"];
    [[image TIFFRepresentation] writeToFile:@"/Users/apple/Desktop/weiyun/BaiduYunTool/A.png" atomically:NO];
}

@end
