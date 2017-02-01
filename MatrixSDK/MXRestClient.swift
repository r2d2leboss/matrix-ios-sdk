/*
 Copyright 2017 Avery Pierce
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/**
 Captures the result of an API call and it's associated success data.
 
 # Examples:
 
 Use a switch statement to handle both a success and an error:
 
     mxRestClient.publicRooms { response in
        switch response {
        case .success(let rooms):
            // Do something useful with these rooms
            break
     
        case .failure(let error):
            // Handle the error in some way
            break
        }
     }
 
 Silently ignore the failure case:
 
     mxRestClient.publicRooms { response in
         guard let rooms = response.value else { return }
         // Do something useful with these rooms
     }

 */
public enum MXResponse<T> {
    case success(T)
    case failure(Error)
    
    /// Indicates whether the API call was successful
    var isSuccess: Bool {
        switch self {
        case .success:   return true
        default:        return false
        }
    }
    
    /// The response's success value, if applicable
    var value: T? {
        switch self {
        case .success(let value): return value
        default: return nil
        }
    }
    
    /// Indicates whether the API call failed
    var isFailure: Bool {
        return !isSuccess
    }
    
    /// The response's error value, if applicable
    var error: Error? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
}

fileprivate extension MXResponse {
    
    /**
     Take the value from an optional, if it's available.
     Otherwise, return a failure with _MXUnknownError
     
     - parameter value: to be captured in a `.success` case, if it's not `nil` and the type is correct.
     
     - returns: `.success(value)` if the value is not `nil`, otherwise `.failure(_MXUnkownError())`
     */
    static func fromOptional(value: Any?) -> MXResponse<T> {
        if let value = value as? T {
            return .success(value)
        } else {
            return .failure(_MXUnknownError())
        }
    }
    
    /**
     Take the error from an optional, if it's available.
     Otherwise, return a failure with _MXUnknownError
     
     - parameter error: to be captured in a `.failure` case, if it's not `nil`.
     
     - returns: `.failure(error)` if the value is not `nil`, otherwise `.failure(_MXUnkownError())`
     */
    static func fromOptional(error: Error?) -> MXResponse<T> {
        return .failure(error ?? _MXUnknownError())
    }
}



/**
 Represents an error that was unexpectedly nil.
 
 This struct only exists to fill in the gaps formed by optionals that
 were created by ObjC headers that don't specify nullibility. Under
 normal controlled circumstances, this should probably never be used.
 */
struct _MXUnknownError : Error {
    var localizedDescription: String {
        return "error object was unexpectedly nil"
    }
}


/// Represents a login flow
public enum MXLoginFlowType : String {
    case password = "m.login.password"
    case recaptcha = "m.login.recaptcha"
    case OAuth2 = "m.login.oauth2"
    case emailIdentity = "m.login.email.identity"
    case token = "m.login.token"
    case dummy = "m.login.dummy"
    case emailCode = "m.login.email.code"
}

/// Represents account data type
public enum MXAccountDataType {
    case direct
    case pushRules
    case ignoredUserList
    case custom(String)
    
    var rawValue: String {
        switch self {
        case .direct:               return kMXAccountDataTypeDirect
        case .pushRules:            return kMXAccountDataTypePushRules
        case .ignoredUserList:      return kMXAccountDataKeyIgnoredUser
        case .custom(let value):    return value
        }
    }
}

/// Represents a mode for forwarding push notifications.
public enum MXPusherKind {
    case http, none, custom(String)

    var objectValue: NSObject {
        switch self {
        case .http: return "http" as NSString
        case .none: return NSNull()
        case .custom(let value): return value as NSString
        }
    }
}


/**
 Push rules kind.
 
 Push rules are separated into different kinds of rules. These categories have a priority order: verride rules
 have the highest priority.
 Some category may define implicit conditions.
 */
public enum MXPushRuleKind {
    case override, content, room, sender, underride

    var objc: __MXPushRuleKind {
        switch self  {
        case .override: return __MXPushRuleKindOverride
        case .content: return __MXPushRuleKindContent
        case .room: return __MXPushRuleKindRoom
        case .sender: return __MXPushRuleKindSender
        case .underride: return __MXPushRuleKindUnderride
        }
    }
}


