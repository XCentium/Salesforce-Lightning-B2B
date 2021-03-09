@isTest
public class TestNews_AnnouncementsController {
//    public static RecordType rt = [select id,Name from RecordType where SobjectType='Lead' and Name='Lead' Limit 1]; 
    static testMethod void test() {
    Test.startTest();
        Integer numDocs = 2;
        News_AnnouncementsController newsCon = new News_AnnouncementsController();
        List<News_Announcements__c> listNews = new List<News_Announcements__c>();
        //needs long content for rich text field Content__c else the test covereage on the populateNewsAnnouncementsTrigger does not get covered and test class fails 
        News_Announcements__c News = new News_Announcements__c(title__c='Title', Source__c='Source1', News_Channel__c ='Corporate',Content__c='Lorem ipsum dolor sit amet, ut nibh voluptatibus sea. Ad pri pertinacia interesset, quo modo saperet adipisci ei. Ne vim iriure discere saperet. Posse singulis mediocritatem qui ad, novum assentior at mea. Ei est vero elit alienum, ne rebum idque fabellas ius, ex error argumentum omittantur');
        listNews.add(News);
        insert listNews;
        News_AnnouncementsController.getNewsChannelNames();
        News_AnnouncementsController.getnumDocsByChannel ();
        News_AnnouncementsController.getFirstNewsChannelRecords(numDocs);
        News_AnnouncementsController.getNewsChannelRecordsByChannel(listNews[0].News_Channel__c, numDocs);
        //Attachment
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Lorem ipsum dolor sit amet, tortor massa lacus');
    	attach.body=bodyBlob;
        attach.parentId=listNews[0].id;
        insert attach;
    Test.stopTest();
    }
}