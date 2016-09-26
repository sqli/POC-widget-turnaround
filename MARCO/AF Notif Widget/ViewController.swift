//
//  ViewController.swift
//  AF Notif Widget
//
//  Created by Damien on 20/09/16.
//  Copyright © 2016 Damien. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIWebViewDelegate {

    // Messages viewed
    var messagesViewed = [String]()
    // Messages not viewed
    var messagesNotViewed = [String]()
    
    // Alert button
    var buttonAlert = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
    // Close button
    var buttonClose = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    // Webview to display widget
    var webV=UIWebView()
    
    // Remote Widget URL
    let WIDGET_URL="https://sqli.github.io/POC-widget-turnaround/WIDGET/index.html?application=MARCO"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Loading fake Marco app (with Marco screenshot)
        let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: view.bounds.height-20))
        backgroundImage.image = UIImage(named: "MARCO")
        self.view.insertSubview(backgroundImage, at: 0)
        
        // Init close button (in large view to make touch action easier)
        let buttonCloseView=UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        buttonClose.image = UIImage(named: "close")
        buttonCloseView.insertSubview(buttonClose, at: 0)
        buttonCloseView.frame.origin=CGPoint(x: view.bounds.maxX-35, y: 20)
        self.buttonClose.frame.origin=CGPoint(x: 0, y: 15)
        buttonCloseView.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction))
        buttonCloseView.addGestureRecognizer(tap)
        buttonCloseView.isUserInteractionEnabled = true
        self.buttonClose.isHidden=true
        
        // Init alert button
        self.buttonAlert.frame.origin=CGPoint(x: view.bounds.maxX-buttonAlert.frame.width-50, y: 25)
        self.buttonAlert.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        self.buttonAlert.clipsToBounds=true
        self.buttonAlert.backgroundColor = UIColor.init(red:165/255, green: 0/255, blue: 0/255, alpha: 1)
        self.buttonAlert.addTarget(self, action: #selector(openAction), for: .touchUpInside)
        self.buttonAlert.setTitle("0", for: .normal)
        let path = UIBezierPath(roundedRect:self.buttonAlert.bounds, byRoundingCorners:[.topRight, .bottomRight], cornerRadii: CGSize(width: 10,height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.buttonAlert.layer.mask = maskLayer
        
        
        // Init msg button
        let buttonMsg = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
        buttonMsg.frame.origin=CGPoint(x: view.bounds.maxX-(buttonMsg.frame.width*2)-50, y: 25)
        buttonMsg.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        buttonMsg.clipsToBounds=true
        buttonMsg.backgroundColor = UIColor.init(red:19/255, green: 144/255, blue: 191/255, alpha: 1)
        buttonMsg.setTitle("0", for: .normal)
        let path2 = UIBezierPath(roundedRect:buttonMsg.bounds, byRoundingCorners:[.topLeft, .bottomLeft], cornerRadii: CGSize(width: 10,height: 10))
        let maskLayer2 = CAShapeLayer()
        maskLayer2.path = path2.cgPath
        buttonMsg.layer.mask = maskLayer2
        
        // Init webview to display the widget
        self.webV = UIWebView(frame: CGRect(x: view.bounds.maxX, y: 20, width: view.bounds.width/2, height: view.bounds.height))
        self.webV.delegate = self;
        self.webV.layer.borderWidth=1;
        self.webV.layer.borderColor=UIColor.init(red:175/255, green: 175/255, blue: 175/255, alpha: 1).cgColor;
        self.webV.loadRequest(NSURLRequest(url: NSURL(string: WIDGET_URL) as! URL) as URLRequest)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.webV.addGestureRecognizer(panGesture)
        
        // Init Firebase observers
        let ref = FIRDatabase.database().reference(withPath: "messages")
        
        // Read data and react to changes
        ref.observeSingleEvent(of: .value, with: { snapshot in
            // Init messages viewed and not viewed
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
                if (self.messagesNotViewed.count > 0 && self.webV.frame.origin.x==self.view.bounds.maxX) {
                    self.buttonAlert.setTitle(String(self.messagesNotViewed.count), for: .normal)
                }
            })
        })

        // Add views in root view
        self.view.addSubview(webV)
        self.view.addSubview(buttonMsg)
        self.view.addSubview(buttonAlert)
        self.view.addSubview(buttonCloseView)

    }

    // Manage Webview pan gesture
    func handlePan(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in:view)
        if (self.webV.frame.origin.x+translation.x > self.view.bounds.maxX/2 && self.webV.frame.origin.x+translation.x < self.view.bounds.maxX) {
            self.webV.frame.origin.x=self.webV.frame.origin.x+translation.x;
        }
        
        if panGesture.state == UIGestureRecognizerState.ended {
            if (self.webV.frame.origin.x > (self.view.bounds.maxX/2+self.view.bounds.maxX/4)) {
                closeAction(sender: nil)
            } else {
                openAction(sender: nil)
            }
        }
    }
    
    // Close widget action
    func closeAction(sender: UIButton!) {
        self.buttonClose.isHidden=true
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.webV.frame=CGRect(x: self.view.bounds.maxX-20, y: 20, width: self.view.bounds.width/2, height: self.view.bounds.height)
            }, completion: { (finished: Bool) -> Void in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.webV.frame=CGRect(x: self.view.bounds.maxX, y: 20, width: self.view.bounds.width/2, height: self.view.bounds.height)
                    }, completion: nil)
          })
    }

    // Open widget action
    func openAction(sender: UIButton!) {
        for view in self.messagesNotViewed {
            self.messagesViewed.append(view)
        }
        self.messagesNotViewed = []
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.webV.frame=CGRect(x: self.view.bounds.maxX/2+20, y: 20, width: self.view.bounds.width/2, height: self.view.bounds.height)
            }, completion: { (finished: Bool) -> Void in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.webV.frame=CGRect(x: self.view.bounds.maxX/2, y: 20, width: self.view.bounds.width/2, height: self.view.bounds.height)
                    }, completion: { (finished: Bool) -> Void in
                        self.buttonClose.isHidden=false
                        self.buttonAlert.setTitle("0", for: .normal)
                })        })

    }

}

