//
//  MineViewController.m
//  WeLove
//
//  Created by 宇玄丶 on 2016/11/13.
//  Copyright © 2016年 qianmo. All rights reserved.
//

#import "MineViewController.h"
/** Nav */
#import "NavHeadTitleView.h"
/** headView */
#import "HeadImageView.h"
#import "HeadLineView.h"

#import "DayTimeCell.h"

#import "LineDayModel.h"
#import "LineMonthModel.h"
#import "LineDisplayModel.h"

#import "BirdFlyViewController.h" // 飞翔小鸟
#import "WebViewController.h"
#import "PhotosTypeViewController.h"
#import "PhotoAlbumViewController.h"  // 左右滑动模式
#import "AlbumPhotosViewController.h" // 流式
#import "ListPhotoViewController.h"   // 列表

@interface MineViewController ()<NavHeadTitleViewDelegate,headLineDelegate,UITableViewDataSource,UITableViewDelegate>
{
    //头像
    UIImageView *_headerImg;
    //昵称
    UILabel *_nickLabel;
}

@property(nonatomic,strong)UIView *headerView;

@property(nonatomic,strong)UIImageView *backgroundImgV;//背景图
/** 头部 */
@property(nonatomic,assign)float backImgHeight;
@property(nonatomic,assign)float backImgWidth;
@property(nonatomic,assign)float backImgOrgy;
@property(nonatomic,strong)NavHeadTitleView *NavView;//导航栏
@property(nonatomic,strong)HeadImageView *headImageView;//头视图
@property(nonatomic,strong)HeadLineView *headLineView;//
@property(nonatomic,assign)int rowHeight;
@property(nonatomic,strong)UITableView *tableView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 拉伸顶部图片
    [self lashenBgView];
    // 创建导航栏
    [self createNav];
    // 创建TableView
    [self createTableView];
}
#pragma mark - 拉伸顶部图片
- (void)lashenBgView {
    
    _backgroundImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 180)];
    _backgroundImgV.image = [UIImage imageNamed:@"lbg41009"];
    _backgroundImgV.userInteractionEnabled = YES;
    _backImgHeight = _backgroundImgV.frame.size.height;
    _backImgWidth = _backgroundImgV.frame.size.width;
    _backImgOrgy = _backgroundImgV.frame.origin.y;
    [self.view addSubview:_backgroundImgV];
}
#pragma mark - 创建TableView
- (void)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 49) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    _tableView.tableHeaderView = self.headerView;
}

#pragma mark - 头视图
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 180)];
        _headerView.backgroundColor = [UIColor clearColor];
        
        // 头像
        _headerImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame) - 40, 80, 80)];
        _headerImg.center = CGPointMake(kScreenWidth/2, 100);
        [_headerImg setImage:[UIImage imageNamed:@"WechatIMG11.jpeg"]];
        [_headerImg.layer setMasksToBounds:YES];
        [_headerImg.layer setCornerRadius:2.0f];
        _headerImg.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [_headerImg addGestureRecognizer:tap];
        [_headerView addSubview:_headerImg];
        // 昵称
        _nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(147, CGRectGetMaxY(_headerImg.frame) + 20, kScreenWidth - 20, 20)];
        _nickLabel.center = CGPointMake(kScreenWidth/2, 160);
        _nickLabel.text = @"◆◇、遇见你、是我今生最美好的相遇...";
        _nickLabel.textColor = kDarkGrayColor;
        _nickLabel.font = XiHeiFont(14);
        _nickLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_nickLabel];
    }
    return _headerView;
}


// 头像点击事件
- (void)tapClick:(UITapGestureRecognizer *)recognizer {
    NSLog(@"修改头像");
}

