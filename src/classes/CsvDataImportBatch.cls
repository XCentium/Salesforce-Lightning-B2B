global class CsvDataImportBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
	
	private String csvData;
	private Map<Integer, String> fieldPositions;
	private Map<String, Integer> fieldIndexes;
	private List<WaveApplicationObjectRelation> relations;
	private SObjectType objectType;
	private List<SmartLookup> smartLookups;
	private List<CompositeSmartLookup> compositeSmartLookups;
	private List<String> errorMessages;
	private Double apiVersion;
	private String sessionId;

	global CsvDataImportBatch(SObjectType objectType, String csvData, Map<Integer, String> fieldPositions, List<WaveApplicationObjectRelation> relations, Double apiVersion) {
		this.objectType = objectType;
		this.csvData = csvData;
		this.fieldPositions = fieldPositions;
		this.relations = relations;
		this.errorMessages = new List<String>();
		this.apiVersion = apiVersion;
		this.sessionId = UserInfo.getSessionId();

		// Then we get the table of <fieldName, columnIndexInCSV
		this.fieldIndexes = new Map<String, Integer>();

		for(Integer columnNumber: this.fieldPositions.keySet()) {
    		
    		// Gets the column name
    		String headerValue = this.fieldPositions.get(columnNumber).replace('"','');

    		this.fieldIndexes.put(headerValue, columnNumber);
    	}

    	for(WaveApplicationObjectRelation wAppObjectRelation: relations){
    		
			if (wAppObjectRelation.compositeForeignKey == null) {
				String columnName = wAppObjectRelation.csvColumnName;
				if(!this.fieldIndexes.containsKey(columnName)){
					throw new WaveConfiguratorException('Error with relation. The CSV dataset is required to contain a column named ' + columnName + '.');
				}
			}
			else {
				for (WaveApplicationCompositeForeignKeyPart fkPart: wAppObjectRelation.compositeForeignKey) {
				   	String columnName = fkPart.csvColumnName;
					if(!this.fieldIndexes.containsKey(columnName)){
						throw new WaveConfiguratorException('Error with composite foreign key relation. The CSV dataset is required to contain a column named ' + columnName + '.');
					}
				}
			}
    	}
	}
	
	global Iterable<String> start(Database.BatchableContext BC) {
		
		try {
			// Prepare headers and return all data
			this.prepareSmartLookups();

			return new CSV_RowIterator(this.csvData);
		}
		catch(Exception ex){
			System.debug('Exception in start');
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());

			throw ex;
		}
	}

   	global void execute(Database.BatchableContext BC, List<String> scope) {

   		try {
			
	   		List<String> lines = new List<String>();

	        for(String row : scope)
	        {
	            lines.add(row);
	        }

	        String joinedContents = String.join(lines, '\n');
	        String csvContentsToParse = joinedContents + '\n';
	        List<List<String>> rowsBatch = CSVReader.Parse(csvContentsToParse);

	        System.debug('About to process ' + rowsBatch.size() + ' objects of type ' + this.objectType.getDescribe().getName());

	   		// First handle smart lookups
	   		this.processSmartLookupForBatch(rowsBatch);

	   		List<SObject> objectsBatch = new List<SObject>();
	   		List<String> lstExternalIds = new List<String>();
	   		Map<String, Schema.SObjectField> objectFields = this.objectType.getDescribe().fields.getMap();
            
	   		
	   		Integer rowIndex = 0;
                
            // For each row of data in the CSV    
			for(List<String> sObjRow: rowsBatch) {

				// Will create an object
				SObject objToCreate = this.objectType.newSObject();

				// For each column in the CSV row
				for(Integer i = 0; i < sObjRow.size(); i++) {
					
					// We get the name using the position and then its value
					String fieldName = this.fieldPositions.get(i);
                    
                    if(String.isNotBlank(sObjRow[i]) && objectFields.containsKey(fieldName)){

						String fieldValue = sObjRow[i].trim();
						
						// Get field datatype
						Schema.DisplayType fieldType  = objectFields.get(fieldName).getDescribe().getType();

						if(fieldType == Schema.DisplayType.Boolean){
							// Boolean
							objToCreate.put(fieldName, Boolean.valueOf(fieldValue));
						}
						else if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Percent) {
							// Real number
							objToCreate.put(fieldName, Double.valueOf(fieldValue));
						}
						else if (fieldType == Schema.DisplayType.Integer) {
							// Integer
							objToCreate.put(fieldName, Integer.valueOf(fieldValue));
						}
						else if (fieldType == Schema.DisplayType.Date) {
							// Date
							objToCreate.put(fieldName, Date.valueOf(fieldValue));	
						}
						else if (fieldType == Schema.DisplayType.DateTime) {
							// Datetime
							objToCreate.put(fieldName, DateTime.valueOf(fieldValue));
						}
                        else if (fieldType == Schema.DisplayType.Time) {
                            // Time
                            DateTime dt = DateTime.valueOf(fieldValue);
                            objToCreate.put(fieldName, dt.time());
                        }
						else {
							// String
							if(!(this.objectType.getDescribe().getName() == 'User' && (fieldName.equalsIgnoreCase('Name') || fieldName.equalsIgnoreCase('Username') || fieldName.equalsIgnoreCase('CommunityNickname')))){
								objToCreate.put(fieldName, fieldValue);	
							}
							
							if(this.objectType.getDescribe().getName() == 'User' && fieldName.equalsIgnoreCase('Alias')){
								String nick = fieldValue + DateTime.now().getTime();
								objToCreate.put('CommunityNickname', nick);
								objToCreate.put('Username', nick + '@demo.user');	
							}
						}

						if(fieldName.equalsIgnoreCase('External_Id__c')){
							lstExternalIds.add(fieldValue);
						}
					}
				}
                
                // Composite Ids for the object
                for (CompositeSmartLookup csmLookUp : this.compositeSmartLookups) {
                    if(String.isNotBlank(csmLookup.RetrievedIds.get(rowIndex))){
                   		objToCreate.put(csmLookup.LookupFieldName, csmLookup.RetrievedIds.get(rowIndex));
                    }
                }

				objectsBatch.add(objToCreate);
                rowIndex++;
			}

			if(objectsBatch.size() > 0) {
				
				// UserRole has a distinct management
				if(this.objectType.getDescribe().getName() == 'UserRole'){
					List<UserRole> lstRoles = (List<UserRole>)objectsBatch;
					Set<String> setNames = new Set<String>();
					
					// Retrieve names
					for(UserRole role : lstRoles){
						if(String.isNotBlank(role.Name)){
							setNames.add(role.Name);
						}
					}

					Map<String, String> roleIdByName = new Map<String, String>();
					List<UserRole> existingRoles = [SELECT Id, Name FROM UserRole WHERE Name IN :setNames];

					// We fill the Ids map
					for(UserRole exRole : existingRoles){
						roleIdByName.put(exRole.Name, exRole.Id);
					}

					// New list for allow DML
					List<UserRole> rolesToUpsert = new List<UserRole>();

					// Set Ids
					for(UserRole role : lstRoles){
						UserRole newRole = new UserRole();
						
						if(String.isNotBlank(role.Name)){
							
							if(roleIdByName.containsKey(role.Name)){
								newRole.Id = roleIdByName.get(role.Name);
							}
							
							newRole.Name = role.Name;

							if(String.isNotBlank(role.ParentRoleId)){
								newRole.ParentRoleId = role.ParentRoleId;
							}
                            
                            if(String.isNotBlank(role.ForecastUserId)){
								newRole.ForecastUserId = role.ForecastUserId;
							}

							rolesToUpsert.add(newRole);
						}
					}

					upsert rolesToUpsert;
				} 
				else if(this.objectType.getDescribe().getName() == 'Group'){
					List<Group> lstGroups = (List<Group>)objectsBatch;
					Set<String> setNames = new Set<String>();
					
					// Retrieve names
					for(Group g : lstGroups){
						if(String.isNotBlank(g.DeveloperName)){
							setNames.add(g.DeveloperName);
						}
					}

					Map<String, String> groupIdByName = new Map<String, String>();
					List<Group> existingGroups = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :setNames];

					// We fill the Ids map
					for(Group exGroup : existingGroups){
						groupIdByName.put(exGroup.DeveloperName, exGroup.Id);
					}

					// New list for allow DML
					List<Group> groupsToUpsert = new List<Group>();

					// Set Ids
					for(Group g : lstGroups){
						Group newGroup = new Group();
						
						if(String.isNotBlank(g.DeveloperName)){
							
							if(groupIdByName.containsKey(g.DeveloperName)){
								newGroup.Id = groupIdByName.get(g.DeveloperName);
							}
							else {
								newGroup.Type = g.Type;
							}
							
							newGroup.Name = g.Name;
							newGroup.DeveloperName = g.DeveloperName;
							newGroup.Email = g.Email;
							newGroup.QueueRoutingConfigId = g.QueueRoutingConfigId;
							newGroup.DoesSendEmailToMembers = g.DoesSendEmailToMembers;
							newGroup.DoesIncludeBosses = g.DoesIncludeBosses;

							groupsToUpsert.add(newGroup);
						}
					}

					upsert groupsToUpsert;
				}
				else if(this.objectType.getDescribe().getName() == 'QueueSobject'){
					List<QueueSobject> lstQueueSobject = (List<QueueSobject>)objectsBatch;
					Set<String> setQueueId = new Set<String>();
					Set<String> setSObjectName = new Set<String>();

					// Retrieve names
					for(QueueSobject q : lstQueueSobject){
						if(String.isNotBlank(q.QueueId)){
							setQueueId.add(q.QueueId);
						}

						if(String.isNotBlank(q.SobjectType)){
							setSObjectName.add(q.SobjectType);
						}
					}

					Map<String, String> auxMap = new Map<String, String>();
					List<QueueSobject> existingSObjects = [SELECT Id, QueueId, SobjectType FROM QueueSobject WHERE QueueId IN :setQueueId OR SobjectType IN :setSObjectName];

					// We fill the Ids map
					for(QueueSobject exSObjectQueue : existingSObjects){
						auxMap.put(exSObjectQueue.QueueId + '-' + exSObjectQueue.SobjectType, exSObjectQueue.Id);
					}

					// New list for allow DML
					List<QueueSobject> sObjectsToInsert = new List<QueueSobject>();

					// Set Ids
					for(QueueSobject q : lstQueueSobject){
						QueueSobject newQueueSobject = new QueueSobject();
						
						if(String.isNotBlank(q.QueueId) && String.isNotBlank(q.SobjectType)){
							
							String key = q.QueueId + '-' + q.SobjectType;

							if(!auxMap.containsKey(key)){
								newQueueSobject.QueueId = q.QueueId;	
								newQueueSobject.SobjectType = q.SobjectType;
								sObjectsToInsert.add(newQueueSobject);
							}

						}
					}

					insert sObjectsToInsert;
				} 
				else if(this.objectType.getDescribe().getName() == 'LiveChatButton' || this.objectType.getDescribe().getName() == 'ServiceChannel' ||
					this.objectType.getDescribe().getName() == 'Skill'){

					String objType = this.objectType.getDescribe().getName();
					Set<String> setNames = new Set<String>();

					for(SObject s: objectsBatch){
						String value = String.valueOf(s.get('DeveloperName'));
						if(String.isNotBlank(value)){
							setNames.add(value);
						}
					}

					String genQuery = 'SELECT DeveloperName FROM ' + objType + ' WHERE DeveloperName IN :setNames';
					List<SObject> alreadyThere = Database.query(genQuery);
					Set<String> existingDevNames = new Set<String>();
					
					for(SObject sObj: alreadyThere) {
			        	existingDevNames.add(String.valueOf(sObj.get('DeveloperName')));
			        }

			        List<SObject> lstToInsert = new List<SObject>();

			        for(SObject sObj: objectsBatch){
			        	if(!existingDevNames.contains(String.valueOf(sObj.get('DeveloperName')))){
			        		lstToInsert.add(sObj);
			        	}
			        }

			        if(lstToInsert.size() <= 200){
			        	String requestJSON = '{ "records": [';
			        	List<String> lstObjJson = new List<String>();

			        	Integer i = 0;

			        	//This will iterate over objects and generate one object for "records" array.
			        	for(SObject sObj: lstToInsert){

			        		String objJson = '{';
			        		
			        		List<String> subProps = new List<String>();
			        		subProps.add('"attributes" : { "type" : "'+ objType + '", "referenceId" : "ref' + i + '" }');

			        		Map<String, Object> fieldsToValue = sObj.getPopulatedFieldsAsMap();

			        		for(String fieldName: fieldsToValue.keySet()){
			        			subProps.add('"' + fieldName + '" : "' + fieldsToValue.get(fieldName) + '"');
			        		}

			        		objJson += String.join(subProps, ',') + '}';
			        		
			        		lstObjJson.add(objJson);
			        		
			        		i++;
			        	}

			        	requestJSON += String.join(lstObjJson, ',') + ']}';
			       		
			       		String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
			       		String url = salesforceHost + '/services/data/v' + this.apiVersion + '/composite/tree/' + objectType;
			       		
			       		HttpRequest req = new HttpRequest();
						req.setEndpoint(url);
				        req.setMethod('POST');
				        req.setBody(requestJSON);
				        req.setHeader('Content-type', 'application/json');
						req.setHeader('Authorization', 'OAuth ' + sessionId);

						Http http = new Http();
				        HTTPResponse res = http.send(req);
			       		
			       		RestApiCompositeTreeResponse apiRes = (RestApiCompositeTreeResponse)JSON.deserialize(res.getBody(), RestApiCompositeTreeResponse.class);

			       		if(apiRes.hasErrors || !WaveConfiguratorUtils.checkStatus(res)){
			       			throw new RestApiResponseException(res.getBody());
			       		}
			       	}

				}
                else if(this.objectType.getDescribe().getName() == 'ForecastingQuota'){
					List<ForecastingQuota> lstForecastingQuota = (List<ForecastingQuota>)objectsBatch;
					Set<String> setForecastingTypeId = new Set<String>();
					Set<Date> setStartDate = new Set<Date>();
                    Set<String> setQuotaOwnerId = new Set<String>();

					// Retrieve fields
					for(ForecastingQuota fq : lstForecastingQuota){
						
                        if(String.isNotBlank(fq.ForecastingTypeId)){
							setForecastingTypeId.add(fq.ForecastingTypeId);
						}

						if(fq.StartDate != null){
							setStartDate.add(fq.StartDate);
						}
                        
                        if(String.isNotBlank(fq.QuotaOwnerId)){
							setQuotaOwnerId.add(fq.QuotaOwnerId);
						}
					}

					Map<String, String> auxMap = new Map<String, String>();
					List<ForecastingQuota> existingFQ = [SELECT Id, ForecastingTypeId, StartDate, QuotaOwnerId FROM ForecastingQuota WHERE ForecastingTypeId IN :setForecastingTypeId OR StartDate IN :setStartDate OR QuotaOwnerId IN :setQuotaOwnerId];

					// We fill the Ids map
					for(ForecastingQuota exFQ : existingFQ){
						auxMap.put(exFQ.ForecastingTypeId + '-' + exFQ.QuotaOwnerId + '-' + String.valueOf(exFQ.StartDate), exFQ.Id);
					}

					// New list for insert
					List<ForecastingQuota> sObjectsToInsert = new List<ForecastingQuota>();

					// Set Ids
					for(ForecastingQuota fq : lstForecastingQuota){
						ForecastingQuota newFQ = new ForecastingQuota();
						
						if(String.isNotBlank(fq.ForecastingTypeId) && fq.StartDate != null && String.isNotBlank(fq.QuotaOwnerId)){
							
							String key = fq.ForecastingTypeId + '-' + fq.QuotaOwnerId + '-' + String.valueOf(fq.StartDate);

							if(!auxMap.containsKey(key)){
								newFQ.ForecastingTypeId = fq.ForecastingTypeId;	
								newFQ.QuotaOwnerId = fq.QuotaOwnerId;
                                newFQ.StartDate = fq.StartDate;
                                newFQ.QuotaAmount = fq.QuotaAmount;                                
                                
								sObjectsToInsert.add(newFQ);
							}

						}
					}

					insert sObjectsToInsert;
				}
				else {
					// We must determine which objects to insert, and which to update
					String genQuery = 'SELECT Id, External_Id__c FROM ' + this.objectType.getDescribe().getName() + ' WHERE External_Id__c IN :lstExternalIds';
	                
	                // only add All Rows and IsDeleted when Tasks and Events
	                if(this.objectType.getDescribe().getName() == 'Task' || this.objectType.getDescribe().getName() == 'Event')
	                    genQuery += ' AND IsDeleted = False ALL ROWS';
	                
			        List<SObject> alreadyThere = Database.query(genQuery);
			        Map<String, String> sfIdsByExternalId = new Map<String, String>();
			        
			        for(SObject sObj: alreadyThere) {
			        	sfIdsByExternalId.put(String.valueOf(sObj.get('External_Id__c')), String.valueOf(sObj.get('Id')));
			        }

			        List<SObject> lstToInsert = new List<SObject>();
			        List<SObject> lstToUpdate = new List<SObject>();

			        for(SObject sObj: objectsBatch) {
			        	if(sfIdsByExternalId.containsKey(String.valueOf(sObj.get('External_Id__c')))){
			        		sObj.put('Id', sfIdsByExternalId.get(String.valueOf(sObj.get('External_Id__c'))));
			        		lstToUpdate.add(sObj);
			        	}
			        	else {
			        		lstToInsert.add(sObj);
			        	}
			        }

			        System.debug(lstToInsert.size() + ' objects to insert.');
			        System.debug(lstToUpdate.size() + ' objects to update.');

			        // DML
			        update lstToUpdate; // For now, only inserts
					insert lstToInsert;
				}				
			}

		} 
		catch(Exception ex){
			
			System.debug(ex.getMessage());

			this.errorMessages.add(ex.getMessage());

			throw ex;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		if(this.errorMessages.size() > 0){
			String subject = 'Exception processing data load for objects of type: ' + this.objectType.getDescribe().getName();
			WaveConfiguratorUtils.sendEmail(UserInfo.getUserEmail(), subject, String.join(this.errorMessages, '\r\n'));
		}
	}

	private void prepareSmartLookups(){
		
    	this.smartLookups = new List<SmartLookup>();
		this.compositeSmartLookups = new List<CompositeSmartLookup>();

    	// Now we traverse relations of the object
    	for(WaveApplicationObjectRelation relObj: this.relations) {
    		
    		// SmartLookup or CompositeSmartLookup
			if (relObj.compositeForeignKey != null) {
				// CompositeSmartLookup
				CompositeSmartLookup compSmLookUp = new CompositeSmartLookup();
				compSmLookUp.SObjectType = relObj.targetSObject;
				compSmLookUp.LookupFieldName = relObj.foreignKeyField;				

				for (WaveApplicationCompositeForeignKeyPart fkPart : relObj.compositeForeignKey) {
					compSmLookUp.TargetFields.add(fkPart.targetSObjectLookupField);
					compSmLookUp.TargetFieldsIndexes.add(this.fieldIndexes.get(fkPart.csvColumnName));
				}

				this.compositeSmartLookups.add(compSmLookUp);
			}
			else {
				SmartLookup smLookUp = new SmartLookup();
				String csvColumnName = relObj.csvColumnName;
				smLookUp.columnNumber = this.fieldIndexes.get(csvColumnName);
				smLookUp.SObjectType = relObj.targetSObject;
				smLookUp.targetField = relObj.targetSObjectLookupField;

				this.fieldPositions.put(smLookUp.columnNumber, relObj.foreignKeyField);
				this.smartLookups.add(smLookUp);
			}
    	}
	}

	private void processSmartLookupForBatch(List<List<String>> scope){
		
		if(scope != null) {

        	// Get all possible unique values to be replaced with IDs
        	// For each smart lookup
	        for (SmartLookup smLookUp : this.smartLookups) {

	        	// For each row we collect the values in the set
	            for (List<String> row : scope) {
	            	String val = row.get(smLookUp.columnNumber);
	            	if(String.isNotBlank(val)){
	            		smLookUp.plainTextValues.add(val.trim());
	            	}
	            }
	        }

	        // Get mapping of id to name, and add to lookup object
	        for (SmartLookup s : this.smartLookups) {	        	
	            
	            List<String> relevantValues = new List<String>(s.plainTextValues);
	            
	            String sObjToQuery = s.SObjectType;
	            String sFieldToQuery = s.targetField;
				String generatedQuery = 'SELECT Id, ' + sFieldToQuery + ' FROM ' + sObjToQuery + ' WHERE ' + sFieldToQuery + ' IN :relevantValues';

	            // RecordType special hadling
				if(sObjToQuery == 'RecordType'){
					generatedQuery += ' AND SobjectType = \'' + this.objectType.getDescribe().getName() + '\'';
				}

	            List<SObject> temp = Database.query(generatedQuery);
	            
	            for (SObject t: temp) {
	                s.replaceValues.put(String.valueOf(t.get(sFieldToQuery)), String.valueOf(t.get('Id')));
	            }

	            // Search whether there are Extenal_Id__c with not found id
	            for(String relVal: relevantValues) {
	            	if(String.isNotBlank(relVal) && !s.replaceValues.containsKey(relVal)){
	            		// This time: Throw exception for not being able to find Id for lookup
	            		throw new CsvDataImportException(String.format('Id not found for {0} = "{1}" in SObject: {2}.', new String[]{ sFieldToQuery, relVal, sObjToQuery }));
	            	}
	            }
	        }
	        
	        // Replace name values with Id equivalent
	        for (List<String> row : scope) {
	            for (SmartLookup s: this.smartLookups) {
                    if(String.isNotBlank(row[s.ColumnNumber])){
	            		row[s.ColumnNumber] = s.replaceValues.get(row[s.ColumnNumber].trim());
	            	}
	            }
	        }

			// Now is time for Composite Smart Lookups
			
			// Get all values of each field that make the composite foreign key
	        for (CompositeSmartLookup csmLookUp : this.compositeSmartLookups) {

	        	// For each row we collect the values in the set
	            for (List<String> row : scope) {
	            	
					for (Integer i = 0; i < csmLookUp.TargetFields.size(); i++) {
						String fieldName = csmLookUp.TargetFields.get(i);
						Integer fieldIndexInCSV = csmLookUp.TargetFieldsIndexes.get(i);
						
						if (!csmLookUp.TargetFieldsValues.containsKey(fieldName)) {
							csmLookUp.TargetFieldsValues.put(fieldName, new Set<String>());
						}

						Set<String> fieldValues = csmLookUp.TargetFieldsValues.get(fieldName);
						
						String val = row.get(fieldIndexInCSV);
						if(String.isNotBlank(val)){
							fieldValues.add(val.trim());
						}						
					}				
	            }

				// Build table to get Id for each composite foreign key
				String sObjToQuery = csmLookUp.SObjectType;
	            String sFieldsToQuery = String.join(csmLookUp.TargetFields, ',');
				List<String> compositeWhereConds = new List<String>();
				for (String f : csmLookUp.TargetFields) {
					Set<String> fieldValues = csmLookUp.TargetFieldsValues.get(f);
					if (fieldValues.size() > 0) {
						List<String> lstFieldValues = new List<String>();                       
                        for(String fv : fieldValues){
                            lstFieldValues.add('\'' + fv + '\'');
                        }
                        
						String whereCond = f + ' IN (' + String.join(lstFieldValues, ',') + ')';
						compositeWhereConds.add(whereCond);                        
					}
				}
				
				String generatedQuery = 'SELECT Id, ' + sFieldsToQuery + ' FROM ' + sObjToQuery + ' WHERE ' + String.join(compositeWhereConds, ' AND ');

	            // RecordType special hadling
				if(sObjToQuery == 'RecordType'){
					generatedQuery += ' AND SobjectType = \'' + this.objectType.getDescribe().getName() + '\'';
				}
				
	            List<SObject> temp = Database.query(generatedQuery);
                
                Map<String, String> IdsByKeys = new Map<String, String>();
	            
	            for (SObject t: temp) {
	                List<String> compositeKeysForMap = new List<String>();
                    for(String tf: csmLookUp.TargetFields){
                        compositeKeysForMap.add(String.valueOf(t.get(tf)));
                    }
					IdsByKeys.put(String.join(compositeKeysForMap, '-'), String.valueOf(t.get('Id')));
	            }
                
                // Now we have all Ids for each composite key in the target object
                // Now is time to process batch and get for each for the Id
                
                for (List<String> row : scope) {
	            	
                    List<String> compositeKeysToRetrieve = new List<String>();
                    for(Integer tfIndex: csmLookUp.TargetFieldsIndexes){
                        String val = row.get(tfIndex);
						if(String.isNotBlank(val)){
							compositeKeysToRetrieve.add(val);
						}                        
                    }
                    
                    String key = String.join(compositeKeysToRetrieve, '-');
                    if(IdsByKeys.ContainsKey(key)){
                        csmLookUp.RetrievedIds.add(IdsByKeys.get(key));
                    }
                    else {
                        csmLookUp.RetrievedIds.add('');
                    }
	            }
	        }
		}
	}

	global class CsvDataImportException extends Exception {
		
	}

	global class RestApiResponseException extends Exception {
		
	}
}