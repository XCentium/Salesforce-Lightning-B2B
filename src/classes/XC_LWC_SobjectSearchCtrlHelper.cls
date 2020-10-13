/*
 * @FileName: XC_LWC_SobjectSearchCtrlHelper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_SobjectSearchCtrlHelper {

    public static String executeSearch(String criteriaJSON) {
        SearchWrapper wrapper = (SearchWrapper) JSON.deserialize(criteriaJSON, SearchWrapper.class);
        wrapper.searchString = String.escapeSingleQuotes(wrapper.searchString);

        List<ResultWrapper> results = new List<ResultWrapper>();

        if(wrapper.searchSOQL) {
            results = searchSOQL(wrapper);
        } else {
            results = searchSOSL(wrapper);
        }

        return JSON.serialize(results);
    }

    private static List<ResultWrapper> searchSOSL(SearchWrapper wrapper) {
        String query = 'FIND \'' + wrapper.searchString + '\' IN ALL FIELDS RETURNING ';

        List<String> objs = new List<String>(wrapper.fieldsByObject.keySet());

        // specify which objects and fields to return
        for(String obj : objs) {
            query += obj +  wrapper.fieldsByObject.get(obj) + ',';
        }

        query = query.substring(0, query.length() - 1);

        query += ' LIMIT ' + wrapper.resultLimit;

        Search.SearchResults results;

        // query specified objects and fields
        if(wrapper.noSharing) {
            results = XC_LWC_SobjectSearchNoSharing.searchSOSL(query);
        } else {
            results = Search.find(query);
        }

        // merge search results into a single list
        List<Search.SearchResult> resultsList = new List<Search.SearchResult>();

        for(String obj : wrapper.fieldsByObject.keySet()) {
            resultsList.addAll(results.get(obj));
        }

        // convert search results to result wrapper list
        List<ResultWrapper> finalResults = new List<ResultWrapper>();

        for(Search.SearchResult sr : resultsList) {
            finalResults.add(new ResultWrapper(sr.getSObject(), wrapper.displayFields));
        }

        return finalResults;
    }

    private static List<ResultWrapper> searchSOQL(SearchWrapper wrapper) {
        List<String> objs = new List<String>(wrapper.fieldsByObject.keySet());

        String query = 'SELECT ' + wrapper.fieldsByObject.get(objs[0]);

        query += ' FROM ' + objs[0] +
                ' WHERE ' + wrapper.comparisonField + ' LIKE \'%' + wrapper.searchString + '%\'';

        if(String.isNotBlank(wrapper.queryFilters)) {
            query += ' ' + wrapper.queryFilters;
        }

        query += ' LIMIT ' + wrapper.resultLimit;

        List<SObject> results;

        // return query
        if(wrapper.noSharing) {
            results = XC_LWC_SobjectSearchNoSharing.searchSOQL(query);
        } else {
            results = Database.query(query);
        }

        // convert search results to result wrapper list
        List<ResultWrapper> finalResults = new List<ResultWrapper>();

        for(SObject record : results) {
            finalResults.add(new ResultWrapper(record, wrapper.displayFields));
        }

        return finalResults;
    }

    // WRAPPER CLASSES
    public class SearchWrapper {
        public String searchString;
        public Map<String,String> fieldsByObject;
        public String queryFilters;
        public String comparisonField;
        public List<String> displayFields;
        public Integer resultLimit;
        public Boolean searchSOQL;
        public Boolean noSharing;
    }

    public class ResultWrapper {
        public SObject record;
        public String type;
        public String displayValue;

        public ResultWrapper(SObject record, List<String> displayFields) {
            this.record = record;
            this.type = String.valueOf(record.getSObjectType()).toLowerCase();
            this.displayValue = getDisplayValue(record, displayFields);
        }

        private String getDisplayValue(SObject record, List<String> displayFields) {
            String value = '';

            for(String field : displayFields) {
                value += String.valueOf(getFieldValue(record, field)) + ' ';
            }

            value = value.substring(0, value.length() - 1);

            return value;
        }

        public Object getFieldValue(SObject o, String field) {
            if(o == null) return null;

            if(field.contains('.')) {
                String relation = field.substringBefore('.');
                String nextField = field.substringAfter('.');

                return getFieldValue((SObject) o.getSObject(relation), nextField);
            } else {
                return o.get(field);
            }
        }
    }
}