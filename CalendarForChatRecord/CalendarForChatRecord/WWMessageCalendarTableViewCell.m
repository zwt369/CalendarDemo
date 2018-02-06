//
//  WWMessageCalendarTableViewCell.m
//  WoWo
//
//  Created by Tony Zhang on 2018/1/24.
//  Copyright © 2018年 Woohe. All rights reserved.
//

#import "WWMessageCalendarTableViewCell.h"
#import "WWCalendarCollectionViewCell.h"

@interface WWMessageCalendarTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

/**collectionView*/
@property(nonatomic,strong)UICollectionView *colleciontView;

@end


@implementation WWMessageCalendarTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat itemWidth = (WWScreenWidth-30)/7;
    CGFloat itemHeight = WWScreenWidth/7+10;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
//    [collectionView setCollectionViewLayout:layout animated:YES];
    collectionView.scrollEnabled = NO;
    [self.contentView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.offset(15);
        make.width.mas_equalTo(WWScreenWidth-30);
    }];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    self.colleciontView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[WWCalendarCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

-(void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self.colleciontView reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WWCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
