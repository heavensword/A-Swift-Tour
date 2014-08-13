//
//  MasterViewController.swift
//  ApplicationListDemo
//
//  Created by Sword on 8/3/14.
//  Copyright (c) 2014 Sword. All rights reserved.
//

import UIKit
import StoreKit

class MasterViewController: UITableViewController, SKStoreProductViewControllerDelegate {

    var applications = NSMutableArray()

    @IBOutlet var indicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib:UINib = UINib(nibName: "ApplicationCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "ApplicationCell")
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl = UIRefreshControl();
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(self.refreshControl)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshControl.beginRefreshing()
        showLoading()
        loadApplications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let object = applications[indexPath.row] as NSDate
            (segue.destinationViewController as DetailViewController).detailItem = object
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applications.count
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let application:Application = applications[indexPath.row] as Application!;
        let fixedHeight:CGFloat = 60.0
        var cellHeight:CGFloat = 50;
        
        var attributes:NSDictionary = [NSFontAttributeName:UIFont.systemFontOfSize(13)]
        var boundingRect:CGRect = application.desc!.boundingRectWithSize(CGSizeMake(226, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        cellHeight += boundingRect.size.height

        if cellHeight <= fixedHeight {
            cellHeight = fixedHeight;
        }
        NSLog("cell height \(cellHeight)")
        return cellHeight;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ApplicationCell", forIndexPath: indexPath) as ApplicationCell

        cell.application = applications[indexPath.row] as? Application
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        var scrollView:UIScrollView = UIScrollView()
        scrollView.delegate?.scrollViewDidScroll?(scrollView)
        return true
    }

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        NSLog("didSelectRowAtIndexPath")        
        if (NSClassFromString("SKStoreProductViewController") != nil) {
            self.showLoading()
            var application:Application = self.applications[indexPath.row] as Application
            var bunldId:NSString = application.bundleId!
            let productViewController:SKStoreProductViewController = SKStoreProductViewController()
            productViewController.delegate = self
            productViewController.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier: bunldId], completionBlock:
                {(result:Bool, error:NSError!) -> Void in
                    self.hideLoading()
                    if result {
                        self.presentViewController(productViewController, animated: true, completion: nil)
                    }
                }
            )
        }
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        self.hideLoading()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadApplications(){
        var url = NSURL.URLWithString("https://itunes.apple.com/search?term=qq&country=cn&entity=software")
        var request:NSURLRequest = NSURLRequest(URL: url)        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{
            ( response:NSURLResponse!,  data:NSData!, error:NSError!) -> Void in
                self.hideLoading()
                if (data != nil) {
                    self.applications.removeAllObjects()
                    var jsonObject:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as NSDictionary
                    var applicationDicArray:NSArray = jsonObject["results"]? as NSArray
                    for applicationDic in applicationDicArray {
                        let application = Application()
                        application.name = applicationDic["trackName"] as? NSString
                        application.icon = applicationDic["artworkUrl512"] as? NSString
                        application.desc = applicationDic["description"] as? NSString
                        application.bundleId = (applicationDic["trackId"] as? NSNumber)?.stringValue
                        self.applications.addObject(application)
                    }
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        
    }

    func showLoading() {
        if self.indicatorView.superview != nil {
            self.indicatorView.center = UIApplication.sharedApplication().keyWindow.center
            UIApplication.sharedApplication().keyWindow.addSubview(self.indicatorView)
        }
        self.indicatorView.alpha = 1.0;
        self.indicatorView.hidden = false
        self.indicatorView.startAnimating()
    }
    
    func hideLoading() {
        UIView.animateWithDuration(0.3, animations:{ () -> Void in
            self.indicatorView.alpha = 0.0
            }, completion: {(finished:Bool) -> Void in
                if finished {
                    self.hideLoading()
                }
            })
    }
    
    func refresh(sender:AnyObject!){
        NSLog("refresh")
        self.loadApplications()
    }
}

