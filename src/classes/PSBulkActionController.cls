public class PSBulkActionController
{
	@AuraEnabled
	public static string executeSAQLQuery(string query)
	{
		System.debug('executeSAQLQuery invoked...');
		try
		{
			query = EncodingUtil.urlDecode(query, 'UTF-8');
			ConnectApi.LiteralJson result = ConnectApi.Wave.executeQuery(query);
			string response = result.json;
			return response;
		}
		catch(Exception e)
		{
			throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage());
		}
	}
	@AuraEnabled
	public static string getFieldDefs(String configName, string sobjectPrefix, string fields)
	{
		SObjectDef objectDef = new  SObjectDef();
		try
		{
			string objectName = getObjectName(sobjectPrefix);
			Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
			if(targetType == null)
			{
				//return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
				System.debug('targetType is null');
			}
			Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
			Map<string, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
			objectDef.objectLabel = sobjResult.label;
			objectDef.objectName = sobjResult.name;
			objectDef.objectPrefix = sobjResult.keyPrefix;
			// set list of fields to describe
			List<string> keySet = null;
			keySet = parseCSVString(fields);
			if(keySet == null)
			{
				keySet = new  List<string>(fieldMap.keySet());
			}
			string fld;
			string fieldKeyDef = null;
			List<FieldDef> fieldDefList = new  List<FieldDef>();
			for(string key: keySet)
			{
				fld = key;
				/////////////////////////////////////////
				// get the core metadata def for field //
				/////////////////////////////////////////
                if (fieldMap.containsKey(fld))
                {
				   Schema.DescribeFieldResult descField = fieldMap.get(fld).getDescribe();
				   System.debug('descField=' + JSON.serializePretty(descField));

					FieldDef fieldDef = new  FieldDef();
					fieldDef.label = descField.getLabel();
					fieldDef.name = descField.getName();
					fieldDef.ftype = descField.getType().name().toLowerCase();
					fieldDef.value = null;
					string fieldType = descField.getType().name().toLowerCase();
					//if a field is a picklist, I want the values
					if(fieldType == 'picklist' || fieldType == 'multipicklist')
					{
						List<object> optionsList = new  List<object>();
						List<Schema.PicklistEntry> pickListValues = descField.getPickListValues();
						for(Schema.PicklistEntry plv: pickListValues)
						{
							fieldDef.addOption(plv.getLabel(), plv.getValue());
						}
					}
					else if(fieldType == 'reference')
					{
						fieldDef.referenceTo = descField.getReferenceTo()[0].getDescribe().name;
						fieldDef.placeholderName = fieldDef.referenceTo.toLowerCase();
						fieldDef.icon = getIconName(descField.getReferenceTo()[0].getDescribe().name);
					}
					else if(fieldType == 'double' || fieldType == 'currency' || fieldType == 'percent')
					{
						fieldDef.scale = descField.getScale();
						fieldDef.precision = descField.getPrecision();
					}
					fieldDefList.add(fieldDef);
					//objectDef.addField(fieldDef);
				}
                
                else
                {
                    throw new PSBulkActionException('Could not find field \'' + key + '\' for object \'' + objectName +  '\'. Please validate your PSBulkActionConfig setting for name \'' + configName + '\'.');
                }
			}
			// re-order and put checkbox at the end
			for(FieldDef def: fieldDefList)
			{
				if(def.ftype != 'boolean')
				{
					objectDef.addField(def);
				}
			}
			if(Math.mod(objectDef.fields.size(), 2) == 1)
			{
				FieldDef fieldDef = new  FieldDef();
				fieldDef.label = 'skip';
				fieldDef.name = 'skip';
				fieldDef.ftype = 'skip';
				fieldDef.value = null;
				objectDef.addField(fieldDef);
			}
			for(FieldDef def: fieldDefList)
			{
				if(def.ftype == 'boolean')
				{
					objectDef.addField(def);
				}
			}
			return JSON.serialize(objectDef);
		}
        catch(PSBulkActionException e)
		{
			throw new  AuraHandledException(e.getMessage());
		}
		catch(Exception e)
		{
			throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
		}
	}
	@AuraEnabled
	public static void updateRecords(string sobjectDef, List<string> ids)
	{
		try
		{
			System.debug('sobjectDef=' + sobjectDef);
			System.debug('ids=' + JSON.serializePretty(ids));
			SObjectDef def = (SObjectDef)JSON.deserialize(sobjectDef, SObjectDef.class);
			List<SObject> recList = new  List<SObject>();
			for(string id: ids)
			{
				SObject rec = Schema.getGlobalDescribe().get(def.objectName).newSObject();
				rec.put('Id', id);
				for(FieldDef fieldDef: def.fields)
				{
					if(fieldDef.value != null)
					{
						if(fieldDef.ftype == 'boolean')
						{
							rec.put(fieldDef.name, Boolean.valueOf(fieldDef.value));
						}
						else if(fieldDef.ftype == 'reference')
						{
							if(fieldDef.value.length() > 0)
							{
								rec.put(fieldDef.name, fieldDef.value);
							}
						}
						else
						{
							rec.put(fieldDef.name, fieldDef.value);
						}
					}
				}
				recList.add(rec);
			}
			//System.debug('recList=' + JSON.serializePretty(recList));
			if (recList != null && recList.size() > 0) update recList;
		}
		catch(Exception e)
		{
			throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage());
		}
	}
	@AuraEnabled
	public static PSBulkActionConfig__c getBulkEditConfig(string configName)
	{
        try
		{
		PSBulkActionConfig__c config = [SELECT
			Id, 
			Name, 
			Config_Name__c, 
			SAQL_ID_Field__c, 
			Bulk_Edit_Fields__c, 
			Show_Bulk_Edit__c, 
			Show_Chatter__c, 
			Show_Data__c, 
			Show_SAQL__c, 
			Show_Task__c,
			Title__c,
			Header_Icon__c,
			Tab_Background_Color__c
		FROM
			PSBulkActionConfig__c
		WHERE
			Config_Name__c = :configName OR
			Name = :configName OR
			ID = :configName LIMIT 1];
		return config;
        }
        catch (QueryException qe)
        {
            throw new  AuraHandledException('Cannot find PSBulkActionConfig record for name = \'' + configName + ' \'. Please validate you have configuration created with specified name.');
        }
		catch(Exception e)
		{
			throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage());
		}
	}
	@AuraEnabled
	public static void postChatter(string sobjectName, string users, Boolean mentionOwners, string groups, string post, List<string> ids)
	{
		try
		{
			System.debug('users=' + users);
			System.debug('mentionOwners=' + mentionOwners);
			System.debug('groups=' + groups);
			System.debug('post=' + post);
			Map<string, string> ownerMap = new  Map<string, string>();
			if(mentionOwners)
			{
				string queryStr = 'SELECT Id, OwnerId FROM ' + sobjectName + ' WHERE ID IN (' + convListToCSV(ids) + ')';
				List<sObject> sobjList = Database.query(queryStr);
				for(Sobject obj: sobjList)
				{
					ownerMap.put((string)obj.Id, (string)obj.get('OwnerId'));
				}
			}
			List<ConnectApi.BatchInput> batchInputs = new  List<ConnectApi.BatchInput>();
			for(string id: ids)
			{
				ConnectApi.FeedItemInput feedItemInput = new  ConnectApi.FeedItemInput();
				ConnectApi.MessageBodyInput messageBodyInput = new  ConnectApi.MessageBodyInput();
				ConnectApi.TextSegmentInput textSegmentInput = new  ConnectApi.TextSegmentInput();
				messageBodyInput.messageSegments = new  List<ConnectApi.MessageSegmentInput>();
				textSegmentInput.text = post.stripHtmlTags() + '\r\n \r\n';
				messageBodyInput.messageSegments.add(textSegmentInput);
				// handle user mentions
				if(users != null && users.length() > 0)
				{
					List<string> userList = users.split(';');
					for(string u: userList)
					{
						ConnectApi.MentionSegmentInput mentionSegmentInput = new  ConnectApi.MentionSegmentInput();
						mentionSegmentInput.id = u;
						messageBodyInput.messageSegments.add(mentionSegmentInput);
						ConnectApi.TextSegmentInput tsi = new  ConnectApi.TextSegmentInput();
						tsi.text = ' ';
						messageBodyInput.messageSegments.add(tsi);
					}
				}
				// handle group mentions
				if(groups != null && groups.length() > 0)
				{
					List<string> groupList = groups.split(';');
					for(string g: groupList)
					{
						ConnectApi.MentionSegmentInput mentionSegmentInput = new  ConnectApi.MentionSegmentInput();
						mentionSegmentInput.id = g;
						messageBodyInput.messageSegments.add(mentionSegmentInput);
						ConnectApi.TextSegmentInput tsi = new  ConnectApi.TextSegmentInput();
						tsi.text = ' ';
						messageBodyInput.messageSegments.add(tsi);
					}
				}
				// handle record owners
				if(mentionOwners)
				{
					ConnectApi.MentionSegmentInput mentionSegmentInput = new  ConnectApi.MentionSegmentInput();
					mentionSegmentInput.id = ownerMap.get(id);
					messageBodyInput.messageSegments.add(mentionSegmentInput);
					ConnectApi.TextSegmentInput tsi = new  ConnectApi.TextSegmentInput();
					tsi.text = ' ';
					messageBodyInput.messageSegments.add(tsi);
				}
				feedItemInput.body = messageBodyInput;
				feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
				feedItemInput.subjectId = id;
				ConnectApi.BatchInput batchInput = new  ConnectApi.BatchInput(feedItemInput);
				batchInputs.add(batchInput);
				break;
			}
			//System.debug('chatter=' + JSON.serializePretty(batchInputs));
			ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
		}
		catch(Exception e)
		{
			throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
		}
	}
	private static string convListToCSV(List<string> vals)
	{
		string tmpStr = null;
		for(string str: vals)
		{
			if(tmpStr == null)
			{
				tmpStr = '\'' + str + '\'';
			}
			else
			{
				tmpStr += ',\'' + str + '\'';
			}
		}
		return tmpStr;
	}
	@AuraEnabled
	public static void createTasks(string subject, string description, string type, string ownerId, string dueDate, string status, string priority, string sobjectName, Boolean recordOwner, List<string> ids)
	{
		try
		{
			List<Task> taskList = new  List<Task>();
			// set task owner as record owner
			Map<string, string> ownerMap = new  Map<string, string>();
			if(recordOwner != null && recordOwner)
			{
				string queryStr = 'SELECT Id, OwnerId FROM ' + sobjectName + ' WHERE ID IN (' + convListToCSV(ids) + ')';
				List<sObject> sobjList = Database.query(queryStr);
				for(Sobject obj: sobjList)
				{
					ownerMap.put((string)obj.Id, (string)obj.get('OwnerId'));
				}
				System.debug('ownerMap=' + JSON.serializePretty(ownerMap));
			}

			for(string id: ids)
			{
				Task t = new  Task();
				if(recordOwner != null && recordOwner)
				{
					t.OwnerId = ownerMap.get(id);
				}
				else
				{
					if(ownerId != null)
					{
						t.OwnerId = ownerId;
					}
				}
				if(subject != null)
				{
					t.Subject = subject;
				}
				if(description != null)
				{
					t.Description = description;
				}
				if(dueDate != null)
				{
					t.ActivityDate = Date.valueOf(dueDate);
				}
				if(status != null)
				{
					t.Status = status;
				}
				if(priority != null)
				{
					t.Priority = priority;
				}
				if(id.startsWith('003') || id.startsWith('00Q'))// Contacts or Leads
				{
					t.WhoId = id;
				}
				else
				{
					t.WhatId = id;
				}
				taskList.add(t);
			}
			//System.debug('taskList=' + JSON.serializePretty(taskList));
			if (taskList != null && taskList.size() > 0) insert taskList[0];
		}
		catch(Exception e)
		{
			throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
		}
	}
	private static string getIconName(string sObjectName)
	{
		string u;
		List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
		List<Schema.DescribeTabResult> tabDesc = new  List<Schema.DescribeTabResult>();
		List<Schema.DescribeIconResult> iconDesc = new  List<Schema.DescribeIconResult>();
		for(Schema.DescribeTabSetResult tsr: tabSetDesc)
		{
			tabDesc.addAll(tsr.getTabs());
		}
		for(Schema.DescribeTabResult tr: tabDesc)
		{
			if(sObjectName == tr.getSobjectName())
			{
				if(tr.isCustom() == true)
				{
					iconDesc.addAll(tr.getIcons());
				}
				else
				{
					u = 'standard:' + sObjectName.toLowerCase();
				}
			}
		}
		for(Schema.DescribeIconResult ir: iconDesc)
		{
			if(ir.getContentType() == 'image/svg+xml')
			{
				u = 'custom:' + ir.getUrl().substringBetween('custom/', '.svg').substringBefore('_');
				break;
			}
		}
		return u;
	}
	private static List<string> parseCSVString(string str)
	{
		return parseDelimitedString(str, ',');
	}
	private static List<string> parseDelimitedString(string str, string delim)
	{
		List<string> optList = new  List<string>();
		for(string key: str.split(delim))
		{
			optList.add(key.trim());
		}
		return optList;
	}
	private static string getObjectName(string keyPrefix)
	{
		if(keyPrefix == null)
		{
			return null;
		}
		string objectAPIName = '';
		for(Schema.SObjectType obj: Schema.getGlobalDescribe().Values())
		{
			string prefix = obj.getDescribe().getKeyPrefix();
			if(prefix == keyPrefix)
			{
				objectAPIName = obj.getDescribe().getName();
				break;
			}
		}
		return objectAPIName;
	}
	public class SObjectDef
	{
		public string objectName;
		public string objectLabel;
		public string objectPrefix;
		public List<FieldDef> fields = null;
		public void addField(FieldDef fld)
		{
			if(fields == null)
			{
				fields = new  List<FieldDef>();
			}
			fields.add(fld);
		}
	}
	public class FieldDef
	{
		public string label;
		public string name;
		public string ftype;
		public string value;
		public string referenceTo;
		public string placeholderName;
		public Integer scale;
		public Integer precision;
		public string icon = 'standard:custom';
		public List<OptionDef> options = null;
		public void addOption(OptionDef opt)
		{
			if(options == null)
			{
				options = new  List<OptionDef>();
			}
			options.add(opt);
		}
		public void addOption(string label, string value)
		{
			if(options == null)
			{
				options = new  List<OptionDef>();
			}
			OptionDef opt = new  OptionDef();
			opt.label = label;
			opt.value = value;
			options.add(opt);
		}
	}
	public class OptionDef
	{
		public string label;
		public string value;
	}
}