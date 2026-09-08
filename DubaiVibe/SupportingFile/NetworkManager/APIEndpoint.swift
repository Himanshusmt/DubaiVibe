//
//  APIEndpoint.swift
//  MyGuardianLink
//

import Foundation

enum APIEndpoint {
    //production
    static let baseURL = "https://api.myguardianlink.com/api/v1/"
    //Staging
   // static let baseURL = "https://stagingapi.myguardianlink.com:3001/api/v1/"
    
    static let privcypolicy = "https://portal.myguardianlink.com/privacy-policy?standalone=true"
    static let termsAndConditions = "https://portal.myguardianlink.com/terms-of-use?standalone=true"
    
    case sendOTP
    case verifyOTP
    case resendOTP
    case callOTP
    case onboardingStatus
    case getGroups
    case searchGroup(String, Int, Int)
    case continueWithOutGroupID
    case verifyGroup
    case uploadImage
    case getOnboardingProfile
    case confirmOnboardingProfile
    case getRecentContacts
    case viewAllContacts(String, Int, Int)
    case deleteTrustedContact(String)
    case getSearchTrustedContacts(String, Int, Int)
    case clearAllTrustedContact
    case addTrustedContact
    case sendInvitation
    case getPersonalBasicDetails
    case getMedicalEmergencyDetails
    case getVehicleInfo
    case getVehicleInfoOptions
    case getAlerts(type: String? = nil)
    case updateNotifications
    case verifyEmailSendOTP
    case verifyEmailConfirmOTP
    case verifyPhoneSendOTP
    case verifyPhoneConfirmOTP
    case verifyEmailResendOTP
    case verifyPhoneCallOTP
    case getGroupPlanById(String, String)
    case setupGroupPlan
    case updateSetupPlan(String)
    case addGroupMember(String)
    case deleteGroupMember(String)
    case planscatalog
    case planstier(String,String)
    case billingcheckoutsession
    case billingsubscriptionscurrent(String ,String)
    case skipOnboardingStep
    case reviewPlanDetail
    //template
    case getAlertTemplate(String)
    case alertHome(String)
    case onboardingComplete
    case onboardingProfile
    case googleLogin
    case appleLogin

    case receivedMessages(page: Int, limit: Int, id: String? = nil)
    case sentMessages(page: Int, limit: Int, id: String? = nil)
    case deleteReceivedMessage(messageId: String)
    case markMessageAsRead(messageId: String)
    case sendAlert
    case getLiveLocation(alertId: String)
    case updateLiveLocation(alertId: String)
    case stopLiveLocation(alertId: String)