/**
 Scope for a specific push rule.
 
 Push rules can be applied globally, or to a spefific device given a `profileTag`
 */
public enum MXPushRuleScope {
    case global, device(profileTag: String)

    var identifier: String {
        switch self {
        case .global: return "global"
        case .device(let profileTag): return "device/\(profileTag)"
        }
    }
}





/**
 Types of Matrix events
 
 Matrix events types are exchanged as strings with the home server. The types
 specified by the Matrix standard are listed here as NSUInteger enum in order
 to ease the type handling.
 
 Custom events types, out of the specification, may exist. In this case,
 `MXEventTypeString` must be checked.
 */
public enum MXEventType {
    case roomName
    case roomTopic
    case roomAvatar
    case roomMember
    case roomCreate
    case roomJoinRules
    case roomPowerLevels
    case roomAliases
    case roomCanonicalAlias
    case roomEncrypted
    case roomEncryption
    case roomGuestAccess
    case roomHistoryVisibility
    case roomKey
    case roomMessage
    case roomMessageFeedback
    case roomRedaction
    case roomThirdPartyInvite
    case roomTag
    case presence
    case typing
    case newDevice
    case callInvite
    case callCandidates
    case callAnswer
    case callHangup
    case receipt
    
    case custom(String)
    
    var identifier: String {
        switch self {
        case .roomName: return kMXEventTypeStringRoomName
        case .roomTopic: return kMXEventTypeStringRoomTopic
        case .roomAvatar: return kMXEventTypeStringRoomAvatar
        case .roomMember: return kMXEventTypeStringRoomMember
        case .roomCreate: return kMXEventTypeStringRoomCreate
        case .roomJoinRules: return kMXEventTypeStringRoomJoinRules
        case .roomPowerLevels: return kMXEventTypeStringRoomPowerLevels
        case .roomAliases: return kMXEventTypeStringRoomAliases
        case .roomCanonicalAlias: return kMXEventTypeStringRoomCanonicalAlias
        case .roomEncrypted: return kMXEventTypeStringRoomEncrypted
        case .roomEncryption: return kMXEventTypeStringRoomEncryption
        case .roomGuestAccess: return kMXEventTypeStringRoomGuestAccess
        case .roomHistoryVisibility: return kMXEventTypeStringRoomHistoryVisibility
        case .roomKey: return kMXEventTypeStringRoomKey
        case .roomMessage: return kMXEventTypeStringRoomMessage
        case .roomMessageFeedback: return kMXEventTypeStringRoomMessageFeedback
        case .roomRedaction: return kMXEventTypeStringRoomRedaction
        case .roomThirdPartyInvite: return kMXEventTypeStringRoomThirdPartyInvite
        case .roomTag: return kMXEventTypeStringRoomTag
        case .presence: return kMXEventTypeStringPresence
        case .newDevice: return kMXEventTypeStringNewDevice
        case .callInvite: return kMXEventTypeStringCallInvite
        case .callCandidates: return kMXEventTypeStringCallCandidates
        case .callAnswer: return kMXEventTypeStringCallAnswer
        case .callHangup: return kMXEventTypeStringCallHangup
        case .receipt: return kMXEventTypeStringReceipt
            
        // Swift converts any constant with the suffix "Notification" as the type `Notification.Name`
        // The original value can be reached using the `rawValue` property.
        case .typing: return NSNotification.Name.mxEventTypeStringTyping.rawValue
            
        case .custom(let string): return string
        }
    }
}

/// Types of messages
public enum MXMessageType {
    case text, emote, notice, image, audio, video, location, file
    
    var identifier: String {
        switch self {
        case .text: return kMXMessageTypeText
        case .emote: return kMXMessageTypeEmote
        case .notice: return kMXMessageTypeNotice
        case .image: return kMXMessageTypeImage
        case .audio: return kMXMessageTypeAudio
        case .video: return kMXMessageTypeVideo
        case .location: return kMXMessageTypeLocation
        case .file: return kMXMessageTypeFile
        }
    }
}



public enum MXRoomHistoryVisibility {
    case worldReadable, shared, invited, joined
    
