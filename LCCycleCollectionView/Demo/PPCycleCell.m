//
//  PPCycleCell.m
//  LCCycleCollectionView
//
//  Created by Long on 2021/5/26.
//

#import "PPCycleCell.h"

@interface PPCycleCell()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation PPCycleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    self.backgroundColor = UIColor.greenColor;
    
    self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:50];
    [self addSubview:self.textLabel];
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

- (void)configCell:(id)model {
    if (model && [model isKindOfClass:NSString.class]) {
        self.textLabel.text = model;
    }
}

@end
