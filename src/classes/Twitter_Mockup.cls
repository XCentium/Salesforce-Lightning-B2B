public class Twitter_Mockup {
    public static String comment { get; set; }
    public static String comm {get; set;} 
    public void createSocialCase() {
        String contid = [SELECT Id FROM Contact Where Name = 'Rachel Morris' Limit 1].Id;
        String contName = [SELECT Name FROM Contact Where Name = 'Rachel Morris' Limit 1].Name;
        String accid = [SELECT AccountId FROM Contact Where Name = 'Rachel Morris' Limit 1].AccountId;
        Case caseObj = new Case(
            ContactId = contid,
            AccountId = accid,
            Status = 'New',
            Origin = 'Twitter',
            Subject = 'Twitter Case From ' + contName,
            Description = comm
        );
        insert caseObj;
    }
}