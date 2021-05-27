//
//  PPCycleColletionView.m
//  PPCycleColletionView
//
//  Created by Long on 2021/5/26.
//

#import "PPCycleColletionView.h"
#import "PPCycleCell.h"

@interface PPProxy : NSProxy
@property (nonatomic, weak)id target;
+ (instancetype)proxyWithTarget:(id)target;
@end

@implementation PPProxy
+ (instancetype)proxyWithTarget:(id)target {
    PPProxy *proxy = [PPProxy alloc];
    proxy.target = target;
    return proxy;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end


//缩略点之间的间隙
#define kIndicatorPadding       8.0f
#define kIndicatorWidth         3.0f
#define kMoveIndicatorWidth     10.0f
#define kIndicatorDefaultHeight 3.0f

@interface PPPageControl : UIView

/// 容器View
@property (nonatomic, strong) UIView *pageIndicatorContentView;

/// indicator图片数组
@property (nonatomic, strong) NSMutableArray *indicatorImageViews;

/// move indicator图片, 移动的图片
@property (nonatomic, strong) UIImageView *currentIndicatorImageView;

/// default is 0
@property (nonatomic, assign) NSInteger numberOfPages;

/// default is 0. Value is pinned to 0..numberOfPages-1
@property (nonatomic, assign) NSInteger currentPage;

/// default is lightGrayColor
@property (nullable, nonatomic, strong) UIColor *pageIndicatorTintColor;

/// The tint color for the currently-selected indicators. Default is blackColor.
@property (nullable, nonatomic, strong) UIColor *currentPageIndicatorTintColor;

/// The image for the indicators. Default is nil.
@property (nullable, nonatomic, strong) UIImage *pageIndicatorImage;

/// The image for the currently-selected indicators. Default is nil.
@property (nullable, nonatomic, strong) UIImage *currentPageIndicatorImage;


/// 设置默认指示器图片以及当前页指示器的图片
/// @param indicatorImage 默认指示器图片
/// @param curIndicatorImage 当前页指示器的图片
- (void)setPageIndicatorImage:(nonnull UIImage *)indicatorImage currentPageIndicatorImage:(nonnull UIImage *)curIndicatorImage;

@end

@implementation PPPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _indicatorImageViews = [NSMutableArray array];
        _pageIndicatorTintColor = [UIColor lightGrayColor];
        _currentPageIndicatorTintColor = [UIColor blackColor];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _pageIndicatorContentView = [[UIView alloc] init];
    _pageIndicatorContentView.backgroundColor = UIColor.clearColor;
    [self addSubview:_pageIndicatorContentView];

    _currentIndicatorImageView = [[UIImageView alloc] init];
}

#pragma mark - Public Method
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages <= 0) return;
    _numberOfPages = numberOfPages;
    
    if (_pageIndicatorContentView.subviews.count > 0) {
        [_pageIndicatorContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    for (int i = 0; i < numberOfPages; i++) {
        UIImageView* imageView = [[UIImageView alloc] init];
        
        if (_pageIndicatorImage) {
            imageView.image = _pageIndicatorImage;
            imageView.backgroundColor = [UIColor clearColor];
        } else {
            imageView.backgroundColor = _pageIndicatorTintColor;
        }
        imageView.frame = CGRectMake(i * (kIndicatorWidth + kIndicatorPadding), 0, kIndicatorWidth, kIndicatorDefaultHeight);
        
        [_pageIndicatorContentView addSubview:imageView];
        [self.indicatorImageViews addObject:imageView];
    }
    
    /// 计算总宽度
    CGFloat indicatorContentViewWidth = (kIndicatorWidth * numberOfPages) + (kIndicatorPadding * (numberOfPages - 1));
    _pageIndicatorContentView.frame = CGRectMake((self.frame.size.width - indicatorContentViewWidth)/2.0, CGRectGetMidY(self.bounds) - kIndicatorDefaultHeight, indicatorContentViewWidth, kIndicatorDefaultHeight);
    
    UIImageView *firstIndicatorImageView = [self.indicatorImageViews firstObject];
    _currentIndicatorImageView.frame = CGRectMake(0, 0, kMoveIndicatorWidth, kIndicatorDefaultHeight);
    _currentIndicatorImageView.center = firstIndicatorImageView.center;
    if (_currentPageIndicatorImage) {
        _currentIndicatorImageView.image = _currentPageIndicatorImage;
        _currentIndicatorImageView.backgroundColor = [UIColor clearColor];
    } else {
        _currentIndicatorImageView.backgroundColor = _currentPageIndicatorTintColor;
    }
    [_pageIndicatorContentView addSubview:_currentIndicatorImageView];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage < 0 || currentPage >= self.indicatorImageViews.count) return;
    _currentPage = currentPage;
    
    UIImageView *currentImageView = self.indicatorImageViews[currentPage];
    self.currentIndicatorImageView.center = currentImageView.center;
}

