//
//  AppDelegate.swift
//  NaiveSwiftCoinIOS
//
//  Created by Ronald "Danger" Mannak on 5/13/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            let blockchain = try Blockchain()
            var wallet = Wallet(with: blockchain)
            let account1 = try wallet.createAccount()
            let account2 = try wallet.createAccount()

            print("Account 1 add initial amount")
            try account1.addInitialAmount(blockchain: blockchain)
            print("Account 2 add initial amount")
            try account2.addInitialAmount(blockchain: blockchain)
            print(wallet) // both accounts should own 500 coins
            print("Acount 1 send 200 coins")
            try account1.send(amount: 200, to: account2.address, blockchain: blockchain)
            print("Mine")
            try blockchain.mine()
            print(wallet) // 1 should have 300, 2 700
        } catch {
            print("Error: \(error)")
            fatalError()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

