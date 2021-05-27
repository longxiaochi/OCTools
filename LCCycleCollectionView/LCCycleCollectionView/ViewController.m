//
//  ViewController.m
//  LCCycleCollectionView
//
//  Created by Long on 2021/5/26.
//

#import "ViewController.h"
#import "PPCycleColletionView.h"
#import "PPCycleCell.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.grayColor;
    
    PPCycleColletionView *cyleView = [[PPCycleColletionView alloc] initWithFrame:CGRectMake(0, 88, self.view.bounds.size.width, 200) cycleCell:[PPCycleCell new]];
    cyleView.scrollInterval = 2;
    cyleView.autoPage = YES;
    [cyleView setPageIndicatorImage:[UIImage imageNamed:@"normal_unselect"] currentPageIndicatorImage:[UIImage imageNamed:@"normal_select"]];
    cyleView.data = @[@"Hello222",@"world22",@"!22"];
    [self.view addSubview:cyleView];
}


@end
