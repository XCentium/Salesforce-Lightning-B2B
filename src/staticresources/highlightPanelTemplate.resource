var templates = [
	{
		"name": "contact_name",
        "objects": [
            "Contact",
            "Lead",
            "Account"
        ],
		"heading": "Name",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "Name",
                    "isImage": true,
                    "value": "/resource/panelIcons/profile-img.jpg"
				},
				{
					"label": "Membership",
                    "isImage": true,
					"value": "/resource/panelIcons/membership-1.svg",
                    "colour": "salmon",
                    "class": "svg"
				}
			]
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Email address",
					"value": "test@test.demo"
				},
				{
					"label": "Phone no.",
					"value": "123456789"
				},
				{
					"label": "Member no.",
					"value": "123545623"
				}
			]
		}
	},
    {
		"name": "order",
        "objects": [
            "Account", 
            "Contact"
        ],
		"heading": "Current Order",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "Stage",
                    "isImage": true,
					"value": "/resource/panelIcons/stage-1.svg",
                    "class": "svg"
				},
				{
					"label": "Items",
                    "isImage": false,
					"value": "3"
				}
			]
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Order No.",
					"value": "565621215"
				},
				{
					"label": "Date",
					"value": "2016-01-01"
				},
				{
					"label": "Open cases",
					"value": "3"
				}
			]
		}
	},
    {
		"name": "activities_summary",
        "objects": [
            "Account", 
            "Contact",
            "Lead"
        ],
		"heading": "Activities Summary",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "NPS",
                    "isImage": true,
					"value": "/resource/panelIcons/nps-1.svg"
				},
				{
					"label": "Spend",
                    "isImage": false,
					"value": "6.1K"
				}
			]
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Last Active (days)",
					"value": "7"
				},
				{
					"label": "Total Orders",
					"value": "3"
				},
				{
					"label": "Total Cases",
					"value": "3"
				}
			]
		}
	},
    {
		"name": "subscription",
        "objects": [
            "Account", 
            "Contact"
        ],
		"heading": "Subscription",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "Plan",
                    "isImage": true,
					"value": "/resource/panelIcons/plan.svg"
				},
				{
					"label": "Spend",
                    "isImage": false,
					"value": "6.1K"
				}
			]
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Start date",
					"value": "2016-05-01"
				},
				{
					"label": "End date",
					"value": "2017-04-30"
				},
				{
					"label": "Open cases",
					"value": "3"
				}
			]
		}
    },
    {
		"name": "tokens",
        "objects": [
            "Account", 
            "Contact"
        ],
		"heading": "Tokens",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "Utilisation",
                    "isImage": false,
					"value": "89%"
				},
				{
					"label": "Remaining",
                    "isImage": false,
					"value": "2"
				}
			]
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Total tokens",
					"value": "3"
				},
				{
					"label": "Expiry date",
					"value": "2017-04-30"
				}
			]
		}
    },
    {
		"name": "services",
        "objects": [
            "Account", 
            "Contact"
        ],
		"heading": "Tokens",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "Service level",
                    "isImage": true,
					"value": "/resource/panelIcons/tokens.svg"
				},
				{
					"label": "Open cases",
                    "isImage": false,
					"value": "3"
				}
			]
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Total cases",
					"value": "3"
				},
				{
					"label": "Renewal risk score",
					"value": "26"
				}
			]
		}
    },
    {
		"name": "chart-on-right",
        "objects": [
            "Account",
            "Contact",
            "Lead"
        ],
		"heading": "Services",
		"leftPanel": 
		{
			"type": "icons",
			"fields": 
			[
				{
					"label": "Service level",
                    "isImage": true,
					"value": "/resource/panelIcons/tokens.svg"
				},
				{
					"label": "Open cases",
                    "isImage": false,
					"value": "3"
				}
			]
		},
		"rightPanel": {
			"type": "chart",
            "value": 50,
            "chart": "circular",
            "label": "Resolved",
            "max" : 100,
		}
    },
    {
		"name": "chart-on-left",
        "objects": [
            "Account",
            "Contact",
            "Lead"
        ],
		"heading": "Services",
		"leftPanel": 
		{
			"type": "chart",
            "value": 50,
            "chart": "circular",
            "label": "Resolved",
            "max" : 100,
		},
		"rightPanel": {
			"type": "list",
			"fields": [
				{
					"label": "Start date",
					"value": "2016-05-01"
				},
				{
					"label": "End date",
					"value": "2017-04-30"
				},
				{
					"label": "Open cases",
					"value": "3"
				}
			]
		}
    },
    {
		"name": "trends",
        "objects": [
            "Account",
            "Contact",
            "Lead"
        ],
		"heading": "Trends",
		"leftPanel": 
		{
			"type": "chart",
            "value": 80,
            "chart": "gauge",
            "label": "Revenue",
            "max" : 100,
		},
		"rightPanel": {
			"type": "chart",
            "value": 50,
            "chart": "circular",
            "label": "Revenue",
            "max" : 100,
		}
    }
];