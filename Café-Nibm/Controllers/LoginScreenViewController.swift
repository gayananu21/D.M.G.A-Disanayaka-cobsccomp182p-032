//
//  LoginScreenViewController.swift
//  Café-Nibm
//
//  Created by Gayan Disanayaka on 2/22/21.
//  Copyright © 2021 Gayan Disanayaka. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import CoreLocation
import LocalAuthentication
import FacebookCore
import FacebookLogin




class LoginScreenViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate{
    
    private var locationManager: CLLocationManager?

    @IBOutlet weak var secoundView: UIView!
    @IBOutlet weak var darkTextLabel: UHBCustomLabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shinyTextLabel: UHBCustomLabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: FBLoginButton!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate

    
    /// The username and password that we want to store or read.
       struct Credentials {
           var username: String
           var password: String
       }

       /// The server we are accessing with the credentials.
       let server = "www.example.com"

       /// Keychain errors we might encounter.
       struct KeychainError: Error {
           var status: OSStatus

           var localizedDescription: String {
               return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
           }
       }
    
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if NetworkMonitor.shared.isConnected == false {
            
            print("No network")
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                                             let VC1 = storyBoard.instantiateViewController(withIdentifier: "NO_NETWORK") as! NoNetworkViewController
                                       
                           
                           
                           

                                                               
                                  
                                  self.navigationController?.pushViewController(VC1, animated: true)
        }
        
        
        
        
        
        
        
        
        
        
       scrollView.delegate = self
        
       self.emailTextField.addBottomBorder()
       self.passwordTextField.addBottomBorder()
        
        
        
        //Looks for single or multiple taps.
       let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

            view.addGestureRecognizer(tap)
        
               //add Shimmer effect to logo text
        
               darkTextLabel.textColor = .black
               secoundView.addSubview(darkTextLabel)
               
               shinyTextLabel.textColor = .orange
               shinyTextLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
               shinyTextLabel.textAlignment = .center
               
               secoundView.addSubview(shinyTextLabel)
               
               
               
               let gradientLayer = CAGradientLayer()
               gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
               gradientLayer.locations = [0, 0.5, 1]
               gradientLayer.frame = shinyTextLabel.frame
               
               let angle = 45 * CGFloat.pi / 100
               gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
               
               shinyTextLabel.layer.mask = gradientLayer
               
               let animation = CABasicAnimation(keyPath: "transform.translation.x")
               animation.duration = 2
               animation.fromValue = -view.frame.width
               animation.toValue = view.frame.width
               animation.repeatCount = Float.infinity
               
               gradientLayer.add(animation, forKey: "just some key")
        
        
        
        //Checking Keychain saved email and passwords
        
