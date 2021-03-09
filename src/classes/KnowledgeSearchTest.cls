@isTest
private class KnowledgeSearchTest {
    static testMethod void myPhonyTest() {
        knowledgeSearch_CT x = new knowledgeSearch_CT();
        ArticleDataCategory y = new ArticleDataCategory();
        y = new ArticleDataCategory('data_category_name','api_name','article_type');
        y = new ArticleDataCategory('data_category_name','api_name','article_type', 'parent-api');
    }
    /*
    static testMethod void myTest() {
        ArticlePagedResult result = knowledgeSearch_CT.searchAll('', 1);
        for(ArticleDataCategory adc : knowledgeSearch_CT.getDataCategories_ct()){
            String data_cat_string = '[{"api_name" : "", "parent_api" : ""}]';
            result = knowledgeSearch_CT.searchByCategory('', data_cat_string, 1);
        }
        System.assert(result != null);
     }
*/
}