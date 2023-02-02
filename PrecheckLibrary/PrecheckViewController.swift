//
//  PrecheckViewController.swift
//  PrecheckLibrary
//
//  Created by Hasta Ragil on 17/01/23.
//


import UIKit
import AVKit
import MLKit

class PrecheckViewController: UIViewController {
	//	@IBOutlet var frameView: FrameView!
	
	@IBOutlet var frameView: FrameView!
	@IBOutlet var message: UILabel!
	@IBOutlet weak var checkmark: UIImageView!
	
	private var previewLayer: AVCaptureVideoPreviewLayer!
	private lazy var captureSession = AVCaptureSession()
	private lazy var sessionQueue = DispatchQueue(label: "com.google.mlkit.visiondetector.SessionQueue")
	private var lastFrame: CMSampleBuffer?
	private var lastImage: CVPixelBuffer?
	
	private var firstGoodFrameTime: Int64 = 0
	private var isDone = false
	public var configuration = PrecheckConfiguration()
	
	public var onSuccess: ((_ image: String)-> Void)?
	public var onError: ((_ errorCode: Int)-> Void)?
	
	private var isInitialized = false
	private var isManualDismiss = false
	
	private var timer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		setUpCaptureSessionOutput()
		setUpCaptureSessionInput()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("viewdidappear")
		
		
		reset()
		startSession()
		startTimer()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		print("viewDidDisappear \(self.isManualDismiss)")
		
		stopSession()
		if(!self.isManualDismiss) {
			self.onError?(5001)
			self.timer?.invalidate()
		}
	}
	
	func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: self.configuration.timeoutTime / 1000, repeats: false) { [weak self] timer in
			self?.onErrorInternal(errorCode: 5007)
		}
	}
}

// MARK: - Gesture methods

extension PrecheckViewController {
	@IBAction func handleTap(_ sender: UITapGestureRecognizer) {
		//		faceView.isHidden.toggle()
		//    laserView.isHidden.toggle()
		//    faceViewHidden = faceView.isHidden
		//
		//    if faceViewHidden {
		//			laserView.setBadFrame()
		//      faceLaserLabel.text = "Lasers"
		//    } else {
		//			laserView.setGoodFrame()
		//      faceLaserLabel.text = "Face"
		//    }
	}
}

// MARK: - Video Processing methods

