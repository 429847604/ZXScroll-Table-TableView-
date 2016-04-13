//
//  ZXScrollTableView.m
//  PartyMaster
//
//  Created by zhaoxu on 16/4/11.
//  Copyright © 2016年 ZX. All rights reserved.
//

#define SCROLLSIZE 100

#import "ZXScrollTableView.h"
#import "MJRefresh.h"

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define ZXColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface ZXScrollTableView ()
//<UITableViewDelegate,UITableViewDataSource>

@property (assign,nonatomic) int comPageIndex;
@property (assign,nonatomic) int mesPageIndex;
@property (assign,nonatomic) int type;

@property (strong,nonatomic) NSMutableArray *comDataSource;
@property (strong,nonatomic) NSMutableArray *mesDataSource;

@end

@implementation ZXScrollTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.type = 1;
        self.btnTag = 10;
        self.comPageIndex = 1;
        self.mesPageIndex = 1;
        self.comDataSource = [NSMutableArray array];
        self.mesDataSource = [NSMutableArray array];
        
        //获取评论的数据
        [self addTheCommentsData:10];
        
        //获取评论的数据
        [self addTheCommentsData:11];
    }
    return self;
}

//获取评论的数据
- (void)addTheCommentsData:(NSInteger)tag {
    NSLog(@"%ld", (long)tag);
    int pageCount;
    if (tag == 10) {
        pageCount = self.comPageIndex;
        self.type = 1;
    } else {
        pageCount = self.mesPageIndex;
        self.type = 2;
    }
}

- (void)setBtnTag:(NSInteger)btnTag {
    _btnTag = btnTag;
    
    [UIView animateWithDuration:0.2 animations:^{
        for (int i = 0; i < self.tableCount; i++) {
            UIView *backViews = [self viewWithTag:i+100];
            //更改视图的中心点坐标
            CGPoint points = backViews.center;
            points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*((btnTag-10)-i));
            backViews.center = points;
        }
    }];
}

- (void)setTableCount:(int)tableCount {
    _tableCount = tableCount;
    
    for (int i = 0; i < tableCount; i++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH*i, 0, UISCREEN_WIDTH, self.frame.size.height)];
        backView.userInteractionEnabled = YES;
        backView.tag = i+100;
        [self addSubview:backView];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, self.frame.size.height)];
        tableView.tag = i+1000;
//        tableView.delegate = self;
//        tableView.dataSource = self;
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.backgroundColor = ZXColor(246, 241, 245);
        if (i == 1) {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [backView addSubview:tableView];
        
        [tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(refreshActivityListTableViewHeader)];
        [tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(refreshActivityListTableViewFooter)];
        
        if (i == 0) {//创建最前面的一个View的拖拽手势
            //创建拖拽手势
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesturesFirst:)];
            //无论最大还是最小都只允许一个手指
            panGestureRecognizer.minimumNumberOfTouches = 1;
            panGestureRecognizer.maximumNumberOfTouches = 1;
            [backView addGestureRecognizer:panGestureRecognizer];
        } else if (i == tableCount-1) {//创建最后面的一个View的拖拽手势
            //创建拖拽手势
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesturesLast:)];
            //无论最大还是最小都只允许一个手指
            panGestureRecognizer.minimumNumberOfTouches = 1;
            panGestureRecognizer.maximumNumberOfTouches = 1;
            [backView addGestureRecognizer:panGestureRecognizer];
        } else {
            //创建拖拽手势
            UIPanGestureRecognizer *panGestureRecognizerLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesturesLeft:)];
            //无论最大还是最小都只允许一个手指
            panGestureRecognizerLeft.minimumNumberOfTouches = 1;
            panGestureRecognizerLeft.maximumNumberOfTouches = 1;
            [backView addGestureRecognizer:panGestureRecognizerLeft];
        }
    }
}

#pragma mark  -  刷新
-(void)refreshActivityListTableViewHeader {
    UITableView *tableView = (UITableView *)[self viewWithTag:self.btnTag-10+1000];
    if (self.btnTag == 10) {
        self.comPageIndex = 1;
        [tableView.footer  endRefreshing];
        [tableView.header  endRefreshing];
        [self.comDataSource removeAllObjects];
    } else {
        self.mesPageIndex = 1;
        [tableView.footer  endRefreshing];
        [tableView.header  endRefreshing];
        [self.mesDataSource removeAllObjects];
    }
    
    [self addTheCommentsData:self.btnTag];
}

-(void)refreshActivityListTableViewFooter {
    UITableView *tableView = (UITableView *)[self viewWithTag:self.btnTag-10+1000];
    if (self.btnTag == 10) {
        self.comPageIndex ++;
        [self addTheCommentsData:10];
    } else {
        self.mesPageIndex ++;
        [self addTheCommentsData:11];
    }
    [tableView.footer  endRefreshing];
}

