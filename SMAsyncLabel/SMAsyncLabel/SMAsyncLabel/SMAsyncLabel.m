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
    
    // remove attachment
    task.willDisplay = ^(CALayer *layer) {
        
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        
        
        
        
        
        
        // donging...
        for (SMTextStorage *textStorage in self.textArray) {
            CGPoint point = CGPointZero;
            
            [textStorage.textLayout sm_drawInContext:context size:size point:point cancel:isCancelled];
        };
        
    };
    
    // remove attachment, animation
    task.didEndDisplay = ^(CALayer *layer, BOOL finished) {
        
    };
    
    
    return task;
}

@end
