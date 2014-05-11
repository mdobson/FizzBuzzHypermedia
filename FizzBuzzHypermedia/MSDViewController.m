//
//  MSDViewController.m
//  FizzBuzzHypermedia
//
//  Created by Matthew Dobson on 5/10/14.
//  Copyright (c) 2014 Matthew Dobson. All rights reserved.
//

#import "MSDViewController.h"
#import "SHMKit/SHMParser.h"
#import "SHMKit/SHMEntity.h"
#import "SHMKit/SHMLink.h"

@interface MSDViewController ()

@property (nonatomic, retain) SHMParser *parser;
@property (nonatomic, retain) SHMAction *fizzbuzz;
@property (nonatomic, retain) NSString *url;

@end

@implementation MSDViewController

@synthesize parser, url, fizzbuzz;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.queryIndicator.hidden = YES;
    self.fizzbuzzQuery.delegate = self;
    [self.indicator startAnimating];
    self.url = @"http://fizzbuzzaas.herokuapp.com";
    self.parser = [[SHMParser alloc] initWithSirenRoot:self.url];
    [self.parser retrieveRoot:^(NSError *err, SHMEntity *entity) {
        if (err) {
            NSLog(@"err:%@", err);
        } else {
            if ([entity hasLinkRel:@"first"]) {
                [self patchLink:entity andLinkRel:@"first"];
                [entity stepToLinkRel:@"first" withCompletion:^(NSError *error, SHMEntity *entity) {
                    if (error) {
                        NSLog(@"First step err:%@", error);
                    } else {
                        NSLog(@"Value:%@", entity.properties[@"value"]);
                        [self fizzbuzz:entity];
                    }
                }];
            }
            
            self.fizzbuzz = [entity getSirenAction:@"get-fizzbuzz-value"];
            //Quick link patch
            NSString *actionHref = [NSString stringWithFormat:@"%@%@", self.url, self.fizzbuzz.href];
            self.fizzbuzz.href = actionHref;
            self.fizzbuzzQuery.placeholder = self.fizzbuzz.title;
        }
    }];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fizzbuzz:(SHMEntity *) entity {
    if ([entity hasLinkRel:@"next"]) {
        [self patchLink:entity andLinkRel:@"next"];
        [entity stepToLinkRel:@"next" withCompletion:^(NSError *error, SHMEntity *entity) {
            if (error) {
                NSLog(@"Next step err:%@", error);
            } else {
                NSLog(@"Value:%@", entity.properties[@"value"]);
                [self fizzbuzz:entity];
            }
        }];
    } else {
        //Completed
        self.indicator.hidden = YES;
        self.number.text = [NSString stringWithFormat:@"%@",entity.properties[@"number"]];
        self.value.text = entity.properties[@"value"];
    }
}

-(void)patchLink:(SHMEntity *)entity andLinkRel:(NSString*)linkRel{
    for (SHMLink *link in entity.links) {
        for (NSString *rel in link.rel) {
            if ([rel isEqualToString:linkRel]) {
                NSString *patchedLink = [NSString stringWithFormat:@"%@%@", self.url, link.href];
                link.href = patchedLink;
            }
        }
    }
}

-(void)searchFizzbuzz:(id)sender {
    self.queryIndicator.hidden = NO;
    [self.queryIndicator startAnimating];
    NSString * number = self.fizzbuzzQuery.text;
    NSNumber * fizzbuzzValue = [NSNumber numberWithInt:[number integerValue]];
    NSDictionary *params = @{@"number": fizzbuzzValue};
    [self.fizzbuzz performActionWithFields:params andCompletion:^(NSError *error, SHMEntity *entity) {
        if (error) {
            NSLog(@"Error: %@!", error);
        } else {
            self.queryIndicator.hidden = YES;
            self.queryNumber.text = [NSString stringWithFormat:@"%@",entity.properties[@"number"]];
            self.queryValue.text = entity.properties[@"value"];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.fizzbuzzQuery resignFirstResponder];
    return YES;
}

@end
