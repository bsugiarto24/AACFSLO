import SystemConfiguration

//utility class
public class Reachability {
    
    //returns true if connected to internet
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    class func internetCheck() {
        //check internet connection
        if !Reachability.isConnectedToNetwork() {
            Reachability.alertView("No Internet Connection",
                                   message: "Please connect to the internet")
        }
    }
    
    
    //parses "Optional()" from a string
    class func parseOptional(str : String) ->String{
        if(str.containsString("Optional(")) {
            return str.substringWithRange(str.startIndex.advancedBy(9)..<str.endIndex.advancedBy(-1))
        }
        return str
    }
    
    
    //converts epoch to YYYY.M.D
    class func epochtoDate(epoch : Double) ->String {
        let foo: NSTimeInterval = epoch / 1000
        let theDate = NSDate(timeIntervalSince1970: foo)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: theDate)
        let year =  components.year
        let month = components.month
        let day = components.day
        
        return String(year) + "." + String(month) + "." + String(day)
    }
    
    //converts epoch to HH:MM
    class func epochtoTime(epoch : Double) ->String {
        let date = NSDate(timeIntervalSince1970: epoch)
        let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: date)
        var hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date)
        var ampm = "am"
        
        if(hour > 12){
            hour -= 12
            ampm = "pm"
        }else if (hour == 0){
            hour = 12
        }else if(hour == 12){
            ampm = "pm"
        }

        if(minute < 10){
            return String(hour) + ":0" + String(minute) + ampm
        }
        return String(hour) + ":" + String(minute) + ampm
    }
    
    
    //converts epoch to HH:MM
    class func alertView(title: String, message : String) {
        //shows an alert window if not admin
        let alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = title;
        alertView.message = message;
        alertView.show();
    }
    
    
    
}