//
//  SMTextLayout.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextLayout.h"
#import <CoreText/CoreText.h>
#import "SMTextAttribute.h"
const CGSize SMTextContainerMaxSize = (CGSize){0x100000, 0x100000};
@interface SMTextLayout ()
//@property (nonatomic,strong) SMTextContainer *container;
//@property (nonatomic,strong) NSAttributedString *text;

@end

@implementation SMTextLayout
#pragma mark - Init
+ (instancetype)sm_layoutWithContainer:(SMTextContainer *)container text:(NSAttributedString *)text {
    
    BOOL needTruncation = NO;
    SMTextLine *truncatedLine = nil;
    if (!text || !container) return nil;
    SMTextLayout *layout = [[SMTextLayout alloc] init];
    
    // CTFrameRef
    NSMutableAttributedString *attText = text.mutableCopy;
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)attText);
    CFRange range = CFRangeMake(0, (CFIndex)attText.length);
    CGPathRef containerPath = container.path.CGPath;
    CGRect boundingBox = CGPathGetBoundingBox(containerPath);
    
    // calculate  bounding size
    CGSize constraints = CGSizeMake(boundingBox.size.width, SMTextContainerMaxSize.height);
    if (container.numberOfLines > 0) {
        CGMutablePathRef npath = CGPathCreateMutable();
        CGPathAddRect(npath, NULL, CGRectMake(0.0f, 0.0f, constraints.width, constraints.height));
        CTFrameRef nframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), npath, NULL);
        CFArrayRef nlines = CTFrameGetLines(nframe);
        
        if (CFArrayGetCount(nlines) > 0) {
            NSInteger nindex = MIN((CFIndex)container.numberOfLines, CFArrayGetCount(nlines)) -1;
            CTLineRef nline = CFArrayGetValueAtIndex(nlines, nindex);
            CFRange nrange = CTLineGetStringRange(nline);
            
            range = CFRangeMake(0, nrange.location + nrange.length);
        }
        
        CFRelease(nframe);
        CFRelease(npath);
    }
    
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, NULL, constraints, NULL);
    CGSize size = CGSizeMake(ceil(suggestSize.width), ceil(suggestSize.height));
    
    // addRect
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = {boundingBox.origin,{boundingBox.size.width, size.height}};
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, range, path, NULL);
    
    
    // CTLineRef
    int rowIndex = -1;
    int rowCount = 0;
    int curIndex = 0;
    
    CGRect lastRect = CGRectMake(0.0f, -CGFLOAT_MAX, 0.0f, 0.0f);
    CGPoint lastPos = CGPointMake(0.0f, -CGFLOAT_MAX);
    CGRect textBoundRect = CGRectZero;
    
    NSMutableArray *linesArray = [NSMutableArray array];
    
    CFArrayRef ctLines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(ctLines);
    CGPoint *lineOrigins = NULL;
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount *sizeof(CGPoint));
        CTFrameGetLineOrigins(frame, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    for (int i = 0; i < lineCount; i++) {
        
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(ctLine);
        CFIndex run = CFArrayGetCount(runs);
        if (!runs || run == 0) continue;
        
        CGPoint lineOrigin = lineOrigins[i];
        CGPoint position = CGPointMake(rect.origin.x + lineOrigin.x, rect.size.height + rect.origin.y - lineOrigin.y);
        
        SMTextLine *line = [SMTextLine sm_textLineWithCTLine:ctLine lineOrigin:position];
        CGRect lineRect = line.frame;
        
        BOOL newRow = YES;
        if (position.x != lastPos.x) {
            if (lineRect.size.height > lastRect.size.height) {
                if (lineRect.origin.y < lastPos.y && lastPos.y < lineRect.origin.y + lineRect.size.height) {
                    newRow = NO;
                }
            } else {
                if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) {
                    newRow = NO;
                }
            }
        }
        if (newRow){
            rowIndex ++;
        }
        
        lastRect = lineRect;
        lastPos = position;
        line.index = curIndex;
        line.row = rowIndex;
        [linesArray addObject:line];
        
        rowCount = rowIndex + 1;
        curIndex += 1;
        if (i == 0) {
            textBoundRect = lineRect;
        } else {
            textBoundRect = CGRectUnion(textBoundRect, lineRect);
        }
    }
    
    // Truncation
    if (rowCount) {
        if (container.numberOfLines > 0) {
            if (rowCount > container.numberOfLines) {
                rowCount = (int)container.numberOfLines;
            }
            do {
                SMTextLine *line = linesArray.lastObject;
                if (!line) break;
                if (line.row < rowCount) break;
                [linesArray removeLastObject];
            } while (1);
        }
        
        SMTextLine *lastLine = linesArray.lastObject;
        if (!needTruncation && lastLine.range.location + lastLine.range.length < text.length) {
            needTruncation = YES;
        }
    }
    // to be continued ...
    
    CFRange crange = CTFrameGetVisibleStringRange(frame);
    NSRange visibleRange = NSMakeRange(crange.location, crange.length);
    
    if (needTruncation) {
        SMTextLine *lastLine = linesArray.lastObject;
        NSRange lastRange = lastLine.range;
        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
        
        // create truncated line
        if (container.truncationType != SMTextTruncationTypeNone) {
            CTLineRef truncationTokenLine = NULL;
            CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
            NSUInteger runCount = CFArrayGetCount(runs);
            NSMutableDictionary *attrs = nil;
            if (runCount > 0) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                attrs = (id)CTRunGetAttributes(run);
                attrs = attrs ? attrs.mutableCopy : [NSMutableArray new];
                
                NSArray *keys = @[(id)kCTSuperscriptAttributeName,
                                  (id)kCTRunDelegateAttributeName,
                                  (id)NSAttachmentAttributeName];
                
                [attrs removeObjectsForKeys:keys];
                CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
                CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
                font = CTFontCreateWithName((__bridge CFStringRef)uiFont.fontName, uiFont.pointSize, NULL);
                if (font) {
                    attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
                    uiFont = nil;
                    CFRelease(font);
                }
                CGColorRef color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                if (color && CFGetTypeID(color) == CGColorGetTypeID() && CGColorGetAlpha(color) == 0) {
                    [attrs removeObjectForKey:(id)kCTForegroundColorAttributeName];
                }
                if (!attrs) attrs = [NSMutableDictionary new];
            }
            NSAttributedString *truncationToken = [[NSAttributedString alloc] initWithString:@"..." attributes:attrs];
            truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            //                }
            if (truncationTokenLine) {
                CTLineTruncationType type = kCTLineTruncationEnd;
                if (container.truncationType == SMTextTruncationTypeStart) {
                    type = kCTLineTruncationStart;
                } else if (container.truncationType == SMTextTruncationTypeMiddle) {
                    type = kCTLineTruncationMiddle;
                }
                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
                [lastLineText appendAttributedString:truncationToken];
                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
                if (ctLastLineExtend) {
                    CGFloat truncatedWidth = lastLine.width;
                    CGRect cgPathRect = CGRectZero;
                    if (CGPathIsRect(path, &cgPathRect)) {
                        
                        truncatedWidth = cgPathRect.size.width;
                        
                    }
                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                    CFRelease(ctLastLineExtend);
                    if (ctTruncatedLine) {
                        truncatedLine =  [SMTextLine sm_textLineWithCTLine:ctTruncatedLine lineOrigin:lastLine.lineOrigin];
                        truncatedLine.index = lastLine.index;
                        truncatedLine.row = lastLine.row;
                        CFRelease(ctTruncatedLine);
                    }
                }
                CFRelease(truncationTokenLine);
            }
        }
    }
    
    // check attribute status
    // can change
    if (visibleRange.length > 0) {
        layout->_needDrawText = YES;
        
//        [text enumerateAttributesInRange:visibleRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//            if (attrs[SMTextAttachmentAttributeName]) layout->_needDrawAttachment = YES;
//        }];
    }
    
    NSMutableArray *attachments = [NSMutableArray array];
    NSMutableArray *attachmentRanges = [NSMutableArray array];
    NSMutableArray *attachmentRects = [NSMutableArray array];
    NSMutableSet *attachmentContents = [NSMutableSet set];
    for (SMTextLine *line in linesArray) {
        if (line.attachments.count > 0) {
            [attachments addObjectsFromArray:line.attachments];
            [attachmentRects addObjectsFromArray:line.attachmentRects];
            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
            
            layout->_needDrawAttachment = YES;
            
            for (SMTextAttachment *attachment in line.attachments) {
                if (attachment.content) {
                    [attachmentContents addObject:attachment.content];
                }
            }
        }
    }
    
    // Setter
    layout->_container = container;
    layout->_text = text.mutableCopy;
    layout->_linesArray = linesArray;
    layout->_size = size;
    layout->_rowCount = rowCount;
    layout->_truncatedLine = truncatedLine;
    layout->_attachments = attachments;
    layout->_attachmentRects = attachmentRects;
    layout->_attachmentRanges = attachmentRanges;
    layout->_attachmentContents = attachmentContents;
    // TODO: setting more ....
    
    CFRelease(frameSetter);
    CFRelease(frame);
    CFRelease(path);
    if (lineOrigins) free(lineOrigins);
    return layout;
}

