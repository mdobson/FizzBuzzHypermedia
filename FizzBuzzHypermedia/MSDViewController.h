//
//  MSDViewController.h
//  FizzBuzzHypermedia
//
//  Created by Matthew Dobson on 5/10/14.
//  Copyright (c) 2014 Matthew Dobson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSDViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UILabel *number;
@property (nonatomic, retain) IBOutlet UILabel *value;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, retain) IBOutlet UILabel *queryNumber;
@property (nonatomic, retain) IBOutlet UILabel *queryValue;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *queryIndicator;

@property (nonatomic, retain) IBOutlet UITextField *fizzbuzzQuery;

-(IBAction)searchFizzbuzz:(id)sender;

@end
