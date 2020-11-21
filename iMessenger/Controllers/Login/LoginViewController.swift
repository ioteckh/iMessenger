//
//  LoginViewController.swift
//  iMessenger
//
//  Created by Martins Michael on 17/11/2020.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController{
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        logoImage.image = UIImage(named: "logo")
        return logoImage
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame:  CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.placeholder = "Email Address"
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.isSecureTextEntry = true
        field.leftView = UIView(frame:  CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookButton: FBLoginButton = {
        let button = FBLoginButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.permissions = ["email, public_profile"]
        return button
    }()
    
    private let googleButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.style = .standard
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let strongSelf = self else{
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done
                                                            , target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        facebookButton.delegate = self
        
         //Add Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(logoImage)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookButton)
        scrollView.addSubview(googleButton)
                
    }
    
    deinit {
        if let observer = loginObserver{
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        
        logoImage.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 40,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: logoImage.bottom + 20,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom + 20,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom + 20,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        facebookButton.center = scrollView.center
        facebookButton.frame = CGRect(x: 30,
                                  y: loginButton.bottom + 20,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        googleButton.frame = CGRect(x: 30,
                                  y: facebookButton.bottom + 20,
                                  width: scrollView.width - 60,
                                  height: 52)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create An Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        //Firebase Login
        Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self]authResult, error in
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
             
            guard authResult != nil , error == nil else{
                strongSelf.alertUserLoginError(message: "The Email or Password Entered Is Incorrect")
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func alertUserLoginError(message: String = "Please Fill In All Fields To Login ") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil ))
        present(alert, animated:  true)
    }
    
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //No Operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("User failed to log in with Facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any], error == nil else{
                print("Failed to make graph request")
                return
            }
            
            print(result)
            
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let pictureUrl = data["url"] as? String else{
                print("Failed to get email and name from Facebook")
                return
            }
            
            
            DatabaseManager.shared.userExits(with: email, completion: {exists in
                if !exists{
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: {success in
                        if success{
                            guard let url = URL(string: pictureUrl) else{
                                return
                            }
                            
                            print("Downloading data from Facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: {data, _, _ in
                                guard let data = data else{
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("Got data from Facebook, Uploading ...")
                                
                                //upload image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {result in
                                    switch result{
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage Manager Error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else{
                    return
                }
                
                guard authResult != nil, error == nil else{
                    if let error = error{
                        print("MFA Failed - \(error)")
                    }
                    return
                }
                print("Logged In succesfully")
                strongSelf.navigationController!.dismiss(animated: true, completion: nil)
            })
        })
    }
    
     
}
