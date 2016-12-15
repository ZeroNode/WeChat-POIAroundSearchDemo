//
//  ViewController.swift
//  AMapDemo
//
//  Created by mc on 08/12/2016.
//  Copyright © 2016 mc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var locationStr = ""
    var cellIdentifier = "cellIdentifier"
    var tabview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AMapServices.sharedServices().apiKey = ""  //注册高德APIKEY
        self.navigationItem.title = "所在位置"
        
        tabview = UITableView(frame: CGRectMake(0,88,UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height),style:UITableViewStyle.Grouped)
        tabview.dataSource = self
        tabview.delegate = self
        tabview.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tabview)
        
        print("locationStr",locationStr)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        for subView:UIView in cell.contentView.subviews{
            subView.removeFromSuperview()
        }
        
        let titleLab:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width , height: cell.frame.size.height))
        titleLab.textAlignment = NSTextAlignment.Left
        titleLab.textColor = UIColor.brownColor()
        titleLab.font = UIFont.systemFontOfSize(15)
        cell.contentView.addSubview(titleLab)
        
        if locationStr.isEmpty == false{
            titleLab.text = locationStr
        }else{
            titleLab.text = "所在位置"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // 位置
        let v:SelectLocationViewController = SelectLocationViewController()
        v.completion = { (selectData:AnyObject)->Void in
            self.locationStr = selectData as! String
            // 刷新cell
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        v.selectLocation = self.locationStr
        v.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(v, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



