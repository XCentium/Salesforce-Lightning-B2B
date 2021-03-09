trigger populateNewsAnnouncementsTeaser on News_Announcements__c (before insert, before update) {
    if(System.isBatch()) return;
    for (News_Announcements__c n: Trigger.new) {
        If(n.Content__c!=null && (n.Content__c.length()>122)){
            n.Teaser__c = n.Content__c.substring(0,122).stripHtmlTags() + ' ...';
        }else if(n.Content__c!=null && (n.Content__c.length()<122)){
            n.Teaser__c = n.Content__c.stripHtmlTags() + ' ...';
        }
    }
}