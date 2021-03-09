{
	"appName": "Simple",
	"appType": "",
	"appDescription": "",
	"timeShift": {
		"usage": "This attribute is used to configure timeshifting",
		"tObject": "Opportunity",
		"dateField": "CloseDate",
		"filter": "External_Id__c LIKE 'W_Opportunity%' AND StageName = 'Closed Won'",
		"compareDate": "2017-09-20",
		"displayText": "Date of latest closed won opportunity"
	},
	"objects": [
		{
			"name": "User",
			"url": "simple/User.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "simple/User_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Profile.Name",
					"targetSObject" : "Profile",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "ProfileId"
				},
				{
					"csvColumnName": "",
					"targetSObject" : "UserRole",
					"targetSObjectLookupField" : "",
					"foreignKeyField" : "UserRoleId",
					"compositeForeignKey": [
						{
							"csvColumnName": "Role.DeveloperName",
							"targetSObjectLookupField" : "DeveloperName"
						}
					] 
				}
			]
		},
		{
			"name": "Account",
			"url": "simple/Account.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "simple/Account_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Owner.External_Id__c",
					"targetSObject" : "User",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "OwnerId"
				}
			],
			"dateFieldsToShift": [
				"CreatedDate__c"
			]
		},
		{
			"name": "Opportunity",
			"url": "simple/Opportunity.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "simple/Opportunity_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Owner.External_Id__c",
					"targetSObject" : "User",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "OwnerId"
				},
				{
					"csvColumnName": "Account.External_Id__c",
					"targetSObject" : "Account",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "AccountId"
				},
				{
					"csvColumnName": "RecordType.Name",
					"targetSObject" : "RecordType",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "RecordTypeId"
				}
			],
			"dateFieldsToShift": [
				"DateTimeCreated__c",
				"LastActivityDate__c",
				"LastModifiedDate__c"
			],
			"recordTypes": [
				{
					"developerName": "RecordTypeA",
					"label": "Record Type A"
				},
				{
					"developerName": "RecordTypeB",
					"label": "Record Type B"
				}
			]
		}
	],
	"edgemarts": [
        {
            "edgemartDeveloperName": "DemoData_Account",
            "edgemartLabel": "Account Demo Data",
            "objectName": "Account",
            "edgemartCsvDataUrl": "https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Account.csv",
            "edgemartJsonSchemaUrl": "https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Account.schema.json",
            "edgemartNodeNameInDataflow": "Extract_Edg_Account",
            "replaceData": true
        }
    ]
}