        do {
            let credentials = try readCredentials(server: server)
            //show(status: "Read credentials: \(credentials.username)/\(credentials.password)")
            self.emailTextField.text = credentials.username
            self.passwordTextField.text = credentials.password
        } catch {
            if let error = error as? KeychainError {
                //show(status: error.localizedDescription)
            }
        }
        
        
            
        
        }
    
    
   
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // Facebook graph request to retrieve the user email & name
        let token = AccessToken.current?.tokenString
        let params = ["fields": "first_name, last_name, email"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params, tokenString: token, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in

            if let err = error {
                print("Facebook graph request error: \(err)")
            } else {
                print("Facebook graph request successful!")

                guard let json = result as? NSDictionary else { return }
                if let email = json["email"] as? String {
                    print("\(email)")
                }
                if let firstName = json["first_name"] as? String {
                    print("\(firstName)")
                }
                if let lastName = json["last_name"] as? String {
                    print("\(lastName)")
                }
                if let id = json["id"] as? String {
                    print("\(id)")
                }
                
                // `AccessToken` is generated after user logs in through Facebook SDK successfully
                let facebookToken = AccessToken.current!.tokenString
                let credential = FacebookAuthProvider.credential(withAccessToken: facebookToken)
                Auth.auth().signIn(with: credential) { (result, error) in
                  if let error = error {
                    print("Firebase auth fails with error: \(error.localizedDescription)")
                  } else if let result = result {
                    print("Firebase login succeeds")
                  
                  }
                }
                
              
                
                
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    
    
    
    //Hide navigation bar when top and show navigation bar when scrolling down.
    
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if (scrollView.contentOffset.y < 0) {
                // Move UP - Show Navigation Bar
                
                UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseOut, animations: {
                               
                                                   self.navigationController?.setNavigationBarHidden(true, animated: true)
                                                }, completion: nil)
            } else if (scrollView.contentOffset.y > 0) {
                 UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn, animations: {
                                              
                                                                  self.navigationController?.setNavigationBarHidden(false, animated: true)
                                                               }, completion: nil)
                
            }
        }
    

    //Calls this function when the tap is recognized to dismiss keyboard
    
    @objc func dismissKeyboard() {
            //Causes the view (or one of its embedded text fields) to resign the first responder status.
            view.endEditing(true)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
           
    }
    
  
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginClicked(_ sender: Any) {
        
        createSpinnerView()
        
        
        self.errorLabel.alpha = 1
        let email = emailTextField.text ?? ""
            let password = passwordTextField.text ?? ""
          
         
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
              if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    self.errorLabel.text = "Please enable Firebase Sign in method"
                  // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    let alert = UIAlertController(title: "ERROR", message: "\(self.errorLabel.text ?? "")", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                                                                   
                                                                            

                                                              }))
                                                                                  self.present(alert, animated: true, completion: nil)

                case .userDisabled:
                    self.errorLabel.text = "Your account has been disabled by an administrator"
                  // Error: The user account has been disabled by an administrator.
                    let alert = UIAlertController(title: "ERROR", message: "\(self.errorLabel.text ?? "")", preferredStyle: .alert)
                                                   alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                                                                                      
                                                                                               

                                                                                 }))
                                                                                                     self.present(alert, animated: true, completion: nil)
                    
                case .wrongPassword:
                    self.errorLabel.text = "The password is invalid or the user does not have a password"
                  // Error: The password is invalid or the user does not have a password.
                    let alert = UIAlertController(title: "ERROR", message: "\(self.errorLabel.text ?? "")", preferredStyle: .alert)
                                                   alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                                                                                      
                                                                                               

                                                                                 }))
                                                                                                     self.present(alert, animated: true, completion: nil)
                    
                case .invalidEmail:
                    self.errorLabel.text = "Please enter a valid email address"
                  // Error: Indicates the email address is malformed.
                    let alert = UIAlertController(title: "ERROR", message: "\(self.errorLabel.text ?? "")", preferredStyle: .alert)
                                                   alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                                                                                      
                                                                                               

                                                                                 }))
                                                                                                     self.present(alert, animated: true, completion: nil)
                    
                default:
                    self.errorLabel.text = "Unable to login"
                    print("Error: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "ERROR", message: "\(self.errorLabel.text ?? "")", preferredStyle: .alert)
                                                   alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                                                                                      
                                                                                               

                                                                                 }))
                                                                                                     self.present(alert, animated: true, completion: nil)
                    
                }
              } else {
                
                self.errorLabel.text = "User signs in successfully"
                print("User signs in successfully")
                let userInfo = Auth.auth().currentUser
                let email = userInfo?.email
                let name = userInfo?.displayName
                let phoneNumber = userInfo?.phoneNumber
                
                // Normally, username and password would come from the user interface.
                       let credentials = Credentials(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")

                       do {
                        try self.addCredentials(credentials, server: self.server)
                          // show(status: "Added credentials.")
                       } catch {
                           if let error = error as? KeychainError {
                              // show(status: error.localizedDescription)
                           }
                       }
                
                func isUserLoggedIn() -> Bool {
                  return Auth.auth().currentUser != nil
                }
                if (isUserLoggedIn() == true) {
                    // Show logout page
                   
                   
                         
                           let storyboard = UIStoryboard(name: "Main", bundle: nil)
                           let vc = storyboard.instantiateViewController(withIdentifier: "HOME_TAB")
                           vc.modalPresentationStyle = .fullScreen
                           vc.modalTransitionStyle = .crossDissolve
                           self.present(vc, animated: true)

               
                    
                  } else {
                    // Show login page
                    
                   
                  }
              }
                
                
            }
        }
    
    /// Draws the status string on the screen, including a partial fade out.
      

       // MARK: - Keychain Access

       /// Stores credentials for the given server.
       func addCredentials(_ credentials: Credentials, server: String) throws {
           // Use the username as the account, and get the password as data.
           let account = credentials.username
           let password = credentials.password.data(using: String.Encoding.utf8)!

           // Create an access control instance that dictates how the item can be read later.
           let access = SecAccessControlCreateWithFlags(nil, // Use the default allocator.
                                                        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                        .userPresence,
                                                        nil) // Ignore any error.

           // Allow a device unlock in the last 10 seconds to be used to get at keychain items.
           let context = LAContext()
           context.touchIDAuthenticationAllowableReuseDuration = 10

           // Build the query for use in the add operation.
           let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                       kSecAttrAccount as String: account,
                                       kSecAttrServer as String: server,
                                       kSecAttrAccessControl as String: access as Any,
                                       kSecUseAuthenticationContext as String: context,
                                       kSecValueData as String: password]

           let status = SecItemAdd(query as CFDictionary, nil)
           guard status == errSecSuccess else { throw KeychainError(status: status) }
       }

       /// Reads the stored credentials for the given server.
       func readCredentials(server: String) throws -> Credentials {
           let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                       kSecAttrServer as String: server,
                                       kSecMatchLimit as String: kSecMatchLimitOne,
                                       kSecReturnAttributes as String: true,
                                       kSecUseOperationPrompt as String: "Access your password on the keychain",
                                       kSecReturnData as String: true]

           var item: CFTypeRef?
           let status = SecItemCopyMatching(query as CFDictionary, &item)
           guard status == errSecSuccess else { throw KeychainError(status: status) }

           guard let existingItem = item as? [String: Any],
               let passwordData = existingItem[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: String.Encoding.utf8),
               let account = existingItem[kSecAttrAccount as String] as? String
               else {
                   throw KeychainError(status: errSecInternalError)
           }

           return Credentials(username: account, password: password)
       }
        
    
}




//Here we can add bottom line to UITextField

extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: 1200, height: 1)
        bottomLine.backgroundColor = UIColor.black.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}

