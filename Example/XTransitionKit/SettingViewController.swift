//
//  SettingViewController.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit
import XTransitionKit

struct Setting {
    public static var shared = Setting()
    
    var presentAnimation: AnimationType = AnimationType.none
    var presentInteraction: InteractionType = InteractionType.none
    var pushAnimation: AnimationType = AnimationType.none
    var pushInteraction: InteractionType = InteractionType.none
    var tabAnimation: AnimationType = AnimationType.none
    var tabInteraction: InteractionType = InteractionType.none
}

class SettingViewController: UIViewController {
    let animations: [AnimationType] = [AnimationType.none, .flip, .turn, .fold, .cube, .explode, .crossfade]
    let interactions: [InteractionType] = [InteractionType.none, .horizontal, .vertical]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let doneBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.setTitleColor(UIColor(red: 255 / 255.0, green: 155 / 255.0, blue: 174 / 255.0, alpha: 1.0), for: .normal)
        doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)
        
        // table view
        let tableView = UITableView(frame: self.view.bounds)
        self.view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func doneAction() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("settingUpdateNotify"), object: nil, userInfo: nil)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section % 2 > 0 {
            return self.interactions.count
        }else {
            return self.animations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell")!
        cell.accessoryType = .none
        
        var text: String = ""
        if indexPath.section % 2 > 0 {
            text = self.interactions[indexPath.row].rawValue
        }else {
            text = self.animations[indexPath.row].rawValue
        }
        cell.textLabel?.text = text
        
        if indexPath.section == 0, Setting.shared.pushAnimation.rawValue == text {
            cell.accessoryType = .checkmark
        }else if indexPath.section == 1, Setting.shared.pushInteraction.rawValue == text {
            cell.accessoryType = .checkmark
        }else if indexPath.section == 2, Setting.shared.presentAnimation.rawValue == text {
            cell.accessoryType = .checkmark
        }else if indexPath.section == 3, Setting.shared.presentInteraction.rawValue == text {
            cell.accessoryType = .checkmark
        }else if indexPath.section == 4, Setting.shared.tabAnimation.rawValue == text {
            cell.accessoryType = .checkmark
        }else if indexPath.section == 5, Setting.shared.tabInteraction.rawValue == text {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            Setting.shared.pushAnimation = self.animations[indexPath.row]
        }else if indexPath.section == 1 {
            Setting.shared.pushInteraction = self.interactions[indexPath.row]
        }else if indexPath.section == 2 {
            Setting.shared.presentAnimation = self.animations[indexPath.row]
        }else if indexPath.section == 3 {
            Setting.shared.presentInteraction = self.interactions[indexPath.row]
        }else if indexPath.section == 4 {
            Setting.shared.tabAnimation = self.animations[indexPath.row]
        }else if indexPath.section == 5 {
            Setting.shared.tabInteraction = self.interactions[indexPath.row]
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Push / Pop animation"
        }else if section == 1 {
            return "Push / Pop interaction"
        }else if section == 2 {
            return "Present / Dismiss animation"
        }else if section == 3 {
            return "Present / Dismiss interaction"
        }else if section == 4 {
            return "tabbar animation"
        }else if section == 5 {
            return "tabbar interaction"
        }
        return ""
    }
}
