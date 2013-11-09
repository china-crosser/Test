//
//  GSImageSliceManager.m
//  test
//
//  Created by crosser on 13-11-9.
//  Copyright (c) 2013年 crosser. All rights reserved.
//

#import "GSImageSliceManager.h"

//<?xml version="1.0" encoding="UTF-8"?>
//<images>
//    <image filename="Control.png">
//        <slice id="Icon" rect="0,0,10,10"/>
//        <slice id="ButtonStateNormal" rect="0,0,10,10" margins='1,1,1,1'/>
//        <slice id="ButtonStateHighlighted" rect="0,0,10,10" margins='1,1,1,1'/>
//        <slice id="ButtonStateDisabled" rect="0,0,10,10" margins='1,1,1,1'/>
//        <slice id="ButtonStateSelected" rect="0,0,10,10" margins='1,1,1,1'/>
//    </image>
//</images>

NS_INLINE Margins MakeMargins(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
    Margins m;
    m.left = left;
    m.top = top;
    m.right = right;
    m.bottom = bottom;
    return m;
}

const Margins ZeroMargins = {0, 0, 0, 0};

@interface NSValue (NSValueMarginsExtensions)

+ (NSValue *)valueWithMargins:(Margins)margins;
- (Margins)marginsValue;

@end

@implementation NSValue (NSValueMarginsExtensions)

+ (NSValue *)valueWithMargins:(Margins)margins
{
    return [NSValue valueWithBytes:&margins objCType:@encode(Margins)];
}

- (Margins)marginsValue
{
    Margins margins;
    
    [self getValue:&margins];
    
    return margins;
}

@end

@interface GSImageSliceManager ()
{
    NSMutableDictionary *_slicesDict;
}

@property (nonatomic, retain) NSMutableDictionary *slicesDict;

@end

@implementation GSImageSliceManager

@synthesize slicesDict = _slicesDict;

+ (id)defaultImageSliceManager
{
    static dispatch_once_t once;
    static GSImageSliceManager *staticImageSliceManager = nil;
    dispatch_once(&once, ^{
        staticImageSliceManager = [[GSImageSliceManager alloc] init];
    });
    
    return staticImageSliceManager;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.slicesDict = [NSMutableDictionary dictionary];
        [self loadConfigFile:[self resourcePath:@"Control.xml"]];
	}
	
	return self;
}

- (void)dealloc
{
    self.slicesDict = nil;
    [super dealloc];
}

- (NSRect)RectFromString:(NSString *)strValue
{
    NSRect result = NSZeroRect;
    NSArray *values = [strValue componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    if ([values count] == 4) {
        NSString *strRect = [NSString stringWithFormat:@"{{%@,%@},{%@,%@}}",
                                [values objectAtIndex:0],
                                [values objectAtIndex:1],
                                [values objectAtIndex:2],
                                [values objectAtIndex:3]];
        result = NSRectFromString(strRect);
    }
    
    return result;
}

- (Margins)MarginsFromString:(NSString *)strValue
{
    //注意，这个使用RectFromString进行解析，所以下面的代码看起来比较怪
    NSRect rect = [self RectFromString:strValue];
    if (NSIsEmptyRect(rect)) {
        return ZeroMargins;
    } else {
        //注意，这个使用RectFromString进行解析，所以下面的代码看起来比较怪
        return MakeMargins(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    }
}

BOOL IsEmptyMargins(Margins aMargins)
{
    if ((ZeroMargins.left == aMargins.left) &&
        (ZeroMargins.top == aMargins.top) &&
        (ZeroMargins.right == aMargins.right) &&
        (ZeroMargins.bottom == aMargins.bottom)) {
        return YES;
    }
    
    return NO;
}

- (void)loadConfigFile:(NSString *)filePath
{
	if (!filePath) {
		return;
    }
	
	NSXMLDocument *xmlDoc = nil;
    NSError *err = nil;
	
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    if(!fileURL) {
		return;
    }
	
	xmlDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:fileURL
												  options:NSXMLDocumentTidyXML
													error:&err] autorelease];
    if(xmlDoc == nil) {
		return;
    }
	
	NSXMLNode *nodeRoot = [xmlDoc rootElement];
	if (!nodeRoot) {
		return;
    }

    [self.slicesDict removeAllObjects];
	NSArray* nodeImages = [nodeRoot children];
	for (NSXMLElement *nodeImage in nodeImages) {
		NSArray *nodeSlices = [nodeImage children];
        NSString *filename = [[nodeImage attributeForName:@"filename"] stringValue];
		for (NSXMLElement *nodeSlice in nodeSlices) {
			NSMutableDictionary * dictSlice = [NSMutableDictionary dictionary];
			NSString *strId = [[nodeSlice attributeForName:@"id"] stringValue];
			NSString *strRect = [[nodeSlice attributeForName:@"rect"] stringValue];
			NSString *strMargins = [[nodeSlice attributeForName:@"margins"] stringValue];
            NSString *sliceId = strId;
			NSRect sliceRect = [self RectFromString:strRect];
            Margins sliceMargins = [self MarginsFromString:strMargins];
            if (!NSIsEmptyRect(sliceRect)) {
                [dictSlice setObject:[NSValue valueWithRect:sliceRect] forKey:@"rect"];
            }
            if (!IsEmptyMargins(sliceMargins)) {
                [dictSlice setObject:[NSValue valueWithMargins:sliceMargins] forKey:@"margins"];
            }
            [dictSlice setObject:filename forKey:@"filename"];
            [self.slicesDict setObject:dictSlice forKey:sliceId];
		}
	}
}

- (NSImage *)cropImage:(NSImage *)image rect:(NSRect)rect
{
    NSImage *subImage = [[NSImage alloc] initWithSize:rect.size];
    NSRect drawRect = NSZeroRect;
    drawRect.size = rect.size;
    [subImage lockFocus];
    [image drawInRect:drawRect
             fromRect:rect
            operation:NSCompositeSourceOver
             fraction:1.0f];
    [subImage unlockFocus];
    return [subImage autorelease];
}

- (NSString *)resourcePath:(NSString *)fileName {
	NSBundle *bundle = [NSBundle mainBundle];
    NSString *suffix = [fileName pathExtension];
    NSString *name = [fileName stringByDeletingPathExtension];
	return [bundle pathForResource:name ofType:suffix];;
}

- (NSImage *)imageOfSliceId:(NSString *)sliceId
{
    NSDictionary *data = [self.slicesDict objectForKey:sliceId];
    NSString *path = [data objectForKey:@"filename"];
    NSImage *sourceImage = [NSImage imageNamed:path];
    NSRect clipRect = [self rectOfSliceId:sliceId];
    if (!sourceImage || NSIsEmptyRect(clipRect)) {
        return nil;
    }
    
    return [self cropImage:sourceImage rect:clipRect];
}

- (NSRect)rectOfSliceId:(NSString *)sliceId
{
    NSDictionary *data = [self.slicesDict objectForKey:sliceId];
    NSValue *value = [data valueForKey:@"rect"];
    return [value rectValue];
}

- (Margins)marginsOfSliceId:(NSString *)sliceId
{
    NSDictionary *data = [self.slicesDict objectForKey:sliceId];
    NSValue *value = [data valueForKey:@"margins"];
    return [value marginsValue];
}

@end
