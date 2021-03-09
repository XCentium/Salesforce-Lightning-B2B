public class CustomerPortalWelcomeController {
   
   User loggedInUser = [Select id,contactId,Contact.AccountId from User where id = :UserInfo.getUserId()];
   
   public List<Asset> MyRegisteredProducts {get; set;}
   public List<Case> MyRecentCases {get; set;}
   public List<Solution> TopSolutions {get; set;}
   public List<Idea> PopularIdeas {get; set;}
   
   public String sortField1 {get; set;}
   public String previousSortField1 {get; set;}
   public String sortField2 {get; set;}
   public String previousSortField2 {get; set;}
   public String sortField3 {get; set;}
   public String previousSortField3 {get; set;}
   public String sortField4 {get; set;}
   public String previousSortField4 {get; set;}
            
   public CustomerPortalWelcomeController() {
        MyRegisteredProducts = [select id,Name,SerialNumber,InstallDate,UsageEndDate,Status 
                                from Asset 
                                where ContactId = :loggedInUser.ContactId 
                                order by SerialNumber desc limit 3];
        
        MyRecentCases = [select id,CaseNumber,Subject,Status,LastModifiedDate 
                         from Case 
                         where ContactId = :loggedInUser.ContactId 
                         order by LastModifiedDate desc limit 3];
        
        TopSolutions = [select id,SolutionName,TimesUsed,LastModifiedDate 
                        from Solution 
                        order by TimesUsed desc limit 3];
                              
        PopularIdeas = [select id,Title,Categories,VoteTotal 
                        from Idea 
                        order by VoteTotal desc limit 3];
                        
   }
   
   public void SortProducts(){
        String order = 'asc';
        if(previousSortField1 == sortField1){
            order = 'desc';
            previousSortField1 = null;
        }else{
            previousSortField1 = sortField1;
        }
        superSort.sortList(MyRegisteredProducts,sortField1,order);
    }
    public void SortCases(){
        String order = 'asc';
        if(previousSortField2 == sortField2){
            order = 'desc';
            previousSortField2 = null;
        }else{
            previousSortField2 = sortField2;
        }
        superSort.sortList(MyRecentCases,sortField2,order);
    }
    public void SortSolutions(){
        String order = 'asc';
        if(previousSortField3 == sortField3){
            order = 'desc';
            previousSortField3 = null;
        }else{
            previousSortField3 = sortField3;
        }
        superSort.sortList(TopSolutions,sortField3,order);
    }
    public void SortIdeas(){
        String order = 'asc';
        if(previousSortField4 == sortField4){
            order = 'desc';
            previousSortField4 = null;
        }else{
            previousSortField4 = sortField4;
        }
        superSort.sortList(PopularIdeas,sortField4,order);
    }
    
   /*
   public List<Asset> getMyRegisteredProducts() {
       List<Asset> aList = [select id,Name,SerialNumber,InstallDate,UsageEndDate,Status 
                            from Asset 
                            where ContactId = :loggedInUser.ContactId 
                            order by SerialNumber desc limit 3];
       if (aList.isEmpty()) {
         return null;
       }
       return aList;
   }
   
   public List<Case> getMyRecentCases() {
      cList = [select id,CaseNumber,Subject,Status,LastModifiedDate 
                          from Case 
                          where ContactId = :loggedInUser.ContactId 
                          order by LastModifiedDate desc limit 3];
      if (cList.isEmpty()) { 
        return null;
      }
      return cList;
   }
   
   public List<Solution> getTopSolutions() {
      List<Solution> sList = [select id,SolutionName,TimesUsed,LastModifiedDate 
                              from Solution 
                              order by TimesUsed desc limit 3];
      if (sList.isEmpty()) {
        return null;
      }
      return sList;
   }
   
   public List<Idea> getPopularIdeas() {
      List<Idea> iList = [select id,Title,Category,VoteTotal 
                          from Idea 
                          order by VoteTotal desc limit 3];
      if (iList.isEmpty()) {
        return null;
      }
      return iList;
   }
   */

}