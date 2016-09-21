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

public typealias LoginCompletion = (_ response: LoginResponse) -> Void

@objc public enum AuthType: Int {
    case email
    case phone
    case facebook
    case twitter
    case soundCloud
}

public func StringFromAuthType(_ authType: AuthType) -> String {
    switch authType {
    case .email:
        return "Email"
        
    case .phone:
        return "Phone"
        
    case .facebook:
        return "Facebook"
        
    case .twitter:
        return "Twitter"
        
    case .soundCloud:
        return "SoundCloud"
    }
}

@objc public protocol LoginProtocol: NSObjectProtocol {
    func request(_ completion: @escaping LoginCompletion)
    func authType() -> AuthType
    func hasAuthData() -> Bool
    func authData() -> [String : Any]
    func authDataFromResponse(_ response: Any) -> [String : Any]
    func save(_ response: Any)
    func reset()
}

@objc public protocol HILoginManagerDelegate: NSObjectProtocol {
    @objc optional func userIdDidChanged()
    func userDidLoggedOut()
}

open class AuthCredentials: NSObject {
    
    open var type: AuthType
    open var data: [String : Any]
    
    required public init(authType: AuthType, authData: [String : Any]) {
        self.type = authType
        self.data = authData
        super.init()
    }
}

open class LoginResponse: NSObject {
    open var response: Any? = nil
    open var error: NSError? = nil
    open var credentials: AuthCredentials? = nil
}

open class LoginManager: NSObject {
    
    open static var delegate: HILoginManagerDelegate? = nil
    
    open static var extensions = [LoginProtocol]()
    
    open static var userId: NSNumber? {
        set {
            Defaults["userId"] = newValue
            self.delegate?.userIdDidChanged?()
        }
        get {
            return Defaults.numberForKey("userId")
        }
    }
    
    fileprivate class func extensionForType(_ authType: AuthType) -> LoginProtocol {
        let loginExtension = LoginManager.extensions.filter({ $0.authType() == authType })
        assert(loginExtension.count > 0, "You doesn't register a login extension for \(StringFromAuthType(authType))")
        return loginExtension.first!
    }
    
    open class func request(_ authType: AuthType, completion: @escaping LoginCompletion) {
        extensionForType(authType).request(completion)
    }
    
    open class func hasAuthData() -> Bool {
        let loginExtension = LoginManager.extensions.filter({ $0.hasAuthData() == true })
        return loginExtension.count > 0
    }
    
    open class func authData() -> AuthCredentials {
        let loginExtension = LoginManager.extensions.filter({ $0.hasAuthData() == true }).first
        return AuthCredentials(authType: loginExtension!.authType(), authData: loginExtension!.authData())
    }
    
    open class func saveAuthData(_ response: Any, authType: AuthType) {
        extensionForType(authType).save(response)
    }
    
    open class func logOut() {
        for (_, loginExtension) in LoginManager.extensions.enumerated() {
            loginExtension.reset()
        }
        KeychainSwift().clear()
        
        self.delegate?.userDidLoggedOut()
    }
}
