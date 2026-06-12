//
//  LocationService.swift
//  CardWar
//

import Foundation
import CoreLocation

/// Wraps CoreLocation and turns a single location fix into a `PlayerSide` by
/// comparing the device longitude to a fixed midpoint. After the first usable
/// fix it stops updating — the assignment asks us to stop location requests
/// once a position is received.
final class LocationService: NSObject {

    /// East of this longitude → East side, otherwise West side.
    static let middleLongitude = 34.817549168324334

    /// Called (on the main thread) once a side has been resolved.
    var onSideResolved: ((PlayerSide) -> Void)?

    /// Called if location permission is denied/restricted (the game can't run
    /// without a location, so the menu shows guidance in that case).
    var onDenied: (() -> Void)?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// Starts the permission + location flow. Safe to call on every appearance.
    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            onDenied?()
        }
    }

    private func resolve(longitude: Double) {
        let side: PlayerSide = longitude > Self.middleLongitude ? .east : .west
        onSideResolved?(side)
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            onDenied?()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()   // one fix is enough — stop requesting
        resolve(longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient failures are ignored; a hard denial arrives via the
        // authorization-change callback above.
    }
}