    var identifier: String {
        switch self {
        case .worldReadable: return kMXRoomHistoryVisibilityWorldReadable
        case .shared: return kMXRoomHistoryVisibilityShared
        case .invited: return kMXRoomHistoryVisibilityInvited
        case .joined: return kMXRoomHistoryVisibilityJoined
        }
    }
    
    init?(identifier: String) {
        let historyVisibilities: [MXRoomHistoryVisibility] = [.worldReadable, .shared, .invited, .joined]
        guard let value = historyVisibilities.first(where: {$0.identifier == identifier}) else { return nil }
        self = value
    }
}

/**
 Room join rule.
 
 The default homeserver value is invite.
 */
public enum MXRoomJoinRule {
    
    /// Anyone can join the room without any prior action
    case `public`
    
    /// A user who wishes to join the room must first receive an invite to the room from someone already inside of the room.
    case invite
    
    /// Reserved keyword which is not implemented by homeservers.
    case `private`, knock
    
    var identifier: String {
        switch self {
        case .public: return kMXRoomJoinRulePublic
        case .invite: return kMXRoomJoinRuleInvite
        case .private: return kMXRoomJoinRulePrivate
        case .knock: return kMXRoomJoinRuleKnock
        }
    }
    
    init?(identifier: String) {
        let joinRules: [MXRoomJoinRule] = [.public, .invite, .private, .knock]
        guard let value = joinRules.first(where: { $0.identifier == identifier}) else { return nil }
        self = value
    }
}


/// Return a closure that accepts any object, converts it to a MXResponse value, and then executes the provded completion block
fileprivate func success<T>(_ completion: @escaping (MXResponse<T>) -> Void) -> (Any?) -> Void {
    return { completion(.fromOptional(value: $0)) }
}

/// Return a closure that accepts any error, converts it to a MXResponse value, and then executes the provded completion block
fileprivate func error<T>(_ completion: @escaping (MXResponse<T>) -> Void) -> (Error?) -> Void {
    return { completion(.fromOptional(error: $0)) }
}


public extension MXRestClient {
    
    
    // MARK: - Initialization
    
    /**
     Create an instance based on homeserver url.
     
     - parameters:
         - homeServer: The homeserver address.
         - handler: the block called to handle unrecognized certificate (`nil` if unrecognized certificates are ignored).
     
     - returns: a `MXRestClient` instance.
     */
    @nonobjc convenience init(homeServer: URL, unrecognizedCertificateHandler handler: MXHTTPClientOnUnrecognizedCertificate?) {
        self.init(__homeServer: homeServer.absoluteString, andOnUnrecognizedCertificateBlock: handler)
    }
    
    /**
     Create an instance based on existing user credentials.
     
     - parameters:
         - credentials: A set of existing user credentials.
         - handler: the block called to handle unrecognized certificate (`nil` if unrecognized certificates are ignored).
     
     - returns: a `MXRestClient` instance.
     */
    @nonobjc convenience init(credentials: MXCredentials, unrecognizedCertificateHandler handler: MXHTTPClientOnUnrecognizedCertificate?) {
        self.init(__credentials: credentials, andOnUnrecognizedCertificateBlock: handler)
    }

    
    
    
    // MARK: - Registration Operations
    
