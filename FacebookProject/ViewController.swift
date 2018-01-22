import UIKit
import FacebookCore
import FacebookLogin
import FacebookShare
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LoginButtonDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    let picker = UIImagePickerController()
    var loginButton: LoginButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var picShareToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        
        titleLabel.center = view.center
        titleLabel.center.y = titleLabel.center.y - 150
        
        view.addSubview(loginButton)
        loginButton.delegate = self
        picker.delegate = self
        
        picker.mediaTypes = [kUTTypeImage as String]
        
        if imageView.image == nil {
            shareButton.isEnabled = false
        }
        
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                if let email = value.dictionaryValue {
                print(email)
                    self.userLoggedIn()
                }
            case .failed(let error):
                self.picShareToolbar.isHidden = true
                print(error)
            }
        }
        
    }
    
    func userLoggedIn() {
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.titleLabel.center.y = self.titleLabel.center.y - 100
            self.loginButton.center.y = self.loginButton.center.y + 250
            self.view.backgroundColor = .gray
            self.picShareToolbar.isHidden = false
        })
    }
    
    func  userLoggedOut() {
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.imageView.isHidden = true
            self.titleLabel.center.y = self.titleLabel.center.y + 100
            self.loginButton.center.y = self.loginButton.center.y - 250
            self.view.backgroundColor = .black
            self.picShareToolbar.isHidden = true
            self.shareButton.isEnabled = false
        })
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("Cancelled")
        case .success:
            userLoggedIn()
            print("Logged In")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        userLoggedOut()
    }


    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func useCamera(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        }
        else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        imageView.isHidden = false
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareOnFacebook(_ sender: UIBarButtonItem) {
        if let myViewController = UIApplication.shared.keyWindow?.rootViewController {
            let photo = Photo(image: self.imageView.image!, userGenerated: true)
            let content = PhotoShareContent(photos: [photo])
            do {
                try ShareDialog.show(from: myViewController, content: content)
            }
            catch {
                cannotShare()
            }
        }
    }
    
    func cannotShare(){
        let alertVC = UIAlertController(title: "Photo not shared", message: "Sorry, your photo could not be shared", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }

}

