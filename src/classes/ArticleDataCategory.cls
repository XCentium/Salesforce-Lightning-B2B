global class ArticleDataCategory {

    @AuraEnabled
    public String data_category_name { get;set; }

    @AuraEnabled
    public String api_name { get;set; }

    @AuraEnabled
    public String article_type { get;set; }

    @AuraEnabled
    public List<ArticleDataCategory> category_list {get; set;}

    @AuraEnabled
    public String parent_api{get; set;}

    public ArticleDataCategory(){
    }
    public ArticleDataCategory( String data_category_name, String api_name, String article_type){
        this.data_category_name = data_category_name;
        this.api_name = api_name;
        this.article_type = article_type;
        this.parent_api = null;
        this.category_list = new List<ArticleDataCategory>();
    }
    public ArticleDataCategory( String data_category_name, String api_name, String article_type, String parent_api){
        this.data_category_name = data_category_name;
        this.api_name = api_name;
        this.article_type = article_type;
        this.parent_api = parent_api;
        this.category_list = new List<ArticleDataCategory>();
    }
}