    /**
     Check whether a username is already in use.
     
     - parameters:
         - username: The user name to test.
         - completion: A block object called when the operation is completed.
         - inUse: Whether the username is in use
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func isUserNameInUse(_ username: String, completion: @escaping (_ inUse: Bool) -> Void) -> MXHTTPOperation? {
        return __isUserName(inUse: username, callback: completion)
    }
    
    /**
     Get the list of register flows supported by the home server.
     
     - parameters:
         - completion: A block object called when the operation is completed.
         - response: Provides the server response as an `MXAuthenticationSession` instance.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func getRegisterSession(completion: @escaping (_ response: MXResponse<MXAuthenticationSession>) -> Void) -> MXHTTPOperation? {
        return __getRegisterSession(success(completion), failure: error(completion))
    }

    
    /**
     Generic registration action request.
     
     As described in [the specification](http://matrix.org/docs/spec/client_server/r0.2.0.html#client-authentication),
     some registration flows require to complete several stages in order to complete user registration.
     This can lead to make several requests to the home server with different kinds of parameters.
     This generic method with open parameters and response exists to handle any kind of registration flow stage.
     
     At the end of the registration process, the SDK user should be able to construct a MXCredentials object
     from the response of the last registration action request.
     
     - parameters:
         - parameters: the parameters required for the current registration stage
         - completion: A block object called when the operation completes.
         - response: Provides the raw JSON response from the server.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func register(parameters: [String: Any], completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation? {
        return __register(withParameters: parameters, success: success(completion), failure: error(completion))
    }
    
    
    
    /*
     TODO: This method accepts a nil username. Maybe this should be called "anonymous registration"? Would it make sense to have a separate API for that case?
     We could also create an enum called "MXRegistrationType" with associated values, e.g. `.username(String)` and `.anonymous`
     */
    /**
     Register a user.
     
     This method manages the full flow for simple login types and returns the credentials of the newly created matrix user.
     
     - parameters:
         - loginType: the login type. Only `MXLoginFlowType.password` and `MXLoginFlowType.dummy` (m.login.password and m.login.dummy) are supported.
         - username: the user id (ex: "@bob:matrix.org") or the user id localpart (ex: "bob") of the user to register. Can be nil.
         - password: the user's password.
         - completion: A block object called when the operation completes.
         - response: Provides credentials to use to create a `MXRestClient`.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func register(loginType: MXLoginFlowType = .password, username: String?, password: String, completion: @escaping (_ response: MXResponse<MXCredentials>) -> Void) -> MXHTTPOperation? {
        return __register(withLoginType: loginType.rawValue, username: username, password: password, success: success(completion), failure: error(completion))
    }
    
    
    /// The register fallback page to make registration via a web browser or a web view.
    var registerFallbackURL: URL {
        let fallbackString = __registerFallback()!
        return URL(string: fallbackString)!
    }
    
    
    
    
    
    
    // MARK: - Login Operation
    
    /**
     Get the list of login flows supported by the home server.
     
     - parameters:
         - completion: A block object called when the operation completes. 
         - response: Provides the server response as an MXAuthenticationSession instance.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func getLoginSession(completion: @escaping (_ response: MXResponse<MXAuthenticationSession>) -> Void) -> MXHTTPOperation? {
        return __getLoginSession(success(completion), failure: error(completion))
    }
    
    /**
     Generic login action request.
     
     As described in [the specification](http://matrix.org/docs/spec/client_server/r0.2.0.html#client-authentication),
     some login flows require to complete several stages in order to complete authentication.
     This can lead to make several requests to the home server with different kinds of parameters.
     This generic method with open parameters and response exists to handle any kind of authentication flow stage.
     
     At the end of the registration process, the SDK user should be able to construct a MXCredentials object
     from the response of the last authentication action request.
     
     - parameters:
         - parameters: the parameters required for the current login stage
         - completion: A block object called when the operation completes.
         - response: Provides the raw JSON response from the server.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func login(parameters: [String: Any], completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation? {
        return __login(parameters, success: success(completion), failure: error(completion))
    }
    
    /**
     Log a user in.
     
     This method manages the full flow for simple login types and returns the credentials of the logged matrix user.
     
     - parameters:
         - type: the login type. Only `MXLoginFlowType.password` (m.login.password) is supported.
         - username: the user id (ex: "@bob:matrix.org") or the user id localpart (ex: "bob") of the user to authenticate.
         - password: the user's password.
         - completion: A block object called when the operation succeeds.
         - response: Provides credentials for this user on `success`
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func login(type loginType: MXLoginFlowType = .password, username: String, password: String, completion: @escaping (_ response: MXResponse<MXCredentials>) -> Void) -> MXHTTPOperation? {
        return __login(withLoginType: loginType.rawValue, username: username, password: password, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Get the login fallback page to make login via a web browser or a web view.
     
     Presently only server auth v1 is supported.
     
     - returns: the fallback page URL.
     */
    var loginFallbackURL: URL {
        let fallbackString = __loginFallback()!
        return URL(string: fallbackString)!
    }

    
    /**
     Reset the account password.
     
     - parameters:
         - parameters: a set of parameters containing a threepid credentials and the new password.
         - completion: A block object called when the operation completes.
         - response: indicates whether the operation succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func resetPassword(parameters: [String: Any], completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __resetPassword(withParameters: parameters, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Replace the account password.
     
     - parameters:
         - old: the current password to update.
         - new: the new password.
         - completion: A block object called when the operation completes
         - response: indicates whether the operation succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func changePassword(from old: String, to new: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __changePassword(old, with: new, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Invalidate the access token, so that it can no longer be used for authorization.
     
     - parameters:
         - completion: A block object called when the operation completes.
         - response: Indicates whether the operation succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func logout(completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __logout(success(completion), failure: error(completion))
    }
    
    
    
    
    // MARK: - Account data
    
    /**
     Set some account_data for the client.
     
     - parameters:
         - data: the new data to set for this event type.
         - type: The event type of the account_data to set. Custom types should be namespaced to avoid clashes.
         - completion: A block object called when the operation completes
         - response: indicates whether the request succeeded or not
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setAccountData(_ data: [String: Any], for type: MXAccountDataType, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setAccountData(data, forType: type.rawValue, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    
    // MARK: - Push Notifications
    
    /**
     Update the pusher for this device on the Home Server.
     
     - parameters:
        - pushkey: The pushkey for this pusher. This should be the APNS token formatted as required for your push gateway (base64 is the recommended formatting).
        - kind: The kind of pusher your push gateway requires. Generally `.http`. Specify `.none` to disable the pusher.
        - appId: The app ID of this application as required by your push gateway.
        - appDisplayName: A human readable display name for this app.
        - deviceDisplayName: A human readable display name for this device.
        - profileTag: The profile tag for this device. Identifies this device in push rules.
        - lang: The user's preferred language for push, eg. 'en' or 'en-US'
        - data: Dictionary of data as required by your push gateway (generally the notification URI and aps-environment for APNS).
        - completion: A block object called when the operation succeeds.
        - response: indicates whether the request succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setPusher(pushKey: String, kind: MXPusherKind, appId: String, appDisplayName: String, deviceDisplayName: String, profileTag: String, lang: String, data: [String: Any], append: Bool, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setPusherWithPushkey(pushKey, kind: kind.objectValue, appId: appId, appDisplayName: appDisplayName, deviceDisplayName: deviceDisplayName, profileTag: profileTag, lang: lang, data: data, append: append, success: success(completion), failure: error(completion))
    }
    // TODO: setPusherWithPushKey - futher refinement
    /*
     This method is very long. Some of the parameters seem related,
     specifically: appId, appDisplayName, deviceDisplayName, and profileTag.
     Perhaps these parameters can be lifted out into a sparate struct?
     Something like "MXPusherDescriptor"?
     */
    
    
    /**
     Get all push notifications rules.
     
     - parameters:
        - completion: A block object called when the operation completes.
        - response: Provides the push rules on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func pushRules(completion: @escaping (_ response: MXResponse<MXPushRulesResponse>) -> Void) -> MXHTTPOperation? {
        return __pushRules(success(completion), failure: error(completion))
    }
    
    
    /*
     TODO: Consider refactoring. The following three methods all contain (ruleId:, scope:, kind:).
     
     Option 1: Encapsulate those parameters as a tuple or struct called `MXPushRuleDescriptor`
     This would be appropriate if these three parameters typically get passed around as a set,
     or if the rule is uniquely identified by this combination of parameters. (eg. one `ruleId`
     can have different settings for varying scopes and kinds).
     
     Option 2: Refactor all of these to a single function that takes a "MXPushRuleAction"
     as the fourth paramerer. This approach might look like this:
     
         enum MXPushRuleAction {
            case enable
            case disable
            case add(actions: [Any], pattern: String, conditions: [[String: Any]])
            case remove
         }
         
         func pushRule(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, action: MXPushRuleAction, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation ? {
             switch action {
             case .enable:
                 // ... Call the `enablePushRule` method
             case .disable:
                 // ... Call the `enablePushRule` method
             case let .add(actions, pattern, conditions):
                 // ... Call the `addPushRule` method
             case let .remove:
                 // ... Call the `removePushRule` method
             }
         }
    
     Option 3: Leave these APIs as-is.
     */
    
