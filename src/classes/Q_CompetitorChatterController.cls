public class Q_CompetitorChatterController {
    public CollaborationGroup competitor {get;set;}
    public Q_CompetitorChatterController(){
        competitor = [SELECT Id,Name From CollaborationGroup WHERE Name='Competitive Experts'];
    }
    static public String protocolAndHost {
        get {
            if (protocolAndHost == null) {
                //memoize
                String orgId = UserInfo.getOrganizationId();
                String userId = UserInfo.getUserId();
                String sessionId = UserInfo.getSessionId();
    
                //use getSalesforceBaseUrl within batches and schedules (not Visualforce), and fix inconsistent protocol
                if (sessionId == null) return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');
    
                PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
                pr.getParameters().put('oauth_token', sessionId);
                pr.getParameters().put('format', 'json');
    
                //within test context use url class, else derive from identity api
                String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
                Map<String,Object> result = (Map<String,Object>)Json.deserializeUntyped(data);
                Map<String,Object> urls = (Map<String,Object>)result.get('urls');
                Url rest = new Url((String)urls.get('rest'));
                protocolAndHost = rest.getProtocol() + '://' + rest.getHost();
            }
    
            return protocolAndHost;
        }
    }
    public PageReference goCompete(){
        PageReference reference=new PageReference(protocolAndHost + '/_ui/core/chatter/groups/GroupProfilePage?g=' + competitor.id);
        reference.setRedirect(false);
        return reference;
    }
}