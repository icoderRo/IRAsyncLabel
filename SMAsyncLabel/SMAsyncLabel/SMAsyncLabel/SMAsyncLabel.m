//
//  SMAsyncLabel.m
//  SMAsyncLabel
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAsyncLabel.h"
#import "SMAsyncLayer.h"


@interface SMAsyncLabel () <SMLayerDelegate>
//@property (nonatomic, copy) NSArray<SMTextStorage *> *textArray;
@end

@implementation SMAsyncLabel
+ (Class)layerClass {
    return SMAsyncLayer.class;
}

- (void)setLayout:(SMTextLayout *)layout {
    if (_layout == layout) return;
    
    _layout = layout;
    [self.layer setNeedsDisplay];
}

#pragma mark - SMLayerDelegate
- (SMLayerDisplayTask *)displayTask {
    SMLayerDisplayTask *task = [[SMLayerDisplayTask alloc] init];
    
    // 移除所有attachment
    task.willDisplay = ^(CALayer *layer) {
        
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        // 准备干活
        
        for (SMTextStorage *textStorage in self.textArray) {
            [textStorage.textLayout sm_drawInContext:context size:size point:CGPointMake(self.frame.origin.x, self.frame.origin.y) cancel:isCancelled];
        };
        
    };
    
    // 移除所有的attachment, 动画
    task.didEndDisplay = ^(CALayer *layer, BOOL finished) {
        
    };
    
    
    return task;
}

@end
