public class IdeaListController {
   public IdeaListController() {}
   
   public List<Idea> getRecentIdeas() {
       List<Idea>iList = [select id, title, CreatedDate, VoteScore, VoteTotal from Idea order by CreatedDate desc limit 10];
       if (iList.isEmpty()) {
        return null;
       }
       return iList;
   }
}