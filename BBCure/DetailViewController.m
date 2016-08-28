//
//  DetailViewController.m
//  BBCure
//
//  Created by Chen on 15/5/31.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import "DetailViewController.h"
#import "Masonry.h"
#import "CureData.h"
#import "UIDetailTableCell.h"
#import "MHPresenterImageView.h"
#import "UIImageView+WebCache.h"

#define addText(fmt, ...) [self add:[NSString stringWithFormat:fmt,##__VA_ARGS__]]

#define UserDefault_ShowTableView @"showTableView"

@interface DetailViewController ()
{
    NSMutableArray *galleryItems;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;
//@property (weak, nonatomic) IBOutlet UIView *imageContainerView;

//@property (weak, nonatomic) IBOutlet MHPresenterImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *scrollContainerView;

@property (strong, nonatomic) UIBarButtonItem *addNewButtonItem;
@property (strong, nonatomic) UIBarButtonItem *editMyButtonItem;


@property (nonatomic)  NSMutableArray *objects; //默认（按时间由近及远）
@property (nonatomic)  NSArray *objectsByDateAsc; //按时间由远及近

@end

@implementation DetailViewController

#pragma mark - lift cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.addNewButtonItem;
    self.navigationItem.title = self.detailName;
    [self.view addSubview:self.scrollview];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:UserDefault_ShowTableView]) {
        [self.tableView setHidden:NO];
        [self.graphView setHidden:YES];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    else
    {
        [self.tableView setHidden:YES];
        [self.graphView setHidden:NO];
        self.graphView.delegate = self;
        self.graphView.dataSource = self;
        [self.graphView reloadGraph];
        self.navigationItem.leftBarButtonItem = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
    cell.data = self.objects[indexPath.row];
    
    return  cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //删除数据库对应数据
        [CureData deleteToDB:self.objects[indexPath.row]];
        
        [self.objects removeObjectAtIndex:indexPath.row];
        _objectsByDateAsc = nil;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.objectsByDateAsc count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    CureData *data = self.objectsByDateAsc[index];
    return data.cureDuration;
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 0;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

//图表外部Label显示
//- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
//    self.labelValues.text = [NSString stringWithFormat:@"%@", [self.arrayOfValues objectAtIndex:index]];
//    self.labelDates.text = [NSString stringWithFormat:@"in %@", [self labelForDateAtIndex:index]];
//}

//- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.labelValues.alpha = 0.0;
//        self.labelDates.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
//        self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
//        
//        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self.labelValues.alpha = 1.0;
//            self.labelDates.alpha = 1.0;
//        } completion:nil];
//    }];
//}
//
//- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
//    self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
//    self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
//}

/* - (void)lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
 // Use this method for tasks after the graph has finished drawing
 } */

- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" 秒";
}

//- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
//    return @"$ ";
//}

#pragma mark - private methods

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    CureData *data = self.objectsByDateAsc[index];
    NSDate *date = data.date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd";
    NSString *label = [df stringFromDate:date];
    return label;
}

-(void)circleImageView:(UIImageView* )imageView
{
    //http://ju.outofmemory.cn/entry/76525 圆形头像
    imageView.layer.cornerRadius = imageView.frame.size.height/2;
    imageView.clipsToBounds = YES;
    //边框
    [imageView.layer setMasksToBounds:YES];
    [imageView.layer setBorderWidth:2.0];   //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 227.0/256., 227.0/256., 227.0/256., 1 });
    [imageView.layer setBorderColor:colorref];//边框颜色
    NSLog(@"%f, %f",imageView.frame.size.width, imageView.frame.size.height);
}

//切换列表显示和图表显示
- (void)refreshView
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //if ([userDefaults boolForKey:UserDefault_ShowTableView]) {
    if ([self.tableView isHidden]) {
      
        [userDefaults setBool:YES forKey:UserDefault_ShowTableView];
        
        [self.tableView setHidden:NO];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.graphView setHidden:YES];
        self.graphView.delegate = nil;
        [self.tableView reloadData];
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
    }
    else
    {
        [userDefaults setBool:NO forKey:UserDefault_ShowTableView];

        [self.tableView setHidden:YES];
        self.tableView.delegate = nil;
        
        [self.graphView setHidden:NO];
        self.graphView.delegate = self;
        self.graphView.dataSource = self;
        [self.graphView reloadGraph];
        
        self.navigationItem.leftBarButtonItem = nil;
        
    }
}

