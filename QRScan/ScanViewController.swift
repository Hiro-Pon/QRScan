//
//  ScanViewController.swift
//  QRScan
//
//  Created by 張翔 on 2018/11/29.
//  Copyright © 2018 張翔. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class ScanViewController: UIViewController {
    
    var viewModel: ScanViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var qrTextLabel: UILabel!
    
    private let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewModel = ScanViewModel.init()
        bind()
        
        viewModel.setupQRScan()
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.startQRScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stopQRScan()
    }
    
    func bind() {
        viewModel.foundQR.drive(onNext: {[weak self] (data) in
            self?.countLabel.text = String(data.count)
            self?.qrTextLabel.text = String(data.text)
            AudioServicesPlaySystemSound(1519)
        }).disposed(by: disposeBag)
    }

}

