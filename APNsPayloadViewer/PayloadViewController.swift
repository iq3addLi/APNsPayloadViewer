//
//  PayloadViewController.swift
//  APNsPayloadViewer
//
//  Created by iq3AddLi on 2020/10/29.
//

import UIKit

class PayloadViewController: UIViewController {
    var payload: Payload?
    
    @IBOutlet var textView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = payload?.body
    }
}
