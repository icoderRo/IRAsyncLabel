//
//  SMTextLayout.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTextContainer.h"
#import "SMTextLine.h"
extern const CGSize SMTextContainerMaxSize;
@interface SMTextLayout : NSObject
@property (nonatomic, strong, readonly) SMTextContainer *container;
@property (nonatomic, strong, readonly) SMTextLine *truncatedLine;
@property (nonatomic, strong, readonly) NSAttributedString *text;
//@property (nonatomic, copy) NSArray *textArray;
@property (nonatomic, strong, readonly) NSArray<SMTextLine *> *linesArray;
@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) BOOL needDrawText;
@property (nonatomic, assign, readonly) BOOL needDrawAttachment;
@property (nonatomic, assign, readonly) NSUInteger rowCount;
@property (nonatomic, strong, readonly) NSArray<SMTextAttachment *> *attachments;
@property (nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRanges;
@property (nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRects;
@property (nonatomic, strong, readonly) NSSet<id> *attachmentContents;

+ (instancetype)sm_layoutWithContainer:(SMTextContainer *)container
                                  text:(NSAttributedString *)text;

- (void)sm_drawInContext:(CGContextRef)context
                    size:(CGSize)size
                   point:(CGPoint)point
                    view:(UIView *)view
                   layer:(CALayer *)layer
                  cancel:(BOOL (^)(void))cancel;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE; 
@end
