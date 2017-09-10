//
//  SolarSystemViewController.m
//  AR_SolarSystem
//
//  Created by Mac on 2017/9/7.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "SolarSystemViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface SolarSystemViewController () <ARSCNViewDelegate>
//view
@property (nonatomic, strong) ARSCNView *arScenView;
//ar管理
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARConfiguration *arSessionConfiguration;
/*earth
The moon
The sun
 */
@property (nonatomic, strong) SCNNode *earthNode;
@property (nonatomic, strong) SCNNode *moonthNode;
@property (nonatomic, strong) SCNNode *sunNode;

@property (nonatomic, strong) SCNNode *earthAndMoonthNode;



@end

@implementation SolarSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化AR，将ARSCNView添加到View上
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.arScenView];
    //设置代理
    self.arScenView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //创建追踪器
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    _arSessionConfiguration = configuration;
    //自适应灯光（从室内到室外切换比较柔和）
    _arSessionConfiguration.lightEstimationEnabled = YES;
    //给arSession添加追踪器
    [self.arSession runWithConfiguration:_arSessionConfiguration];
    
}
#pragma mark - 初始化节点
- (void) initNode {
    //初始化
    _sunNode = [[SCNNode alloc] init];
    _earthNode = [[SCNNode alloc] init];
    _moonthNode = [[SCNNode alloc] init];
    _earthAndMoonthNode = [[SCNNode alloc] init];
    
    //创建几何图形
    _sunNode.geometry = [SCNSphere sphereWithRadius:3.0];
    _earthNode.geometry = [SCNSphere sphereWithRadius:1.0];
    _moonthNode.geometry = [SCNSphere sphereWithRadius:0.5];
    
    //设置太阳
    //设置图片,渲染上图diffus：个人理解是平铺
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    //multiply:深入到图形里面，
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
    //深入强度
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    //指定方向
    _sunNode.geometry.firstMaterial.diffuse.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapT =
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.multiply.wrapS = SCNWrapModeRepeat;
    
    
    //设置地球的
    //默认图
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
    //夜光图：背光面
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-emissive.jpg";
    //设置地球的位置
    _earthNode.position = SCNVector3Make(3, 0, 0);
    
    //设置月球
    _moonthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
    _moonthNode.position = SCNVector3Make(3, 0, 0);
    

    
    
    //太陽照到地球上的光層，還有反光度，地球的反光度
    _earthNode.geometry.firstMaterial.shininess = 0.1;//光泽
    _earthNode.geometry.firstMaterial.specular.intensity = 0.5;//反光率
    //设置月球反光的颜色
    _moonthNode.geometry.firstMaterial.specular.contents = [UIColor whiteColor];
    
    //设置太阳的位置
    [_sunNode setPosition:SCNVector3Make(0, 5, -20)];
    //把地球节点放到地月节点上
    [_earthAndMoonthNode addChildNode:_earthNode];
    //设置地月节点的位置
    _earthAndMoonthNode.position = SCNVector3Make(10, 0, 0);
    
    //给scnView添加根节点
    [self.arScenView.scene.rootNode addChildNode:_sunNode];
    
    //添加太阳自转动画
    [self addAnimationToSun];
    
    //添加地球动画
    [self setEarthAnimation];
    
    SCNNode *orbitalNode = [SCNNode node];
    orbitalNode.geometry = [SCNPlane planeWithWidth:30 height:30];
    orbitalNode.position = SCNVector3Make(0, 5, -20);
    orbitalNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    orbitalNode.eulerAngles = SCNVector3Make(20, -5, 0);
    [_sunNode addChildNode:orbitalNode];
    
}

- (void)setEarthAnimation {
    //创建地球自转
    [_earthNode runAction: [SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    //地球绕着太阳的动画
    //创建地球围绕太阳的节点
    SCNNode *earthRevolutionNode = [SCNNode node];
    [_sunNode addChildNode:earthRevolutionNode];
    [earthRevolutionNode addChildNode:_earthAndMoonthNode];
    
    
    //添加地球公转的动画
    CABasicAnimation *earthRevolutionAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    //动画时间
    earthRevolutionAnimation.duration = 10.0;
    earthRevolutionAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    earthRevolutionAnimation.repeatCount = FLT_MAX;
    [earthRevolutionNode addAnimation:earthRevolutionAnimation forKey:@"earth rotation around sun"];
    
    //设置月球公转
    //创建月球公转的节点
    SCNNode *moomRotationNode = [SCNNode node];
    //将月球节点添加到月球公转的节点
    [moomRotationNode addChildNode:_moonthNode];
    
    //月球自转的动画moomRotationAnimation
    CABasicAnimation *moomRevolutionAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    //动画时间
    moomRevolutionAnimation.duration = 5.0;
    moomRevolutionAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moomRevolutionAnimation.repeatCount = FLT_MAX;
    [_moonthNode addAnimation:moomRevolutionAnimation forKey:@"moom rotat"];
    
    //月球公转的动画
    CABasicAnimation *moomRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moomRotationAnimation.duration = 10.0;
    moomRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moomRotationAnimation.repeatCount = FLT_MAX;
    [moomRotationNode addAnimation:moomRotationAnimation forKey:@"moom Revolution Animation"];
    
    //将月球公转节点添加到地月节点
    [_earthAndMoonthNode addChildNode:moomRotationNode];
    
}


//添加太阳自转动画
- (void)addAnimationToSun {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    //动画时间
    animation.duration = 10.0;
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeTranslation(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeTranslation(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    
    //添加动画
    [self.sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
}



#pragma mark - lazy load
- (ARSCNView *)arScenView {
    if (!_arScenView) {
        _arScenView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _arScenView.session = self.arSession;
        _arScenView.automaticallyUpdatesLighting = YES;
        [self initNode];
    }
    return _arScenView;
}

- (ARSession *)arSession {
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
    }
    return _arSession;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