#pragma mark - Draw
- (void)sm_drawInContext:(CGContextRef)context
                    size:(CGSize)size
                   point:(CGPoint)point
                  cancel:(BOOL (^)(void))cancel {
    
    
    @autoreleasepool {
        if (self.needDrawText && context) {
            if (cancel && cancel()) return;
            SMTextDrawText(self, context, size, point, cancel);
            //        SMTextDrawFrameText(context, self, size, point, cancel);
        }
        
        if (self.needDrawAttachment && context) {
            if (cancel && cancel()) return;
            SMTextDrawAttachment(self, context, size, point, cancel);
        }
    }
  
}

static void SMTextDrawText(SMTextLayout *layout, CGContextRef context, CGSize size, CGPoint point,  BOOL (^cancel)(void)) {
    CGContextSaveGState(context); {
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        //        for (SMTextLine *line in layout.linesArray)
        
        
        for (NSUInteger i = 0; i < layout.linesArray.count; i++) {
            
            if (cancel && cancel()) break;
            SMTextLine *line = layout.linesArray[i];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) {
                line = layout.truncatedLine;
            }
            
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, line.lineOrigin.x, size.height - line.lineOrigin.y);
            
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            
            for (int i = 0; i < CFArrayGetCount(runs); i++) {
                if (cancel && cancel()) break;
                
                CTRunRef run = CFArrayGetValueAtIndex(runs, i);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    } CGContextRestoreGState(context);
}

