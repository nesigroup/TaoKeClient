
//  LLSegmentBar.m
//  LLSegmentBar
//
//  Created by liushaohua on 2017/6/3.
//  Copyright © 2017年 416997919@qq.com. All rights reserved.
//

#import "LLSegmentBar.h"
#import "UIView+LLSegmentBar.h"

#define KMinMargin (/*TKScale(23)*/self.buttonsMargin)

@interface LLSegmentBar ()

/** 内容承载视图 */
@property (nonatomic, weak) UIScrollView *contentView;
/** 添加的按钮数据 */
@property (nonatomic, strong) NSMutableArray <UIButton *>*itemBtns;
/** 指示器 */
@property (nonatomic, weak) UIView *indicatorView;

@property (nonatomic, strong) LLSegmentBarConfig *config;

@end

@implementation LLSegmentBar{
// 记录最后一次点击的按钮
    UIButton *_lastBtn;
}

+ (instancetype)segmentBarWithFrame:(CGRect)frame{
    LLSegmentBar *segmentBar = [[LLSegmentBar alloc]initWithFrame:frame];
    return segmentBar;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = self.config.sBBackColor;
        self.borderMargin = 0.0;
        self.isSimpleView = false;
        self.indicatorFitTitle = true;
        self.indicatorConstWidth = 14;
        self.buttonAddctionWidth = 0;
        self.indicatorMarginFromBottom = 0;
        self.buttonsMinMarginFromBorder = 23 * UIScreen.mainScreen.bounds.size.width / 375.0;
        self.buttonsMargin = self.buttonsMinMarginFromBorder;
    }
    return self;
}



