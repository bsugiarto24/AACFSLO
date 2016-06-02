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
    
    
}