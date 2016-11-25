//
//  SMAsyncLabel.h
//  SMAsyncLabel
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTextLayout.h"
#import "SMTextStorage.h"

@interface SMAsyncLabel : UIView
@property (nonatomic, strong) SMTextLayout *layout;
@property (nonatomic, copy) NSArray<SMTextStorage *> *textArray;
@end
