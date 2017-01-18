//
//  Player.swift
//  RemoteMediaPlayer
//
//  Created by auc on 7/11/16.
//  Copyright © 2016 Donn. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class Player: AVPlayerViewController
{
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return [UIInterfaceOrientationMask.LandscapeRight ,UIInterfaceOrientationMask.LandscapeLeft]
    }
    
    override func shouldAutorotate() -> Bool
    {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)
        {
            return true
        }
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
