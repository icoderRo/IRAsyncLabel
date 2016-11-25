//
//  SMTextLayout.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextLayout.h"

@interface SMTextLayout ()
@property (nonatomic,strong) SMTextContainer *container;
@end

@implementation SMTextLayout
+ (instancetype)SM_layoutWithContainer:(SMTextContainer *)container text:(NSAttributedString *)text {
    
    if (!text || !container) return nil;
    
    
    
    SMTextLayout *layout = [[SMTextLayout alloc] init];
    layout.container = container;
    
    return layout;
}
@end
