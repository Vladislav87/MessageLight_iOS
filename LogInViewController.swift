//
//  LogInViewController.swift
//  MessageLight
//
//  Created by Владислав Ходеев on 15.07.16.
//  Copyright © 2016 Vlad Samoilov. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LogInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var googleButton: UIButton!
    
    @IBOutlet weak var anonimButton: UIButton!

    @IBOutlet weak var LogoViewImage: UIImageView!
    
    @IBOutlet weak var LogoTextUnderImage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       


       
        let scaleAnimation = CGAffineTransformMakeScale(0.0, 0.0)
        let translationAnimation = CGAffineTransformMakeTranslation(0, 600)
        googleButton.transform = CGAffineTransformConcat(scaleAnimation, translationAnimation)
      

        let scaleАnimation2 = CGAffineTransformMakeScale(0.0, 0.0)
        let translationAnimation2 = CGAffineTransformMakeTranslation(0, 600)
        self.anonimButton.transform = CGAffineTransformConcat(scaleАnimation2, translationAnimation2)

       
        let scaleAnimation3 = CGAffineTransformMakeScale(0.0, 0.0)
        let translationAnimation3 = CGAffineTransformMakeTranslation(0, 600)
        googleButton.transform = CGAffineTransformConcat(scaleAnimation3, translationAnimation3)
       
        let scaleAnimation4 = CGAffineTransformMakeScale(0.0, 0.0)
        let translationAnimation4 = CGAffineTransformMakeTranslation(0, 600)
        googleButton.transform = CGAffineTransformConcat(scaleAnimation4, translationAnimation4)
        
        



        
        
        
        GIDSignIn.sharedInstance().clientID = "993008978397-kughn7qmfgijhfv73b0ojjvuvv93g912.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    
        
       
    
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
        

        FIRAuth.auth()?.addAuthStateDidChangeListener( {(auth:FIRAuth,user: FIRUser?) in
            if user != nil {
                print(user)
                Helper.helper.switchToNavigationViewController()
                
            }else {
               print("Неавторизованный пользователь!")
            }
        })
       
        
        UIView.animateWithDuration(0.7, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
            
            
            let scaleAnimation = CGAffineTransformMakeScale(1.0, 1.0)
            let translationAnimation = CGAffineTransformMakeTranslation(0, 0)
            self.googleButton.transform = CGAffineTransformConcat(scaleAnimation, translationAnimation)
            }, completion: nil)
        
        
        UIView.animateWithDuration(0.7, delay: 0.9, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
        let scaleАnimation2 = CGAffineTransformMakeScale(1.0, 1.0)
        let translationAnimation2 = CGAffineTransformMakeTranslation(0, 0)
            self.anonimButton.transform = CGAffineTransformConcat(scaleАnimation2, translationAnimation2)}, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            
            
            let scaleAnimation = CGAffineTransformMakeScale(1.0, 1.0)
            let translationAnimation = CGAffineTransformMakeTranslation(0, 0)
            self.LogoViewImage.transform = CGAffineTransformConcat(scaleAnimation, translationAnimation)
            }, completion: nil)
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.4, options: [], animations: {
            
            
            let scaleAnimation = CGAffineTransformMakeScale(1.0, 1.0)
            let translationAnimation = CGAffineTransformMakeTranslation(0, 0)
            self.LogoTextUnderImage.transform = CGAffineTransformConcat(scaleAnimation, translationAnimation)
            }, completion: nil)

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func LoginAnonimously(sender: AnyObject) {
        print("анонимная регистрация")
        
        
      Helper.helper.LoginAnonimously()
        
        
        
        
        
        
        
    }
   
    @IBAction func GoogleLogIning(sender: AnyObject) {
        print("регистрация через гугл")
        
        GIDSignIn.sharedInstance().signIn()
        
        
        
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        print(user.authentication)
        Helper.helper.logInWithGoogle(user.authentication)

    }
    
    

}
