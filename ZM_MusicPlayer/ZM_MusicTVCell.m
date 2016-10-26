//
//  ZM_MusicTVCell.m
//  ZM_MusicPlayer
//
//  Created by GVS on 16/10/21.
//  Copyright © 2016年 GVS. All rights reserved.
//

#import "ZM_MusicTVCell.h"
#import "UIImageView+WebCache.h"
@implementation ZM_MusicTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}
-(void)creatCellWithModel:(ZM_MusicModel *)model
{
    
    self.textLabel.text = model.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@",model.singer,model.album];
    NSArray * array = [model.singerIcon componentsSeparatedByString:@":"];
    if ([array[0] isEqualToString:@"http"]) {
        //是网络图片
        //[self.imageView sd_setImageWithURL:[NSURL URLWithString:model.singerIcon]];
    }else{
        self.imageView.image = [self makeCircleImageWithName:model.singerIcon imageBorderWidth:2.0 andBorderColor:[UIColor grayColor]];
    }
}

/**
 画圆
 
 @param imageName   旧图片名称
 @param borderWidth 新图片边框宽度
 @param borderColor       新边框颜色
 */
-(UIImage *)makeCircleImageWithName:(NSString *)imageName imageBorderWidth:(CGFloat)borderWidth andBorderColor:(UIColor *)borderColor
{
    if (imageName.length == 0) {
        imageName = @"default_icon";
        borderColor = [UIColor colorWithRed:0.0f green:187.0f blue:156.0f alpha:0];
    }
    //第一步，加载源图
    UIImage * oldImage = [UIImage imageNamed:imageName];
    
    //第二步，开启上下文
    //2.1 获取新图像的宽，高，并得到大小
    CGFloat imageWidth = oldImage.size.width + 2 * borderWidth;
    CGFloat imageHeight = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    //2.2 开启上下文
    UIGraphicsBeginImageContext(imageSize);
    
    //第三步，取得当前对象的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //第四步，画边框
    [borderColor set];
    CGFloat borderCircleRadius = imageWidth * 0.5;//边框圆的半径
    CGFloat borderCircleCenterX = borderCircleRadius;//圆心
    CGFloat borderCircleCenterY = borderCircleRadius;
    CGContextAddArc(ctx, borderCircleCenterX, borderCircleCenterY, borderCircleRadius, 0, 2 * M_PI, 0);
    CGContextFillPath(ctx);//画圆
    
    //第五步，画边框内的圆
    //大圆半径－边框宽＝小圆半径
    CGFloat circleRadius = borderCircleRadius - borderWidth;
    CGContextAddArc(ctx, borderCircleCenterX, borderCircleCenterY, circleRadius, 0, 2 * M_PI, 0);
    CGContextClip(ctx);
    
    //第六步，画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    //第七步，取图
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //第八步，结束上下文
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