-(void)configImageView:(MHPresenterImageView*)imageView
{
    if (galleryItems == nil) {
        NSMutableArray *galleryMutableItems = NSMutableArray.new;
        for (CureData *data in self.objects ){
            if (data.image != nil) {
                MHGalleryItem *item = [[MHGalleryItem alloc] initWithImage:data.image];
                [galleryMutableItems addObject:item];
            }
            
        }
        galleryItems = galleryMutableItems;
    }
    
    __weak DetailViewController *blockSelf = self;
    __weak MHPresenterImageView *blockImageView = imageView;
    
    NSInteger index = imageView.tag;
    
    [imageView setInseractiveGalleryPresentionWithItems:galleryItems currentImageIndex:index currentViewController:self finishCallback:^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode) {
        if (viewMode == MHGalleryViewModeOverView) {
            [blockSelf dismissViewControllerAnimated:YES completion:nil];
        }else{
            blockImageView.image = image;
            blockImageView.currentImageIndex = currentIndex;
            [blockSelf.presentedViewController dismissViewControllerAnimated:YES dismissImageView:blockImageView completion:nil];
        }
    }];
    
    //MHGalleryItem *landschaft = [[MHGalleryItem alloc]initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(47).jpg"
      //                                                galleryType:MHGalleryTypeImage];
    
    //[self.imageView sd_setImageWithURL:[NSURL URLWithString:landschaft.URLString]];
    //[imageView setUserInteractionEnabled:YES];
    
    //imageView.shoudlUsePanGestureReconizer = YES;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing];
}

#pragma mark - getter

-(UIBarButtonItem*) addNewButtonItem
{
    _addNewButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];
    return _addNewButtonItem;
}

-(BEMSimpleLineGraphView *)graphView
{
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    _graphView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    _graphView.enableTouchReport = YES;
    _graphView.enablePopUpReport = YES;
    _graphView.enableYAxisLabel = YES;
    _graphView.autoScaleYAxis = YES;
    _graphView.alwaysDisplayDots = NO;
    _graphView.enableReferenceXAxisLines = YES;
    _graphView.enableReferenceYAxisLines = YES;
    _graphView.enableReferenceAxisFrame = YES;
    
    UIColor *color = [UIColor colorWithRed:31.0/255.0 green:187.0/255.0 blue:166.0/255.0 alpha:1.0];
    _graphView.colorTop = color;
    _graphView.colorBottom = color;
    self.view.tintColor = color;
    
    // Draw an average line
    _graphView.averageLine.enableAverageLine = NO;
    _graphView.averageLine.alpha = 0.6;
    _graphView.averageLine.color = [UIColor darkGrayColor];
    _graphView.averageLine.width = 2.5;
    _graphView.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    _graphView.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    _graphView.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    return _graphView;
}

-(UIScrollView *)scrollview
{
    //NSLog(@"%f, %f", _scrollview.frame.size.height, _scrollview.frame.size.width);
    //UIView *view = [[UIView alloc] initWithFrame:_scrollview.frame];
    
    //NSLog(@"%f, %f", view.frame.size.height, view.frame.size.width);
    
    float x = 0;
    float y = 4;
    float space = 5;
    float width = 140;
    
    NSInteger index = 0;
    for (CureData *data in self.objects ){
        if (data.image != nil) {
            MHPresenterImageView *imageView = [[MHPresenterImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
            imageView.tag = index++;
            [imageView setImage:data.image];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [self circleImageView:imageView];
            
            [self configImageView:imageView];
            
            [_scrollview addSubview:imageView];
            
            x += imageView.frame.size.width + space;
        }
    }
    NSLog(@"%f, %f", _scrollview.frame.size.height, _scrollview.frame.size.width);
    return _scrollview;
}

//-(MHPresenterImageView *)imageView
//{
//    
//    
//    
//    return _imageView;
//}

-(NSArray*)objects
{
    if (_objects == nil) {
        NSString *where = [NSString stringWithFormat:@"name = '%@'", self.detailName];
        NSString *strOrderBy = @"date desc";
        _objects = [CureData searchWithWhere:where orderBy:strOrderBy offset:0 count:100];
    }
    return _objects;
}
-(NSArray *)objectsByDateAsc
{
    if (_objectsByDateAsc == nil) {
        _objectsByDateAsc = [[self.objects reverseObjectEnumerator] allObjects];
    }
    return _objectsByDateAsc;
}

@end
