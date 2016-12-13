//
//  SMAsyncLabel.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAsyncLabel.h"
#import "SMAsyncLayer.h"

@interface SMAsyncLabel () <SMLayerDelegate>
/// make the NSAttributedString -> NSMutableAttributedString for using addAttributemethod  or removeAttribute
@property (nonatomic, copy) NSMutableAttributedString *attrs;
/// if has textLayout, then no need layout
@property (nonatomic, assign) BOOL layoutNeedUpdate;

@property (nonatomic, strong) SMTextContainer *container;


@end

@implementation SMAsyncLabel
#pragma mark - Override
+ (Class)layerClass {
    return SMAsyncLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setupLabel];
    }
    
    return self;
}

- (void)setupLabel {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    
    _font = [UIFont systemFontOfSize:15.0f];
    _layoutNeedUpdate = YES;
    
    _container = [[SMTextContainer alloc] init];
    _container.size = self.frame.size;
}


#pragma mark - SMLayerDelegate
- (SMLayerDisplayTask *)displayTask {
    
    SMLayerDisplayTask *task = [[SMLayerDisplayTask alloc] init];
    
    // remove attachment
    task.willDisplay = ^(CALayer *layer) {
        
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        if (self.layoutNeedUpdate) {
            _container.size = size;
            _textLayout = [SMTextLayout sm_layoutWithContainer:_container text:_attrs];
        }
        
        CGPoint point = CGPointZero;
        
        [_textLayout sm_drawInContext:context size:_textLayout.size point:point cancel:isCancelled];
    };
    
    // remove attachment, animation
    task.didEndDisplay = ^(CALayer *layer, BOOL finished) {
        
    };
    
    
    return task;
}

