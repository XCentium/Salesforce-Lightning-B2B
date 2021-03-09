public class News_AnnouncementsController {
    public static String firstNewsChannel; //store firstNewsChannel

    @AuraEnabled
    public Static List<String> getNewsChannelNames() {//get News_Channel__c picklist values
        Schema.DescribeFieldResult fieldResult = News_Announcements__c.News_Channel__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> newsChannelNames = new List<String>();
        for( Schema.PicklistEntry f : ple){ // get News_Channel__c piclist values
      		newsChannelNames.add(f.getValue());
   		}       
		if(newsChannelNames.size()>0){
            firstNewsChannel = newsChannelNames[0];
        }
        return newsChannelNames;
    }    
    @AuraEnabled
    public Static Map<String, Integer> getnumDocsByChannel() {//get number of records per News Channel
        Map<String, Integer> numDocsByChannel = new Map<String, Integer>();
        List<String> newsChannelNames = new List<String>();
        newsChannelNames = getNewsChannelNames();
        List<News_Announcements__c> newsChannelRecords = new List<News_Announcements__c>();
        String QueryString = 'SELECT Id, Title__c, News_Channel__c, Source__c, Teaser__c, External_URL__c, URL__c, ImageAttachmentId__c, DisplayDate__c, LastModifiedDate FROM News_Announcements__c ORDER BY LastModifiedDate DESC';
        newsChannelRecords = Database.Query(QueryString);
        for(String nChannel: newsChannelNames){
            Integer channelCount = 0;
            for(News_Announcements__c n: newsChannelRecords){
                if(n.News_Channel__c.contains(nChannel)){
                    channelCount++;
                }
            }
            numDocsByChannel.put(nChannel,channelCount);
    	}
        return numDocsByChannel;
    }
    @AuraEnabled
    public Static List<News_Announcements__c> getFirstNewsChannelRecords(Integer numDocs)
     {
        List<News_Announcements__c> firstNewsChannelRecords = new List<News_Announcements__c>();
        String QueryString = 'SELECT Id, Title__c, News_Channel__c, Source__c, Teaser__c, External_URL__c, URL__c, ImageAttachmentId__c, DisplayDate__c, LastModifiedDate FROM News_Announcements__c WHERE News_Channel__c includes (\''+firstNewsChannel+'\')  ORDER BY LastModifiedDate DESC LIMIT '+numDocs;
        firstNewsChannelRecords = Database.Query(QueryString);
        return firstNewsChannelRecords;
    }
    @AuraEnabled
    public Static List<News_Announcements__c>  getNewsChannelRecordsByChannel(String newsChannel, Integer numDocs)
     {
        List<News_Announcements__c> newsChannelRecords = new List<News_Announcements__c>();
        String QueryString = 'SELECT Id, Title__c, News_Channel__c, Source__c, Teaser__c, External_URL__c, URL__c, ImageAttachmentId__c, DisplayDate__c, LastModifiedDate FROM News_Announcements__c WHERE News_Channel__c includes (\''+newsChannel+'\')  ORDER BY LastModifiedDate DESC LIMIT '+numDocs;
        newsChannelRecords = Database.Query(QueryString);
        return newsChannelRecords;
    }
}