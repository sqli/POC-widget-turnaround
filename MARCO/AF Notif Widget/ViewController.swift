//
//  ViewController.swift
//  AF Notif Widget
//
//  Created by Damien on 20/09/16.
//  Copyright © 2016 Damien. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIWebViewDelegate  {

    var messagesViewed = [String]()
    var messagesNotViewed = [String]()
    var button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    var webV=UIWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "MARCO")
        self.view.insertSubview(backgroundImage, at: 0)
        
        let ref = FIRDatabase.database().reference(withPath: "messages")
        
        self.button.frame.origin=CGPoint(x: view.bounds.maxX-button.frame.width-10, y: 20)
        self.button.layer.cornerRadius = 0.5 * button.bounds.size.width
        self.button.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        self.button.clipsToBounds=true
        self.button.backgroundColor = UIColor.init(red:250/255, green: 69/255, blue: 85/255, alpha: 1)
        self.button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.button.isHidden=true;
        
        // Read data and react to changes
        ref.observeSingleEvent(of: .value, with: { snapshot in
            self.messagesViewed = []
            self.messagesNotViewed = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    self.messagesViewed.append(snap.key)
                }
            }
            ref.observe(.value, with: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        if (!self.messagesViewed.contains(snap.key) && !self.messagesNotViewed.contains(snap.key)) {
                            self.messagesNotViewed.append(snap.key)
                        }
                    }
                }
                if (self.messagesNotViewed.count > 0) {
                    self.button.setTitle(String(self.messagesNotViewed.count), for: .normal)
                    self.button.isHidden=false;
                } else {
                    self.button.isHidden=true;
                }
            })
        })
        self.webV = UIWebView(frame: CGRect(x: view.bounds.maxX, y: 0, width: view.bounds.width/2, height: view.bounds.height))
        self.webV = UIWebView(frame: CGRect(x: view.bounds.maxX, y: 0, width: view.bounds.width/2, height: view.bounds.height))
        
        self.webV.delegate = self;
        self.view.addSubview(button)
        let viewTwo = UIView(frame: CGRect(x:0, y:50, width: UIScreen.main.bounds.size.width, height: 150))
        viewTwo.backgroundColor = UIColor.black
        self.view.addSubview(webV)
        
        self.webV.loadRequest(NSURLRequest(url: NSURL(string: "https://sqli.github.io/POC-widget-turnaround/WIDGET/index.html?application=MARCO") as! URL) as URLRequest)
    }
    
    
    func buttonAction(sender: UIButton!) {
        for view in self.messagesNotViewed {
            self.messagesViewed.append(view)
        }
        self.messagesNotViewed = []
        self.button.isHidden=true;
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.webV.frame=CGRect(x: self.view.bounds.maxX/2, y: 0, width: self.view.bounds.width/2, height: self.view.bounds.height)
            }, completion: nil)

    }

}