static void SMTextDrawAttachment(SMTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL(^cancel)(void)) {
   
    for (NSUInteger i = 0; i < layout.attachments.count; i++) {
        if (cancel && cancel()) break;
        
        SMTextAttachment *attachment = layout.attachments[i];
        if (!attachment) continue;
        
        UIImage *image = nil;
        UIView *view = nil;
        CALayer *layer = nil;
        
        if ([attachment.content isKindOfClass:[UIImage class]]) {
            image = attachment.content;
        } else if ([attachment.content isKindOfClass:[UIView class]]) {
            view = attachment.content;
        } else if ([attachment.content isKindOfClass:[CALayer class]]) {
            layout = attachment.content;
        }
        
        if (!image && !layer && !view) continue;
     
        
        CGSize _size = image ? image.size : view ? view.frame.size : layer.frame.size;
        CGRect rect = ((NSValue *)layout.attachmentRects[i]).CGRectValue;
        rect = UIEdgeInsetsInsetRect(rect, attachment.contentInsets);
        rect = SMCGRectFitWithContentMode(rect, _size, attachment.contentMode);
        rect = CGRectStandardize(rect);
        rect.origin.x += point.x;
        rect.origin.y += point.y;
        
        if (image) {
            CGImageRef imageRef = image.CGImage;
            if (imageRef) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, CGRectGetMaxY(rect) + CGRectGetMinY(rect));
                CGContextScaleCTM(context, 1, -1);
                CGContextDrawImage(context, rect, imageRef);
                CGContextRestoreGState(context);
            }
        } else if (view) {
            
        } else if (layer) {
            
        }   
    }
}

static CGRect SMCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode) {
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (mode == UIViewContentModeScaleAspectFit) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}
// test
static void SMTextDrawFrameText(CGContextRef context, SMTextLayout *layout, CGSize size, CGPoint point,  BOOL (^cancel)(void)) {
    
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {1.0, 0.0, 0.0, 0.8};
        CGColorRef red = CGColorCreate(rgbColorSpace, components);
        CGColorSpaceRelease(rgbColorSpace);
        
        CFRange cfRange = CFRangeMake(0, (CFIndex)[layout.text length]);
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)layout.text, cfRange, kCTBackgroundColorAttributeName, red);
        
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)layout.text);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(point.x, point.y, size.width, size.height));
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, cfRange, path, NULL);
        
        CTFrameDraw(frame, context);
        
        CFRelease(path);
        CFRelease(frameSetter);
        CFRelease(frame);
        
    } CGContextRestoreGState(context);
}
@end
