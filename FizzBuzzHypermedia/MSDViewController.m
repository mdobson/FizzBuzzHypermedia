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

@property SHMParser *parser;
@property NSString *url;

@end

@implementation MSDViewController

@synthesize parser, url;

- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
