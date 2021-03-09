public class CloudCrazeRedirectCntr {
    @AuraEnabled
    public Static List<String> commurl(String Community) {
        Network myCommunity = [SELECT Id FROM Network WHERE Name = :Community];
		ConnectApi.Community comm = ConnectApi.Communities.getCommunity(myCommunity.Id);
		List<String> BaseURL = comm.siteUrl.split('[/]');
        return BaseURL;
    }
	
}