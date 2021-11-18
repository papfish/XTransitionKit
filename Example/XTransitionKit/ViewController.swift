//
//  ViewController.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import UIKit
import XTransitionKit

var viewControllerIndex: Int = 0

class ViewController: UIViewController, TransitionKitDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.extendedLayoutIncludesOpaqueBars = true
        
        let tintColors = [UIColor(red: 255 / 255.0, green: 71 / 255.0, blue: 71 / 255.0, alpha: 1),
                          UIColor(red: 247 / 255.0, green: 175 / 255.0, blue: 52 / 255.0, alpha: 1),
                          UIColor(red: 48 / 255.0, green: 176 / 255.0, blue: 155 / 255.0, alpha: 1)]
        let barTintColor = tintColors[viewControllerIndex]
        viewControllerIndex += 1
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = barTintColor
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
            self.navigationController?.navigationBar.barTintColor = barTintColor;
        }
        
        let scWdith = UIScreen.main.bounds.size.width
        let scHeight = UIScreen.main.bounds.size.height
        let btnWidth = 160.0
        let btnHeight = 40.0
        
        // background image view
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        self.view.addSubview(backgroundImageView)
        backgroundImageView.image = UIImage(named: "background_red")
        backgroundImageView.contentMode = .scaleToFill
        
        // push button
        let pushBtn = UIButton(frame: CGRect(x: (scWdith - btnWidth)/2, y: scHeight/2, width: btnWidth, height: btnHeight))
        pushBtn.setTitle("Push Action", for: .normal)
        pushBtn.setTitleColor(.white, for: .normal)
        pushBtn.backgroundColor = UIColor(red: 255 / 255.0, green: 217 / 255.0, blue: 213 / 255.0, alpha: 1.0)
        pushBtn.layer.cornerRadius = 4.0
        pushBtn.layer.masksToBounds = true
        pushBtn.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
        self.view.addSubview(pushBtn)
        
        // present button
        let presentBtn = UIButton(frame: CGRect(x: (scWdith - btnWidth)/2, y: pushBtn.frame.maxY + 20.0, width: btnWidth, height: btnHeight))
        presentBtn.setTitle("Present Action", for: .normal)
        presentBtn.setTitleColor(.white, for: .normal)
        presentBtn.backgroundColor = UIColor(red: 255 / 255.0, green: 217 / 255.0, blue: 213 / 255.0, alpha: 1.0)
        presentBtn.layer.cornerRadius = 4.0
        presentBtn.layer.masksToBounds = true
        presentBtn.addTarget(self, action: #selector(presentAction), for: .touchUpInside)
        self.view.addSubview(presentBtn)
        
        // setting button
        let settingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        settingBtn.setTitle("Setting", for: .normal)
        settingBtn.setTitleColor(.white, for: .normal)
        settingBtn.addTarget(self, action: #selector(settingAction), for: .touchUpInside)
        
        let settingItem = UIBarButtonItem(customView: settingBtn)
        self.navigationItem.rightBarButtonItem = settingItem
    }
    
    @objc func pushAction() {
        let vc2 = ViewController2()
        self.navigationController?.pushViewController(vc2, animated: true)
    }
    
    @objc func presentAction() {
        let vc2 = ViewController2()
        vc2.tk.setup(animationType: Setting.shared.presentAnimation, interactionType: Setting.shared.presentInteraction)
        vc2.modalPresentationStyle = .fullScreen
        self.present(vc2, animated: true, completion: nil)
    }
    
    @objc func settingAction() {
        let settingVC = SettingViewController()
        let settingNav = UINavigationController(rootViewController: settingVC)
        settingNav.modalPresentationStyle = .fullScreen
        self.present(settingNav, animated: true, completion: nil)
    }
}
