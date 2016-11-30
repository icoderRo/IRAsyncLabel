//
//  SMAsyncLayer.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAsyncLayer.h"
#import <libkern/OSAtomic.h>

@implementation SMAsyncLayer {
    SMSentinel *_sentinel;
}

#pragma mark - queue
+ (dispatch_queue_t)SMDisplayQueue {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.icoderRo.SMAsyncLabel", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.icoderRo.SMAsyncLabel", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    NSLog(@"%@", queues[(cur) % queueCount]);
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

+ (dispatch_queue_t)SMReleaseQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

#pragma mark - LifeCycle
+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displayAsync"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        static CGFloat scale;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            scale = [UIScreen mainScreen].scale;
        });
        self.contentsScale = scale;
        
        _sentinel = [[SMSentinel alloc] init];
        _displayAsync = YES;
    }
    
    return self;
}

- (void)setNeedsDisplay {
    [self cancelDisplay];
    [super setNeedsDisplay];
}

- (void)display {
    super.contents = super.contents;
    [self display:_displayAsync];
}

#pragma mark - private
- (void)display:(BOOL)async {
    __strong id<SMLayerDelegate> delegate = (id<SMLayerDelegate>)self.delegate;
    // 设置displayTask的block
    SMLayerDisplayTask *task = [delegate displayTask];
    
    if (!task) { // 执行开始和结束的block
        if (task.willDisplay) task.willDisplay(self);
        self.contents = nil;
        if (task.didEndDisplay) task.didEndDisplay(self, YES);
        return;
    }
    
    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    
    CGColorRef backgroupColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
    
    if (size.width < 1 || size.height < 1) {
        CGImageRef image = (__bridge_retained CGImageRef)(self.contents);
        self.contents = nil;
        if (image) {
            dispatch_async([SMAsyncLayer SMReleaseQueue], ^{
                CFRelease(image);
            });
        }
        
        if (task.didEndDisplay) task.didEndDisplay(self, YES);
        CGColorRelease(backgroupColor);
        return;
    }
    
    
    if (async) {
        if (task.willDisplay) task.willDisplay(self);
        
        // init
        SMSentinel *sentinel = _sentinel;
        int32_t value = sentinel.value;
        
        // cancel block
        BOOL (^isCancelled)() = ^BOOL() {
            return value != sentinel.value;
        };
        
        dispatch_async([SMAsyncLayer SMDisplayQueue], ^{
            if (isCancelled()) {
                CGColorRelease(backgroupColor);
                return;
            }
            
            // scale传入0则表示让图片的缩放因子根据屏幕的分辨率而变化, 也可以根据Device的[UIScreen mainScreen].scale获得比例
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            // 利用Core Graphics实现绘图, 非UIKit, 参考《Programming iOS5》中Drawing
            // 绘图的形式可以是 UIKit和 Core Graphics, OpenGL ES(除外)
            //  UIKit和Core Graphics可以在相同的图形上下文中混合使用。在iOS 4.0之前，使用UIKit和UIGraphicsGetCurrentContext被认为是线程不安全的。而在iOS4.0以后苹果让绘图操作在第二个线程中执行解决了此问题。
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            // opaque 这个属性的默认值是YES
            // 如果设置为YES，绘制系统将会把这个视图视为完全不透明。这样允许系统优化一些绘制操作和提高性能。如果设置为NO，绘图系统会复合这个视图和其他的内容，
            if (opaque) { // 不透明
                // 因为图形上下文在每一时刻都有一个确定的状态，该状态概括了图形上下文所有属性的设置。为了便于操作这些状态，图形上下文提供了一个用来持有状态的栈。调用CGContextSaveGState函数，上下文会将完整的当前状态压入栈顶；调用CGContextRestoreGState函数，上下文查找处在栈顶的状态，并设置当前上下文状态为栈顶状态。
                
                // 因此一般绘图模式是：在绘图之前调用CGContextSaveGState函数保存当前状态，接着根据需要设置某些上下文状态，然后绘图，最后调用CGContextRestoreGState函数将当前状态恢复到绘图之前的状态。要注意的是，CGContextSaveGState函数和CGContextRestoreGState函数必须成对出现
                CGContextSaveGState(context); {
                    // backgroundColor为nil并且opaque属性为YES，视图的背景颜色就会变成黑色。初始化为白色
                    if (!backgroupColor || CGColorGetAlpha(backgroupColor) < 1) {
                        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width *scale, size.height *scale));
                        CGContextFillPath(context);
                    }
                    
                    if (backgroupColor) {
                        CGContextSetFillColorWithColor(context, backgroupColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width *scale, size.height *scale));
                        CGContextFillPath(context);
                    }
                } CGContextRestoreGState(context); // 恢复"🖌"状态
                CGColorRelease(backgroupColor);
            }
            
            // block doing...
            task.display(context, size, isCancelled);
            
            if (isCancelled()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didEndDisplay) task.didEndDisplay(self, NO);
                });
                return;
            }
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelled()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didEndDisplay) task.didEndDisplay(self, NO);
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCancelled()) {
                    if (task.didEndDisplay) task.didEndDisplay(self, NO);
                } else {
                    self.contents = (__bridge id)(image.CGImage);
                    if (task.didEndDisplay) task.didEndDisplay(self, YES);
                }
            });
        });
        
    } else {
        [self cancelDisplay];
        if (task.willDisplay) task.willDisplay(self);
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (opaque) {
            CGContextSaveGState(context); {
                if (!backgroupColor || CGColorGetAlpha(backgroupColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width *scale, size.height *scale));
                    CGContextFillPath(context);
                }
                
                if (backgroupColor) {
                    CGContextSetFillColorWithColor(context, backgroupColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width *scale, size.height *scale));
                    CGContextFillPath(context);
                }
            } CGContextRestoreGState(context);
            CGColorRelease(backgroupColor);
        }
        task.display(context, size, ^{return NO;});
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)(image.CGImage);
        if (task.didEndDisplay) task.didEndDisplay(self, YES);
    }
}

- (void)cancelDisplay {
    [self.sentinel increment];
}

- (void)dealloc {
    [self cancelDisplay];
}
@end

@implementation SMSentinel {
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increment {
    return OSAtomicIncrement32(&_value);
}
@end

@implementation SMLayerDisplayTask
@end
