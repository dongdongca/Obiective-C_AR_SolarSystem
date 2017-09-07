//
//  ViewController.m
//  AR_SolarSystem
//
//  Created by Mac on 2017/9/7.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "SolarSystemViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)enterAR:(id)sender {
    
    [self.navigationController pushViewController:[[SolarSystemViewController alloc] init] animated:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
