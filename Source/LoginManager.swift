//
//  LoginManager.swift
//  Spindle
//
//  Created by Vlad Getman on 20.05.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import KeychainSwift

public typealias LoginCompletion = (response: LoginResponse) -> Void

@objc public enum AuthType: Int {
    case Email
    case Facebook
    case Twitter
    case SoundCloud
}

public func StringFromAuthType(authType: AuthType) -> String {
    switch authType {
    case .Email:
        return "Email"
        
    case .Facebook:
        return "Facebook"
        
    case .Twitter:
        return "Twitter"
        
    case .SoundCloud:
        return "SoundCloud"
    }
}

@objc public protocol LoginProtocol: NSObjectProtocol {
    func request(completion: LoginCompletion)
    func authType() -> AuthType
    func hasAuthData() -> Bool
    func authData() -> [String : AnyObject]
    func authDataFromResponse(response: AnyObject) -> [String : AnyObject]
    func save(response: AnyObject)
    func reset()
}

@objc public protocol HILoginManagerDelegate: NSObjectProtocol {
    optional func userIdDidChanged()
    func userDidLoggedOut()
}

public class AuthCredentials: NSObject {
    
    public var type: AuthType
    public var data: [String : AnyObject]
    
    required public init(authType: AuthType, authData: [String : AnyObject]) {
        self.type = authType
        self.data = authData
        super.init()
    }
}

public class LoginResponse: NSObject {
    public var response: AnyObject? = nil
    public var error: NSError? = nil
    public var credentials: AuthCredentials? = nil
}

public class LoginManager: NSObject {
    
    public static var delegate: HILoginManagerDelegate? = nil
    
    public static var extensions = [LoginProtocol]()
    
    public static var userId: NSNumber? {
        set {
            Defaults["userId"] = newValue
            self.delegate?.userIdDidChanged?()
        }
        get {
            return Defaults.numberForKey("userId")
        }
    }
    
    private class func extensionForType(authType: AuthType) -> LoginProtocol {
        let loginExtension = LoginManager.extensions.filter({ $0.authType() == authType })
        assert(loginExtension.count > 0, "You doesn't register a login extension for \(StringFromAuthType(authType))")
        return loginExtension.first!
    }
    
    public class func request(authType: AuthType, completion: LoginCompletion) {
        extensionForType(authType).request(completion)
    }
    
    public class func hasAuthData() -> Bool {
        let loginExtension = LoginManager.extensions.filter({ $0.hasAuthData() == true })
        return loginExtension.count > 0
    }
    
    public class func authData() -> AuthCredentials {
        let loginExtension = LoginManager.extensions.filter({ $0.hasAuthData() == true }).first
        return AuthCredentials.init(authType: loginExtension!.authType(), authData: loginExtension!.authData())
    }
    
    public class func saveAuthData(response: AnyObject, authType: AuthType) {
        extensionForType(authType).save(response)
    }
    
    public class func logOut() {
        for (_, loginExtension) in LoginManager.extensions.enumerate() {
            loginExtension.reset()
        }
        KeychainSwift().clear()
        
        self.delegate?.userDidLoggedOut()
    }
}