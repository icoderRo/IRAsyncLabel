//
//  SMTextLine.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/28.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextLine.h"

@implementation SMTextLine {
    CGFloat _firstGlyphPos; // first glyph position for baseline, typically 0.
}

+ (instancetype)sm_textLineWithCTLine:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin {
    
    if (!CTLine) return nil;
    
    SMTextLine *textLine = [[self alloc] init];
    textLine->_lineOrigin = lineOrigin;
    [textLine setCTLine:CTLine];
    
    return textLine;
}

- (void)dealloc {
    if (_CTLine) CFRelease(_CTLine);
}

#pragma mark - Setter
- (void)setCTLine:(CTLineRef)CTLine {
    if (_CTLine != CTLine) {
        if (_CTLine) CFRelease(_CTLine);
        if (CTLine) _CTLine = CFRetain(CTLine);
        
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPos = pos.x;
            } else {
                _firstGlyphPos = 0.0f;
            }
            
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPos = _trailingWhitespaceWidth = 0.0f;
            _range = NSMakeRange(0, 0);
        }
        
        [self sm_calculateBounds];
    }
}

- (void)sm_calculateBounds {
    _frame = CGRectMake(_lineOrigin.x + _firstGlyphPos, _lineOrigin.y - _ascent, _lineWidth, _ascent + _descent);

    if (!_CTLine) return;
    
    // get runs
    CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount ==0) return;
    
    NSMutableArray *attachments = [NSMutableArray array];
    NSMutableArray *attachmentRanges = [NSMutableArray array];
    NSMutableArray *attachmentRects = [NSMutableArray array];
    
    // if run attribute -> ReCalculate
    for (NSUInteger i = 0; i < runCount; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
        
        NSDictionary *dict = (id)CTRunGetAttributes(run);
        SMTextAttachment *attachment = dict[SMTextAttachmentAttributeName];
        if (attachment) {
            CGPoint runPos = CGPointZero;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPos);
            
            CGFloat ascent, descent, leading, runWidth;
            CGRect runTypographicBounds;
            runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            
            runPos.x += _lineOrigin.x;
            runPos.y = self.lineOrigin.y - runPos.y;
            runTypographicBounds = CGRectMake(runPos.x, runPos.y - ascent, runWidth, ascent + descent);
            
            CFRange cfRange = CTRunGetStringRange(run);
            NSRange runRange = NSMakeRange(cfRange.location, cfRange.length);
            
            [attachments addObject:attachment];
            [attachmentRects addObject:[NSValue valueWithCGRect:runTypographicBounds]];
            [attachmentRanges addObject:[NSValue valueWithRange:runRange]];
        }
    }
    
    _attachments = attachments.count ? [attachments copy] : nil;
    _attachmentRanges = attachmentRanges.count ? [attachmentRanges copy] : nil;
    _attachmentRects = attachmentRects.count ? [attachmentRects copy] : nil;
    
}

#pragma mark - Getter
- (CGSize)size {
    return _frame.size;
}

- (CGFloat)width {
    return CGRectGetWidth(_frame);
}

- (CGFloat)height {
    return CGRectGetHeight(_frame);
}

- (CGFloat)top {
    return CGRectGetMinY(_frame);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(_frame);
}

- (CGFloat)left {
    return CGRectGetMinX(_frame);
}

- (CGFloat)right {
    return CGRectGetMaxX(_frame);
}


@end
