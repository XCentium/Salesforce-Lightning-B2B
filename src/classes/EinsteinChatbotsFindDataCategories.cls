global class EinsteinChatbotsFindDataCategories {
    
    @InvocableMethod(label='Einstein Chatbots - Find Knowledge Product Data Categories' description='Returns a list of Knowledge Data Categories in the Product Group')
    public static List<List<String>> getDescribeDataCategoryGroupStructureResults(){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        List<String> categoryList = new List<String>();
        try {
            //Making the call to the describeDataCategoryGroups to
            //get the list of category groups associated
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            
            //Creating a list of pair objects to use as a parameter
            //for the describe call
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
            
            //Looping throught the first describe result to create
            //the list of pairs for the second describe call
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
                
            }
            
            //describeDataCategoryGroupStructures()
            describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
            
            //Getting data from the result
            for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                //Get name of the associated Sobject
                //Get the name of the data category group
                if(singleResult.getName()=='Product') { 
                    DataCategory [] toplevelCategories =  singleResult.getTopCategories();
                    //Recursively get all the categories
                    List<DataCategory> allCategories = getAllCategories(toplevelCategories);
                    for(DataCategory category : allCategories) {
                        //Get the name of the category
                        category.getLabel();
                        categoryList.add(category.getLabel());
                    }
                }
            }
        } 
        catch (Exception e){
            system.debug(e.getMessage());
        }
        
        
        return new List<List<String>>{categoryList};
    }
    
    public  static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
                } else {
                    DataCategory [] categoriesClone = categories.clone();
                    DataCategory category = categoriesClone[0];
                    DataCategory[] allCategories = new DataCategory[]{category};
                        categoriesClone.remove(0);
                    categoriesClone.addAll(category.getChildCategories());
                    allCategories.addAll(getAllCategories(categoriesClone));
                    return allCategories;
                    
                }
    }
    
}