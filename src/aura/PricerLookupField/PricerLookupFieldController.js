({
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        helper.doSearch(cmp,event);
        
        if ($A.get("$Browser.formFactor")!='DESKTOP') {
            var mainDiv = cmp.find('mainDiv');
            $A.util.addClass(mainDiv, 'lookupModal');
            var lookupList= cmp.find('lookuplist');
            $A.util.addClass(lookupList, 'staticForNonDesktop');
            window.scrollTo(0, 0);
		    document.body.scrollTop = 0;
        }
    },

    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
    
    itemOver: function(cmp, event, helper) {
        helper.handleMouseOver(cmp, event);
    },

    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp);
    },

    autoClear: function(cmp, event, helper) {
       if (cmp.get("v.selectedItemId")==""){
        helper.clearSelection(cmp);
        }
    },

    createRecord: function(cmp, event, helper) {
        helper.createNewRecord(cmp);
    },

    initLookup: function(cmp, event, helper) {
        helper.handleInitialSelection(cmp);
        cmp.set('v.selector',-1);
    },

    inputBlur: function(cmp, event, helper) {
        
        var lookupDiv = cmp.find('lookup-div');
        $A.util.removeClass(lookupDiv, 'slds-is-open');
        
        if ($A.get("$Browser.formFactor")!='DESKTOP') {
            var mainDiv = cmp.find('mainDiv');
	        $A.util.removeClass(mainDiv, 'lookupModal');  
        }
        cmp.set('v.selector',-1);
           
        
    },
    
    getCmpId: function(cmp, event, helper) {
        
        return cmp.getGlobalId();
        
    },
    
    focus: function(cmp, event, helper) {
        var targetField=cmp.find('lookup');
        if (targetField!=null) {
            setTimeout(function(){ targetField.focus(); }, 200);
        }
    },    
    
    onRender: function(cmp, event, helper) {
        if ((cmp.get('v.fireScrollEventAfterRendering')) && ($A.get("$Browser.formFactor")=='DESKTOP')){
            var cmpEvent = cmp.getEvent("askPricerToScroll");
            cmpEvent.setParams({
                "lookupGid" : cmp.getGlobalId() });
            cmpEvent.fire();
            //console.log('askPricerToScroll event fired with gid: '+cmp.getGlobalId());
            cmp.set('v.fireScrollEventAfterRendering',false);
        }
        if ($A.get("$Browser.formFactor")!='DESKTOP') {
            window.scrollTo(0, 0);
		    document.body.scrollTop = 0;
        } 
        
    }

})