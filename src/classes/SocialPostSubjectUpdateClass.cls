public with sharing class SocialPostSubjectUpdateClass {
  public static void updateSubject(Set<Id> spIds) {
    
    List<SocialPost> spList = [SELECT Id, ParentId, Name, Content FROM SocialPost WHERE Id =: spIds];

    for (SocialPost sp : spList){
      try{
        Case c = [SELECT Subject FROM Case Where Id =: sp.ParentId LIMIT 1];
        c.Subject = sp.Content.abbreviate(50); 
        c.Type = 'General'; 
        c.Description = sp.Name;
        system.debug('*****DEBUG: '+c.Subject);
        update c;
      }
      catch(Exception e){}
    }
  }    
}