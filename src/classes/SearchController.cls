public class SearchController {
    public String searchType {get;set;}
    public String sbstrSearch {get;set;}
    public String urlIFrame {get;set;}
    public String sen {get{ return '500'; } set;}
    
    public SearchController() {
        this.searchType = (ApexPages.currentPage().getParameters().get('search') != '') ? ApexPages.currentPage().getParameters().get('search') : searchType;
        this.sbstrSearch = (ApexPages.currentPage().getParameters().get('sbstr') != '') ? ApexPages.currentPage().getParameters().get('sbstr') : sbstrSearch;
    }
    
    public PageReference GoSearch() {
        PageReference ResultPage = new PageReference('/apex/SearchResults?search=' + this.searchType + '&sbstr=' + this.sbstrSearch);
        
        ResultPage.setRedirect(true);
        return ResultPage;
    }
}