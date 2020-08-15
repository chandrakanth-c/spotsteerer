//
//  ViewController.swift
//  TestFinalProject
//
//  Created by Chandrakanth on 4/22/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
    
    var videoPlayer:AVPlayer?
    
    var videoPlayerLayer:AVPlayerLayer?

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        setUpVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Set up the video in the background
        
    }
    
    func setUpElements(){
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleFilledButton(loginButton)
        
    }
    
    func setUpVideo() {
        
        //Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "loginbg", ofType: "mp4")
        
        guard bundlePath != nil else {
            return
        }
        
        //Create a URL from it
        let url = URL(fileURLWithPath: bundlePath!)
        
        //Create the video player item
        let item = AVPlayerItem(url: url)
        
        //Create the player
        videoPlayer = AVPlayer(playerItem: item)
        
        //Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        //Adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        //Add it in the view and play it
        videoPlayer?.playImmediately(atRate: 0.3)
        
    }

}
