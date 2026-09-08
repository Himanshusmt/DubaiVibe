//
//  LocationManager.swift
//  LocationManager
//
//  Created by Rajan Maheshwari on 22/10/16.
//  Copyright © 2016 Rajan Maheshwari. All rights reserved.
//

import UIKit
import MapKit

final class LocationManager: NSObject {
    
    enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
        case unknown = "Some Unknown Error occurred"
    }
    
    typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    private var locationCompletionHandler: LocationClosure?
    
    typealias ReverseGeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    private var geoLocationCompletionHandler: ReverseGeoLocationClosure?
    
    private var locationManager:CLLocationManager?
    var locationAccuracy = kCLLocationAccuracyBest
    private var isPermissionOnlyRequest = false
    private var hasRequestedAlwaysUpgrade = false
    
    private var lastLocation:CLLocation?
    private var cachedLastKnownLocation: CLLocation?
    private var reverseGeocoding = false
    private var isReverseGeocodeInProgress = false
    private var isLiveSharingActive = false
    private var liveSharingHandler: ((CLLocation, CLPlacemark?) -> Void)?
    
    //Singleton Instance
    static let shared: LocationManager = {
        let instance = LocationManager()
        // setup code
        return instance
    }()
    
    private override init() {}

    //MARK:- Destroy the LocationManager
    deinit {
        destroyLocationManager()
    }
    
    //MARK:- Private Methods
    private func setupLocationManager() {
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.delegate = self
        locationManager?.pausesLocationUpdatesAutomatically = true
        locationManager?.showsBackgroundLocationIndicator = true
    }

    private func requestAlwaysAuthorizationIfNeeded() {
        switch currentAuthorizationStatus() {
        case .notDetermined, .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        default:
            break
        }
    }

    private func configureBackgroundLocationIfNeeded() {
        guard currentAuthorizationStatus() == .authorizedAlways else { return }
        if locationManager == nil {
            setupLocationManager()
        }
        locationManager?.allowsBackgroundLocationUpdates = true
    }

    private func completePermissionOnlyRequest() {
        isPermissionOnlyRequest = false
        hasRequestedAlwaysUpgrade = false

        if currentAuthorizationStatus() == .authorizedAlways {
            configureBackgroundLocationIfNeeded()
            return
        }

        locationManager?.stopUpdatingLocation()
        if locationCompletionHandler == nil && geoLocationCompletionHandler == nil {
            destroyLocationManager()
        }
    }
    
    private func destroyLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
        lastLocation = nil
    }
    
    @objc private func sendPlacemark() {
        guard let location = lastLocation else {
            
            self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
                        
            lastLocation = nil
            return
        }

        guard !isReverseGeocodeInProgress else { return }

        isReverseGeocodeInProgress = true
        lastLocation = nil
        self.reverseGeoCoding(location: location)
    }
    
    @objc private func sendLocation() {
        guard let _ = lastLocation else {
            self.didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            lastLocation = nil
            return
        }
        self.didComplete(location: lastLocation,error: nil)
        lastLocation = nil
    }
    
