//
//  EventBus.swift
//  CocoaMqttC
//
//  Created by iotn2n on 16/4/23.
//  Copyright © 2016年 iot. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var animal: String?
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var animalsImageView: UIImageView! {
        didSet {
            animalsImageView.clipsToBounds = true
            animalsImageView.layer.borderWidth = 1.0
            animalsImageView.layer.cornerRadius = animalsImageView.frame.width / 2.0
        }
    }
    
    @IBAction func connectToServer() {
        let chatViewController = storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController
        navigationController!.pushViewController(chatViewController!, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        tabBarController?.delegate = self
        animal = tabBarController?.selectedViewController?.tabBarItem.title
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.hidden = false
    }

}


extension ViewController: UITabBarControllerDelegate {
    // Prevent automatic popToRootViewController on double-tap of UITabBarController
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}