//
//  PrecheckConfiguration.swift
//  PrecheckLibrary
//
//  Created by Hasta Ragil on 23/01/23.
//

import Foundation

public struct PrecheckConfiguration: Codable {
    public var license: String = "";
    public var colorOverlay: String = "";
    public var colorOverlayOpacity: Double = 0.5;
    public var colorBorderGood: String = "";
    public var colorBorderBad: String = "";
    public var colorCheckmark: String = "";
    public var colorCheckmarkOpacity: Double = 0.5;
    public var colorCaptureButton: String = "";
    public var colorCaptureText: String = "";
    public var autoCapture: Bool = true;
    public var delayCheckmark: Double = 2000.0;
    public var delayAutoCapture: Double = 2000.0;
    public var messageLoading: String = "Loading";
    public var messageNoFaceDetected: String = "No face detected";
    public var messageMultipleFaceDetected: String = "Multiple face detected";
    public var messageCenterYourFace: String = "Center your face";
    public var messageMoveFaceAway: String = "Move face away from camera";
    public var messageMoveFaceCloser: String = "Move face closer to camera";
    public var messageLookStraight: String = "Look straight";
    public var messageEyesClosed: String = "Eyes closed";
    public var messageKeepStill: String = "Keep still";
    public var messageMaskDetected: String = "Mask detected";
    public var messageHatDetected: String = "Hat detected";
    public var messageGlassesDetected: String = "Glass detected";
    public var sensitivityYawStart: Double = -0.1;
    public var sensitivityYawEnd: Double = 0.2;
    public var sensitivityRollStart: Double = -0.2;
    public var sensitivityRollEnd: Double = 0.2;
    public var sensitivityPitchStart: Double = -0.1;
    public var sensitivityPitchEnd: Double = 0.2;
    public var sensitivityGlasses: Double = 0.5;
    public var sensitivityMask: Double = 0.5;
    public var sensitivityHat: Double = 0.5;
    public var sensitivityBlur: Double = 0.9;
    public var sensitivityPositionXStart: Double = -0.1;
    public var sensitivityPositionXEnd: Double = 0.2;
    public var sensitivityPositionYStart: Double = 0.1;
    public var sensitivityPositionYEnd: Double = 0.35;
    public var sensitivityPositionHStart: Double = 0.7;
    public var sensitivityPositionHEnd: Double = 1.3;
	public var etcFailOnMultipleFace: Bool = true;
	public var timeoutEnabled: Bool = true;
	public var timeoutTime: Double = 10000.0;
    
    public init() {
        
    }
}
