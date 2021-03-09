({
    loadConfig: function (component) {
        var self = this;

        try
        {
            var configName = null;
            var queryStr = component.get('v.query');

            // handle bulkConfig setting: VF page or passed in SAQL
            if (component.get('v.bulkConfig') != null)
            {
                configName = component.get('v.bulkConfig');
            }
            else
            {
            var lineList = queryStr.split(/\n/);

            for (var i = 0; i < lineList.length; i++) {
                console.log('line=' + lineList[i]);
                if (lineList[i].includes('--bulkconfig=')) {
                    configName = lineList[i].substring(lineList[i].indexOf('--bulkconfig=') + 13).trim();
                    break;
                }
            }
            }

            console.log('configName=' + configName);
            if (configName == null || configName.length == 0)
            {
                throw new Error('No configuration name was provided for the \'--bulkconfig=\' comment in the SAQL code or custom VisualForce page.');
            }
            
            component.set('v.configName', configName);
            self.getBulkEditConfig(component, configName);
        } catch (err) {
            console.log(err.message);
            self.handleErrors(component, err.message);
        }
    },
    getBulkEditConfig: function (component, configName) {
        var self = this;
        try
        {
            var action = component.get("c.getBulkEditConfig");
            action.setParams({"configName": configName});

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var config = a.getReturnValue();
                    //console.log('config=' + JSON.stringify(config));
                    component.set('v.idField', config.SAQL_ID_Field__c);
                    component.set('v.editFields', config.Bulk_Edit_Fields__c);
                    component.set('v.showBulkEdit', config.Show_Bulk_Edit__c);
                    component.set('v.showTasks', config.Show_Task__c);
                    component.set('v.showChatter', config.Show_Chatter__c);
                    component.set('v.showData', config.Show_Data__c);
                    component.set('v.showSAQL', config.Show_SAQL__c);

                    if (config.Title__c != null && config.Title__c.length > 0)
                    {
                        component.set('v.title', config.Title__c);
                    }
                    else
                    {
                        component.set('v.title', 'Bulk Action Editor (' + component.get('v.version') + ')');
                        
                    }

                    if (config.Header_Icon__c != null && config.Header_Icon__c.length > 0)
                    {
                        if (config.Header_Icon__c.startsWith('/'))
                        {
                            component.set('v.customHeaderIcon', true);
                        }
                        component.set('v.headerIcon', config.Header_Icon__c);
                    }
                    else
                    {
                        component.set('v.headerIcon', 'standard:custom');
                    }

                    if (config.Tab_Background_Color__c != null && config.Tab_Background_Color__c.length > 0)
                    {
                        component.set('v.tabBackgroundColor', config.Tab_Background_Color__c);
                    }
                    else
                    {
                        component.set('v.tabBackgroundColor', '#8099ae');
                    }

                    self.executeSAQLQuery(component);
                } else {
                    self.handleErrors(component, a.getError());
                }

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    executeSAQLQuery: function (component) {
        var self = this;

        try
        {
            self.showSpinner(component);

            var action = component.get("c.executeSAQLQuery");
            action.setParams({
                "query": component.get('v.query')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    //console.log('response=' + a.getReturnValue());

                    var idField = component.get("v.idField");
                    var idFieldFound = false;
                    var sobjectPrefixFound = false;
                    var queryResp = JSON.parse(a.getReturnValue());

                    // parse to create columns object
                    var columns = [];
                    var metadata = queryResp.results.metadata[0].lineage.projections;
                    for (var i = 0; i < metadata.length; i++) {
                        var field = metadata[i].field.id;
                        
                        var pos = field.indexOf(".");
                        if (pos != -1)
                        {
                          field = field.substring(pos+1);  
                        }
                        //console.log('field=' + field);

                        if (idFieldFound === false && field === idField) {
                            idFieldFound = true;
                        }

                        var type = metadata[i].field.type;
                        if (type === 'numeric') {
                            type = 'number';
                        } else {
                            type = 'text';
                        }
                        columns.push({'label': field, 'fieldName': field, 'type': type});
                    }

                    columns.push({'label': ' ', 'fieldName': ' ', 'type': 'text', 'initialWidth': '10'});

                    if (idFieldFound === false) {
                        self.hideSpinner(component);
                        component.set('v.errorMsg', 'Object ID field [' + idField + '] not found in SAQL query. Please validate your PSBulkActionConfig setting.');
                    } else {

                        // parse to create data object
                        var data = [];
                        var ids = [];
                        var records = queryResp.results.records;
                        for (i = 0; i < records.length; i++) {
                            var rec = {};

                            for (var j = 0; j < columns.length; j++) {
                                rec[columns[j].fieldName] = records[i][columns[j].fieldName];

                                if (columns[j].fieldName === idField) {
                                    var val = records[i][columns[j].fieldName];
                                    if (!ids.includes(val)) ids.push(val);

                                    if (sobjectPrefixFound === false) {
                                        sobjectPrefixFound = true;
                                        component.set('v.sobjectPrefix', val.substring(0, 3));
                                    }

                                }
                            }

                            data.push(rec);
                        }

                        component.set('v.columns', columns);
                        component.set('v.data', data);
                        component.set('v.ids', ids);

                        self.getFieldDefs(component);
                    }

                    component.set('v.queryResp', JSON.parse(a.getReturnValue()));
                } else {
                    self.handleErrors(component, a.getError());
                }

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    getFieldDefs: function (component) {
        var self = this;
        try
        {
            var action = component.get("c.getFieldDefs");
            action.setParams({
                "configName": component.get('v.configName'),
                "sobjectPrefix": component.get('v.sobjectPrefix'),
                "fields": component.get('v.editFields')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    console.log('sobjectDef=' + a.getReturnValue());
                    component.set('v.sobjectDef', JSON.parse(a.getReturnValue()));
                } else {
                    self.handleErrors(component, a.getError());
                }
                self.hideSpinner(component);

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    updateRecords: function (component) {
        var self = this;
        try {
            self.showSpinner(component);

            component.set('v.errorMsg', null);

            var action = component.get("c.updateRecords");
            action.setParams({
                "sobjectDef": JSON.stringify(component.get('v.sobjectDef')),
                "ids": component.get('v.ids')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var ids = component.get('v.ids');
                    self.hideSpinner(component);
                    siiimpleToast.success(ids.length + ' records have been updated!');
                    //alert(ids.length + ' records have been updated!');
                } else {
                    self.handleErrors(component, a.getError());
                }

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    createTasks: function (component) {
        var self = this;

        try {
            self.showSpinner(component);

            component.set('v.errorMsg', null);

            var action = component.get("c.createTasks");

            action.setParams({
                "subject": component.get('v.taskSubject'),
                "description": component.get('v.taskDescription'),
                "type": component.get('v.taskType'),
                "ownerId": component.get('v.taskOwnerId'),
                "dueDate": component.get('v.taskDueDate'),
                "status": component.get('v.taskStatus'),
                "priority": component.get('v.taskPriority'),
                "sobjectName": component
                    .get('v.sobjectDef')
                    .objectName,
                "recordOwner": component.get('v.taskRecordOwner'),
                "ids": component.get('v.ids')
            });

            console.log('params=' + JSON.stringify(action.getParams()));

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var ids = component.get('v.ids');
                    self.hideSpinner(component);
                    siiimpleToast.success(ids.length + ' tasks have been created!');
                } else {
                    self.handleErrors(component, a.getError());
                }

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }

    },
    postChatter: function (component) {
        var self = this;
        try {
            self.showSpinner(component);

            component.set('v.errorMsg', null);

            var action = component.get("c.postChatter");
            action.setParams({
                "sobjectName": component
                    .get('v.sobjectDef')
                    .objectName,
                "users": component.get('v.chatterUsers'),
                "mentionOwners": component.get('v.chatterMentionOwner'),
                "groups": component.get('v.chatterGroups'),
                "post": component.get('v.chatterText'),
                "ids": component.get('v.ids')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    self.hideSpinner(component);
                    var ids = component.get('v.ids');
                    siiimpleToast.success(ids.length + ' chatter posts have been created!');
                } else {
                    self.hideSpinner(component);
                    self.handleErrors(component, a.getError());
                }

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    showSpinner: function (component) {
        component.set("v.IsSpinner", true);
    },
    hideSpinner: function (component) {
        component.set("v.IsSpinner", false);
    },
    handleErrors: function (component, errors) {
        var errorMsg;
        this.hideSpinner(component);

        console.log('errors=' + JSON.stringify(errors));
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            errorMsg = errors[0].message;
        } else {
            errorMsg = errors;
        }
        component.set("v.errorMsg", errorMsg);

    },
    clearBulkEdit: function (component) {
        this.showSpinner(component);

        var sobjectDef = component.get('v.sobjectDef');
        if (sobjectDef) {
            for (var i = 0; i < sobjectDef.fields.length; i++) {
                if (sobjectDef.fields[i].ftype == 'reference') {
                    sobjectDef.fields[i].value = '';
                } else {
                    sobjectDef.fields[i].value = null;
                }
            }
        }
        component.set('v.sobjectDef', sobjectDef);

        component.set('v.errorMsg', null);

        this.hideSpinner(component);
    },
    clearTasksEdit: function (component) {
        this.showSpinner(component);

        component.set('v.errorMsg', null);
        component.set('v.taskSubject', null);
        component.set('v.taskDescription', null);
        component.set('v.taskType', null);
        component.set('v.taskOwnerId', null);
        component.set('v.taskDueDate', null);
        component.set('v.taskStatus', null);
        component.set('v.taskPriority', null);
        component.set('v.taskRecordOwner', null);

        this.hideSpinner(component);
    },
    clearChatterEdit: function (component) {
        this.showSpinner(component);

        component.set('v.errorMsg', null);
        component.set('v.chatterUsers', null);
        component.set('v.chatterGroups', null);
        component.set('v.chatterText', null);
        component.set('v.chatterMentionOwner', null);

        this.hideSpinner(component);
    }
})