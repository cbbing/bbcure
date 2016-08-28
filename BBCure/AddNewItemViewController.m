//
//  AddNewItemViewController.m
//  BBCure
//
//  Created by Chen on 15/6/5.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import "AddNewItemViewController.h"
#import "masonry.h"
#import "CureData.h"

@interface AddNewItemViewController()
{
    BOOL isFullScreen;
    CGRect orignImageViewFrame;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *cureDurationPicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UILabel *curentTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) UIBarButtonItem *backButtonItem;

@end

@implementation AddNewItemViewController

#pragma mark - life cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.nameTextField];
    [self.view addSubview:self.noteTextView];
    [self.view addSubview:self.curentTimeLabel];
    self.navigationItem.leftBarButtonItem = self.backButtonItem;
    
    [self.cureDurationPicker setLocale:[NSLocale systemLocale]];
    
    NSString *where = [NSString stringWithFormat:@"name = '%@'", self.partName];
    NSString *strOrderBy = @"date desc";
    NSMutableArray *objects = [CureData searchWithWhere:where orderBy:strOrderBy offset:0 count:100];
    if ([objects count] > 0) {
        CureData *data = objects[0];
        
        long minute = data.cureDuration/60;
        long second = data.cureDuration%60;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat  = @"yyyy/MM/dd HH:mm:ss";
        NSString *strDate = [NSString stringWithFormat:@"2015/06/12 %d:%d:00", (int)minute, (int)second];
        NSDate *aDate = [df dateFromString: strDate];
        
        [self.cureDurationPicker setDate:aDate];
    }



}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = 0;
        
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //取消
                    return;
                    //break;
                case 1:
                    //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            if (buttonIndex == 0) {
                return;
            }
            else
            {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 跳转到相机或相册页面
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            //[self.navigationController pushViewController:imagePickerController animated:YES];
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        
        
    }
}

#pragma mark UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    //保存至本地，方法见下文
    [self saveImage:image withName:@"currentImage.png"];
    
    isFullScreen = NO;
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    [self.imageView setImage:savedImage];
    self.imageView.tag = 100;
    orignImageViewFrame = self.imageView.frame;
    
    [self.imageView setHidden:NO];
    [self.deleteButton setHidden:NO];
    [self.addButton setHidden:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - event response

- (IBAction)buttonOKAction:(id)sender {
    LKDBHelper *globalHelper = [CureData getUsingLKDBHelper];
    
    //当前时间
    NSDate *currentDate = [self getCurrentDate];
    
    if ([self.nameTextField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"名称为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSTimeZone* GTMZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:GTMZone];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy-MM-dd MM:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    
    //insert
    CureData *data = [[CureData alloc] init];
    data.name = self.nameTextField.text;
    data.cureDuration = [self getTotalSeconds];
    data.date = currentDate;
    //data.timeIntervalSince1970 = [currentDate timeIntervalSince1970];
    data.note = self.noteTextView.text;
    data.image = [self addText:self.imageView.image text:currentDateStr];
    [globalHelper insertToDB:data];

    [self.popoverVC dismissPopoverAnimated:YES];

    [self.delegate refreshTableView];
    
}

- (IBAction)addFiveSecondAction:(id)sender {
    
    NSDate *date = [[NSDate alloc] initWithTimeInterval:5*60 sinceDate:self.cureDurationPicker.date];
    [self.cureDurationPicker setDate:date];

}

- (IBAction)addTenSecondAction:(id)sender {
    NSDate *date = [[NSDate alloc] initWithTimeInterval:10*60 sinceDate:self.cureDurationPicker.date];
    [self.cureDurationPicker setDate:date];
}

- (IBAction)addPicture:(id)sender {
    UIActionSheet *sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"相册", nil];
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"相册", nil];
    }
    sheet.tag = 255;
    [sheet showInView:self.view];
}

- (IBAction)deletePicture:(id)sender {
    [self.imageView setHidden:YES];
    [self.addButton setHidden:NO];
    [self.deleteButton setHidden:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isFullScreen = !isFullScreen;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGPoint imagePoint = self.imageView.frame.origin;
    
    //触点在imageView内，点击放大，再次点击时缩小。
    if (imagePoint.x <= touchPoint.x && imagePoint.x + self.imageView.frame.size.width>=touchPoint.x && imagePoint.y <= touchPoint.y && imagePoint.y+self.imageView.frame.size.height >= touchPoint.y) {
        //设置图片放大动画
        [UIView beginAnimations:nil context:nil];
        //动画时间
        [UIView setAnimationDuration:1];
        if (isFullScreen) {
            //放大尺寸
            self.imageView.frame = self.view.frame;
        }
        else
        {
            //缩小尺寸
            self.imageView.frame = orignImageViewFrame;
        }
        
        //commit动画
        [UIView commitAnimations];
    }
}

#pragma mark - private methods

-(NSDate*) getCurrentDate
{
    //当前时间
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];//时区
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    return localDate;
    
//    NSDate *date = [NSDate date];
//    NSTimeInterval sec = [date timeIntervalSinceNow];
//    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
//    return currentDate;
}

//此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数
-(void)saveImage:(UIImage*)currentImage withName:(NSString*)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.2);
    
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

-(long)getTotalSeconds
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.cureDurationPicker.date];
    long seconds = comps.hour * 60 + comps.minute; //以秒为单位
    return seconds;
}

-(UIImage *)addImageLogo:(UIImage *)img text:(UIImage *)logo
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    int logoWidth = logo.size.width;
    int logoHeight = logo.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake(w-logoWidth, 0, logoWidth, logoHeight), [logo CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    // CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}

-(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    //上下文的大小
    int w = img.size.width;
    int h = img.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//创建颜色
    //创建上下文
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);//将img绘至context上下文中
    CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1);//设置颜色
    char* text = (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    CGContextSelectFont(context, "Georgia", 70, kCGEncodingMacRoman);//设置字体的大小
    CGContextSetTextDrawingMode(context, kCGTextFill);//设置字体绘制方式
    CGContextSetRGBFillColor(context, 255, 0, 255, 1);//设置字体绘制的颜色
    CGContextShowTextAtPoint(context, 50, 50, text, strlen(text));//设置字体绘制的位置
    //Create image ref from the context
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);//创建CGImage
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];//获得添加水印后的图片 
}

#pragma mark - getter and setter

-(UITextField *)nameTextField
{
    if (_bEditing) {
        _nameTextField.text =_partName;
        [_nameTextField setEnabled:NO];
    }
    else
    {
        [_nameTextField setEnabled:YES];
    }
    return _nameTextField;
}

-(UITextView*)noteTextView
{
    _noteTextView.layer.borderColor = [UIColor grayColor].CGColor;
    _noteTextView.layer.borderWidth = 1.0;
    _noteTextView.layer.cornerRadius = 5.0;
    return _noteTextView;
}

- (UILabel*)curentTimeLabel
{
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    // 设置日期格式
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    _curentTimeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    return _curentTimeLabel;
    
}

-(UIBarButtonItem*)backButtonItem
{
    if (_backButtonItem == nil)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"tab_left"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 20, 20);
        _backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _backButtonItem;
}

@end
