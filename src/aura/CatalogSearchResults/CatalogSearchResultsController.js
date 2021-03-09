({
	doInit : function(component, event, helper) {
        //filterTree is the JS object that will contain all our filters received from all the filter components.
        //let's initialize it. 
        var filterTree={type:'AND',rootObjectFilters:[],pbeFilters:[]};
        component.set('v.filterTree',filterTree);
        var orderBy={options:[],selectedField:'',selectedDirection:'ASC'};
        component.set('v.orderBy',orderBy);
        var itemsPerPageOptions = [{label:'5',value:'5'},{label:'10',value:'10'},{label:'20',value:'20'},
                                 {label:'50',value:'50'}];
        component.set('v.itemsPerPageOptions',itemsPerPageOptions);
        
        var pagination={pageNumber:0,pagesCount:0,startRecIndex:0,endRecIndex:0,totalRecordsCount:0};
        component.set('v.pagination',pagination);
        
        
        console.log('Initialising');
        console.log(filterTree);
        if (component.get('v.displayMode')=="tiles") helper.tilesSwitch(component,event);
        if (component.get('v.displayMode')=="table") helper.tableSwitch(component,event);
        helper.queryColumns(component,helper);
		
	},
    
    handleReceiveFilter : function(component, event, helper) {
        var filterTree=component.get('v.filterTree');
        var newTreeBranch=JSON.parse(event.getParam("JSONFilterData"));
        var insertBranchLocation=event.getParam("filterSection");
        //let's update our filterTree with the new filter.
        //Each filter branch is identified by a groupName. If filterBranch already exists, let's replace it. 
        var doNewBranchAlreadyExist=false;
        for (var i = 0; i < filterTree[insertBranchLocation].length; i++) {
            if (filterTree[insertBranchLocation][i].groupName==newTreeBranch.groupName) {
				filterTree[insertBranchLocation][i]=newTreeBranch;
                doNewBranchAlreadyExist=true;
                break;
            }
        }
        if (!doNewBranchAlreadyExist) filterTree[insertBranchLocation].push(newTreeBranch);
        component.set('v.filterTree',filterTree);
        component.set('v.filterTreeJSON',JSON.stringify(filterTree,undefined,4));
        
        if (insertBranchLocation=='pbeFilters' && newTreeBranch.groupName=='priceFilter') 
            component.set('v.isPriceFilterEnabled',newTreeBranch.enabled);
        
        helper.prepareSOQLClauses(component);
        helper.queryProducts(component,helper);
       // console.log(JSON.parse(JSON.stringify(filterTree)));

		
	},
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'main_button':
                console.log(row);
                //alert(row.Id+' '+row.ProductCode);
                var appEvent = $A.get("e.c:CatalogSelectProductEvent");
                appEvent.setParams({
                    "productId" : row.Id,
                    "sendBackData" : cmp.get('v.sendBackData')});
                appEvent.fire();
                break;
            default:
                alert('Action is not mapped');
                break;
        }
    },
    
    handleTableSwitchClick: function (cmp, event, helper) {
        
        if (!cmp.get('v.tableSelected'))
			cmp.set('v.dataTableCols',helper.restoreColumnWidths(cmp.get('v.dataTableCols')));
        helper.tableSwitch(cmp,event);
    },
    handleTilesSwitchClick: function (cmp, event, helper) {
        helper.tilesSwitch(cmp,event);
    },

    storeColumnWidths: function (cmp, event, helper) {
        helper.storeColumnWidths(event.getParam('columnWidths'));
    },
    
    clickPrevPage: function (cmp, event, helper) {
        cmp.set('v.queryOffset',cmp.get('v.pagination.prevOffset'));
		helper.queryProducts(cmp,helper);
    },
    
    clickNextPage: function (cmp, event, helper) {
        cmp.set('v.queryOffset',cmp.get('v.pagination.nextOffset'));
		helper.queryProducts(cmp,helper);
    },
    
    changeOrderByField :function (cmp,event,helper){
        cmp.set('v.queryOffset',0);
        helper.queryProducts(cmp,helper);
        
    },
    changeOrderByDirection :function (cmp,event,helper){
        var oldDirection=cmp.get('v.orderBy.selectedDirection');
        var newDirection=(oldDirection=='ASC')?'DESC':'ASC';
        cmp.set('v.orderBy.selectedDirection',newDirection);
        cmp.set('v.queryOffset',0);
        helper.queryProducts(cmp,helper);
    },
    
    changeItemsPerPageLimit :function (cmp,event,helper){
		cmp.set('v.queryOffset',0);
        helper.queryProducts(cmp,helper);
    }

})