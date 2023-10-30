//  AppDelegate.swift
//  AWARE-DynamicESM
//
//  Created by Yuuki Nishiyama on 2019/03/28.
//  Copyright © 2019 tetujin. All rights reserved.
//
//  This is a sample application (DynamicESM) using ESM with sensor data.
//  In this example, this application sends a notification based on device usage.
//  If a user uses the phone more than 10 min in a session, this application sends
//  a push notification and survey on the phone. The survey is valid only 30 minutes.

import UIKit
import CoreData
import AWAREFramework
import SafariServices
import CoreLocation
import Speech
import UserNotifications


struct SurveyLocation {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let radius: Double // in meters
}

let surveyLocations = [
    SurveyLocation(name: "Capitol View/Stifft's Station", coordinate: CLLocationCoordinate2D(latitude: 34.711358, longitude: -92.284333), radius: 100.0),
    SurveyLocation(name: "Chenal Valley", coordinate: CLLocationCoordinate2D(latitude: 34.749435, longitude: -92.338972), radius: 100.0),
    SurveyLocation(name: "East Little Rock", coordinate: CLLocationCoordinate2D(latitude: 34.737459, longitude: -92.198972), radius: 100.0),
    SurveyLocation(name: "Governor's Mansion District", coordinate: CLLocationCoordinate2D(latitude: 34.741833, longitude: -92.287056), radius: 100.0),
    SurveyLocation(name: "The Heights and Hillcrest", coordinate: CLLocationCoordinate2D(latitude: 34.736667, longitude: -92.27875), radius: 100.0),
    SurveyLocation(name: "Mabelvale", coordinate: CLLocationCoordinate2D(latitude: 34.674167, longitude: -92.233333), radius: 100.0),
    SurveyLocation(name: "MacArthur Park District", coordinate: CLLocationCoordinate2D(latitude: 34.741833, longitude: -92.270556), radius: 100.0),
    SurveyLocation(name: "Quapaw Quarter", coordinate: CLLocationCoordinate2D(latitude: 34.737459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "South Main Residential Historic District (SoMa)", coordinate: CLLocationCoordinate2D(latitude: 34.731833, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Alpine", coordinate: CLLocationCoordinate2D(latitude: 34.537459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Andover Square", coordinate: CLLocationCoordinate2D(latitude: 34.787459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Apple Gate", coordinate: CLLocationCoordinate2D(latitude: 34.711358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Big Rock", coordinate: CLLocationCoordinate2D(latitude: 34.637459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Birchwood", coordinate: CLLocationCoordinate2D(latitude: 34.761358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Breckenridge", coordinate: CLLocationCoordinate2D(latitude: 34.837459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Broadmoor", coordinate: CLLocationCoordinate2D(latitude: 34.791358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Brodie Creek", coordinate: CLLocationCoordinate2D(latitude: 34.741358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Briarwood", coordinate: CLLocationCoordinate2D(latitude: 34.701358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Cammack Village", coordinate: CLLocationCoordinate2D(latitude: 34.661358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Candlewood", coordinate: CLLocationCoordinate2D(latitude: 34.621358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Capitol Hill", coordinate: CLLocationCoordinate2D(latitude: 34.587459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Carmel", coordinate: CLLocationCoordinate2D(latitude: 34.957459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Central High School Neighborhood Historic District", coordinate: CLLocationCoordinate2D(latitude: 34.741833, longitude: -92.270556), radius: 100.0),
    SurveyLocation(name: "Cherry Creek", coordinate: CLLocationCoordinate2D(latitude: 34.861358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Chenal Ridge", coordinate: CLLocationCoordinate2D(latitude: 34.749435, longitude: -92.338972), radius: 100.0),
    SurveyLocation(name: "Cloverdale", coordinate: CLLocationCoordinate2D(latitude: 34.611358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "College Station", coordinate: CLLocationCoordinate2D(latitude: 34.571358, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Colony West", coordinate: CLLocationCoordinate2D(latitude: 34.787459, longitude: -92.260556), radius: 100.0),
    SurveyLocation(name: "Southwest City", coordinate: CLLocationCoordinate2D(latitude: 38.472862, longitude: -90.318372), radius: 100.0),
    SurveyLocation(name: "The Hamptons", coordinate: CLLocationCoordinate2D(latitude: 38.611335, longitude: -90.256369), radius: 100.0),
    SurveyLocation(name: "The Hill-Dogtown", coordinate: CLLocationCoordinate2D(latitude: 38.606173, longitude: -90.243923), radius: 100.0),
    SurveyLocation(name: "Garden District", coordinate: CLLocationCoordinate2D(latitude: 38.611673, longitude: -90.217584), radius: 100.0),
    SurveyLocation(name: "Tower Grove", coordinate: CLLocationCoordinate2D(latitude: 38.623926, longitude: -90.242932), radius: 100.0),
    SurveyLocation(name: "Bevo / Morgan Ford", coordinate: CLLocationCoordinate2D(latitude: 38.590948, longitude: -90.203861), radius: 100.0),
    SurveyLocation(name: "Greater Dutchtown", coordinate: CLLocationCoordinate2D(latitude: 38.592052, longitude: -90.229491), radius: 100.0),
    SurveyLocation(name: "Cherokee Area", coordinate: CLLocationCoordinate2D(latitude: 38.603759, longitude: -90.217867), radius: 100.0),
    SurveyLocation(name: "Carondelet", coordinate: CLLocationCoordinate2D(latitude: 38.521467, longitude: -90.198677), radius: 100.0),
    SurveyLocation(name: "Soulard / Benton Park", coordinate: CLLocationCoordinate2D(latitude: 38.588157, longitude: -90.202904), radius: 100.0),
    SurveyLocation(name: "McKinley-Fox", coordinate: CLLocationCoordinate2D(latitude: 38.611827, longitude: -90.263316), radius: 100.0),
    SurveyLocation(name: "Midtown", coordinate: CLLocationCoordinate2D(latitude: 38.607459, longitude: -90.218887), radius: 100.0),
    SurveyLocation(name: "Lafayette Square / Near South Side", coordinate: CLLocationCoordinate2D(latitude: 38.613586, longitude: -90.225195), radius: 100.0),
    SurveyLocation(name: "Downtown", coordinate: CLLocationCoordinate2D(latitude: 38.627273, longitude: -90.201901), radius: 100.0),
    SurveyLocation(name: "Upper West End", coordinate: CLLocationCoordinate2D(latitude: 38.644326, longitude: -90.210615), radius: 100.0),
    SurveyLocation(name: "West End / Forest Park", coordinate: CLLocationCoordinate2D(latitude: 38.636519, longitude: -90.251599), radius: 100.0),
    SurveyLocation(name: "Central West End / Grove", coordinate: CLLocationCoordinate2D(latitude: 38.631651, longitude: -90.217256), radius: 100.0),
    SurveyLocation(name: "Greater Ville", coordinate: CLLocationCoordinate2D(latitude: 38.628684, longitude: -90.231062), radius: 100.0),
    SurveyLocation(name: "Near North Side", coordinate: CLLocationCoordinate2D(latitude: 38.640019, longitude: -90.225195), radius: 100.0),
    SurveyLocation(name: "Fairgrounds / O'Fallon", coordinate: CLLocationCoordinate2D(latitude: 38.641044, longitude: -90.208477), radius: 100.0),
    SurveyLocation(name: "Old North / Hyde Park", coordinate: CLLocationCoordinate2D(latitude: 38.663722, longitude: -90.216283), radius: 100.0),
    SurveyLocation(name: "North Kingshighway / Penrose", coordinate: CLLocationCoordinate2D(latitude: 38.670546, longitude: -90.204293), radius: 100.0),
    SurveyLocation(name: "Wells-Goodfellow", coordinate: CLLocationCoordinate2D(latitude: 38.677104, longitude: -90.224541), radius: 100.0),
    SurveyLocation(name: "Walnut Park / Cemeteries", coordinate: CLLocationCoordinate2D(latitude: 38.664553, longitude: -90.251599), radius: 100.0),
    SurveyLocation(name: "Baden / North Riverfront", coordinate: CLLocationCoordinate2D(latitude: 38.660274, longitude: -90.201901), radius: 100.0)
]

var locationSurveyTimestamps: [Date] = []
var noiseSurveyTimestamps: [Date] = []
var scheduledSurveyTimestamps: [Date] = []

var locationSurveyCounter = 0
var noiseSurveyCounter = 0
var scheduledSurveyCounter = 0
var lastSurveyTimestamps: [Date] = []


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    // Define surveyTimestamps as a property of AppDelegate
    var surveyTimestamps: [Date] = []
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Load the survey counts
           loadSurveyCounts()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        
        // Override point for customization after application launch.
        let core    = AWARECore.shared()
        let manager = AWARESensorManager.shared()
        let study   = AWAREStudy.shared()
        core.requestPermissionForBackgroundSensing { (status) in
            core.requestPermissionForPushNotification(completion: nil)
            core.activate()
            /// If user uses smartphone over 60 second,
            /// this application makes a notification as an ESM
            let deviceUsage = DeviceUsage()
            let activity = IOSActivityRecognition(awareStudy: study)
            let location = Locations(awareStudy: study)
            let fuslocation = FusedLocations(awareStudy: study)
            let conversations = Conversation(awareStudy: study)
            let noiseSensor = AmbientNoise(awareStudy: study)
            
            
            deviceUsage.startSensor()
            activity.startSensor()
            location.startSensor()
            fuslocation.startSensor()
            conversations.startSensor()
            noiseSensor.startSensor()
            
            
            // Add sensors to the sensor manager
            manager.add(activity)
            manager.add(fuslocation)
            manager.add(conversations)
            manager.add(noiseSensor)
            manager.add(deviceUsage)
            manager.add(location)
            
            manager.addSensors(with: study)
            // Schedule the surveys when the app starts
            scheduleSurveys()
            
            func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
                if region is CLCircularRegion {
                    triggerLocalNotification(forRegion: region)
                }
            }

            func triggerLocalNotification(forRegion region: CLRegion) {
                let content = UNMutableNotificationContent()
                content.title = "Geofence Triggered"
                content.body = "You have entered the geofenced area: \(region.identifier)"
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else {
                    print("Notification permission denied.")
                }
            }
            
            // Set a sensor handler for location
            location.setSensorEventHandler { [weak self] (sensor, data) in
                guard self != nil else { return }
                if let data = data,
                   let latitude = data["latitude"] as? Double,
                   let longitude = data["longitude"] as? Double {
                    let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
                    
                    for surveyLocation in surveyLocations {
                        let surveyLocationCL = CLLocation(latitude: surveyLocation.coordinate.latitude, longitude: surveyLocation.coordinate.longitude)
                        let distance = currentLocation.distance(from: surveyLocationCL)
                        
                        if distance <= surveyLocation.radius {
                            cleanUpOldTimestamps()
                            if locationSurveyCounter < 3 {
                                openSurvey()
                                locationSurveyTimestamps.append(Date())
                                locationSurveyCounter += 1
                            }
                            break
                        }
                    }
                } else {
                    print("Data not available or invalid format")
                }
            }
            // Set a sensor handler for noise
            noiseSensor.setSensorEventHandler { [weak self] sensor, data in
                guard let self = self else { return }
                if let d = data, let isSilent = d["is_silent"] as? Int, isSilent == 0 {
                    cleanUpOldTimestamps()
                    if noiseSurveyCounter < 3 {
                        openSurvey()
                        noiseSurveyTimestamps.append(Date())
                        noiseSurveyCounter += 1
                    }
                }
            }
            
            //return true
        }
        func cleanUpOldTimestamps() {
            let now = Date()
            locationSurveyTimestamps = locationSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            noiseSurveyTimestamps = noiseSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            
            if locationSurveyTimestamps.count < 3 {
                locationSurveyCounter = locationSurveyTimestamps.count
            }
            
            if noiseSurveyTimestamps.count < 3 {
                noiseSurveyCounter = noiseSurveyTimestamps.count
            }
        }
        
        
        func attemptToOpenSurvey() {
            let now = Date()
            
            // Filter out timestamps older than 24 hours
            surveyTimestamps = surveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            
            // Check if less than 3 surveys have been opened in the last 24 hours
            if surveyTimestamps.count < 3 {
                openSurvey()
                surveyTimestamps.append(now)
            } else {
                print("Survey limit reached for today.")
            }
        }
        
        
        func scheduleSurveys() {
            let now = Date()
            let calendar = Calendar.current
            
            // Filter out timestamps older than 24 hours
            scheduledSurveyTimestamps = scheduledSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            
            // Calculate the total number of surveys already scheduled or completed today
            let totalSurveysToday = locationSurveyTimestamps.count + noiseSurveyTimestamps.count + scheduledSurveyTimestamps.count
            
            // Ensure we don't schedule more than 3 scheduled surveys and the total does not exceed 9 surveys in a 24-hour period
            let maxScheduledSurveysToday = min(3, 9 - totalSurveysToday)
            guard scheduledSurveyCounter < maxScheduledSurveysToday else {
                print("Already scheduled the maximum number of surveys for today.")
                return
            }
            
            for _ in 1...(maxScheduledSurveysToday - scheduledSurveyCounter) {
                var components = calendar.dateComponents([.year, .month, .day], from: now)
                components.hour = Int.random(in: 9...20)
                components.minute = Int.random(in: 0...59)
                components.second = Int.random(in: 0...59)
                
                if let surveyTime = calendar.date(from: components), surveyTime > now {
                    Timer.scheduledTimer(withTimeInterval: surveyTime.timeIntervalSinceNow, repeats: false) { _ in
                        // Ensure the total number of surveys today does not exceed 9 before opening a new survey
                        if locationSurveyTimestamps.count + noiseSurveyTimestamps.count + scheduledSurveyTimestamps.count < 9 {
                            openSurvey()
                            scheduledSurveyTimestamps.append(Date())
                            scheduledSurveyCounter += 1
                        } else {
                            print("Reached the total daily limit of 9 surveys.")
                        }
                    }
                    print("Survey scheduled for \(surveyTime)")
                }
            }
        }
        
        
        
        
        
        func resetDailyCounters() {
            let now = Date()
            locationSurveyTimestamps = locationSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            noiseSurveyTimestamps = noiseSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            scheduledSurveyTimestamps = scheduledSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            
            locationSurveyCounter = locationSurveyTimestamps.count
            noiseSurveyCounter = noiseSurveyTimestamps.count
            scheduledSurveyCounter = scheduledSurveyTimestamps.count
        }
        func openSurvey() {
            guard let urlString = URL(string: "https://wustl.az1.qualtrics.com/jfe/form/SV_0HyB20WVoAztGTk") else {
                print("Invalid URL")
                return
            }
            
            let svc = SFSafariViewController(url: urlString)
            
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(svc, animated: true, completion: nil)
            } else {
                print("Failed to find the current view controller")
            }
            saveSurveyCounts()
        }
        
        func saveSurveyCounts() {
            UserDefaults.standard.set(locationSurveyCounter, forKey: "locationSurveyCounter")
            UserDefaults.standard.set(noiseSurveyCounter, forKey: "noiseSurveyCounter")
            UserDefaults.standard.set(scheduledSurveyCounter, forKey: "scheduledSurveyCounter")
        }
        
        
        func shouldOpenSurvey() -> Bool {
            let now = Date()
            lastSurveyTimestamps = lastSurveyTimestamps.filter { now.timeIntervalSince($0) < 24 * 60 * 60 }
            
            if lastSurveyTimestamps.count < 3 {
                lastSurveyTimestamps.append(now)
                return true
            } else {
                print("Already opened 3 surveys in the last 24 hours")
                return false
            }
        }
        
        func loadSurveyCounts() {
            locationSurveyCounter = UserDefaults.standard.integer(forKey: "locationSurveyCounter")
            noiseSurveyCounter = UserDefaults.standard.integer(forKey: "noiseSurveyCounter")
            scheduledSurveyCounter = UserDefaults.standard.integer(forKey: "scheduledSurveyCounter")
        }

        
        func applicationWillResignActive(_ application: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        }
        
        func applicationWillEnterForeground(_ application: UIApplication) {
            // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            // Saves changes in the application's managed object context before the application terminates.
            saveContext()
        }
        
        // MARK: - Core Data stack
        
        lazy var persistentContainer: NSPersistentContainer = {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let container = NSPersistentContainer(name: "AWARE_DynamicESM")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        // MARK: - Core Data Saving support
        
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
       return true
    }
}
