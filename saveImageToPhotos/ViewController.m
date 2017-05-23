//
//  ViewController.m
//  saveImageToPhotos
//
//  Created by hooyking on 2017/5/23.
//  Copyright © 2017年 hooyking. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
//上方大图
@property (nonatomic, strong) UIImageView *imageView;
//下方小图
@property (nonatomic, strong) UIImageView *resImageView;
//图片标识
@property (nonatomic, strong) UILabel *symbolLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"3种方式保存图片到相册";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

#pragma mark - initUI
- (void)initUI {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 80, SCREEN_W-60, 200)];
    self.imageView.image = [UIImage imageNamed:@"showImage.jpg"];
    [self.view addSubview:self.imageView];
    
    NSArray *titleArr = @[@"1.UIImageWriteToSavedPhotosAlbum方法",@"2.ALAssetsLibrary",@"3.PHPhotoLibrary"];
    
    for (int i = 0; i<3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 300+i*60, SCREEN_W, 40);
        button.backgroundColor = [UIColor blueColor];
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        button.tag = i+200;
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    }
    
    self.resImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 480, SCREEN_W-160, 80)];
    [self.view addSubview:self.resImageView];
    
    self.symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 560, SCREEN_W, 60)];
    self.symbolLabel.textAlignment = NSTextAlignmentCenter;
    self.symbolLabel.numberOfLines = 0;
    [self.view addSubview:self.symbolLabel];
}

#pragma mark
- (void)buttonClicked:(UIButton *)sender {
    /***************************<iOS10以后注意要在Info.plist配置下访问相册权限，不然会崩>*************************/
    if (sender.tag == 200) {
        /***************************<第一种通用型>*************************/
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);//按住command后点击鼠标左键访问这个方法，进去就能看到- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo,要知道是否保存成功必须使用这个系统回掉
    } else if (sender.tag == 201) {
        /***************************<第二种iOS4.1-iOS9.0，要加入AssetsLibrary.framework>*************************/
        __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeImageToSavedPhotosAlbum:self.imageView.image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                NSLog(@"2保存成功");
            } else {
                NSLog(@"2保存失败");
            }
        }];
    } else {
        /***************************<第三种iOS8.0-iOS10.x，要加入PhotosLibrary.framework>*************************/
        //下面的一和二请注释掉一种看效果
        //一、这个简单的处理图片保存到相册
        //        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //            [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image];
        //        } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //            if (success) {
        //                NSLog(@"3保存成功");
        //            } else {
        //                NSLog(@"3保存失败");
        //            }
        //        }];
        //二、这个在保存图片后记录了图片标识，可再次根据标识取出来
        [self SaveImageAndShowSymbolImage:self.imageView.image];
    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        NSLog(@"1保存成功");
    }else {
        NSLog(@"1保存失败");
    }
}

- (void)SaveImageAndShowSymbolImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    NSMutableArray *imageSymbol = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        [imageSymbol addObject:req.placeholderForCreatedAsset.localIdentifier];
        NSLog(@"刚保存的图片标识：%@",req.placeholderForCreatedAsset.localIdentifier);
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"3保存成功，且图片标识已经记录");
            //根据图片标识得到的相册中已保存图片
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageSymbol options:nil];
            for (PHAsset *temPHAsset in result) {
                //获取图片二进制数据
                [[PHImageManager defaultManager] requestImageDataForAsset:temPHAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    weakSelf.symbolLabel.text = imageSymbol.lastObject;
                    weakSelf.resImageView.image = [UIImage imageWithData:imageData];
                }];
            }
        }
        
    }];
}

@end
