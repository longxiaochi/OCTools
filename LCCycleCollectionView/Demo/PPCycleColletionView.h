//
//  PPCycleColletionView.h
//  PPCycleColletionView
//
//  Created by Long on 2021/5/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PPCycleCellProtocol <NSObject>

@required
/// cell 的唯一标识符，用于重用
- (NSString *)reuseIdentifier;

/// 配置cell的数据
/// @param model 用于配置cell的数据
- (void)configCell:(id)model;

@end


@interface PPCycleColletionView : UIView

/// 滚动的时间间隔， 默认为3秒
@property (nonatomic, assign) NSInteger scrollInterval;

/// 自动翻页 默认 NO
@property (nonatomic, assign) BOOL autoPage;

/// 指示器的颜色， 默认是lightGrayColor
@property (nonnull, nonatomic, strong) UIColor *pageIndicatorTintColor;

/// 当前页指示器的颜色， 默认是blackColor
@property (nonnull, nonatomic, strong) UIColor *currentPageIndicatorTintColor;

/// 轮播所需要的数据
@property (nonnull, nonatomic, strong) NSArray *data;


/// 初始化方法
/// @param frame 轮播图空间的位置和大小
/// @param cycleCell 用于轮播的cell
- (instancetype)initWithFrame:(CGRect)frame cycleCell:(nonnull UICollectionViewCell<PPCycleCellProtocol> *)cycleCell;


/// 设置默认指示器图片以及当前页指示器的图片
/// @param indicatorImage 默认指示器图片
/// @param curIndicatorImage 当前页指示器的图片
- (void)setPageIndicatorImage:(nonnull UIImage *)indicatorImage currentPageIndicatorImage:(nonnull UIImage *)curIndicatorImage;

@end

NS_ASSUME_NONNULL_END