//MARK:- Public Methods

    /// Request Always location permission when the user opens the app.
    func requestPermissionIfNeeded() {
        switch currentAuthorizationStatus() {
        case .notDetermined, .authorizedWhenInUse:
            isPermissionOnlyRequest = true
            hasRequestedAlwaysUpgrade = false
            if locationManager == nil {
                setupLocationManager()
            }
            requestAlwaysAuthorizationIfNeeded()
        case .authorizedAlways:
            configureBackgroundLocationIfNeeded()
        default:
            break
        }
    }

    /// Call when the app becomes active to finish the Always upgrade flow.
    func finalizePermissionRequestIfNeeded() {
        guard isPermissionOnlyRequest, hasRequestedAlwaysUpgrade else { return }

        switch currentAuthorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            completePermissionOnlyRequest()
        default:
            break
        }
    }

    private func currentAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager?.authorizationStatus ?? CLLocationManager().authorizationStatus
        }
        return CLLocationManager.authorizationStatus()
    }

    /// Check if location services are enabled and the app has permission.
    func hasLocationAccess() -> Bool {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        switch currentAuthorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    /// Check if location is enabled on device or not
    ///
    /// - Parameter completionHandler: nil
    /// - Returns: Bool
    func isLocationEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                return false
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                return true
                @unknown default:
                    break
            }
        } else {
            return false
        }
        
        return false
       // return CLLocationManager.locationServicesEnabled()
    }
    
    /// Get current location
    ///
    /// - Parameter completionHandler: will return CLLocation object which is the current location of the user and NSError in case of error
    func getLocation(completionHandler:@escaping LocationClosure) {
        
        //Resetting last location
        lastLocation = nil
        
        self.locationCompletionHandler = completionHandler
        
        if locationManager == nil {
            setupLocationManager()
        }
        requestAlwaysAuthorizationIfNeeded()
    }
    
    
    /// Get Reverse Geocoded Placemark address by passing CLLocation
    ///
    /// - Parameters:
    ///   - location: location Passed which is a CLLocation object
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the CLLocation and NSError in case of error
    func getReverseGeoCodedLocation(location:CLLocation,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            isReverseGeocodeInProgress = true
            self.reverseGeoCoding(location: location)
        }

    }
    
    /// Get Latitude and Longitude of the address as CLLocation object
    ///
    /// - Parameters:
    ///   - address: address given by the user in String
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the address entered and NSError in case of error
    func getReverseGeoCodedLocation(address:String,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(address: address)
        }
    }
    
    var lastKnownLocation: CLLocation? {
        cachedLastKnownLocation ?? lastLocation
    }

    /// Sender Step 4: background location updates ON (Info.plist UIBackgroundModes=location + Always auth).
    func startLiveSharingUpdates(onUpdate: @escaping (CLLocation, CLPlacemark?) -> Void) {
        isLiveSharingActive = true
        liveSharingHandler = onUpdate

        if locationManager == nil {
            setupLocationManager()
        }

        requestAlwaysAuthorizationIfNeeded()
        configureBackgroundLocationIfNeeded()
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startUpdatingLocation()
    }

    func stopLiveSharingUpdates() {
        isLiveSharingActive = false
        liveSharingHandler = nil
        locationManager?.stopUpdatingLocation()
    }

    /// Alert send ke liye location — cached GPS use karo, lekin address hamesha reverse-geocode se bharo.
    func getLocationForAlertSend(completionHandler: @escaping ReverseGeoLocationClosure) {
        resolveLocationForAlertSend { [weak self] location, error in
            guard let self else { return }

            guard let location else {
                completionHandler(nil, nil, error)
                return
            }

            self.reverseGeocodeForAlertSend(location: location, completionHandler: completionHandler)
        }
    }

    private func resolveLocationForAlertSend(
        completionHandler: @escaping (_ location: CLLocation?, _ error: NSError?) -> Void
    ) {
        if let cached = cachedLastKnownLocation ?? lastLocation,
           cached.horizontalAccuracy >= 0 {
            let locationAge = -cached.timestamp.timeIntervalSinceNow
            if isLiveSharingActive || locationAge <= 120 {
                completionHandler(cached, nil)
                return
            }
        }

        getCurrentReverseGeoCodedLocation { location, _, error in
            completionHandler(location, error)
        }
    }

    private func reverseGeocodeForAlertSend(
        location: CLLocation,
        completionHandler: @escaping ReverseGeoLocationClosure
    ) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                completionHandler(location, placemarks?.first, error as NSError?)
            }
        }
    }

    /// Get current location with placemark
    ///
    /// - Parameter completionHandler: will return Location,Placemark and error
    func getCurrentReverseGeoCodedLocation(completionHandler:@escaping ReverseGeoLocationClosure) {
        if let cached = cachedLastKnownLocation ?? lastLocation,
           cached.horizontalAccuracy >= 0 {
            let locationAge = -cached.timestamp.timeIntervalSinceNow
            if isLiveSharingActive || locationAge <= 30 {
                completionHandler(cached, nil, nil)
                return
            }
        }

        self.geoLocationCompletionHandler = completionHandler

        if reverseGeocoding {
            if let cached = cachedLastKnownLocation ?? lastLocation,
               cached.horizontalAccuracy >= 0 {
                geoLocationCompletionHandler = nil
                completionHandler(cached, nil, nil)
            }
            return
        }

        reverseGeocoding = true

        //Resetting last location
        lastLocation = nil

        if locationManager == nil {
            setupLocationManager()
        }
        requestAlwaysAuthorizationIfNeeded()

        if let cached = cachedLastKnownLocation ?? lastLocation,
           cached.horizontalAccuracy >= 0 {
            let locationAge = -cached.timestamp.timeIntervalSinceNow
            if locationAge <= 30 {
                reverseGeoCoding(location: cached)
                return
            }
        }

        if hasLocationAccess() {
            locationManager?.startUpdatingLocation()
        }
    }

    //MARK:- Reverse GeoCoding
    private func reverseGeoCoding(location:CLLocation?) {
        CLGeocoder().reverseGeocodeLocation(location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                if let _ = location {
                    self.didCompleteGeocoding(location: location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
                self.didCompleteGeocoding(location: location, placemark: nil, error: nil)
            }
        })
    }
    
    private func reverseGeoCoding(address:String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                if let placemark = placemarks?[0] {
                    self.didCompleteGeocoding(location: placemark.location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code: Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo: [NSLocalizedDescriptionKey: LocationErrors.reverseGeocodingFailed.rawValue]))
            }
        })
    }
       
    //MARK:- Final closure/callback
    private func didComplete(location: CLLocation?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        locationCompletionHandler?(location,error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    private func didCompleteGeocoding(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        reverseGeocoding = false
        isReverseGeocodeInProgress = false
        let handler = geoLocationCompletionHandler
        geoLocationCompletionHandler = nil

        if isLiveSharingActive {
            handler?(location, placemark, error)
            return
        }

        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
        handler?(location, placemark, error)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           lastLocation = locations.last
           if let location = locations.last {
               cachedLastKnownLocation = location
               let locationAge = -(location.timestamp.timeIntervalSinceNow)
               if (locationAge > 5.0) {
                 //  print("old location \(location)")
                   return
               }
               if location.horizontalAccuracy < 0 {
                   self.locationManager?.stopUpdatingLocation()
                   self.locationManager?.startUpdatingLocation()
                   return
               }

               if isLiveSharingActive {
                   liveSharingHandler?(location, nil)
               }

               if self.reverseGeocoding {
                   self.sendPlacemark()
               } else if !isLiveSharingActive {
                   self.sendLocation()
               }
           }
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           
           switch status {
               
           case .authorizedAlways:
               configureBackgroundLocationIfNeeded()
               if isPermissionOnlyRequest {
                   completePermissionOnlyRequest()
                   return
               }
               self.locationManager?.startUpdatingLocation()

           case .authorizedWhenInUse:
               if isPermissionOnlyRequest {
                   if !hasRequestedAlwaysUpgrade {
                       hasRequestedAlwaysUpgrade = true
                       self.locationManager?.requestAlwaysAuthorization()
                   }
                   return
               }
               self.locationManager?.startUpdatingLocation()
               
           case .denied:
               if isPermissionOnlyRequest {
                   isPermissionOnlyRequest = false
                   hasRequestedAlwaysUpgrade = false
                   destroyLocationManager()
                   return
               }
               let deniedError = NSError(
                   domain: self.classForCoder.description(),
                   code:Int(CLAuthorizationStatus.denied.rawValue),
                   userInfo:
                   [NSLocalizedDescriptionKey:LocationErrors.denied.rawValue,
                    NSLocalizedFailureReasonErrorKey:LocationErrors.denied.rawValue,
                    NSLocalizedRecoverySuggestionErrorKey:LocationErrors.denied.rawValue])
               
               if reverseGeocoding {
                   didCompleteGeocoding(location: nil, placemark: nil, error: deniedError)
               } else {
                   didComplete(location: nil,error: deniedError)
               }
               
           case .restricted:
               if isPermissionOnlyRequest {
                   isPermissionOnlyRequest = false
                   hasRequestedAlwaysUpgrade = false
                   destroyLocationManager()
                   return
               }
               if reverseGeocoding {
                   didComplete(location: nil,error: NSError(
                       domain: self.classForCoder.description(),
                       code:Int(CLAuthorizationStatus.restricted.rawValue),
                       userInfo: nil))
               } else {
                   didComplete(location: nil,error: NSError(
                       domain: self.classForCoder.description(),
                       code:Int(CLAuthorizationStatus.restricted.rawValue),
                       userInfo: nil))
               }
               
           case .notDetermined:
               self.locationManager?.requestAlwaysAuthorization()
               
           @unknown default:
                   didComplete(location: nil,error: NSError(
                   domain: self.classForCoder.description(),
                   code:Int(CLAuthorizationStatus.denied.rawValue),
                   userInfo:
                   [NSLocalizedDescriptionKey:LocationErrors.unknown.rawValue,
                    NSLocalizedFailureReasonErrorKey:LocationErrors.unknown.rawValue,
                    NSLocalizedRecoverySuggestionErrorKey:LocationErrors.unknown.rawValue]))
           }
       }
       
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(error.localizedDescription)
           self.didComplete(location: nil, error: error as NSError?)
       }
       
}
