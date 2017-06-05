import UIKit
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return // No image selected.
        }
        
        let photo = Photo(image: image, userGenerated: true)
        let content = PhotoShareContent(photos: [photo])
        try ShareDialog.show(from: ViewController, content: content)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

