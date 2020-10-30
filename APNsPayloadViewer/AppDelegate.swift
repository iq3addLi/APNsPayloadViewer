//
//  AppDelegate.swift
//  APNsPayloadViewer
//
//  Created by iq3AddLi on 2020/10/28.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, ApplicationDelegateRegisterForRemoteNotificationsHandlable {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    var registerForRemoteNotificationsCompletion: ((Result<String,Error>) -> Void)?
}


// MARK: Register remote notification
extension AppDelegate{
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registerForRemoteNotificationsCompletion?(.success( deviceToken.map{ String(format: "%.2hhx", $0) }.joined() ))
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        registerForRemoteNotificationsCompletion?(.failure(error))
    }
    
}


// MARK: Receive notification when app at suspend.
extension AppDelegate{
    //
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        do{
            try Store.shared.put(payload: AnyCodable(userInfo))
        }
        catch{
            NSLog("\(error)")
            completionHandler(.failed)
            return
        }
        completionHandler(.newData)
    }
}


// MARK: Extension with Notification
protocol ApplicationDelegateRegisterForRemoteNotificationsHandlable where Self: UIApplicationDelegate{
    var registerForRemoteNotificationsCompletion: ((Result<String,Error>) -> Void)? { get set }
}

extension UIApplication {
    
    private var handlebleDelegate: ApplicationDelegateRegisterForRemoteNotificationsHandlable? {
        guard let handlable = delegate as? ApplicationDelegateRegisterForRemoteNotificationsHandlable else{
            print("Appdelegate is not compliant for ApplicationDelegateRegisterForRemoteNotificationsHandlable.")
            return nil
        }
        return handlable
    }
    
    func registerForRemoteNotifications(completion: @escaping (Result<String,Error>) -> Void ){
        DispatchQueue.main.async { [weak self] in
            self?.handlebleDelegate?.registerForRemoteNotificationsCompletion = completion
            self?.registerForRemoteNotifications()
        }
    }
}
