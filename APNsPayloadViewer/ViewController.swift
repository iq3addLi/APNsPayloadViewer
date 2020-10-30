//
//  ViewController.swift
//  APNsPayloadViewer
//
//  Created by iq3AddLi on 2020/10/28.
//

import UIKit
import UserNotifications

class ViewController: UITableViewController {

    var payloads: [Payload] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if payloads.count == 0{
            requestPayloads { [weak self] payloads in
                self?.payloads += payloads
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
        if deviceToken == nil {
            requestAuthorizationPush()
        }
    }
    
    var deviceToken: String? {
        didSet{
            navigationItem.rightBarButtonItem?.isEnabled = (deviceToken != nil)
        }
    }
}

// MARK: Segue
extension ViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPath(for: cell),
            let destination = segue.destination as? PayloadViewController{
            destination.payload = payloads[index.row]
        }
    }
}

// MARK: IBAction
extension ViewController{
    @IBAction func copyDeviceToken(sender: UIBarButtonItem){
        guard let token = deviceToken else { return }
        UIPasteboard.general.string = token
    }
}

// MARK: Notification Receiver
extension ViewController{
    @objc func willEnterForeground(){
        requestPayloads { [weak self] payloads in
            self?.payloads = payloads
            
            DispatchQueue.main.async{ [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}


// MARK: TableView Delegate/DataSource
extension ViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        payloads.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else{
            fatalError("A table cell has Identifier 'Cell' was not found.")
        }
        let payload = payloads[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell.textLabel?.text = "Received \(formatter.string(from: payload.date))"
        
        return cell
    }
}

// MARK: UseCase
extension ViewController{
    
    func requestPayloads(location: Int = 0, length: Int = 50, completion: @escaping ([Payload]) -> Void){
        DispatchQueue.global().async {
            completion(Store.shared.payloads(location: location, length: length))
        }
    }
    
    func requestAuthorizationPush(){
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] (isAuthorized, errorOrNil) in
            
            if let error = errorOrNil{
                self?.alert("error", message: "\(error.localizedDescription)")
                return
            }
            guard isAuthorized == true else{
                self?.alert("error", message: "Push notifications were not allowed.")
                return
            }
            
            // Authorized
            UIApplication.shared.registerForRemoteNotifications { [weak self] (result) in
                switch result{
                case .failure(let error):
                    self?.alert(message: "\(error.localizedDescription)")
                case .success(let token):
                    self?.deviceToken = token
                }
            }
        }
    }
}

// MARK: Receive notification when app at forground.
extension ViewController : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        do{
            try Store.shared.put(payload: AnyCodable(notification.request.content.userInfo))
        }
        catch{
            NSLog("\(error)")
        }
        requestPayloads(location: 0, length: 1) { [weak self] payloads in
            self?.payloads.insert(payloads.first!, at: 0)
            
            DispatchQueue.main.async{ [weak self] in
                self?.tableView.reloadData()
            }
        }
        completionHandler(.sound)
    }
}

// MARK: Utility extention
extension UIViewController{
    
    func alert(_ title: String? = nil, message: String, completion: (() -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async{ [weak self] in
            self?.present(alert, animated: true, completion: completion)
        }
    }
}