//最前面一个View的拖拽手势
- (void)handlePanGesturesFirst:(UIPanGestureRecognizer *)paramSender{
    if ([self.delegate respondsToSelector:@selector(scrollViewChange:)]) {
        [self.delegate scrollViewChange:paramSender.view.frame.origin.x];
    }
    
    if (paramSender.state != UIGestureRecognizerStateEnded && paramSender.state != UIGestureRecognizerStateFailed){
        //获取移动的大小
        CGPoint point= [paramSender translationInView:paramSender.view];
        for (int i = 0; i < self.tableCount; i++) {
            UIView *backViews = [self viewWithTag:i+100];
            //更改视图的中心点坐标
            CGPoint points = backViews.center;
            points.x += point.x;
            backViews.center = points;
            //每次都清空一下消除坐标叠加
            [paramSender setTranslation:CGPointZero inView:paramSender.view];
        }
    }
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        if (paramSender.view.frame.origin.x > 0 || (paramSender.view.frame.origin.x < 0 && paramSender.view.frame.origin.x > -SCROLLSIZE)) {//滑动不换页面
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    points.x = (UISCREEN_WIDTH/2+UISCREEN_WIDTH*i);
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag];
            }
        } else if (paramSender.view.frame.origin.x <= -SCROLLSIZE) {//滑动换页面
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*((paramSender.view.tag-100)-i));
                    points.x -= UISCREEN_WIDTH;
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag+1];
            }
            
            if (self.btnTag == 10) {
                self.comPageIndex = 1;
                [self.comDataSource removeAllObjects];
            } else {
                self.mesPageIndex = 1;
                [self.mesDataSource removeAllObjects];
            }
            [self addTheCommentsData:self.btnTag];
        }
    }
}

//最后面一个View的拖拽手势
- (void)handlePanGesturesLast:(UIPanGestureRecognizer *)paramSender{
    if ([self.delegate respondsToSelector:@selector(scrollViewChange:)]) {
        [self.delegate scrollViewChange:paramSender.view.frame.origin.x];
    }
    
    if (paramSender.state != UIGestureRecognizerStateEnded && paramSender.state != UIGestureRecognizerStateFailed){
        //获取移动的大小
        CGPoint point= [paramSender translationInView:paramSender.view];
        for (int i = 0; i < self.tableCount; i++) {
            UIView *backViews = [self viewWithTag:i+100];
            //更改视图的中心点坐标
            CGPoint points = backViews.center;
            points.x += point.x;
            backViews.center = points;
            //每次都清空一下消除坐标叠加
            [paramSender setTranslation:CGPointZero inView:paramSender.view];
        }
    }
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        if (paramSender.view.frame.origin.x < 0 || (paramSender.view.frame.origin.x > 0 && paramSender.view.frame.origin.x < SCROLLSIZE)) {//滑动不换页面
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*(self.tableCount-1-i));
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag];
            }
        } else if (paramSender.view.frame.origin.x >= SCROLLSIZE) {//滑动换页面
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*((paramSender.view.tag-100)-i));
                    points.x += UISCREEN_WIDTH;
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag-1];
            }
            
            if (self.btnTag == 10) {
                self.comPageIndex = 1;
                [self.comDataSource removeAllObjects];
            } else {
                self.mesPageIndex = 1;
                [self.mesDataSource removeAllObjects];
            }
            [self addTheCommentsData:self.btnTag];
        }
    }
}

//中间一个View的向左拖拽手势
- (void)handlePanGesturesLeft:(UIPanGestureRecognizer *)paramSender{
    if ([self.delegate respondsToSelector:@selector(scrollViewChange:)]) {
        [self.delegate scrollViewChange:paramSender.view.frame.origin.x];
    }
    
    if (paramSender.state != UIGestureRecognizerStateEnded && paramSender.state != UIGestureRecognizerStateFailed){
        //获取移动的大小
        CGPoint point= [paramSender translationInView:paramSender.view];
        for (int i = 0; i < self.tableCount; i++) {
            UIView *backViews = [self viewWithTag:i+100];
            //更改视图的中心点坐标
            CGPoint points = backViews.center;
            points.x += point.x;
            backViews.center = points;
            //每次都清空一下消除坐标叠加
            [paramSender setTranslation:CGPointZero inView:paramSender.view];
        }
    }
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        if (paramSender.view.frame.origin.x >= SCROLLSIZE) {//滑动换页面向左
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    if (i <= (paramSender.view.tag-100)) {
                        
                    }
                    points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*((paramSender.view.tag-100)-i));
                    points.x += UISCREEN_WIDTH;
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag-1];
            }
            
            if (self.btnTag == 10) {
                self.comPageIndex = 1;
                [self.comDataSource removeAllObjects];
            } else {
                self.mesPageIndex = 1;
                [self.mesDataSource removeAllObjects];
            }
            [self addTheCommentsData:self.btnTag];
        } else if (paramSender.view.frame.origin.x <= -SCROLLSIZE) {//滑动换页面向右
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*((paramSender.view.tag-100)-i));
                    points.x -= UISCREEN_WIDTH;
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag+1];
            }
            
            if (self.btnTag == 10) {
                self.comPageIndex = 1;
                [self.comDataSource removeAllObjects];
            } else {
                self.mesPageIndex = 1;
                [self.mesDataSource removeAllObjects];
            }
            [self addTheCommentsData:self.btnTag];
        } else {//滑动不换页面
            [UIView animateWithDuration:0.2 animations:^{
                for (int i = 0; i < self.tableCount; i++) {
                    UIView *backViews = [self viewWithTag:i+100];
                    //更改视图的中心点坐标
                    CGPoint points = backViews.center;
                    points.x = (UISCREEN_WIDTH/2-UISCREEN_WIDTH*((paramSender.view.tag-100)-i));
                    backViews.center = points;
                    //每次都清空一下消除坐标叠加
                    [paramSender setTranslation:CGPointZero inView:paramSender.view];
                }
            }];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidTheTag:)]) {
                [self.delegate scrollViewDidTheTag:self.btnTag];
            }
        }
    }
}

#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1000) {
        return self.comDataSource.count;
    } else {
        return self.mesDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