#pragma mark - 创建导航栏
- (void)createNav {
    self.NavView = [[NavHeadTitleView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    self.NavView.title = @"个人中心";
    self.NavView.color = [UIColor whiteColor];
    self.NavView.rightTitleImage = @"Setting";
    self.NavView.delegate = self;
    [self.view addSubview:self.NavView];
}
// 右按钮回调
- (void)NavHeadToRight {
    NSLog(@"点击了右按钮");
    //    BirdFlyViewController *birdVC = [[BirdFlyViewController alloc] init];
    //    [kRootNavigation pushViewController:birdVC animated:YES];
}

#pragma mark ---- UITableViewDelegate ----
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_headLineView) {
        _headLineView = [[HeadLineView alloc]init];
        _headLineView.frame = CGRectMake(0, 0, kScreenWidth, 48);
        _headLineView.delegate = self;
        [_headLineView setTitleArray:@[@"日鉴",@"阅读",@"我们的资料"]];
    }
    return _headLineView;
}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"ICON_wodedingdan"];
        cell.textLabel.text = @"宇哥资料";
    }
    else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"ICON_dizhi"];
        cell.textLabel.text = @"小v资料";
    }
    else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"ICON_jilu"];
        cell.textLabel.text = @"相册";
    }
    else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"ICON_kefu"];
        cell.textLabel.text = @"清理缓存";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 4) {
        cell.imageView.image = [UIImage imageNamed:@"ICON_setting"];
        cell.textLabel.text = @"我们家在哈尔滨";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2) {
        PhotosTypeViewController *typeVC = [[PhotosTypeViewController alloc] initWithViewControllerClasses:@[[PhotoAlbumViewController class], [ListPhotoViewController class], [AlbumPhotosViewController class]] andTheirTitles:@[@"陌陌模式", @"列表相册", @"流式相册"]];
        typeVC.menuViewStyle = WMMenuViewStyleLine;
        typeVC.menuItemWidth = 80;
        typeVC.menuBGColor= [UIColor whiteColor];
        typeVC.menuHeight = 40;
        typeVC.titleColorSelected = kNavColor;
        typeVC.titleSizeNormal = 14;
        typeVC.titleSizeSelected = 14;
        
        [self.navigationController pushViewController:typeVC animated:YES];
    }
    
    if (indexPath.row == 3) {
        NSString *path = kCachesPath;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        float folderSize;
        if ([fileManager fileExistsAtPath:path]) {
            // 拿到所有文件的数组
            NSArray *childerFiles = [fileManager subpathsAtPath:path];
            // 拿到每个文件的名字,如有有不想清除的文件就在这里判断
            for (NSString *fileName in childerFiles) {
                //将路径拼接到一起
                NSString *fullPath = [path stringByAppendingPathComponent:fileName];
                folderSize += [self fileSizeAtPath:fullPath];
            }
            
            [UIAlertController showAlertInViewController:self withTitle:@"清理缓存" message:[NSString stringWithFormat:@"缓存大小为%.2fM,确定要清理缓存吗?", folderSize] cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                if (buttonIndex == controller.destructiveButtonIndex) {
                    //点击了确定,遍历整个caches文件,将里面的缓存清空
                    NSString *path = kCachesPath;
                    NSFileManager *fileManager=[NSFileManager defaultManager];
                    if ([fileManager fileExistsAtPath:path]) {
                        NSArray *childerFiles=[fileManager subpathsAtPath:path];
                        for (NSString *fileName in childerFiles) {
                            //如有需要，加入条件，过滤掉不想删除的文件
                            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
                            [fileManager removeItemAtPath:absolutePath error:nil];
                        }
                    }
                }
            }];
            
        }
    }
    if (indexPath.row == 4) {
        WebViewController *webVC = [[WebViewController alloc] init];
        webVC.urlStr = @"http://h5.eqxiu.com/s/NABANe?eqrcode=1&from=timeline&isappinstalled=0";
        [kRootNavigation pushViewController:webVC animated:YES];
    }
}

//计算单个文件夹的大小
- (float)fileSizeAtPath:(NSString *)path{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}


#pragma mark - 导航栏渐变效果
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int contentOffsety = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y <= 170) {
        self.NavView.headBgView.alpha = scrollView.contentOffset.y/170;
        self.NavView.rightImageView = @"Setting";
        self.NavView.color = [UIColor whiteColor];
        //状态栏字体白色
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }else {
        self.NavView.headBgView.alpha = 1;
        self.NavView.rightImageView = @"Setting-click";
        self.NavView.color = kNavColor;
        //隐藏黑线
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        // 状态栏字体黑色
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    if (contentOffsety < 0) {
        CGRect rect = _backgroundImgV.frame;
        rect.size.height = _backImgHeight - contentOffsety;
        rect.size.width = _backImgWidth * (_backImgHeight - contentOffsety)/_backImgHeight;
        rect.origin.x = -(rect.size.width-_backImgWidth)/2;
        rect.origin.y = 0;
        _backgroundImgV.frame = rect;
    }else {
        CGRect rect = _backgroundImgV.frame;
        rect.size.height = _backImgHeight;
        rect.size.width = _backImgWidth;
        rect.origin.x = 0;
        rect.origin.y = -contentOffsety;
        _backgroundImgV.frame = rect;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
