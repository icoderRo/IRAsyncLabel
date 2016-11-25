//
//  SMAsyncLabel.m
//  SMAsyncLabel
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAsyncLabel.h"
#import "SMAsyncLayer.h"
#import "SMTextStorage.h"

@interface SMAsyncLabel () <SMLayerDelegate>
@property (nonatomic, copy) NSArray<SMTextStorage *> *textArray;
@end

@implementation SMAsyncLabel
+ (Class)layerClass {
    return SMAsyncLayer.class;
}

#pragma mark - SMLayerDelegate
- (SMLayerDisplayTask *)displayTask {
    SMLayerDisplayTask *task = [[SMLayerDisplayTask alloc] init];
    
    // 移除所有attachment
    task.willDisplay = ^(CALayer *layer) {
        
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        // 准备干活
    };
    
    // 移除所有的attachment, 动画
    task.didEndDisplay = ^(CALayer *layer, BOOL finished) {
        
    };
    
    
    return task;
}

@end
