import UIKit
import FacebookCore
import FacebookLogin
import FacebookShare

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LoginButtonDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
        loginButton.delegate = self
        picker.delegate = self
        
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue)
            case .failed(let error):
                print(error)
            }
        }
        
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("Cancelled")
        case .success:
            titleLabel.isHidden = true
            loginButton.isHidden = true
            UIView.animate(withDuration: 2.0, animations: { () -> Void in
                self.view.backgroundColor = .gray
            })
            print("Logged In")
        }
    }
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }


    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
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
        
//        let photo = Photo(image: self.imageView.image!, userGenerated: true)
//        var content = PhotoShareContent(photos: [photo])
//        content.photos = [photo]
//        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

