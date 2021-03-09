@isTest
public class liveChatCaseTests {
    public static List<LiveChatTranscript> lct;
    
    static testMethod void testMyTriggers() {
        //LiveChatTranscript lc = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        lct = new List<LiveChatTranscript>();
        lct.add(New LiveChatTranscript(LiveChatVisitorId=lcv.Id));
        insert lct;
        Contact con = new Contact();
		con.LastName = 'Boyle';
        insert con;
        
    }
}