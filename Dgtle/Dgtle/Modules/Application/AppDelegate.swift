//
//  AppDelegate.swift
//  Dgtle
//
//  Created by yfm on 2019/7/13.
//  Copyright © 2019 yfm. All rights reserved.
//

import UIKit
import JPFPSStatus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AOP.swizzling()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        let rootVC = DGTabbarViewController()
        self.window?.rootViewController = rootVC
        
        KingfisherManager.shared.cache.maxMemoryCost = 30 * 1024 * 1024 // 30M
        
        self.window?.makeKeyAndVisible()
        
        JPFPSStatus.sharedInstance()?.open()
        
        return true
    }
}

extension AppDelegate {

}

