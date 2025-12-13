//
//  OfferTimerManager.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 10/12/2025.
//


// OfferTimerManager.swift
import Foundation

class OfferTimerManager {
    static let shared = OfferTimerManager()
    
    private var timer: Timer?
    private var endTime: Date!
    
    // Notification jab time update ho
    static let didUpdateTimeNotification = Notification.Name("OfferTimerDidUpdate")
    static let didExpireNotification = Notification.Name("OfferTimerDidExpire")
    
    // Baaki time seconds mein
    var remainingSeconds: Int {
        max(0, Int(endTime.timeIntervalSinceNow))
    }
    
    var isExpired: Bool {
        remainingSeconds <= 0
    }
    
    private init() {
        // App launch pe 10 minute ka offer start karo
        // Agar pehle se chal raha hai (background se aaya) to resume karo
        if UserDefaults.standard.object(forKey: "OfferEndTime") == nil {
            resetTimer()
        } else {
            loadSavedEndTime()
        }
        startTimer()
    }
    
    func resetTimer() {
        let now = Date()
        endTime = now.addingTimeInterval(10 * 60) // 10 minutes
        UserDefaults.standard.set(endTime, forKey: "OfferEndTime")
        UserDefaults.standard.synchronize()
    }
    
    private func loadSavedEndTime() {
        if let saved = UserDefaults.standard.object(forKey: "OfferEndTime") as? Date {
            endTime = saved
            // Agar already expire ho gaya to reset kar do (optional)
            if endTime < Date() {
                resetTimer()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let remaining = self.remainingSeconds
            
            if remaining <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                NotificationCenter.default.post(name: OfferTimerManager.didExpireNotification, object: nil)
            } else {
                NotificationCenter.default.post(
                    name: OfferTimerManager.didUpdateTimeNotification,
                    object: nil,
                    userInfo: ["remainingSeconds": remaining]
                )
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}