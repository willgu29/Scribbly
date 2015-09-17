//
//  BackgroundViewController.swift
//  Scribbly
//
//  Created by William Gu on 9/14/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

import UIKit

@objc protocol BackgroundSelectorDelegate {
    func newBackgroundSelected(backgroundColor: UIColor);
    func newImageSelected(newImage: ALAsset);
}

class BackgroundViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoFetcherDelegate{
    var delegate: AnyObject?
    var photoFetcher = PhotoFetcher.sharedInstance();
    var arrayOfBackgroundColors: [UIColor] = [UIColor.yellowColor(), UIColor.orangeColor(), UIColor.redColor(), UIColor.whiteColor(), UIColor.blackColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.purpleColor(), UIColor.magentaColor()];
    var arrayOfPictures: [ALAsset] = [];
    @IBOutlet weak var collectionView: UICollectionView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoFetcher.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.collectionView.reloadData();
        initCollectionView()
        self.loadPictures();

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell : GroupCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GroupCollectionViewCell
        if (indexPath.section == 0) {
            cell.backgroundColor = arrayOfBackgroundColors[indexPath.row];
        } else {
            var asset: ALAsset = arrayOfPictures[indexPath.row];
            cell.picture?.image = UIImage(CGImage: asset.thumbnail().takeUnretainedValue());
        }
        return cell;
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2;  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return arrayOfBackgroundColors.count;
        } else {
            return arrayOfPictures.count;
        }
    }
    
    
    //MARK: for headers
    //    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    //
    //    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section == 0) {
            delegate?.newBackgroundSelected(arrayOfBackgroundColors[indexPath.row]);
        } else {
            delegate?.newImageSelected(arrayOfPictures[indexPath.row]);
        }
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 90, height: 90) // The size of one cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.frame.width, 10)  // Header size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let frame : CGRect = self.view.frame
        let margin  = (frame.width - 90 * 3) / 6.0
        return UIEdgeInsetsMake(10, margin, 10, margin) // margin between cells
    }
    
  
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    //Mark: Helperfunctions

    func initCollectionView()
    {
        var nib = UINib(nibName: "GroupCollectionViewCell", bundle: nil)
        var frame: CGRect = CGRectMake(0, 50, self.view.frame.width, self.view.frame.height);

        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: "Cell")
        self.collectionView?.contentSize = CGSizeMake(100, 100);
        self.collectionView?.backgroundColor = UIColor.clearColor()
        //        var nib = UINib(nibName: "EventsTableCell", bundle: nil)
        //        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
    }
    
    func fetchPicturesOnDeviceSuccess(photos: [AnyObject]!) {
        self.arrayOfPictures = photos as! [ALAsset]
        self.collectionView?.reloadData();
    }
    
    func loadPictures()
    {
        photoFetcher.getPhotosOnDevice();
    }

}
