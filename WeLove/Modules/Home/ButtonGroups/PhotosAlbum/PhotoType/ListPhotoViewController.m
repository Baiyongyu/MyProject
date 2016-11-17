//
//  ListPhotoViewController.m
//  WeLove
//
//  Created by 宇玄丶 on 2016/11/3.
//  Copyright © 2016年 anqianmo. All rights reserved.
//

#import "ListPhotoViewController.h"
#import "MyCell.h"
#define cellHeight 250

@interface ListPhotoViewController () <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,strong) UITableView * tableView;

@end

@implementation ListPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self layoutConstraints];
}



- (void)loadSubViews {
   // [super loadSubViews];
   // self.titleLabel.text = @"列表相册";
    //self.leftBtn.hidden = NO;
}

- (void)loadData {
    _dataArray = [[NSMutableArray alloc]init];
    for (int i = 1; i < 28; i++)
    {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"WechatIMG%d.jpeg",i]];
        [_dataArray addObject:image];
    }
}

- (void)layoutConstraints {
    //[super layoutConstraints];
    [self createTableView];
}

//创建tableView
- (void)createTableView {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

#pragma mark ---------tableView-----------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (cell == nil)
    {
        cell = [[MyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    }
    return cell;
}

// 在willDisplayCell里面处理数据能优化tableview的滑动流畅性
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MyCell * myCell = (MyCell *)cell;
    
    [myCell setImg:_dataArray[indexPath.row]];
    [myCell cellOffset];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // visibleCells 获取界面上能显示出来了cell
    NSArray<MyCell *> *array = [self.tableView visibleCells];
    
    //enumerateObjectsUsingBlock 类似于for，但是比for更快
    [array enumerateObjectsUsingBlock:^(MyCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj cellOffset];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
