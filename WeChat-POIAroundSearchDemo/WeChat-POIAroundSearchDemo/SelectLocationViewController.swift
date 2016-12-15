//
//  SelectLocationViewController.swift
//  YuErBao
//
//  Created by mc on 12/12/2016.
//  Copyright © 2016 first mac. All rights reserved.
//

import UIKit

class SelectLocationViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate,MAMapViewDelegate{

    typealias completionBlock = (selectData:AnyObject)->Void
    var completion: completionBlock?
    private var selectData: AnyObject?
    private var selectCell: NSIndexPath?
    
    var selectLocation_Not_Show = "不显示位置"
    var selectLocation:String = ""
    var addressArray:NSMutableArray!
    var identifier = "cell"
    var tableView:UITableView!
    var pageIndex:Int = 0
    var pageCount:Int = 0
    //定位
    var currentLocation:CLLocation?             //当前位置
    var mapView:MAMapView!
    var search:AMapSearchAPI!                   //POI搜索
    var poiRequest:AMapPOIAroundSearchRequest!  //周边搜索请求
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressArray = NSMutableArray()
        let first:AMapPOI = AMapPOI()
        first.name = selectLocation_Not_Show
        self.addressArray.addObject(first)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        mapView = MAMapView(frame:CGRect.zero)
        mapView.delegate = self
        mapView.showsUserLocation = true                        //显示用户位置
        mapView.distanceFilter = CLLocationDistance.abs(100)    //设定定位的最小更新距离
        
        search = AMapSearchAPI()
        search!.delegate = self
        
        let hg = UIScreen.mainScreen().bounds.height - self.navigationController!.navigationBar.frame.size.height - UIApplication.sharedApplication().statusBarFrame.size.height
        tableView = UITableView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,hg),style:UITableViewStyle.Grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(SelectLocationTableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        
        //刷新
        tableView.headerView = XWRefreshNormalHeader(target: self, action: #selector(self.upPullLoadData))
        tableView.footerView = XWRefreshAutoNormalFooter(target: self, action: #selector(self.downPlullLoadData))
        tableView.headerView?.beginRefreshing()
        
    }
    
    /// 返回
    func backAction(sender: AnyObject?){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! SelectLocationTableViewCell
        cell.selectionStyle = .None
        
        let info:AMapPOI = self.addressArray[indexPath.row] as! AMapPOI
        cell.shopNameLab.text = info.name.isEmpty == false ? info.name : info.city
        cell.descLab.text = info.name.isEmpty == false ? info.city + info.district + info.address : ""
        if cell.descLab.text == ""{
            cell.descLab.text = ""
            cell.descLab.fixedHeight = 0
        }else{
            cell.descLab.fixedHeight = 20
        }
        
        if cell.shopNameLab.text == selectLocation{
            selectCell = indexPath
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if selectCell == nil {
            // 直接标记为选中
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectCell = indexPath
            let info:AMapPOI = self.addressArray[indexPath.row] as! AMapPOI
            selectData = info.name.characters.count > 0 ? info.name : info.city
        }else if selectCell != indexPath {
            // 重新标记选中
            let oldCell = tableView.cellForRowAtIndexPath(selectCell!)
            oldCell?.accessoryType = UITableViewCellAccessoryType.None
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectCell = indexPath
            let info:AMapPOI = self.addressArray[indexPath.row] as! AMapPOI
            selectData = info.name.characters.count > 0 ? info.name : info.city
        }
        
        if completion != nil{
            if selectData != nil{
                completion!(selectData: selectData!)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeightForIndexPath(indexPath, cellContentViewWidth:UIScreen.mainScreen().bounds.width, tableView: tableView)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func sendRequest(){
        if AMapServices.sharedServices().apiKey.isEmpty == true {
            print("apiKey为空或位数不合要求")
            self.tableView.reloadData()
            self.tableView.headerView?.endRefreshing()
            self.tableView.footerView?.endRefreshing()
        }
        
        if let coordinate = self.currentLocation?.coordinate {
            poiRequest = AMapPOIAroundSearchRequest()
            poiRequest.keywords = "住宅区|学校|酒店|餐馆|银行|药店|娱乐"
            poiRequest.offset = self.pageCount
            poiRequest.page = self.pageIndex
            poiRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))         //中心点坐标
            poiRequest.radius = 500             //查询半径，范围
            poiRequest.sortrule = 0             //排序规则, 0-距离排序；1-综合排序, 默认1
            poiRequest.requireExtension = true  //返回扩展信息
            //        poiRequest.types = "050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|150000|160000|170000"  //常规分类
            
            self.search.AMapPOIAroundSearch(poiRequest)
        }else{
            print("无法获取当前位置，请稍后重试")
            self.tableView.reloadData()
            self.tableView.headerView?.endRefreshing()
            self.tableView.footerView?.endRefreshing()
        }
        
    }
    // 定位回调
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation {
            currentLocation = userLocation.location
            print("当前位置",currentLocation)
        }
    }
    
    //回调函数
    func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 {
            return
        }
//        self.addressArray = []
        
        if self.addressArray.count == 1{
            let poi:AMapPOI = AMapPOI()
            poi.city = response.pois.first!.city
            self.addressArray.addObject(poi)
        }
        
        self.addressArray.addObjectsFromArray(response.pois)
        self.tableView.reloadData()
        
        self.tableView.footerView?.hidden = response.pois.count != self.pageCount
        self.tableView.headerView?.endRefreshing()
        self.tableView.footerView?.endRefreshing()
        
    }
    
    //头部刷新
    func upPullLoadData(){
        self.pageIndex = 0
        self.pageCount = 10
        self.downPlullLoadData()
    }
    //尾部刷新
    func downPlullLoadData(){
        self.pageIndex += 1
        self.sendRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
