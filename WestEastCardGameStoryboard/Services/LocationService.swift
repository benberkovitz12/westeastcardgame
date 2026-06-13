import CoreLocation
import Foundation

final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    // IMPORTANT:
    // The number you gave, 34.817549168324334, is longitude, not latitude.
    // East/West checks should be done with longitude.
    private let middleLongitude = 34.817549168324334

    private let manager = CLLocationManager()
    private var completion: ((Result<PlayerSide, LocationError>) -> Void)?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPlayerSide(completion: @escaping (Result<PlayerSide, LocationError>) -> Void) {
        self.completion = completion

        if !CLLocationManager.locationServicesEnabled() {
            completion(.failure(.servicesDisabled))
            return
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion(.failure(.permissionDenied))
        @unknown default:
            completion(.failure(.unknown))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion?(.failure(.permissionDenied))
        case .notDetermined:
            break
        @unknown default:
            completion?(.failure(.unknown))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        guard let location = locations.last else {
            completion?(.failure(.noLocationFound))
            return
        }

        let longitude = location.coordinate.longitude
        let side: PlayerSide = longitude >= middleLongitude ? .east : .west
        completion?(.success(side))
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        completion?(.failure(.failed(error.localizedDescription)))
        completion = nil
    }
}

enum LocationError: Error {
    case servicesDisabled
    case permissionDenied
    case noLocationFound
    case failed(String)
    case unknown

    var userMessage: String {
        switch self {
        case .servicesDisabled:
            return "Location services are disabled. Turn them on to play."
        case .permissionDenied:
            return "Location permission is required to decide East/West side."
        case .noLocationFound:
            return "Could not find your location. Try again."
        case .failed(let message):
            return "Location failed: \(message)"
        case .unknown:
            return "Unknown location problem. Try again."
        }
    }
}
