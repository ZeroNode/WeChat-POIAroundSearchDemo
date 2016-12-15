# WeChat-POIAroundSearchDemo
Swift仿微信获取周边位置<br><br>
下载项目需要修改<br>
1.bundle identifier与高德注册appkey保持一致<br>
2.AMapServices.sharedServices().apiKey = ""  //注册高德APIKEY<br><br>
![image](https://github.com/ZeroNode/WeChat-POIAroundSearchDemo/blob/master/bundle.png)

##Requirements
+ Swift 2.3 , Swift 3.0
+ iOS 8.0+
+ Xcode 8+

##Example

```
    // 发送POI请求
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
    
     //回调函数
    func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 {
            return
        }
        
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
```


---

如果你有更好的建议请联系我
