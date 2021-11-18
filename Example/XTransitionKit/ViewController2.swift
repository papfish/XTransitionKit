//
//  ViewController2.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class ViewController2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.extendedLayoutIncludesOpaqueBars = true
        
        // background image view
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        self.view.addSubview(backgroundImageView)
        backgroundImageView.image = UIImage(named: "background_green")
        backgroundImageView.contentMode = .scaleToFill
        
        let scWdith = UIScreen.main.bounds.size.width
        let scHeight = UIScreen.main.bounds.size.height
        let btnWidth = 160.0
        let btnHeight = 40.0
        
        // pop button
        let popBtn = UIButton(frame: CGRect(x: (scWdith - btnWidth)/2, y: scHeight/2, width: btnWidth, height: btnHeight))
        popBtn.setTitle("Pop Action", for: .normal)
        popBtn.setTitleColor(.white, for: .normal)
        popBtn.backgroundColor = UIColor(red: 172 / 255.0, green: 220 / 255.0, blue: 208 / 255.0, alpha: 1.0)
        popBtn.layer.cornerRadius = 4.0
        popBtn.layer.masksToBounds = true
        popBtn.addTarget(self, action: #selector(popAction), for: .touchUpInside)
        self.view.addSubview(popBtn)
        
        // dismiss button
        let dismissBtn = UIButton(frame: CGRect(x: (scWdith - btnWidth)/2, y: popBtn.frame.maxY + 20.0, width: btnWidth, height: btnHeight))
        dismissBtn.setTitle("Dismiss Action", for: .normal)
        dismissBtn.setTitleColor(.white, for: .normal)
        dismissBtn.backgroundColor = UIColor(red: 172 / 255.0, green: 220 / 255.0, blue: 208 / 255.0, alpha: 1.0)
        dismissBtn.layer.cornerRadius = 4.0
        dismissBtn.layer.masksToBounds = true
        dismissBtn.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        self.view.addSubview(dismissBtn)
    }
    
    @objc func popAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
