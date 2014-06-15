//
//  ViewController.m
//  Task
//
//  Created by Muhammad Saad on 6/15/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import "ViewController.h"
#import "Defines.h"
#import "CustomCell.h"
#import "DetailViewController.h"
#import "AsyncImageView.h"

static NSString *cellIdentifierViewRecord   = @"CustomCell";

@interface ViewController ()
@property (nonatomic, strong)NSArray *filterProducts;
@property (nonatomic, strong)NSArray *orignalProducts;
@property (nonatomic, weak)IBOutlet UITableView *tableViewProduct;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Products";
    // Do any additional setup after loading the view from its nib.
    
    [_tableViewProduct registerNib:[UINib nibWithNibName:cellIdentifierViewRecord bundle:nil] forCellReuseIdentifier:cellIdentifierViewRecord];
    _orignalProducts = [NSArray arrayWithArray:[DBHandler fetchObjectsOfEntity:KProductObject]];//fetch Data from dataBase
    _filterProducts = _orignalProducts;
    
    [self startActivity];
    ProductObjectRequest *request = [ProductObjectRequest new]; //Making Product Request
    request.fromValue = @"100";
    request.countValue = @"50";
    [WebServiceDateManager getProductObjectResponseFrom:request forDelegate:self];
    
}

- (void) filterUsersWithText:(NSString*)searchText {
    if (searchText.length == 0) {
        _filterProducts = _orignalProducts;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productName contains[cd] %@",searchText];
        _filterProducts = [_orignalProducts filteredArrayUsingPredicate:predicate];
    }
    
    [_tableViewProduct reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Webservice Delegate
- (void) responseRecievedFor:(WebServiceBase*)webService withResponse:(NSObject*)response{
    NSArray *Array = (NSArray *)response;
    if ([Array count]!= 0) {
        for (Product *object in _orignalProducts) {
            [DBHandler deleteObject:object];
        }
    }
    for (ProductObjectResponse *object in Array)
    {
        Product *ProductObj = [DBHandler manageObjectForEntity:KProductObject];
        [ProductObj setProductBrand       :object.productBrand];
        [ProductObj setProductID          :object.productID];
        [ProductObj setProductImage       :object.productImage];
        [ProductObj setProductName        :object.productName];
        [ProductObj setProductPage        :object.productPage];
        [ProductObj setProductPrice       :object.productPrice];
        [ProductObj setProductSKU         :object.productSKU];
        [DBHandler insertObject:ProductObj]; //Insert Data into DataBase
        [DBHandler saveContext];
    }
    [self removeActivity];
}

- (void) invalidResponseRecivedFor:(WebServiceBase*)webService withResponse:(NSObject*)response{
    NSLog(@"invalidResponseRecivedFor");
    [self removeActivity];
    ALERT(@"Warning", @"Unable to fetch the data");
    
}

#pragma mark
#pragma mark UITableViewDataSource methods
- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
	return 104.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return [_filterProducts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell *cell =  (CustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierViewRecord];
    if (cell == nil) {
        cell = [CustomCell createCell];
    }
    else
    {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgMain];
    }
    Product *page = [_filterProducts objectAtIndex:indexPath.row];
    cell.imgMain.image = [UIImage imageNamed:@"Placeholder.png"];

    cell.lblName.text = page.productName;
    cell.lblPrice.text = page.productPrice;
    cell.imgMain.imageURL = [NSURL URLWithString:page.productImage];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath  *)indexPath
{
    DetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    vc.obj=_filterProducts[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark UISearchBar Delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterUsersWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
    [searchBar resignFirstResponder];
}

@end
