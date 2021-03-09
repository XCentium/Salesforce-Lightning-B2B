public class Community_Popular_Topics_Controller {
    
    public List<Topic> popularTopics {get;set;}
    
    public String sPrefixStr {
        get;
        set{ sPrefixStr = value; initialize(); }
    }
    
    public void initialize() {
        if(sPrefixStr != null && sPreFixStr != '') {
            List<Network> n = [Select n.UrlPathPrefix, n.Name, n.Id 
                               From Network n
                               Where n.UrlPathPrefix =: sPrefixStr.subString(1)];
            
            if(n!= null && n.size() > 0) {
                popularTopics = [Select t.Id, t.Name, t.CreatedDate, t.talkingAbout
                                 From Topic t
                                 Where t.NetworkID =: n[0].Id
                                 Order By t.talkingAbout Desc Limit 5];
            }
        }
    }
}