    case getManualEntry
    case getMessageAlert(String, Int, Int)
    case getUrgentMessageSetting
    case tutorialVideos
    case logout
    case deleteAccount
    case invitePreview(groupInvite: String)
    case invitePreviewOrg(orgCode: String)
    case inviteAccept
    case inviteMemberCheckout(token: String)

    
    var path: String {
        
        switch self {
            
        case .sendOTP:
            return "/send-otp"
            
        case .verifyOTP:
            return "verify-otp"
            
        case .resendOTP:
            return "/resend-otp"
            
        case .callOTP:
            return "/call-otp"
            
        case .onboardingStatus:
            return "onboarding/status"
            
        case .getGroups:
            return "onboarding/groups/matching"
            
        case .searchGroup(let query, let page, let limit):
            return "onboarding/groups/matching?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&limit=\(limit)"
            
        case .continueWithOutGroupID:
            return "onboarding/groups/join"
            
        case .verifyGroup:
            return "onboarding/groups/verify"
            
        case .uploadImage:
            return "onboarding/name"
            
        case .getOnboardingProfile:
            return "onboarding/profile"
            
        case .confirmOnboardingProfile:
            return "onboarding/profile"
            
        case .getRecentContacts:
            return "onboarding/contacts/recent?limit=4"
            
        case .viewAllContacts(let query, let page, let limit):
            return "onboarding/contacts?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&limit=\(limit)"
            
        case .deleteTrustedContact(let id):
            return "onboarding/contacts/\(id)"
            
        case .getSearchTrustedContacts(let query, let page, let limit):
            return "onboarding/contacts/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&limit=\(limit)"
            
        case .clearAllTrustedContact:
            return "onboarding/contacts/search/recent"
            
        case .addTrustedContact:
            return "onboarding/contacts"
            
        case .sendInvitation:
            return "onboarding/contacts/invite"
            
        case .getPersonalBasicDetails:
            return "onboarding/personal-info/basic"
            
        case .getMedicalEmergencyDetails:
            return "onboarding/personal-info/medical-emergency"
            
        case .getVehicleInfo:
            return "onboarding/personal-info/vehicle"
            
        case .getVehicleInfoOptions:
            return "vehicle/options"
            
        case .getAlerts(let type):
            guard let type = type else {
                return "onboarding/alerts"
            }
            return "onboarding/alerts?type=\(type)"
            
        case .updateNotifications:
            return "onboarding/notifications"
            
        case .verifyEmailSendOTP:
            return "verify/email/send"
            
        case .verifyEmailConfirmOTP:
            return "verify/email/confirm"
            
        case .verifyPhoneSendOTP:
            return "verify/phone/send"
            
        case .verifyPhoneConfirmOTP:
            return "verify/phone/confirm"
            
        case .verifyEmailResendOTP:
            return "verify/resend"
            
        case .verifyPhoneCallOTP:
            return "verify/phone/call"
            
        case .getGroupPlanById(let tierId, let interval):
            return "plans/tier/\(tierId)/review?interval=\(interval)"
            
        case .setupGroupPlan:
            return "billing/group-plan/setup"
            
        case .addGroupMember(let setupId):
            return "billing/group-plan/setup/\(setupId)/members"
            
        case .deleteGroupMember(let memberId):
            return "billing/group-plan/setup/members/\(memberId)"
            
        case .updateSetupPlan(let setupId):
            return "billing/group-plan/setup/\(setupId)"
            
        case .planscatalog:
            return "plans/catalog"
            
        case .planstier(let id, let interval):
            return "plans/tier/\(id)/review?interval=\(interval)"
        case .billingcheckoutsession:
            return  "billing/checkout-session"
            
        case .billingsubscriptionscurrent(let planid, let paymentid):
            return "billing/subscriptions/current?planId=\(planid)&paymentMethodId=\(paymentid)"
            
        case .skipOnboardingStep:
            return "onboarding/contacts/skip"
            
        case .reviewPlanDetail:
            return "billing/group-plan/member-checkout"
            
        case .getAlertTemplate(let id):
            return "alerts/templates/\(id)"

        case .alertHome(let type):
            return "alerts/\(type)"
            
        case .onboardingComplete:
            return "onboarding/complete"

        case .receivedMessages(let page, let limit, let id):
            var query = "messages/received?page=\(page)&limit=\(limit)"
            if let id, !id.isEmpty {
                let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? id
                query += "&id=\(encodedId)"
            }
            return query

        case .sentMessages(let page, let limit, let id):
            var query = "messages/sent?page=\(page)&limit=\(limit)"
            if let id, !id.isEmpty {
                let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? id
                query += "&id=\(encodedId)"
            }
            return query

        case .deleteReceivedMessage(let messageId):
            return "messages/\(messageId)"

        case .markMessageAsRead(let messageId):
            return "messages/\(messageId)/read"

        case .sendAlert:
            return "alerts/send"

        case .getLiveLocation(let alertId):
            return "alerts/\(alertId)/live-location"

        case .updateLiveLocation(let alertId):
            return "alerts/\(alertId)/live-location"

        case .stopLiveLocation(let alertId):
            return "alerts/\(alertId)/live-location/stop"
            
        case .getManualEntry:
            return "manual-entry"
            
        case .getMessageAlert(let tab, let page, let limit):
            return "messages?tab=\(tab)&page=\(page)&limit=\(limit)"
            
        case .getUrgentMessageSetting:
            return "users/urgent-message-settings"

        case .tutorialVideos:
            return "tutorial-videos"

        case .onboardingProfile:
            return "onboarding/profile"
            
        case .googleLogin:
            return "google"

        case .appleLogin:
            return "apple"
            
        case .logout:
            return "logout"

        case .deleteAccount:
            return "users/me/account"

        case .invitePreview(let groupInvite):
            let encoded = groupInvite.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? groupInvite
            return "invites/preview?groupInvite=\(encoded)"

        case .invitePreviewOrg(let orgCode):
            let encoded = orgCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? orgCode
            return "invites/preview?orgCode=\(encoded)"

        case .inviteAccept:
            return "invites/accept"

        case .inviteMemberCheckout(let token):
            let encoded = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? token
            return "member-checkout?token=\(encoded)"
        }
    }
    
    var url: String {
        return APIEndpoint.baseURL + path
    }
}