- (void)updateWithConfig:(void (^)(LLSegmentBarConfig *))configBlock{
    if (configBlock) {
        configBlock(self.config);
    }
    // 按照当前的self.config 进行刷新
    self.backgroundColor = self.config.sBBackColor;
    self.indicatorView.backgroundColor = self.config.indicatorC;
    for (UIButton *btn in self.itemBtns) {
        [btn setTitleColor:self.config.itemNC forState:UIControlStateNormal];
        [btn setTitleColor:self.config.itemSC forState:UIControlStateSelected];
        btn.backgroundColor = self.config.itemBC;
        btn.layer.cornerRadius = self.config.itemRa;
        btn.clipsToBounds = (self.config.itemRadius != 0);
        btn.titleLabel.font = self.config.itemF;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

-  (void)setSelectIndex:(NSInteger)selectIndex{
        
    if (self.items.count == 0 || selectIndex < 0 || selectIndex > self.itemBtns.count- 1) {
        return;
    }
    
    
    _selectIndex = selectIndex;
    UIButton *btn = self.itemBtns[selectIndex];
    [self btnClick:btn];
}

- (void)setItems:(NSArray<NSString *> *)items{
    _items = items;
    // 删除之前添加过多的组件
    [self.itemBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.itemBtns = nil;
    
    // 根据所有的选项数据源 创建Button 添加到内容视图
    for (NSString *item in items) {
        UIButton *btn = [[UIButton alloc]init];
        btn.tag = self.itemBtns.count;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
        [btn setTitleColor:self.config.itemNC forState:UIControlStateNormal];
        [btn setTitleColor:self.config.itemSC forState:UIControlStateSelected];
        btn.backgroundColor = self.config.itemBC;
        btn.titleLabel.font = self.config.itemF;
        btn.layer.cornerRadius = self.config.itemRa;
        btn.clipsToBounds = (self.config.itemRadius != 0);
        [btn setTitle:item forState:UIControlStateNormal];
        [self.contentView addSubview:btn];
        [self.itemBtns addObject:btn];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - private
- (void)btnClick:(UIButton *)sender{
    
    [self changedSelectedOnlyWithIndex:sender.tag actionDelegate:true];
}



-(void)changedSelectedOnlyWithIndex:(NSInteger)index
{
    [self changedSelectedOnlyWithIndex:index actionDelegate:false];
}


-(void)changedSelectedOnlyWithIndex:(NSInteger)index actionDelegate:(BOOL)action
{
    if (index >= self.itemBtns.count) {
        
        return;
    }
    
    UIButton *sender = self.itemBtns[index];
    
    //如果连续点击，不作用
    if (sender.tag != _lastBtn.tag && action) {
        
        if ([self.delegate respondsToSelector:@selector(segmentBar:didSelectIndex:fromIndex:)]) {
            
            [self.delegate segmentBar:self didSelectIndex:sender.tag fromIndex:_lastBtn.tag];
        }
    }
    
    _selectIndex = sender.tag;
    
    _lastBtn.selected = NO;
    sender.selected = YES;
    _lastBtn = sender;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (self.indicatorFitTitle) {
            
            self.indicatorView.width = sender.width /*+ self.config.indicatorW * 2*/;
            
        }else {
            
            self.indicatorView.width = self.indicatorConstWidth;
        }
        
//        self.indicatorView.width = sender.width /*+ self.config.indicatorW * 2*/;
        self.indicatorView.centerX = sender.centerX;
    }];
    
    // 滚动到Btn的位置
    CGFloat scrollX = sender.x - self.contentView.width * 0.5;
    
    // 考虑临界的位置
    if (scrollX < 0) {
        scrollX = 0;
    }
    
    
    
    if (scrollX > self.contentView.contentSize.width - self.contentView.width) {
        
        scrollX = self.contentView.contentSize.width - self.contentView.width;
    }
    
    [self.contentView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
}



#pragma mark - layout
- (void)layoutSubviews{
    
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    
    CGFloat totalBtnWidth = 0;
    for (UIButton *btn in self.itemBtns) {
        [btn sizeToFit];
        btn.width = (btn.width + self.buttonAddctionWidth);
        totalBtnWidth += (btn.width + self.buttonAddctionWidth);
    }
    
    CGFloat caculateMargin = (self.width - totalBtnWidth) / (self.items.count + 1);
    
    if (caculateMargin < KMinMargin) {//边距
        caculateMargin = KMinMargin;
    }
    
    CGFloat lastX = self.buttonsMinMarginFromBorder;
    
    if (self.isSimpleView) {
        
        caculateMargin = (self.width - totalBtnWidth - self.borderMargin * 2) / (self.items.count - 1);
        lastX = self.borderMargin;//使用自定义边距
        
    }

    
    for (UIButton *btn in self.itemBtns) {

        btn.y = 2;
        
        btn.x = lastX;
        
        lastX += btn.width + caculateMargin;

    }
    
    self.contentView.contentSize =  self.isSimpleView ? CGSizeMake(self.width, 0) : CGSizeMake(lastX, 0);
    
    
    if (self.itemBtns.count == 0) {
        return;
    }
    
    
    UIButton *btn = self.itemBtns[self.selectIndex];
    
    if (self.indicatorFitTitle) {
        
        self.indicatorView.width = btn.width /*+ self.config.indicatorW * 2*/;
        
    }else {
        
        self.indicatorView.width = self.indicatorConstWidth;
    }
    

    self.indicatorView.centerX = btn.centerX;
    self.indicatorView.height = self.config.indicatorH;
    self.indicatorView.y = self.height - self.indicatorView.height - self.indicatorMarginFromBottom;
    
    //圆角
    if (self.config.indicatorRadius != 0) {
        
        CGFloat radius = self.config.indicatorRadius;
        
        if (radius > MIN(self.indicatorView.tk_height,self.indicatorView.tk_width)) {
            
            radius = MIN(self.indicatorView.tk_height,self.indicatorView.tk_width) / 2.0;
        }
        
        self.indicatorView.layer.cornerRadius = self.config.indicatorRadius;
    }
}

#pragma mark - lazy-init


- (NSMutableArray<UIButton *> *)itemBtns {
    if (!_itemBtns) {
        _itemBtns = [NSMutableArray array];
    }
    return _itemBtns;
}

- (UIView *)indicatorView {
    if (!_indicatorView) {
        CGFloat indicatorH = self.config.indicatorH;
        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - indicatorH, 0, indicatorH)];
        indicatorView.backgroundColor = self.config.indicatorC;
        [self.contentView addSubview:indicatorView];
        _indicatorView = indicatorView;
    }
    return _indicatorView;
}

- (UIScrollView *)contentView {
    if (!_contentView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:scrollView];
        _contentView = scrollView;
    }
    return _contentView;
}

- (LLSegmentBarConfig *)config{
    if (!_config) {
        _config = [LLSegmentBarConfig defaultConfig];
    }
    return _config;
}







@end