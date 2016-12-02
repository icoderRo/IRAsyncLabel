//
//  ViewController.m
//  SMAsyncLabel
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "ViewController.h"
#import "SMAsyncLabel.h"
#import "Masonry.h"
#import "SMTextContainer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SMAsyncLabel *label = [[SMAsyncLabel alloc] initWithFrame:CGRectMake(0, 20, 200, 400)];
    NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd";
    label.font = [UIFont systemFontOfSize:20];
    label.text = test;
    label.textColor = [UIColor greenColor];
    label.backgroundColor = [UIColor redColor];
    [self.view addSubview:label];
    
    
    SMAsyncLabel *label1 = [[SMAsyncLabel alloc] init];
    
    NSString *test1 = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd    sdafasgdhfjg!!!!!!!!!!!!Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd    sdafasgdhfjg!!!!!!!!!!!!";
    label1.backgroundColor = [UIColor yellowColor];
    label1.textColor = [UIColor blueColor];
    label1.text = test1;
    label1.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:label1];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_right).offset(0);
        make.top.equalTo(label).offset(10);
        make.width.equalTo(@(200));
        make.bottom.equalTo(self.view).offset(-200);
    }];
    
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] initWithString:test1];
            [attrs setTextColor:[UIColor whiteColor] range:NSMakeRange(0, attrs.length)];
            SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:CGSizeMake(200, 200)];
            SMTextLayout *textLayout = [SMTextLayout sm_layoutWithContainer:textContainer text:attrs];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                SMAsyncLabel *label = [SMAsyncLabel new];
                
                label.textLayout = textLayout;
                label.frame = CGRectMake(10, 400,textLayout.size.width, textLayout.size.height);
                label.backgroundColor = [UIColor grayColor];
                [self.view addSubview:label];
            });
            
        });
    }
    
    {
        UILabel *label = [[UILabel alloc] init];
        label.text = test1;
        label.backgroundColor = [UIColor orangeColor];
        label.numberOfLines = 0;
        label.preferredMaxLayoutWidth = 200;
        label.font = [UIFont systemFontOfSize:13];
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label1.mas_bottom).offset(-100);
            make.right.equalTo(self.view).offset(-10);
      
        }];
    }
    
    {
        SMAsyncLabel *label = [[SMAsyncLabel alloc] init];
        NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd";
        label.font = [UIFont systemFontOfSize:20];
        label.text = test;
        label.textColor = [UIColor whiteColor];
        label.preferredMaxLayoutWidth = 200;
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor greenColor];
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
             make.center.equalTo(self.view);
        }];
    }
}



@end
