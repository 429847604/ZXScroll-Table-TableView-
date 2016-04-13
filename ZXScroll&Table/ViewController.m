//
//  ViewController.m
//  ZXScroll&Table
//
//  Created by zhaoxu on 16/4/12.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import "ViewController.h"
#import "ZXScrollTableView.h"

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define ZXColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface ViewController () <ZXScrollTableViewDelegate>

@property (assign,nonatomic) NSInteger btnTag;

@property (weak,nonatomic) ZXScrollTableView *scrollTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnTag = 10;
    
    //创建顶部选择按钮
    [self addBtn];
    
    ZXScrollTableView *scrollTableView = [[ZXScrollTableView alloc] initWithFrame:CGRectMake(0, 64+48, UISCREEN_WIDTH*2, UISCREEN_HEIGHT-64-48)];
    scrollTableView.tableCount = 2;
    scrollTableView.delegate = self;
    [self.view addSubview:scrollTableView];
    self.scrollTableView = scrollTableView;
    
    // Do any additional setup after loading the view, typically from a nib.
}

//创建顶部选择按钮
- (void)addBtn {
    NSArray *imageArray = @[@"评论",@"铃铛灰色"];
    NSArray *titleArray = @[@"评论回复",@"系统通知"];
    NSArray *secImageArray = @[@"评论紫色",@"铃铛紫色"];
    for (int i = 0; i < 2; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0+UISCREEN_WIDTH/2*i, 64, UISCREEN_WIDTH/2, 48)];
        view.backgroundColor = [UIColor whiteColor];
        view.userInteractionEnabled = YES;
        [self.view addSubview:view];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(switchTheBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, UISCREEN_WIDTH/2, 48);
        button.tag = i+10;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH/4-10, 10, 60, 20)];
        label.text = [NSString stringWithFormat:@"%@", titleArray[i]];
        label.font = [UIFont systemFontOfSize:15];
        label.tag = i+100;
        [button addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH/4-35, 10, 20, 20)];
        imageView.tag = i+1000;
        [button addSubview:imageView];
        
        if (i == 0) {
            imageView.image = [UIImage imageNamed:secImageArray[i]];
            label.textColor = ZXColor(146, 32, 146);
        } else {
            imageView.image = [UIImage imageNamed:imageArray[i]];
            label.textColor = ZXColor(153, 153, 153);
        }
        
        [view addSubview:button];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 47, UISCREEN_WIDTH/2, 1)];
        lineView.backgroundColor = ZXColor(238, 236, 237);
        [view addSubview:lineView];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH/4-10, 64+35, 60, 3)];
    lineView.layer.masksToBounds = YES;
    lineView.layer.cornerRadius = 3/2;
    lineView.tag = 10000;
    lineView.backgroundColor = ZXColor(146, 32, 146);
    [self.view addSubview:lineView];
}

//头部按钮点击事件
- (void)switchTheBtn:(UIButton *)sender {
    [self switchTheTableView:sender.tag];
}

#pragma mark --ZXScrollTableViewDelegate
- (void)scrollViewChange:(CGFloat)x {
    UIView *view = [self.view viewWithTag:10000];
    if (self.btnTag == 10) {
        view.frame = CGRectMake(UISCREEN_WIDTH/4-10-x/2, 64+35, 60, 3);
    } else {
        view.frame = CGRectMake(UISCREEN_WIDTH/4+UISCREEN_WIDTH/2-10-x/2, 64+35, 60, 3);
    }
}

- (void)scrollViewDidTheTag:(NSInteger)theTag {
    [self switchTheTableView:theTag];
    self.btnTag = theTag;
}

//顶部按钮切换的点击事件
- (void)switchTheTableView:(NSInteger)tag {
    UILabel *secLabel = (UILabel *)[self.view viewWithTag:self.btnTag-10+100];
    secLabel.textColor = ZXColor(153, 153, 153);
    UIImageView *secImageView = (UIImageView *)[self.view viewWithTag:self.btnTag-10+1000];
    if (self.btnTag == 10) {
        secImageView.image = [UIImage imageNamed:@"评论"];
    } else {
        secImageView.image = [UIImage imageNamed:@"铃铛灰色"];
    }
    
    UILabel *label = (UILabel *)[self.view viewWithTag:tag-10+100];
    label.textColor = ZXColor(146, 32, 146);
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:tag-10+1000];
    if (tag == 10) {
        imageView.image = [UIImage imageNamed:@"评论紫色"];
    } else {
        imageView.image = [UIImage imageNamed:@"铃铛紫色"];
    }
    self.btnTag = tag;
    
    self.scrollTableView.btnTag = self.btnTag;
    
    UIView *view = [self.view viewWithTag:10000];
    [UIView animateWithDuration:0.2 animations:^{
        if (tag == 10) {
            view.frame = CGRectMake(UISCREEN_WIDTH/4-10, 64+35, 60, 3);
        } else {
            view.frame = CGRectMake(UISCREEN_WIDTH/4-10+UISCREEN_WIDTH/2, 64+35, 60, 3);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
