////
////  Constent.swift
////  Auction
////
////  Created by mac on 10/12/20.
////
//
//import Foundation
//import  UIKit
//let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//let kAppName = "Blynder"
//let kisLogin = "isLogin"
//var myLat = "0.0"
//var myLong = "0.0"
//
//
//let commonUrl = "https://ctinfotech.com/CTIS/blynder/"
//
//let baseUrl  =  "\(commonUrl)"
//
//let PostImagePath = "\(commonUrl)assets/post/"
//
//let ProfileImagePath  = "\(commonUrl)assets/userfile/profile/"
//
//let CategoryImagePath = "\(commonUrl)assets/category/"
//
//let  VideoImagePath =  "\(commonUrl)assets/reels/"
//
//let  ConcertImagePath =  "\(commonUrl)assets/concerts/"
//
//let  goalImagePath  = "\(commonUrl)assets/images/"
//
//let  songsPath  = "\(commonUrl)assets/songs/"
//
//
//
//let  termsCondition = "https://ctinfotech.com/CTCC/artist_army/home/terms"
//
//let  privacypolicy = "https://ctinfotech.com/CTCC/artist_army/home/privacy"
//
//
//
//
////struct appColor {
//let Pink = UIColor(named: "Pink")
//let White = UIColor(named: "White")
//let whiteBase = UIColor(named: "whiteBase")
//let Black = UIColor(named: "Black")
//let lightPink = UIColor(named: "lightPink")
//let darkBlue = UIColor(named: "DarkBlue")
//
//let yellow = UIColor(named: "yellow")
//let yellow_light = UIColor(named: "yellow_light")
//
//let green_light = UIColor(named: "green_light")
//let green = UIColor(named: "green")
//
//let red = UIColor(named: "Red")
//
//
//
//
//
//
//
//let  lightPurple = UIColor(named: "lightPurple")
///*
//let gradgray = UIColor(named: "grey")
//let gradCoral = UIColor(named: "Coral")
//let green = UIColor(named: "green")
//
//let darkgreen = UIColor(named: "darkgreen")*/
////}
//
//
////struct appColor {
////    let green = UIColor(named: "green")
////}
//
//
//
//struct ApiAction {
//    static let user_signup = "user_signup"
//    static let verify_otp = "verify_otp"
//    static let create_blynder_name = "create_blynder_name"
//    static let create_profile = "create_profile"
//    static let get_question_list = "get_question_list"
//    static let record_question_responce = "record_question_responce"
//    static let get_all_blynder_profiles = "get_all_blynder_profiles"
//    static let add_profile_image = "add_profile_image"
//    static let get_profile_details = "get_profile_details"
//    static let update_profile_data = "update_profile_data"
//    static let change_blynder_says = "change_blynder_says"
//    static let verify_email = "verify_email"
//    static let verify_mobile = "verify_mobile"
//    static let get_user_details = "get_user_details"
//    static let recordQuestionResponce = "recordQuestionResponce"
//    static let blocked_user_list = "blocked_user_list"
//    static let block_user = "block_user"
//    static let unblock_user = "unblock_user"
//    static let get_contact_us = "get_contact_us"
//    static let rate_us = "rate_us"
//    static let delete_account = "delete_account"
//    static let update_preferences = "update_preferences"
//    static let liked_user_list = "liked_user_list"
//    static let my_gift_count = "my_gift_count"
//    static let matches_list = "matches_list"
//    static let gifts_send = "gifts_send"
//    static let reveal_my_photos = "reveal_my_photos"
//    static let report_user = "report_user"
//    static let get_chat_list = "get_chat_list"
//    static let user_chat_messages = "user_chat_messages"
//    
//    
//    
//    
//
//
//    
//    
//    
//    
//}
//
//
//
////MARK:- Validation string
//enum Validation: String {
//    case kEnterMobileNumber = "Please enter mobile number"
//    case kEnterName = "Please enter name"
//    case kDOB = "Please select date of birth"
//    
//    case kaboutyourself = "Please enter about yourself"
//    case kidealdate = "Please enter about your ideal date"
//    
//    ////////////////////////////////////////////////////////////////////
//   
//    case kEnterEmail = "Please Enter Your Email"
//    case kEnterValidEmail = "Please Enter Valid Email Address"
//    case kEnterValidNumber = "Please Enter Valid Mobile Number"
//    case kEnterCompanyName = "Please Enter Company Name"
//    case kEnterEINNumber = "Please Enter EIN Number"
//    case kEnterBusinessType = "Please Select Business Type"
//    case kEnterWebUrl = "Please Enter Website Url"
//    case kSelectCategory = "Please Select Category"
//    case kEnterCompanyDis = "Please Enter Company Description"
//    case kEnterAddress = "Please Enter Your Address"
//    case kEnterPassword = "Please Enter Your Password"
//    case kEnterConfirmPassword = "Please Enter Confirm Password"
//    case kEnterValidPassword = "Please Enter Valid Password"
//    case kPassowrdNotMatched = "New Password & Confirm Password Not Matched"
//    case kEnterNewPassword = "Please Enter New Password"
//    
//    case kProductName = "Please Enter Product Name"
//    case kProductDetail = "Please Enter Product Detail"
//    case kProductDiscription = "Please Enter Product Description"
//    case kEnterTitle = "Please Enter Title"
//    case kEnterDetail = "Please Enter Detail"
//    case kDiscription = "Please Enter Description"
//    case kUserType = "Please Select UserType"
//    case kCompanyImg = "Please Select Company image"
//    case kCountryName = "Please Enter Country name"
//    case kCityName = "Please Enter City name"
//    case kStateName = "Please Enter State name"
//    case kPostalCode = "Please Enter PostalCode"
//    case kprivacy = "Please check privacy & policy"
//    case kdate = "Please select date"
//    case ktime = "Please select time"
//    case kvenue = "Please enter  concert venue"
//    case kdescription = "Please enter concert description"
//    case kdonateAmount = "Please enter donate amount"
//    case kdonateValidAmount = "Please enter valid donate amount"
//    case kGoalName = "Please enter goal name"
//    case kCerditsNedded = "Please enter amount of credits needed"
//    case kImageUpload  = "Please upload image"
//    case kreview  = "Please give review to us"
//    case kreason = "Please provide reason to us"
//}
//
////MARK:- Button titile string
//enum ButtonTitle: String {
//    case kOk = "OK"
//    case kCancel = "CANCEL"
//    case kYes = "YES"
//    case kNo = "NO"
//}
//
//
//struct Message {
//    static let msgSorry            = "Sorry something went wrong."
//    static let msgTimeOut          = "Request timed out."
//    static let msgCheckConnection  = "Please check your connection and try again."
//    static let msgConnectionLost   = "Network connection lost."
//    static let Key_Alert           = ""
//    static let couldNotConnect     = "Could not able to connect with server. Please try again."
//    let networkAlertMessage   = "Please Check Internet Connection"
//}
//
//
//struct params {
//    static let kmobile  = "mobile"
//    static let kmobile_code  = "mobile_code"
//    static let kuser_id  = "user_id"
//    static let kdevice_type  = "device_type"
//    static let kmobile_otp  = "otp"
//    static let ktoken  = "token"
//    static let  kblynder_name = "blynder_name"
//    static let kdate_of_birth = "date_of_birth"
//    static let  kname = "name"
//    static let  kgender = "gender"
//    static let  kpartner_gender = "partner_gender"
//    static let  kabout_yourself = "about_yourself"
//    static let  kabout_yourdate = "about_yourdate"
//    static let  kpartner_age_range = "partner_age_range"
//    static let  kpage_no = "page_no"
//    static let  kanswers_string = "answers_string"
//    static let  koriginal_image = "original_image"
//    static let  kfiltered_image = "filtered_image"
//    static let  kprofile_type = "profile_type"
//    static let  kcontent = "content"
//    static let  kscreen = "screen"
//    
//    static let  kcountry_code = "country_code"
//    static let  kmobile_no = "mobile_no"
//    static let  kblock_id = "block_id"
//    static let  kblock_user_id = "block_user_id"
//    static let  krating_stars = "rating_stars"
//    static let  kreview = "review"
//    static let  kreason = "reason"
//    static let  kdate_distance = "date_distance"
//    static let  kpartner_id = "partner_id"
//    static let  kgift_id = "gift_id"
//    static let  kreport_user_id = "report_user_id"
//    
//    
//    
//    
///////////////////////////////////////////////////////////////////////////
//    static let ksocial  = "social"
//    static let kpassword  = "password"
//    static let kdescription  = "description"
//    static let kpost_type  = "post_type"
//    static let kimage  = "images[]"
//    static let kpost_id  = "post_id"
//    static let kartist_name = "artist_name"
//    static let kgenre_cat = "genre_cat"
//    static let kbiography = "biography"
//    static let kformer_bands = "former_bands"
//    static let kaddress = "address"
//    static let kspotify = "spotify"
//    static let kyoutube = "youtube"
//    static let kinstagram = "instagram"
//    static let kfacebook = "facebook"
//    static let kprofile_image = "profile_image"
//    static let kcomment_id = "comment_id"
//    static let ksender_id = "sender_id"
//    static let kmessage = "message"
//    static let kartist_id = "artist_id"
//    static let kfans_id = "fans_id"
//    static let kfriends_id = "friends_id"
//    static let kreels_id = "reels_id"
//    static let ksearch = "search"
//    static let kconcert_id = "concert_id"
//    static let kgoal_id = "goal_id"
//    static let kfull_name = "full_name"
//    static let kemail = "email"
//    static let kphone_number = "phone_number"
//    static let kcountry = "country"
//    static let kaddress1 = "address1"
//    static let kaddress2 = "address2"
//    static let kcity = "city"
//    static let kstate = "state"
//    static let kpostcode = "postcode"
//    static let kgroup_id = "group_id"
//    static let kconcert_title = "concert_title"
//    static let kconcert_date = "concert_date"
//    static let kconcert_time = "concert_time"
//    static let kconcert_venue = "concert_venue"
//    static let kconcert_image = "concert_image"
//    static let  reel_description = "reel_description"
//    static let  reel_songs = "reel_songs"
//    static let  reel_video = "reel_video"
//    static let  block_id = "block_id"
//    static let  kgenre_name = "genre_name"
//    static let  kfilter = "filter"
//    static let  ktype = "type"
//    static let  kshare_to = "share_to"
//    static let  kref_user_id = "ref_user_id"
//    static let  kref_artist_id = "ref_artist_id"
//    static let   ksong_id  = "song_id"
//    static let   ksong_no  = "song_no"
//    static let   krefer_id  = "refer_id"
//    static let kstart  = "start"
//    static let kpageCount  = "page_count"
//    static let kdonate_bit = "donate_bit"
//    static let kdonate_by = "donate_by"
//    static let kdonate_to = "donate_to"
//    static let kdonate_name = "donate_name"
//    static let kbit_pack_id = "bit_pack_id"
//    static let kbit_amount = "bit_amount"
//    static let reel_image = "reel_image"
//    static let goal_name = "goal_name"
//    static let amount = "amount"
//    static let exp_date = "exp_date"
//    static let exp_time = "exp_time"
//    static let description = "description"
//    static let goal_image = "goal_image"
//    
//    
//    ///-----
//    static let kusername  = "username"
//    
//    static let kein  = "ein"
//    static let kbusiness_type  = "business_type"
//    static let kwebsite  = "website"
//    static let kcompany_description  = "company_description"
//    static let kcategorys  = "categorys"
//    static let kcompany_name  = "company_name"
//    
//    
//    //
//    //login
//    static let kfcm_token  = "fcm_token"
//    static let kcompany_image  = "company_image"
//    
//    static let kcategory_id  = "category_id"
//    static let ksearch_keyword  = "search_keyword"
//    static let kproduct_name  = "product_name"
//    static let kcategory  = "category"
//    static let kproduct_detail = "product_detail"
//    static let kproduct_description = "product_description"
//    static let kid = "id"
//    static let ksort_filter = "sort_filter"
//    static let kto_user = "to_user"
//    static let krate = "rate"
//    static let kreview_title = "review_title"
//    static let kcompany_id = "company_id"
//    static let kreview_description = "review_description"
//    static let kproduct_id = "product_id"
//    static let kcustomer_id = "customer_id"
//    static let kuser_type = "user_type"
//    static let kplan_id = "plan_id"
//    static let kstripeToken = "stripeToken"
//    static let krate_id = "rate_id"
//    static let ktitle = "title"
//    static let kdetail = "detail"
//    static let kticket_id = "ticket_id"
//    static let kcomment = "comment"
//    static let kfriend_id = "friend_id"
//    
//}
//
//
//
//extension HomeVC{
//    func setTabBarItems(){
//        let tabBar = self.tabBarController!.tabBar
//        
//        let myTabBarItem1 = (tabBar.items?[0])! as UITabBarItem
//        myTabBarItem1.image = UIImage(named: "home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem1.selectedImage = UIImage(named: "home_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem1.title = ""
//       myTabBarItem1.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        
//        let myTabBarItem2 = (tabBar.items?[1])! as UITabBarItem
//        myTabBarItem2.image = UIImage(named: "notification")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem2.selectedImage = UIImage(named: "notification_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem2.title = ""
//        myTabBarItem2.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        
//        
//        let myTabBarItem3 = (tabBar.items?[2])! as UITabBarItem
//        myTabBarItem3.image = UIImage(named: "video")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem3.selectedImage = UIImage(named: "video_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem3.title = ""
//        myTabBarItem3.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -6, right: 0)
//        
//        let myTabBarItem4 = (tabBar.items?[3])! as UITabBarItem
//        myTabBarItem4.image = UIImage(named: "favourite")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem4.selectedImage = UIImage(named: "favourite_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        myTabBarItem4.title = ""
//        myTabBarItem4.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        
//    }
//}
//
//
//
//@IBDesignable class TabBarWithCorners: UITabBar {
//    @IBInspectable var color: UIColor?
//    @IBInspectable var radii: CGFloat = 15.0
//
//    private var shapeLayer: CALayer?
//    override func draw(_ rect: CGRect) {
//        addShape()
//    }
//
//    private func addShape() {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = createPath()
//        shapeLayer.strokeColor = UIColor.gray.withAlphaComponent(0.1).cgColor
//        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
//        shapeLayer.lineWidth = 2
//        shapeLayer.shadowColor = UIColor.clear.cgColor
//        shapeLayer.shadowOffset = CGSize(width: 0   , height: -3);
//        shapeLayer.shadowOpacity = 0.2
//        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
//
//        if let oldShapeLayer = self.shapeLayer {
//            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
//        } else {
//            layer.insertSublayer(shapeLayer, at: 0)
//        }
//
//        self.shapeLayer = shapeLayer
//    }
//
//    private func createPath() -> CGPath {
//        let path = UIBezierPath(
//            roundedRect: bounds,
//            byRoundingCorners: [.topLeft, .topRight],
//            cornerRadii: CGSize(width: radii, height: 0.0))
//        return path.cgPath
//    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.isTranslucent = true
//        var tabFrame            = self.frame
//        
//        // UIApplication.shared.windows.filter {$0.isKeyWindow}.first?
//        tabFrame.size.height    = 65 + (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? CGFloat.zero)
//        tabFrame.origin.y       = self.frame.origin.y +   ( self.frame.height - 65 - (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? CGFloat.zero))
//        self.layer.cornerRadius = 20
//        self.frame            = tabFrame
//
//
//
//        self.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0) })
//
//
//    }
//
//}
//
//extension UIDevice {
//    var hasNotch: Bool {
//        if #available(iOS 11.0, *) {
//           return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0 > 0
//        }
//        return false
//   }
//}
//
//extension UITabBarController {
//
//    func addDotToTabBarItemWith(index: Int,size: CGFloat,color: UIColor, verticalOffset: CGFloat = 1.0) {
//         for tabItem in self.viewControllers! {
//            tabItem.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: verticalOffset)
//        }
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.regularFont(size: size)], for: .normal)
//        
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color,NSAttributedString.Key.font:UIFont.regularFont(size: size)], for: .selected)
//     
//        guard let vc = self.viewControllers?[index] else {
//            return
//        }
//
//        vc.tabBarItem.title = "●"
//    }
//}
//
//
//func getCountryCallingCode(countryRegionCode:String)->String{
//    let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263" , "":""]
//    let countryDialingCode = prefixCodes[countryRegionCode]
//    return countryDialingCode!
//}
//
//
//extension String {
//    var decodeEmoji: String{
//        let data = self.data(using: String.Encoding.utf8);
//        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
//        if let str = decodedStr{
//            return str as String
//        }
//        return self
//    }
//    var encodeEmoji: String{
//        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
//            return encodeStr as String
//        }
//        return self
//    }
//}
