({
    doInit: function(component, event, helper) {

        console.log('ckz_ProductMediaTable - begin init()');

        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        component.set('v.columns', [
            {
                label: 'Id', fieldName: 'Id', type: 'text', editable: 'true', hidden: 'true'
                ,label: 'Number', fieldName: 'linkUri', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', tooltip: 'Click to view record' }, initialWidth: 100}
                ,{label: 'Enabled', fieldName: 'ccrz__Enabled__c', type: 'boolean', editable: 'true', initialWidth: 100}
                ,{label: 'Media Type', fieldName: 'ccrz__MediaType__c', type: 'text', initialWidth: 200}
                ,{label: 'Locale', fieldName: 'ccrz__Locale__c', type: 'text', initialWidth: 100, editable: 'true'}
                //,{label: 'File Path', fieldName: 'ccrz__FilePath__c', type: 'text'}
                ,{label: 'URI', fieldName: 'ccrz__URI__c', type: 'text', editable: 'true'}
                // This does not work
                //,{label: '', fieldName: 'imagePreview', type: 'text'}
                ,{ type: 'action', typeAttributes: { rowActions: actions } }

        ]);

        helper.getData(component);

    },
    handleRowAction: function (component, event, helper) {

        console.log('ckz_ProductMediaTable - begin handleRowAction()');

        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                var recordId = row.Id;
                console.log('recordId: ' + recordId);
                component.set("v.recordId", row.Id);
                component.set("v.showDialog", true);
                break;
            case 'delete':
                helper.deleteRecord(component, row);
                break;
        }

        console.log('ckz_ProductMediaTable - exit handleRowAction()');
    },
    handleReloadData: function(component, event, helper) {

        console.log('ckz_ProductMediaTable - begin handleReloadData()');

        var reloadData = component.get("v.reloadData");

        if(reloadData === true) {
            helper.getData(component);
        }

    },
    handleShowDialog: function(component, event, helper) {
        component.set("v.showDialog", true);
    },
    handleDeleteAll: function(component, event, helper) {
        console.log('inside handleDeleteAll');

        helper.deleteAll(component);

    },
    handleDeleteSelected: function(component, event, helper) {

        console.log('inside handleDeleteSelected');

        helper.deleteSelected(component);


    },
    handleUpdateRecords: function(component, event, helper) {

        console.log('inside handleUpdateRecords');

        //var draftValues = event.getParam('draftValues');
        var draftValues = component.find("mediaTable").get("v.draftValues");
        helper.updateRecs(component, draftValues);
        
    },
    waiting: function(component, event, helper) {
        helper.waiting(component);
    },
    doneWaiting: function(component, event, helper) {
        helper.doneWaiting(component);
    },
});