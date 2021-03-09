/**
 * Created by brandon.rogers on 3/29/19.
 */

global with sharing class ckz_CategoryTreeLogic extends ccrz.ccLogicCategoryTree {

    global virtual Map<String, Object> processCategoryTree2(Map<String, Object> inputData) {

        System.debug('ckz_CategoryTreeLogic:processCategoryTree2');

        Map<String, Object> fetchRes = super.processCategoryTree(inputData);

        List<Map<String, Object>> categoryTreeList = (List<Map<String, Object>>) fetchRes.get(ccrz.ccAPICategory.CATEGORYTREE);

        System.debug('ckz_CategoryTreeLogic:categoryTreeList: ');
        System.debug(Json.serialize(categoryTreeList));

        Set<String> categoryIdList = new Set<String>();

        for (Map<String, Object> categoryTreeEntry : categoryTreeList) {
            String name = (String) categoryTreeEntry.get('name'); System.debug('category name: ' + name);
            String sfid = (String) categoryTreeEntry.get('sfid');

            categoryIdList.add(sfid);

            if (categoryIdList.size() == 2)
                break;
        }

        System.debug('ckz_CategoryTreeLogic:categoryIdList: ' + categoryIdList);

        Map<String, Object> inputData2 = new Map<String, Object>{
                ccrz.ccAPICategory.CATEGORYIDLIST => categoryIdList
                , ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                , ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICategory.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
                                , ccrz.ccAPI.SZ_REL => new List<String>{
                                        'Categories__r', 'CategoryI18Ns__r', 'Category_Medias__r'
                                }
                        }
                }
        };

        try {

            Map<String, Object> outputData = ccrz.ccAPICategory.fetch(inputData2);

            System.debug('ckz_CategoryTreeLogic:outputData: ');

            System.debug(JSON.serialize(outputData));

            System.debug('--- getting categoryList');

            Map<String, List<Object>> categoryRelatedMap = new Map<String, List<Object>>();

            if (outputData.get(ccrz.ccAPICategory.CATEGORYLIST) != null) {

                List<Map<String, Object>> outputCategoryList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICategory.CATEGORYLIST);

                for (Map<String, Object> outputCategory : outputCategoryList) {

                    System.debug('ckz_CategoryTreeLogic:outputCategory: ');
                    System.debug(JSON.serialize(outputCategory));

                    System.debug('--- getting categoryMediasS');

                    String sfid = (String) outputCategory.get('sfid');
                    System.debug('sfid: ' + sfid);

                    List<Map<String, Object>> categoryMediaList = new List<Map<String, Object>>();

                    if (outputCategory.containsKey('categoryMediasS')) {

                        categoryMediaList = (List<Map<String, Object>>) outputCategory.get('categoryMediasS');

                    }

                    categoryRelatedMap.put(sfid, categoryMediaList);

                }

            }

            System.debug('ckz_CategoryTreeLogic:categoryRelatedMap: ');
            System.debug(JSON.serialize(categoryRelatedMap));

            for (Map<String, Object> categoryTreeEntry : categoryTreeList) {

                String sfid = (String) categoryTreeEntry.get('sfid');

                List<Map<String, Object>> categoryMediaList = (List<Map<String, Object>>) categoryRelatedMap.get(sfid);

                categoryTreeEntry.put('categoryMedias', categoryMediaList);

            }

            System.debug('ckz_CategoryTreeLogic:categoryTreeList (updated): ');
            System.debug(JSON.serialize(categoryTreeList));

            fetchRes.put(ccrz.ccAPICategory.CATEGORYTREE, categoryTreeList);


        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('Line: ' + e.getLineNumber());
        }


        System.debug('ckz_CategoryTreeLogic: - exit processCategoryTree');

        return fetchRes;

    }

    global override Map<String, Object> fetchCategories(Map<String, Object> inputData) {
        Map<String, Object> fetchInput = new Map<String, Object>{
                ccrz.ccApiCategory.ROOTCATEGORYID => inputData.get(ccrz.ccApiCategory.ROOTCATEGORYID)
                , ccrz.ccAPI.API_VERSION => inputData.get(ccrz.ccAPI.API_VERSION)
                , ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICategory.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L,
                                ccrz.ccAPI.SZ_REL => new List<String>{
                                        'Categories__r', 'CategoryI18Ns__r', 'Category_Medias__r'
                                }
                        }
                }
        };

        if (ccrz.ccUtil.isKeyValued(inputData, ccrz.ccApiCategory.CATEGORYLOCALE)) {
            fetchInput.put(ccrz.ccApiCategory.CATEGORYLOCALE, inputData.get(ccrz.ccApiCategory.CATEGORYLOCALE));
        }

        if (ccrz.ccUtil.isKeyValued(inputData, ccrz.ccAPICategory.STOREFRONT)) {
            fetchInput.put(ccrz.ccAPICategory.STOREFRONT, inputData.get(ccrz.ccAPICategory.STOREFRONT));
        }

        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'custom_ccLogicCategoryTree:fetchCategories:fetchInput', fetchInput);
        System.debug(System.LoggingLevel.DEBUG, 'fetchCategories:fetchInput: ' + JSON.serialize(fetchInput));

        Map<String, Object> res = ccrz.ccAPICategory.fetch(fetchInput);

        System.debug(System.LoggingLevel.DEBUG, 'fetchCategories:res: ' + JSON.serialize(res));

        inputData.put(ccrz.ccAPICategory.CATEGORYLIST, res.get(ccrz.ccAPICategory.CATEGORYLIST));

        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'custom_ccLogicCategoryTree:fetchCategories:inputData', inputData);
        System.debug(System.LoggingLevel.DEBUG, 'fetchCategories:inputData: ' + JSON.serialize(inputData));

        return inputData;
    }
}