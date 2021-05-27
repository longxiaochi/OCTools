//
//  PPCycleCell.h
//  LCCycleCollectionView
//
//  Created by Long on 2021/5/26.
//

#import <UIKit/UIKit.h>
#import "PPCycleColletionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPCycleCell : UICollectionViewCell<PPCycleCellProtocol>

- (NSString *)reuseIdentifier;

- (void)configCell:(id)model;

@end

NS_ASSUME_NONNULL_END
