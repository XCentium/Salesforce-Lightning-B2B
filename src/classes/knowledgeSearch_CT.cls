public with sharing class knowledgeSearch_CT {
 
    @AuraEnabled
    public static ArticlePagedResult searchAll(String searchKey, Decimal pageNumber) {
        Integer pageSize = 5;
        String key = '%' + searchKey + '%';
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        ArticlePagedResult a =  new ArticlePagedResult();
        a.pageSize = pageSize;
        a.page = (Integer) pageNumber;
        a.total = [SELECT count() FROM KnowledgeArticleVersion 
                      WHERE (title LIKE :key OR summary LIKE :key) AND (publishStatus = 'Online' AND language ='en_US') ];
        a.articles = [SELECT Id, title, summary, UrlName FROM KnowledgeArticleVersion 
                      WHERE (title LIKE :key OR summary LIKE :key) AND (publishStatus = 'Online' AND language ='en_US') LIMIT 5 OFFSET :offset];
        System.debug(a);
        return a;
    }
    
    private static List<ArticleDataCategory> convertJSONToListOfArticleDataCategory(String json){
        List<ArticleDataCategory> adcList = new List<ArticleDataCategory>();
        Object[] objList = (Object[])System.JSON.deserializeUntyped(json);
        for (Object obj : objList) {
            Map<String, Object> json_map = (Map<String, Object>)obj;
            ArticleDataCategory adc = new ArticleDataCategory();
            adc.parent_api = (String)json_map.get('parent_api');
            adc.api_name = (String)json_map.get('api_name');
            adcList.add(adc);
        }
        return adcList;
    }

    private static String createWithDataCategoryCondition(List<ArticleDataCategory> dataCategoryList){
        String soql_with_data_category = '';
        for(ArticleDataCategory adc : dataCategoryList){
            soql_with_data_category = soql_with_data_category + (!String.isEmpty(soql_with_data_category) ? ' and ' : '' )
                + adc.parent_api + '__c ABOVE_OR_BELOW ' + adc.api_name + '__c ';
        }
        return soql_with_data_category;
    }

    private static Integer getTotalSize(String key, String soql_with_data_category){
        String soql = 'SELECT count() FROM KnowledgeArticleVersion ';
            soql += 'WHERE (title LIKE \'' + key + '\' OR summary LIKE \'' + key + '\' ) AND ';
            soql += '(publishStatus = \'Online\' AND language = \'en_US\') ';

        if( !String.isEmpty(soql_with_data_category) ){
            soql_with_data_category = 'WITH DATA CATEGORY ' + soql_with_data_category;
        }
        soql = soql + soql_with_data_category;
        try{
            return Database.countQuery(soql);
        }catch(Exception e){
            System.debug(e);
        }
        return null;
    }

    private static List<KnowledgeArticleVersion> getArticles(String key, String soql_with_data_category, Integer offset){
        String soql = 'SELECT Id, title, summary, UrlName, articleType FROM KnowledgeArticleVersion ';
            soql += 'WHERE (title LIKE \'' + key + '\' OR summary LIKE \'' + key + '\' ) AND ';
            soql += '(publishStatus = \'Online\' AND language = \'en_US\') ';
        String soql_limit = ' LIMIT 5 OFFSET ' + offset;

        if( !String.isEmpty(soql_with_data_category) ){
            soql_with_data_category = 'WITH DATA CATEGORY ' + soql_with_data_category;
        }

        soql = soql + soql_with_data_category + soql_limit;
        System.debug(soql);

        try{
            return Database.query (soql);
        }catch(Exception e){
            System.debug(e);
        }
        return null;
    }

    @AuraEnabled
    public static ArticlePagedResult searchByCategory(String searchKey, String dataCategoryString, Decimal pageNumber) {
        List<ArticleDataCategory> dataCategoryList = convertJSONToListOfArticleDataCategory(dataCategoryString);

        Integer pageSize = 5;
        String key = '%' + searchKey + '%';
        Integer offset = ((Integer)pageNumber - 1) * pageSize;

        String soql_with_data_category = createWithDataCategoryCondition(dataCategoryList);

        ArticlePagedResult a = new ArticlePagedResult();
        a.pageSize = pageSize;
        a.page = (Integer) pageNumber;
        a.total = getTotalSize(key, soql_with_data_category);
        a.articles = getArticles(key, soql_with_data_category, offset);

        return a;
    }

    private static List<DescribeDataCategoryGroupResult> getDataCategoryGroups(){
        try {
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            return Schema.describeDataCategoryGroups(objType);
       }catch(Exception e){
           System.debug(e);
           return null;
       }
    }

    private static List<DataCategoryGroupSobjectTypePair> getDataCategoryGroupPairs( List<DescribeDataCategoryGroupResult> dataCategoryGroups ){
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
       for(DescribeDataCategoryGroupResult result: dataCategoryGroups ){
            DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
            pair.setSobject(result.getSobject());
            pair.setDataCategoryGroupName(result.getName());
            pairs.add( pair );
       }
        return pairs;
    }

    private static List<ArticleDataCategory> getChildCategories(Schema.DataCategory parent, String sObject_name, String name){
      List<ArticleDataCategory> adc_childCategories = new List<ArticleDataCategory>();
      for (Schema.DataCategory category : parent.getChildCategories()) {
        ArticleDataCategory adc_childCategory = new ArticleDataCategory( category.getLabel(), category.getName(), sObject_name, name );
        adc_childCategory.category_list = getChildCategories( category, sObject_name, name );
        adc_childCategories.add(adc_childCategory);
      }
      return adc_childCategories;
    }

    @AuraEnabled
    public static List<ArticleDataCategory> getDataCategories_ct(){
      List<ArticleDataCategory> adc_list = new List<ArticleDataCategory>();
      List<DataCategoryGroupSobjectTypePair> pairs = getDataCategoryGroupPairs ( getDataCategoryGroups() );

      for (Schema.DescribeDataCategoryGroupStructureResult result : Schema.describeDataCategoryGroupStructures(pairs,false) ) {
        ArticleDataCategory adc = new ArticleDataCategory( result.getLabel(), result.getName(), result.getSobject() );
        List<ArticleDataCategory> adc_topCategories = new List<ArticleDataCategory>();
        ArticleDataCategory adc_topCategory = new ArticleDataCategory( 'No Filter', 'none', result.getSobject(), result.getName() );
        adc_topCategories.add( adc_topCategory );

        for (Schema.DataCategory topCategory : result.getTopCategories()) {
          adc_topCategory = new ArticleDataCategory( topCategory.getLabel(), topCategory.getName(),  result.getSobject(), result.getName() );
          adc_topCategory.category_list = getChildCategories(topCategory, result.getSobject(), result.getName());
          adc_topCategories.add( adc_topCategory );
        }
        adc.category_list = adc_topCategories;
        adc_list.add( adc );
      }
      return adc_list;
    }
}