    /**
     Enable/Disable a push notification rule.
     
     - parameters:
        - ruleId: The identifier for the rule.
        - scope: Either 'global' or 'device/<profile_tag>' to specify global rules or device rules for the given profile_tag.
        - kind: The kind of rule, ie. 'override', 'underride', 'sender', 'room', 'content' (see MXPushRuleKind).
        - enabled: YES to enable
        - completion: A block object called when the operation completes
        - response: Indiciates whether the operation was successful
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setPushRuleEnabled(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, enabled: Bool, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __enablePushRule(ruleId, scope: scope.identifier, kind: kind.objc, enable: enabled, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Remove a push notification rule.
     
     - parameters:
        - ruleId: The identifier for the rule.
        - scope: Either `.global` or `.device(profileTag:)` to specify global rules or device rules for the given profile_tag.
        - kind: The kind of rule, ie. `.override`, `.underride`, `.sender`, `.room`, `.content`.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func removePushRule(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __removePushRule(ruleId, scope: scope.identifier, kind: kind.objc, success: success(completion), failure: error(completion))
    }
    
    /**
     Create a new push rule.
     
     - parameters:
        - ruleId: The identifier for the rule (it depends on rule kind: user id for sender rule, room id for room rule...).
        - scope: Either `.global` or `.device(profileTag:)` to specify global rules or device rules for the given profile_tag.
        - kind: The kind of rule, ie. `.override`, `.underride`, `.sender`, `.room`, `.content`.
        - actions: The rule actions: notify, don't notify, set tweak...
        - pattern: The pattern relevant for content rule.
        - conditions: The conditions relevant for override and underride rule.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func addPushRule(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, actions: [Any], pattern: String, conditions: [[String: Any]], completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __addPushRule(ruleId, scope: scope.identifier, kind: kind.objc, actions: actions, pattern: pattern, conditions: conditions, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    // TODO: - Room operations
    
    /**
     Send a generic non state event to a room.
     
     - parameters:
        - roomId: the id of the room.
        - eventType: the type of the event.
        - content: the content that will be sent to the server as a JSON object.
        - completion: A block object called when the operation completes.
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     
     */
    @nonobjc @discardableResult func sendEvent(toRoom roomId: String, eventType: MXEventType, content: [String: Any], completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendEvent(toRoom: roomId, eventType: eventType.identifier, content: content, success: success(completion), failure: error(completion))
    }
    /*
     TODO: Consider refactoring.
     
     MXEventType could add associated values for different cases to
     encapsulate the content in an expressive way. eg:
     
         .roomName("A New Room Name")
         .roomMessage("a message", sender: "@bob:matrix.org")
         .typing(true, sender: "@alice:matrix.org")
         .custom(identifier: "custom.event.identifier", content: [String: Any])

     Then we change the function to this:
     
         sendEvent(_ type: MXEventType, toRoomId roomId: String, completion: ...)
     
     So it can be called like this:
     
         mxRestClient.sendEvent(.roomMessage("a new message", sender: "@bob:matrix.org"), toRoomId: "123456ABCDEF") { response in
            // Handle the response
         }
    */
    
    
    /**
     Send a generic state event to a room.
     
     - paramters:
        - roomId: the id of the room.
        - eventType: the type of the event. @see MXEventType.
        - content: the content that will be sent to the server as a JSON object.
        - completion: A block object called when the operation completes.
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendStateEvent(toRoom roomId: String, eventType: MXEventType, content: [String: Any], completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendStateEvent(toRoom: roomId, eventType: eventType.identifier, content: content, success: success(completion), failure: error(completion))
    }
    
    /**
     Send a message to a room
     
     - parameters:
        - roomId: the id of the room.
        - messageType: the type of the message.
        - content: the message content that will be sent to the server as a JSON object.
        - completion: A block object called when the operation completes. 
        - response: Provides the event id of the event generated on the home server on success.
     
     -returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendMessage(toRoom roomId: String, messageType: MXMessageType, content: [String: Any], completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendMessage(toRoom: roomId, msgType: messageType.identifier, content: content, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Send a text message to a room
     
     - parameters:
        - roomId: the id of the room.
        - text: the text to send.
        - completion: A block object called when the operation completion. 
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendTextMessage(toRoom roomId: String, text: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendTextMessage(toRoom: roomId, text: text, success: success(completion), failure: error(completion))
    }
    
    
    
    /**
     Set the topic of a room.
     
     - parameters:
        - roomId: the id of the room.
        - topic: the topic to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setTopic(ofRoom roomId: String, topic: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomTopic(roomId, topic: topic, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the topic of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the topic of the room on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func topic(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __topic(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    /**
     Set the avatar of a room.
     
     - parameters:
        - roomId: the id of the room.
        - avatar: the avatar url to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setAvatar(ofRoom roomId: String, avatarUrl: URL, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomAvatar(roomId, avatar: avatarUrl.absoluteString, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the avatar of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation succeeds.
        - response: Provides the room avatar url on success.
     
     - returns: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func avatar(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<URL>) -> Void) -> MXHTTPOperation? {
        return __avatar(ofRoom: roomId, success: { avatarUrlString in
            
            // The callback returns the URL as a string. We want to parse it into a URL.
            if let avatarUrlString = avatarUrlString, let avatarUrl = URL(string: avatarUrlString) {
                completion(.success(avatarUrl))
            } else {
                completion(.fromOptional(value: avatarUrlString))
            }
        }, failure: error(completion))
    }
    
    
    
    
    /**
     Set the name of a room.
     
     - parameters:
        - roomId: the id of the room.
        - name: the name to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setName(ofRoom roomId: String, name: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomName(roomId, name: name, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the name of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation succeeds.
        - response: Provides the room name on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func name(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __name(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Set the history visibility of a room.
     
     - parameters:
        - roomId: the id of the room
        - historyVisibility: the visibily to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setHistoryVisibility(ofRoom roomId: String, historyVisibility: MXRoomHistoryVisibility, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomHistoryVisibility(roomId, historyVisibility: historyVisibility.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the history visibility of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation succeeds.
        - response: Provides the room history visibility on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func historyVisibility(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomHistoryVisibility>) -> Void) -> MXHTTPOperation? {
        return __historyVisibility(ofRoom: roomId, success: { visibilityIdentifier in
            if let visibilityIdentifier = visibilityIdentifier, let visibility = MXRoomHistoryVisibility(identifier: visibilityIdentifier) {
                completion(.success(visibility))
            } else {
                completion(.fromOptional(value: visibilityIdentifier))
            }
        }, failure: error(completion))
    }
    
    
    
    
    
    
    
    /**
     Set the join rule of a room.
     
     - parameters:
        - roomId: the id of the room.
        - joinRule: the rule to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setJoinRule(ofRoom roomId: String, joinRule: MXRoomJoinRule, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomJoinRule(roomId, joinRule: joinRule.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the join rule of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation succeeds. 
        - response: Provides the room join rule on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func joinRule(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomJoinRule>) -> Void) -> MXHTTPOperation? {
        return __joinRule(ofRoom: roomId, success: { joinRuleIdentifier in
            if let joinRuleIdentifier = joinRuleIdentifier, let joinRule = MXRoomJoinRule(identifier: joinRuleIdentifier) {
                completion(.success(joinRule))
            } else {
                completion(.fromOptional(value: joinRuleIdentifier))
            }
        }, failure: error(completion))
    }
    
    
    
    
    // TODO: - Room tags operations
    
    
    
    
    // TODO: - Profile operations
    
    
    
    
    // TODO: - Presence operations
    
    

    
    // TODO: - Sync
    
    
    

    // TODO: - Directory operations
    
    /**
     Get the list of public rooms hosted by the home server.
     
     - parameter completion: A block object called when the operation is complete.
     - parameter response: Provides an array of the public rooms on this server on `success`
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func publicRooms(completion: @escaping (_ response: MXResponse<[MXPublicRoom]>) -> Void) -> MXHTTPOperation? {
        return __publicRooms(success(completion), failure: error(completion))
    }
    
    
    // TODO: - Media Repository API
    
    
    
    
    // TODO: - Identity server API
    
    
    
    
    // TODO: - VoIP API
    
    
    
    
    // TODO: - read receipts
    
    
    
    
    // TODO: - Search
    
    
    
    // TODO: - Crypto
    
    
    
    // TODO: - Direct-to-device messaging
    

    
    // TODO: - Device Management
    
    
    

    
    
}