- (void)setPageIndicatorImage:(nonnull UIImage *)indicatorImage currentPageIndicatorImage:(nonnull UIImage *)curIndicatorImage {
    self.pageIndicatorImage = indicatorImage;
    self.currentPageIndicatorImage = curIndicatorImage;
    
    if (self.indicatorImageViews.count > 0) {
        for (UIImageView *imageView in self.indicatorImageViews) {
            imageView.backgroundColor = [UIColor clearColor];
            imageView.image = indicatorImage;
        }
        self.currentIndicatorImageView.image = curIndicatorImage;
        self.currentIndicatorImageView.backgroundColor = UIColor.clearColor;
    }
}

@end


//轮播间隔
#define kDefaultScrollInterval 3.0f

@interface PPCycleColletionView ()<UICollectionViewDelegate,UICollectionViewDataSource>
/// 用于滚动的collectionView
@property (nonatomic, strong) UICollectionView *collectionView;
/// 内容cell
@property (nonatomic, strong) UICollectionViewCell<PPCycleCellProtocol> *cycleCell;
///
@property (nonatomic, strong) PPPageControl *pageControl;
/// 定时器
@property (nonatomic, strong) NSTimer *timer;
/// 数据源
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation PPCycleColletionView

- (instancetype)initWithFrame:(CGRect)frame
                    cycleCell:(nonnull UICollectionViewCell<PPCycleCellProtocol> *)cycleCell {
    if (self = [super initWithFrame:frame]) {
        self.cycleCell = cycleCell;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = true;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[self.cycleCell class] forCellWithReuseIdentifier:self.cycleCell.reuseIdentifier];
    _collectionView.showsHorizontalScrollIndicator = false;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.collectionView];
    

    CGFloat controlHeight = 35.0f;
    _pageControl = [[PPPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - controlHeight, self.bounds.size.width, controlHeight)];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.isAccessibilityElement = YES;
    _pageControl.accessibilityLabel = @"page control";
    
    [self addSubview:_pageControl];
}

#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<PPCycleCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cycleCell.reuseIdentifier forIndexPath:indexPath];
    id model = self.dataSource[indexPath.row];
    [cell configCell:model];
    return cell;
}

#pragma mark - UIScrollViewDelegate
//手动拖拽结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _cycleScroll];
    //拖拽动作后间隔3s继续轮播
    if (_autoPage) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow: _scrollInterval > 0 ? _scrollInterval : kDefaultScrollInterval];
    }
}

//自动轮播结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self _cycleScroll];
}

#pragma mark - Public Method
- (void)setData:(nonnull NSArray *)data {
    if (![data isKindOfClass:NSArray.class] || data.count <= 0) return;
    
    // 只有一个的情况  TODO::
    if (data.count == 1) {
        
    } else {
        self.dataSource = [NSMutableArray arrayWithArray:data];
        // 在第一个之前和最后一个之后分别插入数据
        [self.dataSource addObject:data.firstObject];
        [self.dataSource insertObject:data.lastObject atIndex:0];
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
        self.pageControl.numberOfPages = data.count;
    }
}

- (void)setAutoPage:(BOOL)autoPage {
    _autoPage = autoPage;
    
    // 启动一个定时器
    if (autoPage && !self.timer) {
        NSInteger interval = _scrollInterval > 0 ? _scrollInterval : kDefaultScrollInterval;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:[PPProxy proxyWithTarget:self] selector:@selector(_showNext) userInfo:nil repeats:true];
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    }
}

- (void)setScrollInterval:(NSInteger)scrollInterval {
    _scrollInterval = scrollInterval > 0 ? scrollInterval : 0;
    
    // 设置时间间隔，将原有timer置为无效，重新启动一个timer
    if (self.timer && scrollInterval > 0) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:scrollInterval target:[PPProxy proxyWithTarget:self] selector:@selector(_showNext) userInfo:nil repeats:true];
        self.timer.fireDate = _autoPage ? [NSDate dateWithTimeIntervalSinceNow:scrollInterval] : [NSDate distantFuture];
    }
}

- (void)setPageIndicatorImage:(nonnull UIImage *)indicatorImage currentPageIndicatorImage:(nonnull UIImage *)curIndicatorImage {
    [self.pageControl setPageIndicatorImage:indicatorImage currentPageIndicatorImage:curIndicatorImage];
}

#pragma mark - Private Method
// 滚动到右边
- (void)_cycleScroll {
    NSInteger page = self.collectionView.contentOffset.x/self.collectionView.bounds.size.width;
    if (page == 0) {
        // 滚动到左边
        self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width * (self.dataSource.count - 2), 0);
        self.pageControl.currentPage = self.dataSource.count - 2;
    }else if (page == self.dataSource.count - 1){
        // 滚动到右边
        self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width, 0);
        self.pageControl.currentPage = 0;
    }else{
        self.pageControl.currentPage = page - 1;
    }
}

//轮播方法, 自动显示下一个
- (void)_showNext {
    //手指拖拽是禁止自动轮播
    if (self.collectionView.isDragging) return;
    CGFloat targetX =  self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
    [self.collectionView setContentOffset:CGPointMake(targetX, 0) animated:true];
}

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end