extension PrecheckViewController {
	private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
		if #available(iOS 10.0, *) {
			let discoverySession = AVCaptureDevice.DiscoverySession(
				deviceTypes: [.builtInWideAngleCamera],
				mediaType: .video,
				position: .unspecified
			)
			return discoverySession.devices.first { $0.position == position }
		}
		return nil
	}
	
	private func setUpCaptureSessionOutput() {
		weak var weakSelf = self
		sessionQueue.async {
			guard let strongSelf = weakSelf else {
				print("Self is nil!")
				return
			}
			strongSelf.captureSession.beginConfiguration()
			// When performing latency tests to determine ideal capture settings,
			// run the app in 'release' mode to get accurate performance metrics
			strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.medium
			
			let output = AVCaptureVideoDataOutput()
			output.videoSettings = [
				(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
			]
			output.alwaysDiscardsLateVideoFrames = true
			let outputQueue = DispatchQueue(label: "com.google.mlkit.visiondetector.VideoDataOutputQueue")
			output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
			guard strongSelf.captureSession.canAddOutput(output) else {
				print("Failed to add capture session output.")
				return
			}
			strongSelf.captureSession.addOutput(output)
			strongSelf.captureSession.commitConfiguration()
			
			DispatchQueue.main.sync {
				strongSelf.previewLayer.frame = strongSelf.view.bounds
				strongSelf.view.layer.insertSublayer(strongSelf.previewLayer, at: 0)
			}
		}
	}
	
	
	private func setUpCaptureSessionInput() {
		weak var weakSelf = self
		sessionQueue.async {
			guard let strongSelf = weakSelf else {
				print("Self is nil!")
				return
			}
			let cameraPosition: AVCaptureDevice.Position = .front
			guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
				print("Failed to get capture device for camera position: \(cameraPosition)")
				return
			}
			do {
				strongSelf.captureSession.beginConfiguration()
				let currentInputs = strongSelf.captureSession.inputs
				for input in currentInputs {
					strongSelf.captureSession.removeInput(input)
				}
				
				let input = try AVCaptureDeviceInput(device: device)
				guard strongSelf.captureSession.canAddInput(input) else {
					print("Failed to add capture session input.")
					return
				}
				strongSelf.captureSession.addInput(input)
				strongSelf.captureSession.commitConfiguration()
				self.isInitialized = true
				return
			} catch {
				print("Failed to create capture device input: \(error.localizedDescription)")
				return
			}
		}
	}
	
	private func startSession() {
		weak var weakSelf = self
		sessionQueue.async {
			guard let strongSelf = weakSelf else {
				print("Self is nil!")
				return
			}
			
			if(self.isInitialized) {
				strongSelf.captureSession.startRunning()
			} else {
				self.onErrorInternal(errorCode: 5000)
			}
		}
	}
	
	private func stopSession() {
		weak var weakSelf = self
		sessionQueue.async {
			guard let strongSelf = weakSelf else {
				print("Self is nil!")
				return
			}
			if(self.isInitialized) {
				strongSelf.captureSession.stopRunning()
			}
		}
	}
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension PrecheckViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func currentUIOrientation() -> UIDeviceOrientation {
		let deviceOrientation = { () -> UIDeviceOrientation in
			switch UIApplication.shared.statusBarOrientation {
				case .landscapeLeft:
					return .landscapeRight
				case .landscapeRight:
					return .landscapeLeft
				case .portraitUpsideDown:
					return .portraitUpsideDown
				case .portrait, .unknown:
					return .portrait
				@unknown default:
					fatalError()
			}
		}
		guard Thread.isMainThread else {
			var currentOrientation: UIDeviceOrientation = .portrait
			DispatchQueue.main.sync {
				currentOrientation = deviceOrientation()
			}
			return currentOrientation
		}
		return deviceOrientation()
	}
	
	func imageOrientation(
		fromDevicePosition devicePosition: AVCaptureDevice.Position = .front
	) -> UIImage.Orientation {
		var deviceOrientation = UIDevice.current.orientation
		if deviceOrientation == .faceDown || deviceOrientation == .faceUp
			|| deviceOrientation
			== .unknown
		{
			deviceOrientation = currentUIOrientation()
		}
		switch deviceOrientation {
			case .portrait:
				return devicePosition == .front ? .leftMirrored : .right
			case .landscapeLeft:
				return devicePosition == .front ? .downMirrored : .up
			case .portraitUpsideDown:
				return devicePosition == .front ? .rightMirrored : .left
			case .landscapeRight:
				return devicePosition == .front ? .upMirrored : .down
			case .faceDown, .faceUp, .unknown:
				return .up
			@unknown default:
				fatalError()
		}
	}
	
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
			print("Failed to get image buffer from sample buffer.")
			return
		}
		self.lastImage = imageBuffer
		
		let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
		let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
		
		let visionImage = VisionImage(buffer: sampleBuffer)
		let orientation = imageOrientation(
			fromDevicePosition: .front
		)
		
		visionImage.orientation = .leftMirrored
		
		let options = FaceDetectorOptions()
		options.landmarkMode = .all
		options.contourMode = .none
		options.classificationMode = .none
		options.performanceMode = .fast
		
		let faceDetector = FaceDetector.faceDetector(options: options)
		var faces: [Face] = []
		var detectionError: Error?
		do {
			faces = try faceDetector.results(in: visionImage)
		} catch let error {
			detectionError = error
		}
		weak var weakSelf = self
		DispatchQueue.main.sync {
			guard let strongSelf = weakSelf else {
				print("Self is nil!")
				return
			}
			//			strongSelf.updatePreviewOverlayViewWithLastFrame()
			if let detectionError = detectionError {
				print("Failed to detect faces with error: \(detectionError.localizedDescription).")
				strongSelf.onDone(message: self.configuration.messageNoFaceDetected, isGood: false)
				return
			}
			guard !faces.isEmpty else {
				//				print("On-Device face detector returned no results.")
				strongSelf.onDone(message: self.configuration.messageNoFaceDetected, isGood: false)
				return
			}
			
			if(faces.count > 1) {
				strongSelf.onDone(message: self.configuration.messageMultipleFaceDetected, isGood: false)
				return
			}
			
			for face in faces {
				let x = face.frame.origin.x / imageWidth; // actually y
				let y = face.frame.origin.y / imageHeight; // actually x
				let height = face.frame.size.height / imageHeight; // height actualy width
				let width = face.frame.size.width / imageWidth; // width actualy height
				
				if(width < 0.45) {
					strongSelf.onDone(message: self.configuration.messageMoveFaceCloser, isGood: false)
					return
				}
				if(width > 0.65) {
					strongSelf.onDone(message: self.configuration.messageMoveFaceAway, isGood: false)
					return
				}
				if(y < 0.05) {
					strongSelf.onDone(message: self.configuration.messageCenterYourFace, isGood: false)
					return
				}
				if(y > 0.40) {
					strongSelf.onDone(message: self.configuration.messageCenterYourFace, isGood: false)
					return
				}
				if(x < 0.20) {
					strongSelf.onDone(message: self.configuration.messageCenterYourFace, isGood: false)
					return
				}
				if(x > 0.40) {
					strongSelf.onDone(message: self.configuration.messageCenterYourFace, isGood: false)
					return
				}
				
				if(face.headEulerAngleX < -15) {
					print("\(face.headEulerAngleX)")
					strongSelf.onDone(message: self.configuration.messageLookStraight, isGood: false)
					return
				}
				if(face.headEulerAngleX > 15) {
					print("\(face.headEulerAngleX)")
					strongSelf.onDone(message: self.configuration.messageLookStraight, isGood: false)
					return
				}
				if(face.headEulerAngleY < -20) {
					print("\(face.headEulerAngleY)")
					strongSelf.onDone(message: self.configuration.messageLookStraight, isGood: false)
					return
				}
				if(face.headEulerAngleY > 20) {
					print("\(face.headEulerAngleY)")
					strongSelf.onDone(message: self.configuration.messageLookStraight, isGood: false)
					return
				}
				if(face.headEulerAngleZ < -25) {
					print("\(face.headEulerAngleZ)")
					strongSelf.onDone(message: self.configuration.messageLookStraight, isGood: false)
					return
				}
				if(face.headEulerAngleZ > 25) {
					print("\(face.headEulerAngleZ)")
					strongSelf.onDone(message: self.configuration.messageLookStraight, isGood: false)
					return
				}
				
				//				print("\(face.headEulerAngleZ)")
				
				//				print("face detected")
				//				if(face.hasHeadEulerAngleX) {
				//				face.
				//				print(" \(x)")
				//				print("\(y) \(height)")
				strongSelf.onDone(message: self.configuration.messageKeepStill, isGood: true)
				return
				//					print("\(face.headEulerAngleX) \(face.headEulerAngleY) \(face.headEulerAngleZ)")
				//				}
			}
		}
	}
	
	func onDone(message: String, isGood: Bool) {
		if(self.isDone) {
			return
		}
		print("message: \(message) \(isGood)")
		
		self.message.text = message
		
		if(isGood) {
			if(self.firstGoodFrameTime == 0) {
				self.firstGoodFrameTime = Int64(Date().timeIntervalSince1970 * 1000)
				self.frameView.setGoodFrame()
				return
			}
			
			let delay = 2000
			
			if((Int64(Date().timeIntervalSince1970 * 1000) - self.firstGoodFrameTime) >= delay) {
				self.isDone = true
				print("done")
				self.checkmark.isHidden = false
				self.onSuccessInternal()
			}
		} else {
			self.firstGoodFrameTime = 0
			self.frameView.setBadFrame()
		}
	}
	
	func onSuccessInternal() {
		timer?.invalidate()
		guard let lastImage = self.lastImage else {
			return
		}
		
		let ciimage = CIImage(cvPixelBuffer: lastImage)
		let image = UIImage(ciImage: ciimage, scale: 1.0, orientation: .leftMirrored)
		
		guard let imageData:Data = image.pngData() else {
			return
		}
		
		
		let base64 = imageData.base64EncodedString()
		
		self.isManualDismiss = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.navigationController?.popViewController(animated: true)
			
			self.onSuccess?(base64)
		}
	}
	
	func onErrorInternal(errorCode: Int) {
		timer?.invalidate()
		self.onError?(errorCode)
		print("error code \(errorCode)")
		
		
		self.isManualDismiss = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	func reset() {
		timer?.invalidate()
		isDone = false
		self.firstGoodFrameTime = 0
		self.isManualDismiss = false
	}
	
}
