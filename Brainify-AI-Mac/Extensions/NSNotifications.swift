//
//  NSNotifications.swift
//  SnapDownloader
//
//  Created by MackBook Pro on 10/15/25.
//


import Foundation

extension Notification.Name {
    static let didDismissFirstViewController = Notification.Name("didDismissFirstViewController")
    static let appProStatusDidChange = Notification.Name("com.homeworkAI.appProStatusChange")
    static let appFreCountDidChange = Notification.Name("com.homeworkAI.appFreCountDidChange")
    static let appMeCountCountDidChange = Notification.Name("com.homeworkAI.appMeCountDidChange")
    static let appUserNameDidChange = Notification.Name("com.homeworkAI.appUserNameDidChange")
    static let appTaskDidChange = Notification.Name("com.homeworkAI.appTaskDidChange")
    static let ThemeDidChange = Notification.Name("ThemeDidChange")
    static let updateWidgetMaps = Notification.Name("updateWidgetMaps")
    static let didChangeGrokModel = Notification.Name("didChangeGrokModel")
}

extension Notification {
    static let mapsUpdated = Notification(name: .updateWidgetMaps)
}