#pragma mark - Setter
- (void)setText:(NSString *)text {
    if (!text || _text == text) return;
    _text = text.copy;
    
    _attrs = [[NSMutableAttributedString alloc] initWithString:_text attributes:nil];
    
    NSRange range = NSMakeRange(0, _attrs.length);
    [_attrs setFont:_font range:range];
    
    if (_textColor) {
        NSRange range = NSMakeRange(0, _attrs.length);
        [self.attrs setTextColor:_textColor range:range];
    }
    
    [self.layer setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}


- (void)setAttributedText:(NSMutableAttributedString *)attributedText {
    if (attributedText.length <= 0 || _attributedText == attributedText) return;
    
    _attrs = attributedText.mutableCopy;
    
    [self.layer setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    if (!font) font = [UIFont systemFontOfSize:17];
    _font = font;
    
    if (_attrs.length) {
        NSRange range = NSMakeRange(0, _attrs.length);
        [_attrs setFont:_font range:range];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setlineSpacing:(CGFloat)lineSpacing {
    if (lineSpacing == _lineSpacing) return;
    
    _lineSpacing = lineSpacing;
    NSRange range = NSMakeRange(0, _attrs.length);
    [self.attrs setLineSpacing:_lineSpacing range:range];
}

- (void)setCharacterSpacing:(unichar)characterSpacing {
    if (_characterSpacing == characterSpacing) return;
    
    _characterSpacing = characterSpacing;
     NSRange range = NSMakeRange(0, _attrs.length);
    [self.attrs setCharacterSpacing:_characterSpacing range:range];
    
}
- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) textColor = [UIColor blackColor];
    
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    _textColor = textColor;
    NSRange range = NSMakeRange(0, _attrs.length);
    [self.attrs setTextColor:_textColor range:range];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    
    _textAlignment = textAlignment;
    NSRange range = NSMakeRange(0, _attrs.length);
    [self.attrs setTextAlignment:_textAlignment range:range];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (lineBreakMode == _lineBreakMode) return;
    _lineBreakMode = lineBreakMode;
    NSRange range = NSMakeRange(0, _attrs.length);
//    [self.attrs setLineBreakMode:lineBreakMode range:range];
    
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping:
        case NSLineBreakByCharWrapping:
        case NSLineBreakByClipping:{
            _container.truncationType = SMTextTruncationTypeNone;
            [self.attrs setLineBreakMode:lineBreakMode range:range];
        }
            break;
        case NSLineBreakByTruncatingHead:{
            _container.truncationType = SMTextTruncationTypeStart;
            [self.attrs setLineBreakMode:NSLineBreakByWordWrapping range:range];
        } break;
        case NSLineBreakByTruncatingTail:{
            _container.truncationType = SMTextTruncationTypeEnd;
            [self.attrs setLineBreakMode:NSLineBreakByWordWrapping range:range];
        } break;
        case NSLineBreakByTruncatingMiddle: {
            _container.truncationType = SMTextTruncationTypeMiddle;
            [self.attrs setLineBreakMode:NSLineBreakByWordWrapping range:range];
        } break;
        default:
            break;
    }
    
    [self.layer setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextLayout:(SMTextLayout *)textLayout {
    if (_textLayout == textLayout) return;
    _textLayout = textLayout;
    _layoutNeedUpdate = NO;
    [self.layer setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (_preferredMaxLayoutWidth == preferredMaxLayoutWidth) return;
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    
    _numberOfLines = numberOfLines;
    _container.numberOfLines = _numberOfLines;
    if (_attrs.length) {
        [self.layer setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize {
    if (_preferredMaxLayoutWidth == 0) {
        _container.size = SMTextContainerMaxSize;
        SMTextLayout *layout = [SMTextLayout sm_layoutWithContainer:_container text:_attrs];
        
        return layout.size;
    };
    
    CGSize containerSize;
    containerSize.height = SMTextContainerMaxSize.height;
    containerSize.width = _preferredMaxLayoutWidth;
    if (containerSize.width == 0) containerSize.width = self.bounds.size.width;
    
    _container.size = containerSize;
    SMTextLayout *layout = [SMTextLayout sm_layoutWithContainer:_container text:_attrs];
    
    return layout.size;
}

@end


@implementation NSMutableAttributedString (SMText)

- (void)setFont:(UIFont *)font range:(NSRange)range {
    [self setAttribute:NSFontAttributeName value:font range:range];
}

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
    [self setAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle *style = value.mutableCopy;
                          [style setAlignment:textAlignment];
                          [self setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                          [style setAlignment:textAlignment];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle *style = value.mutableCopy;
                          [style setLineBreakMode:lineBreakMode];
                          [self setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineBreakMode:lineBreakMode];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setlineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle *style = value.mutableCopy;
                          [style setLineSpacing:lineSpacing];
                          [self setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineSpacing:lineSpacing];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range {
    CFNumberRef charSpacingNum =  CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&characterSpacing);
    if (charSpacingNum != nil) {
        [self setAttribute:(NSString *)kCTKernAttributeName value:(__bridge id)charSpacingNum range:range];
        CFRelease(charSpacingNum);
    }
}


//- (void)setTextAttachment:(SMTextAttacment *)textAttachment range:(NSRange)range {
//    [self setAttribute:SMTextAttachmentAttributeName value:textAttachment range:range];
//}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

//+ (NSMutableAttributedString *)attachmentStringWithContent:(id)content
//                                               contentMode:(UIViewContentMode)contentMode
//                                                  userInfo:(NSDictionary *)userInfo
//                                                     width:(CGFloat)width
//                                                    ascent:(CGFloat)ascent
//                                                   descent:(CGFloat)descent {
//    
//    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] initWithString:SMTextAttachmentToken];
//    SMTextAttachment *attach = [[SMTextAttachment alloc] init];
//    attach.content = content;
//    attach.contentMode = contentMode;
//    attach.userInfo = userInfo;
//    
//    
//}

#pragma mark - Attribute
- (void)setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]){
        return;
    }
    if (value && ![NSNull isEqual:value]) {
        [self addAttribute:name value:value range:range];
    }else {
        [self removeAttribute:name range:range];
    }
}

- (void)removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

@end
