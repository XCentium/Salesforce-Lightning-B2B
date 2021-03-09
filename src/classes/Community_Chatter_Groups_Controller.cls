public class Community_Chatter_Groups_Controller {
   
    public String userID {get;set;}
    public List<CollaborationGroup> cGroups {get;set;}
    public List<String> cGroupPhotos {get;set;}
        
    public String msg {get;set;} 
        
    public String sPrefixStr {
        get;
        set{ sPrefixStr = value; initialize(); }
    }
    
    public void initialize() {
        Network network;
        if(sPrefixStr != null && sPreFixStr != '') {
            network  = [Select UrlPathPrefix, Name, Id 
                        From Network
                        Where UrlPathPrefix =: sPrefixStr.subString(1) Limit 1];
        }
        
        msg = network.Id;
        
        userID  = UserInfo.getUserID();
        cGroups = new List<CollaborationGroup>();
        cGroupPhotos = new List<String>();

        if(network != null) {
            for(CollaborationGroupMember cgm : [Select Id, CollaborationGroupID From CollaborationGroupMember Where MemberId =: userID ]) {
                CollaborationGroup cg = [Select Id, Name, FullPhotoUrl, NetworkID from CollaborationGroup Where Id =: cgm.CollaborationGroupID];
                if(cg.NetworkID == network.Id) {
                    cGroups.add(cg);
                    cGroupPhotos.add(cg.FullPhotoUrl);
                }
            }
        }
        
    }
    
    public Community_Chatter_Groups_Controller() {
        
    }
}