{
	"appName": "Wave for Sales",
	"appType": "Sales",
	"appDescription": "This package includes data on Users, Accounts, Opportunities for Wave for Sales. It also includes a Wave workflow and dashboards.",
	"dataflowLocation": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dataflows/NEW_Sales_Wave.json",
	"objects": [
		{
			"name": "User",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/UserManager.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/User_metadata.csv",
			"relations": [
				{
					"csvColumnName": "UserRole.Name",
					"targetSObject" : "UserRole",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "UserRoleId"
				},
				{
					"csvColumnName": "Profile.Name",
					"targetSObject" : "Profile",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "ProfileId"
				}
			]
		},
		{
			"name": "User",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/User.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/User_metadata.csv",
			"relations": [
				{
					"csvColumnName": "UserRole.Name",
					"targetSObject" : "UserRole",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "UserRoleId"
				},
				{
					"csvColumnName": "Profile.Name",
					"targetSObject" : "Profile",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "ProfileId"
				},
				{
					"csvColumnName": "Manager.External_Id__c",
					"targetSObject" : "User",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "ManagerId"
				}
			]
		},
		{
			"name": "Account",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Account.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Account_metadata.csv",
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
			"name": "Contact",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Contact.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Contact_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Account.External_Id__c",
					"targetSObject" : "Account",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "AccountId"
				}
			]
		},
		{
			"name": "Case",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Case.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Case_metadata.csv",
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
					"csvColumnName": "Contact.External_Id__c",
					"targetSObject" : "Contact",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "ContactId"
				}
			],
			"dateFieldsToShift": [
				"CreatedDate__c",
				"ClosedDate__c"
			]
		},
		{
			"name": "Opportunity",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Opportunity.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Opportunity_metadata.csv",
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
			]
		},
		{
			"name": "Lead",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Lead.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Lead_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Owner.External_Id__c",
					"targetSObject" : "User",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "OwnerId"
				},
				{
					"csvColumnName": "ConvertedOpportunity.External_Id__c",
					"targetSObject" : "Opportunity",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "ConvertedOpportunityId"
				},
				{
					"csvColumnName": "ConvertedAccount.External_Id__c",
					"targetSObject" : "Account",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "ConvertedAccountId"
				},
				{
					"csvColumnName": "ConvertedContact.External_Id__c",
					"targetSObject" : "Contact",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "ConvertedContactId"
				}
			],
			"dateFieldsToShift": [
				"CreatedDate__c",
				"ConvertedDate__c"
			]
		},
		{
			"name": "OpportunityHistory__c",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/OpportunityHistory.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/OpportunityHistory_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Opportunity.External_Id__c",
					"targetSObject" : "Opportunity",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "OpportunityId__c"
				}
			],
			"dateFieldsToShift": [
				"CreatedDate__c",
				"CloseDate__c"
			]
		},
		{
			"name": "Product2",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Product2.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Product2_metadata.csv",
			"relations": [
				
			]
		},
		{
			"name": "PricebookEntry",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/PricebookEntry.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/PricebookEntry_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Product2.External_Id__c",
					"targetSObject" : "Product2",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "Product2Id"
				},
				{
					"csvColumnName": "Pricebook2.Name",
					"targetSObject" : "Pricebook2",
					"targetSObjectLookupField" : "Name",
					"foreignKeyField" : "Pricebook2Id"
				}
			]
		},
		{
			"name": "OpportunityLineItem",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/OpportunityLineItem.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/OpportunityLineItem_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Opportunity.External_Id__c",
					"targetSObject" : "Opportunity",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "OpportunityId"
				},
				{
					"csvColumnName": "PricebookEntry.External_Id__c",
					"targetSObject" : "PricebookEntry",
					"targetSObjectLookupField" : "External_Id__c",
					"foreignKeyField" : "PricebookEntryId"
				}
			]
		},
		{
			"name": "Task",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Task.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Task_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Owner.External_Id__c",
					"targetSObject": "User",
					"targetSObjectLookupField": "External_Id__c",
					"foreignKeyField": "OwnerId"
    			},
    			{
					"csvColumnName": "What.External_Id__c",
					"targetSObject": "Opportunity",
					"targetSObjectLookupField": "External_Id__c",
					"foreignKeyField": "WhatId"
    			}
  			],
			"dateFieldsToShift": [
				"CreatedDate__c",
				"ActivityDate"
			]
		},
		{
			"name": "Event",
			"url": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/data/Event.csv",
			"additionalDataFiles": 0,
			"metadataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/metadata/Event_metadata.csv",
			"relations": [
				{
					"csvColumnName": "Owner.External_Id__c",
					"targetSObject": "User",
					"targetSObjectLookupField": "External_Id__c",
					"foreignKeyField": "OwnerId"
    			},
    			{
					"csvColumnName": "What.External_Id__c",
					"targetSObject": "Opportunity",
					"targetSObjectLookupField": "External_Id__c",
					"foreignKeyField": "WhatId"
    			}
			],
			"dateFieldsToShift": [
				"CreatedDate__c",
				"ActivityDate",
				"ActivityDateTime"
			]
		}
	],
	"edgemarts": [
		{
			"Name": "plain_quota",
			"Label": "Quota",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/QuotasMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Quotas.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/plain_quota.xmd.json"
		},
		{
			"Name": "opportunity_products",
			"Label": "Oppty Products",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/OpptyProductsMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/OpptyProducts.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/opportunity_products.xmd.json"
		},
		{
			"Name": "quota",
			"Label": "User Allocation",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/UserAllocationMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/UserAllocation.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/quota.xmd.json"
		},
		{
			"Name": "user",
			"Label": "Users",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/UsersMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Users.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/user.xmd.json"
		},
		{
			"Name": "activity",
			"Label": "Activities",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/ActivitiesMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Activities.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/activity.xmd.json"
		},
		{
			"Name": "user_role",
			"Label": "Roles",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/RolesMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Roles.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/user_role.xmd.json"
		},
		{
			"Name": "pipeline_trending",
			"Label": "Pipeline Trending",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/PipelineTrendingMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/PipelineTrending.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/pipeline_trending.xmd.json"
		},
		{
			"Name": "opportunity",
			"Label": "Opportunities",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/OpportunitiesMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Opportunities.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/opportunity.xmd.json"
		},
		{
			"Name": "lead",
			"Label": "Leads",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/LeadsMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Leads.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/lead.xmd.json"
		},
		{
			"Name": "account",
			"Label": "Accounts",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/AccountsMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Accounts.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/account.xmd.json"
		},
		{
			"Name": "case",
			"Label": "Cases",
			"MetadataJsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/CasesMetadata.json",
			"DataUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/Cases.csv",
			"XmdUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/datasets/case.xmd.json"
		}
	],
	"dashboards": [
		{
			"Name": "CompanyOverview",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/CompanyOverview.json"
		},
		{
			"Name": "CompanyTrending",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/CompanyTrending.json"
		},
		{
			"Name": "ExecOverviewPipelinePerformance",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/ExecOverviewPipelinePerformance.json"
		},
		{
			"Name": "ExecOverviewSalesPerformance",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/ExecOverviewSalesPerformance.json"
		},
		{
			"Name": "ExecOverviewServicePerformance",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/ExecOverviewServicePerformance.json"
		},
		{
			"Name": "Forecast",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/Forecast.json"
		},		
		{
			"Name": "LeadAnalysis",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/LeadAnalysis.json"
		},
		{
			"Name": "Leaderboard",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/Leaderboard.json"
		},
		{
			"Name": "PerformanceByCustomer",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/PerformanceByCustomer.json"
		},
		{
			"Name": "PerformanceByGeography",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/PerformanceByGeography.json"
		},
		{
			"Name": "PerformanceByProduct",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/PerformanceByProduct.json"
		},
		{
			"Name": "PerformanceBySource",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/PerformanceBySource.json"
		},
		{
			"Name": "SalesAnalyticsHome",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/SalesAnalyticsHome.json"
		},
		{
			"Name": "SalesRepOverview",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/SalesRepOverview.json"
		},
		{
			"Name": "SalesRepWhitespace",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/SalesRepWhitespace.json"
		},
		{
			"Name": "SalesStageAnalysis",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/SalesStageAnalysis.json"
		},
		{
			"Name": "SummaryOfAccount",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/SummaryOfAccount.json"
		},
		{
			"Name": "SummaryOfOpportunity",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/SummaryOfOpportunity.json"
		},
		{
			"Name": "TeamBenchmark",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/TeamBenchmark.json"
		},
		{
			"Name": "TeamTrending",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/TeamTrending.json"
		},
		{
			"Name": "TeamWhitespace",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/TeamWhitespace.json"
		},
		{
			"Name": "Trending",
			"JsonUrl": "https://raw.githubusercontent.com/rodrigom-oktana-io/wave-tooling/master/Sales/dashboards/Trending.json"
		}
	]
}