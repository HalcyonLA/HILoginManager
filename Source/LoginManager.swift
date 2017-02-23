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
    case instagram
    case linkedIn
    case tumblr
    case google
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
        
    case .instagram:
        return "Instagram"
        
    case .linkedIn:
        return "LinkedIn"
        
    case .tumblr:
        return "Tumblr"
        
    case .google:
        return "Google"
    }
}

@objc public protocol LoginProtocol: NSObjectProtocol {
    func request(_ completion: @escaping LoginCompletion)
    func authType() -> AuthType
    func authDataFromResponse(_ response: Any) -> [String : Any]
    func reset()
}

@objc public protocol HILoginManagerDelegate: NSObjectProtocol {
    @objc optional func userIdDidChanged()
    @objc optional func userWillLoggedOut()
    func userDidLoggedOut()
}

open class AuthCredentials: NSObject, NSSecureCoding {
    
    open var type: AuthType
    open var data: [String : Any]
    
    required public init(authType: AuthType, authData: [String : Any]) {
        self.type = authType
        self.data = authData
        super.init()
    }
    
    // MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        self.type = AuthType(rawValue: aDecoder.decodeInteger(forKey: "type"))!
        self.data = aDecoder.decodeObject(forKey: "data") as! [String : Any]
        super.init()
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(data, forKey: "data")
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
    
    fileprivate static let credentialsKey = "HILoginManager.Credentials"
    
    fileprivate class func extensionForType(_ authType: AuthType) -> LoginProtocol {
        let loginExtension = LoginManager.extensions.filter({ $0.authType() == authType })
        assert(loginExtension.count > 0, "You doesn't register a login extension for \(StringFromAuthType(authType))")
        return loginExtension.first!
    }
    
    open class func request(_ authType: AuthType, completion: @escaping LoginCompletion) {
        extensionForType(authType).request(completion)
    }
    
    open class func hasCredentials() -> Bool {
        return KeychainSwift().getData(credentialsKey) != nil
    }
    
    open class func credentials() -> AuthCredentials {
        let data = KeychainSwift().getData(credentialsKey)!
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! AuthCredentials
    }
    
    open class func saveCredentials(_ credentials: AuthCredentials) {
        let data = NSKeyedArchiver.archivedData(withRootObject: credentials)
        KeychainSwift().set(data, forKey: credentialsKey)
    }
    
    open class func logOut() {
        
        delegate?.userWillLoggedOut?()
        
        for item in extensions {
            item.reset()
        }
        
        KeychainSwift().delete(credentialsKey)
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        delegate?.userDidLoggedOut()
    }
}
