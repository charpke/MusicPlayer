//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Chuck Harpke on 11/26/15.
//  Copyright © 2015 Chuck Harpke. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    var musicFiles = [String]()
    
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()
    var currentIndex: Int = 0
    
    
    var timer: NSTimer = NSTimer()
    
    var timeRemaining: Bool = false
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        loadMusicFiles()
        
        songNameLabel.text = ""
        timeLabel.text = "00:00"
        
        playMusic()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateSlider"), userInfo: nil, repeats: true)
        
        
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func loadMusicFiles() {
        
        let resourcePath: String = NSBundle.mainBundle().resourcePath!
        
        var directoryContents = [String]()
        
        do {
            
            directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(resourcePath) as [String]
            
        } catch _ {
            
            print("Error in Fetching Directory Contents")
            
        }
        
        for i in 0...directoryContents.count - 1 {
            
            //let fileExtension: String = (directoryContents[i] as String).pathExtension
            
            let fileExtension: NSString = (directoryContents[i] as NSString).pathExtension
            
            if fileExtension == "mp3" {
                
                //let fileName: String = (directoryContents[i] as String).stringByDeletingPathExtension
                
                let fileName: NSString = (directoryContents[i] as NSString).stringByDeletingPathExtension
                
                musicFiles.append(String(fileName))
                


            }
        
        }
        
    }
    
    func playMusic() {
        
        let filePath = NSString(string: NSBundle.mainBundle().pathForResource(musicFiles[currentIndex], ofType: "mp3")!)
        
        
        let fileURL = NSURL(fileURLWithPath: filePath as String)

        
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
        } catch _ {
            print ("Error initiating the music player")
        }
        
        musicPlayer.delegate = self
        musicSlider.minimumValue = 0
        musicSlider.maximumValue = Float(musicPlayer.duration)
        
        musicSlider.value = Float(musicPlayer.currentTime)
        
        musicPlayer.volume = volumeSlider.value
        
        musicPlayer.play()
        songNameLabel.text = musicFiles[currentIndex]
        animateSongNameLabel()
        
    }
    
    
    @IBAction func timeButton(sender: AnyObject) {
        timeRemaining = !timeRemaining
    }
    
    
    func updateSlider() {
        
        musicSlider.value = Float(musicPlayer.currentTime)
    
        if timeRemaining == false {
            timeLabel.text = updateTime(musicPlayer.currentTime)
            
        }else {
            timeLabel.text = updateTime(musicPlayer.duration - musicPlayer.currentTime)
        }
        
    
    }
    
    func updateTime(currentTime: NSTimeInterval) -> String {
    
        let current: Int = Int(currentTime)
        
        let minutes = current / 60
        let seconds = current % 60
        
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        if timeRemaining == false {
            return minutesString + ":" + secondsString
        }else {
            return "-" + minutesString + ":" + secondsString
        }
        
    
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        let random = arc4random_uniform(UInt32(musicFiles.count))
        currentIndex = Int(random)
        playMusic()
    }
    
    func animateSongNameLabel() {
        
        UIView.animateWithDuration(1, delay: 0.5, options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: { () -> Void in self.songNameLabel.alpha = 0}, completion: nil)
        
        
    }
    
    // Mark: - Buttons
    
    @IBAction func back(sender: AnyObject) {
        currentIndex -= 1
        if currentIndex < 0 {
            currentIndex = musicFiles.count - 1
        }
        playMusic()
    }
    
    @IBAction func next(sender: AnyObject) {
        currentIndex += 1
        if currentIndex == musicFiles.count {
            currentIndex = 0
        }
        playMusic()
    }
    
    @IBAction func play(sender: AnyObject) {
        musicPlayer.play()
        songNameLabel.text = musicFiles[currentIndex]
        animateSongNameLabel()
    }
    
    @IBAction func pause(sender: AnyObject) {
        musicPlayer.pause()
    }
    
    @IBAction func stop(sender: AnyObject) {
        musicPlayer.stop()
        songNameLabel.text = ""
        musicPlayer.currentTime = 0
    }
    
    @IBAction func musicSliderChanged(sender: AnyObject) {
        if musicPlayer.playing {
            musicPlayer.currentTime = NSTimeInterval(musicSlider.value)
        }
    }
    
    @IBAction func volumeSliderChanged(sender: AnyObject) {
        musicPlayer.volume = volumeSlider.value
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

