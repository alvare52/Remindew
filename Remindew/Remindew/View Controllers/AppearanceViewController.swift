//
//  AppearanceViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/27/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

protocol AppearanceDelegate {
    
    /// Passes back an image picked from AppearanceViewController
    func didSelectAppearanceObjects(image: UIImage?)
    
    /// Passes back customization options
    func didSelectColorsAndIcons(appearanceOptions: AppearanceOptions)
}

class AppearanceViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Holds all other views,
    let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemGroupedBackground
        contentView.layer.cornerRadius = 15
        return contentView
    }()
    
    /// Notch to indicate that view can be dismissed by swiping down
    let notchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiaryLabel
        view.layer.cornerRadius = 2
        return view
    }()
    
    /// The top UIImageView that is just a big blurry version of the plant image passed in
    let blurredImageView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = .defaultImage
        backgroundView.contentMode = .scaleToFill
        return backgroundView
    }()
 
    /// View bahind option buttons/views
    let optionsBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .systemGroupedBackground
        view.clipsToBounds = true
        return view
    }()
        
    /// ImageView that holds main plant picture (in original size)
    let imageView: UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        tempImageView.contentMode = .scaleAspectFit
        tempImageView.backgroundColor = .clear
        tempImageView.image = UIImage(named: "RemindewDefaultImage")
        return tempImageView
    }()
    
    /// Displays customization options for Plant
    let plantCustomizationView: CustomizationView = {
        let view = CustomizationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGroupedBackground
        view.containerView.backgroundColor = .secondarySystemGroupedBackground
        view.containerView.layer.cornerRadius = 11
        return view
    }()
    
    /// Displays customization options for Main Action ("Water", etc)
    let actionCustomizationView: CustomizationView = {
        let view = CustomizationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGroupedBackground
        view.containerView.backgroundColor = .secondarySystemGroupedBackground
        view.containerView.layer.cornerRadius = 11
        return view
    }()
    
    var plantController: PlantController?
    
    /// Initialize here to prevent lag when presenting it for first time
    var imagePicker: UIImagePickerController!
    
    /// Holds plant that will be passed in and displayed
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds plant image that's passed in from DetailViewController
    var mainImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    /// Tells DetailViewController to update its imageView
    var appearanceDelegate: AppearanceDelegate?
    
    /// Standard padding for left and right sides
    let standardMargin: CGFloat = 20.0
    
    /// Height for optionsView that holds image/plant options
    let optionsViewHeight: CGFloat = 278
    
    /// Height for photo buttons
    let buttonHeight: CGFloat = 36.0
    
    /// TableView that holds image options
    var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        return table
    }()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
        updateViews()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // pass back selected appearance options to DetailViewController when view is going to disappear
        let appearanceOptions = AppearanceOptions(plantIconIndex: Int16(plantCustomizationView.localIconCount),
                                                  plantColorIndex: Int16(plantCustomizationView.localColorsCount),
                                                  actionIconIndex: Int16(actionCustomizationView.localIconCount),
                                                  actionColorIndex: Int16(actionCustomizationView.localColorsCount))
        
        appearanceDelegate?.didSelectColorsAndIcons(appearanceOptions: appearanceOptions)
    }
    
    /// Updates all views when plant is passed in
    private func updateViews() {
        
        guard isViewLoaded else { return }
        
        imageView.image = mainImage
        blurredImageView.image = mainImage
        
        // EDIT/DETAIL Mode
        if let plant = plant {
            plantCustomizationView.plantNameLabel.text = plant.nickname
            actionCustomizationView.plantNameLabel.text = plant.mainAction
            
            plantCustomizationView.localIconCount = Int(plant.plantIconIndex)
            plantCustomizationView.localColorsCount = Int(plant.plantColorIndex)
            actionCustomizationView.localIconCount = Int(plant.actionIconIndex)
            actionCustomizationView.localColorsCount = Int(plant.actionColorIndex)
        }

        // ADD Mode
        else {
            plantCustomizationView.plantNameLabel.text = NSLocalizedString("Nickname", comment: "nickname")
            actionCustomizationView.plantNameLabel.text = NSLocalizedString("Water", comment: "water")
            plantCustomizationView.localIconCount = 8
            plantCustomizationView.localColorsCount = 0
            actionCustomizationView.localIconCount = 0
            actionCustomizationView.localColorsCount = 1
        }
    }
    
    // MARK: - Helpers
    
    /// Brings up camera (if permitted) to let user take a photo of their plant
    @objc private func takePhotoTapped() {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Very first time app is run, it asks for camera usage access, and this runs regardless
        if UserDefaults.standard.bool(forKey: .alreadyAskedForCameraUsage) == false {
            UserDefaults.standard.set(true, forKey: .alreadyAskedForCameraUsage)
        }
        
        // From then on, it can run this to check if permission is allowed
        else {
            
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

            switch cameraAuthorizationStatus {
            case .notDetermined, .denied, .restricted:
                print("notDetermined, denied, restricted")
                makeCameraUsagePermissionAlert()
                return
            case .authorized:
                print("Authorized camera in takePhoto")
            default:
                print("Default in takePhoto")
            }
        }
        
        // check if we have access to Camera (if not, present an alert with option to go to Settings). Just in case
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Error: camera is unavailable")
            makeCameraUsagePermissionAlert()
            return
        }
                
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    /// Lets user choose an image from their photo library (no permission required)
    @objc private func choosePhotoTapped() {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    /// Presents an alert for when a user did not usage of their camera and lets them go to Settings to change it (will restart app though)
    private func makeCameraUsagePermissionAlert() {
    
        // add two options
        let title = NSLocalizedString("Camera Access Denied",
                                      comment: "Title for camera usage not allowed")
        let message = NSLocalizedString("Please allow camera usage by going to Settings and turning Camera access on", comment: "Error message for when camera access is not allowed")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("selected OK option")
        }
        let settingsString = NSLocalizedString("Settings", comment: "String for Settings option")
        let settingsAction = UIAlertAction(title: settingsString, style: .default) { _ in
            // take user to Settings app
            print("selected Settings option")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
  
    /// Presents alert that lets user go to Settings to enable access to Photos to add photos
    private func makeLibraryAddUsagePermissionAlert() {
        
        let title = NSLocalizedString("Photos Access Denied",
                                      comment: "Title for library add usage not allowed")
        
        let message = NSLocalizedString("Please allow access to Photos by going to Settings -> Photos -> Add Photos Only", comment: "Error message for when Photos add access is not allowed")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OK
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        // Settings
        let settingsString = NSLocalizedString("Settings", comment: "String for Settings option")
        let settingsAction = UIAlertAction(title: settingsString, style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Button used to save photo to photo library
    @objc private func savePhotoTapped() {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /// Method called when attempting to save image that's inside imageView
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            // we don't have permission to save to library. Also needs to ask permission again
            makeLibraryAddUsagePermissionAlert()
        } else {
            let ac = UIAlertController(title: NSLocalizedString("Photo Saved", comment: "image saved"), message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    /// Lays out all views needed
    private func setupSubViews() {
                
        view.backgroundColor = .systemGroupedBackground
        view.layer.cornerRadius = 15
        
        // Content View
        view.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                
        // Blurred Image View
        contentView.addSubview(blurredImageView)
        blurredImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        blurredImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        blurredImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        blurredImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -optionsViewHeight + standardMargin).isActive = true
        
        // blur effect over Content View
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurView.frame = blurredImageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredImageView.addSubview(blurView)
        
        // Notch View
        contentView.addSubview(notchView)
        notchView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardMargin).isActive = true
        notchView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        notchView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        notchView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        // Image View
        contentView.addSubview(imageView)
        imageView.centerYAnchor.constraint(equalTo: blurredImageView.centerYAnchor, constant: -10).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardMargin).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardMargin).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        // Options View
        contentView.addSubview(optionsBackgroundView)
        optionsBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        optionsBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        optionsBackgroundView.heightAnchor.constraint(equalToConstant: optionsViewHeight).isActive = true
        optionsBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        // Table View
        optionsBackgroundView.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: optionsBackgroundView.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: -22, left: 0 , bottom: 8, right: 0)
        
        // Plant Customization View
        contentView.addSubview(plantCustomizationView)
        plantCustomizationView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        plantCustomizationView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        plantCustomizationView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        plantCustomizationView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        // Main Action Customization View
        contentView.addSubview(actionCustomizationView)
        actionCustomizationView.topAnchor.constraint(equalTo: plantCustomizationView.bottomAnchor).isActive = true
        actionCustomizationView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        actionCustomizationView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        actionCustomizationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

/// For accessing the photo library
extension AppearanceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            // TODO: set to smaller resolution?
            blurredImageView.image = image
            appearanceDelegate?.didSelectAppearanceObjects(image: image)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension AppearanceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        
        cell.tintColor = .label
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = .takePhotoLocalizedString
            cell.accessoryView = UIImageView(image: UIImage(systemName: "camera"))
        case 1:
            cell.textLabel?.text = .choosePhotoLocalizedString
            cell.accessoryView = UIImageView(image: UIImage(systemName: "photo"))
        default:
            cell.textLabel?.text = .savePhotoLocalizedString
            cell.accessoryView = UIImageView(image: UIImage(systemName: "photo.on.rectangle"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            takePhotoTapped()
        case 1:
            choosePhotoTapped()
        case 2:
            savePhotoTapped()
        default:
            return
        }
    }
    
}

/// Holds 4 options for plant appearance (plantIconIndex, plantColorIndex, actionIconIndex, actionColorIndex)
struct AppearanceOptions {
    /// used for UIImage.plantIconArray
    var plantIconIndex: Int16 = 8
    var plantColorIndex: Int16 = 0
    var actionIconIndex: Int16 = 0
    var actionColorIndex: Int16 = 1
}
