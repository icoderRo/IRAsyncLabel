//
//  SMTextLine.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/28.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "SMTextAttribute.h"

/**
 A text line object wrapped `CTLineRef`
 */
@interface SMTextLine : NSObject
@property (nonatomic, assign, readonly) CTLineRef CTLine;
@property (nonatomic, assign, readonly) NSRange range;
@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) CGFloat width;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat top;
@property (nonatomic, assign, readonly) CGFloat bottom;
@property (nonatomic, assign, readonly) CGFloat left;
@property (nonatomic, assign, readonly) CGFloat right;
@property (nonatomic, assign, readonly) CGPoint lineOrigin;
@property (nonatomic, assign, readonly) CGFloat ascent;
@property (nonatomic, assign, readonly) CGFloat descent;
@property (nonatomic, assign, readonly) CGFloat leading;
@property (nonatomic, assign, readonly) CGFloat lineWidth;
@property (nonatomic, assign, readonly) CGFloat trailingWhitespaceWidth;
@property (nonatomic) NSUInteger index;     ///< line index
@property (nonatomic) NSUInteger row;
@property (nonatomic, copy, readonly) NSArray<SMTextAttachment *> *attachments;
@property (nonatomic,copy,readonly) NSArray<NSValue *>* attachmentRanges;
@property (nonatomic,copy,readonly) NSArray<NSValue *>* attachmentRects;


+ (instancetype)sm_textLineWithCTLine:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin;
@end

