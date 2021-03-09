public with sharing class ckz_PIM_TypeaheadController {

    @AuraEnabled
    public static list<sObject> searchRecords( String queryString, String objectName, 
        list<String> fieldsToReturn, String fieldsToSearch, String filterClause, String orderBy, Integer recordLimit ) {

        if (queryString == null) return null;

        String sQuery = String.escapeSingleQuotes( queryString );
        if (sQuery.length() == 0) return null;

        String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes( objectName );

        String sInFields = 
            (fieldsToSearch == null || fieldsToSearch == '' || fieldsToSearch.toUpperCase() == 'ALL') ? '' : 
                ( ' IN ' + String.escapeSingleQuotes(fieldsToSearch) + ' FIELDS' );
        
        String sFields = (fieldsToReturn == null || fieldsToReturn.isEmpty()) ? 'Id, Name' : 
            String.escapeSingleQuotes( String.join( fieldsToReturn, ', ' ) );  
        
        String sOrder = ' ORDER BY ' + ( (orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy) ); 
        
        String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' : 
            ( ' LIMIT ' + String.valueOf(recordLimit));
        
        // can't escape the filter clause
        String sWhere = (filterClause == null || filterClause == '') ? '' : 
            ( ' WHERE ' + filterClause );

        String finalQuery = 'FIND \'' + sQuery + '*\'' + sInFields + 
                ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )';

        System.debug('finalQuery: ' + finalQuery);

        list<list<sObject>> results = Search.query( finalQuery );
        
        return results[0];
    }

    @AuraEnabled
    public static list<sObject> selectRecords( String queryString, String objectName, 
        String fieldsToReturn, String fieldsToSearch, String orderBy, Integer recordLimit ) {

        //if (queryString == null) return null;

        String sQuery = String.escapeSingleQuotes( queryString );
        //if (sQuery.length() == 0) return null;

        String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes( objectName );


        String [] searchFields = fieldsToSearch.split(',');

        String filterClause = '';
        if(fieldsToSearch == null || fieldsToSearch == '') {
            filterClause = 'Name LIKE \'%' + sQuery + '%\'';
        }
        else {
            for(String searchField : searchFields) {
                
                if(filterClause != '') {
                    filterClause += ' OR ';
                }
                
                filterClause += searchField + ' LIKE \'%' + sQuery + '%\' ';
            }
        }
        
        String sFields = null;
		if(fieldsToReturn == null || fieldsToReturn == '') {
            sFields = 'Id, Name';
        }
		else {
    		String [] temp = fieldsToReturn.split(',');
    		sFields = String.escapeSingleQuotes( String.join( temp, ', ' ) );  
		}
        
        String sOrder = ' ORDER BY ' + ( (orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy) ); 
        
        String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' : 
            ( ' LIMIT ' + String.valueOf(recordLimit));
        
        // can't escape the filter clause
        String sWhere = (filterClause == null || filterClause == '') ? '' : 
            ( ' WHERE ' + filterClause );

        String finalQuery = 'SELECT ' + sFields + ' FROM ' + objectName + sWhere + 
                sOrder + sLimit;

        System.debug('finalQuery: ' + finalQuery);

        list<sObject> results = Database.query( finalQuery );
        
        return results;

        }

}