({
    doInit : function(component, event, helper) {
        
        var gid = component.getGlobalId();
        component.set("v.pricerGID", "Pricer"+gid.replace(":", "").replace(";", ""));  
        
        var sObjectName = component.get('v.sObjectName');
        
        //THIS A BUG FIX FOR COMMUNITIES
        if (sObjectName==null) {
            var objCode = component.get('v.recordId').substring(0,3);
            if (objCode == '006') sObjectName ='Opportunity';
            if (objCode == '0Q0') sObjectName ='Quote';
            if (objCode == '801') sObjectName ='Order';
            component.set('v.sObjectName',sObjectName);
        }
        //END OF BUG FIX FOR COMMUNITIES
        
        if ((sObjectName !='Quote') && (sObjectName !='Opportunity') && (sObjectName !='Order')) return;
        helper.loadingSpinner(component,'show');
        
		helper.getOrgInfo(component,helper);
			
        component.set("v.sections",null);
        component.set("v.totalPrice",0);
        component.set("v.totalDiscount",0);
        component.set("v.globalMarginPercent",0);

        //destroy catalog modal if it exists
        var modal=component.find('CatalogModal');
        if (modal) modal.destroy();
        
        //handle display
        var panelCount = 3;
        if (component.get('v.hideDiscounts')) {
            panelCount--
        };
       	if (component.get('v.hideSections')) {
            panelCount--
        };
        if (panelCount==2) component.set('v.panelClass','flexDisp slds-size--1-of-2 slds-medium-size--3-of-6 slds-large-size--6-of-12');
        if (panelCount==1) {
            component.set('v.panelClass','flexDisp slds-size--3-of-3 slds-medium-size--6-of-6 slds-large-size--12-of-12');
            component.set('v.summaryPanelGridLineClass','slds-size--1-of-4 slds-medium-size--3-of-12 slds-large-size--3-of-12'); 
        }    
        
        
        
        
        var greenLimit = Number(component.get('v.greenMarginAbove'));
		var orangeLimit = Number(component.get('v.orangeMarginAbove'));
        if (!isNaN(greenLimit) && !isNaN(orangeLimit)){
            if (orangeLimit<=greenLimit){
              var marginLimits = {};
              marginLimits.green=greenLimit/100; 
              marginLimits.orange=orangeLimit/100;  
              component.set('v.marginLimits',marginLimits);   
            }
        }
        

        var recordId = component.get("v.recordId");
        if (recordId){
            helper.loadLines(component,helper);
           // console.log(component.get("v.sections"));

        }

        if ($A.get("$Browser.formFactor")=='DESKTOP') {
            window.addEventListener('resize', $A.getCallback(function(){
            	helper.checkIfDesktopLargeEnough(component); 
      		}));   
        }


    },
    save :    function(component, event, helper) {

        helper.saveLines(component, event, helper);

    },

    addNewSection :    function(component, event, helper) {
        console.log('Adding new section');
        if (component.get('v.hideSections')) return;
        var sections = component.get("v.sections");
        var newSection = helper.createNewSectionObject(component,helper);
        newSection.isEditMode=true;
        sections.push(newSection);

        
        var prefix = component.get('v.orgInfo.namespacePrefix');
        var sectionUpdateEvent = $A.get("e."+prefix+":PricerSectionUpdated");
        sectionUpdateEvent.fire();

        component.set("v.sections",sections);
        component.set("v.focusAndScrollToNewSecAfterRender",true);
        
        
        		
    },
    
    onRender: function(cmp, event, helper) {
        //debugger;
        if (cmp.get('v.focusAndScrollToNewSecAfterRender')){
            var sectionCmp = cmp.find("PricerSection"); 
            if (sectionCmp == null) return;
            else sectionCmp=(sectionCmp instanceof Array)?sectionCmp:[sectionCmp];
            var lastSectionCmp=sectionCmp[sectionCmp.length-1];
            var sectionField = lastSectionCmp.publicFind('sectionField');
            if (sectionField) sectionField.focus();
            
            var cmpEvent = cmp.getEvent("askPricerToScroll");
            cmpEvent.setParams({
                "whichSection" : sectionCmp.length-1 });
            cmpEvent.fire();
            
	       	cmp.set('v.focusAndScrollToNewSecAfterRender',false);
        }
        
        if (cmp.get('v.isFirstRendering') && $A.get("$Browser.formFactor")=='DESKTOP')
           helper.checkIfDesktopLargeEnough(cmp); 
        
        if (cmp.get('v.isFirstRendering')) cmp.set('v.isFirstRendering',false)
        
       
    },
    
    scopeSelectorChange: function(cmp, evt) { 
        var choice = evt.getSource().get("v.text");
        cmp.set("v.discountScope",choice);
        
    },

    refreshTotals :    function(component, event, helper) {
        var sections=component.get("v.sections");
        var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var totalListPrice=0;
        var totalDiscountPrice=0;
        var totalDiscountPriceOnLinesWithProductCost=0;
        var displaySections=[];
        var totalDiscount = 0;
        var totalCost = 0;
        var globalMarginPercent = 0;
        var total=0;
        var discount=0;
        var greenFlag =false;
        var orangeFlag = false;
        var redFlag = false;

        for (var i=0;i<sections.length;i++){
            if (sections[i].isDeleted) continue;
            total += Number(sections[i].total);

        }

       
        for (var i=0;i<sections.length;i++){
            if (sections[i].isDeleted) continue;
            for  (var j=0;j<sections[i].lines.length;j++){
                var line = sections[i].lines[j];
                if (line.isDeleted) continue ;
                if (line && line.oLine && line.oLine.PricebookEntryId){
                    totalListPrice += line.oLine.PricebookEntry.UnitPrice* line.oLine.Quantity;
                    totalDiscountPrice += +Number(line.totalPrice);
                    if (!isNaN(line.productCost)){
                      totalDiscountPriceOnLinesWithProductCost += Number(line.totalPrice);
                      totalCost += Number(line.productCost) * Number(line.oLine.Quantity);
                    }
                }
            }
        }
        //debugger;
        totalDiscount = (1-(totalDiscountPrice/totalListPrice)).toFixed(4);
        globalMarginPercent = ((totalDiscountPriceOnLinesWithProductCost/totalCost)-1).toFixed(4);

        //console.log("Total Discount=>"+totalDiscount);

        if (isNaN(totalDiscount)) totalDiscount = 0;
        if (isNaN(globalMarginPercent)) globalMarginPercent = 0;
        component.set("v.totalPrice",total);
        component.set("v.totalDiscount",totalDiscount);
        component.set("v.globalMarginPercent",globalMarginPercent);
    },
    applyDiscount :    function(component, event, helper) {
        var parentObjName = component.get("v.sObjectName");
        var prefix = component.get('v.orgInfo.namespacePrefix');
        var dPrefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var sections=component.get("v.sections");
        var discountL1 =  Number(component.get("v.l1ToApply"));
        var discountScope = component.get("v.discountScope");
       
        if (isNaN(Number(discountL1))) return;

        for (var i=0;i<sections.length;i++){
            if (sections[i].isDeleted) continue;
            for  (var j=0;j<sections[i].lines.length;j++){
                var line = sections[i].lines[j];
                if (line.isDeleted) continue ;
                if (discountScope=='Selection' && !line.isSelected) continue ;
                if (line && line.oLine && line.oLine.PricebookEntryId){
                    if (!isNaN(discountL1)) {
                      line.oLine.UnitPrice = line.oLine.UnitPrice*(1-discountL1);
                      line.totalPrice = line.oLine.UnitPrice*line.oLine.Quantity;
                      if (!isNaN(line.oLine.UnitPrice) && !isNaN(line.productCost) && line.productCost!=0)  
                      	line.margin = (line.oLine.UnitPrice/line.productCost)-1;
                      else 
                        line.margin = null;  
                      if (isNaN(line.discount)) line.discount=0;
                      //console.log('Calculated manual discount : 1-((1-'+discountL1+')*(1-'+line.discount+'))');
                      line.discount = 1-((1-discountL1)*(1-line.discount));
                      //line.oLine.Discount = ((1-(line.oLine.UnitPrice/line.oLine.PricebookEntry.UnitPrice))*100).toFixed(2);
                      if (parentObjName == "Quote" || parentObjName == "Opportunity")
                       	 line.oLine.Discount = (line.discount*100).toFixed(2);
                      if (parentObjName == "Order")  
						 line.oLine[dPrefix+'Discount__c'] = (line.discount*100).toFixed(2);
                    }



                }
            }
        }

        component.set("v.sections",sections);
        var triggerSectionCalc = $A.get("e."+prefix+":PricerTriggerSectionCalculation");
        triggerSectionCalc.fire();

        if ($A.get("$Browser.formFactor")!='DESKTOP') helper.hideDistriModal(component);

    },
    reachQuoteTarget: function(component,event,helper){
        //console.log('Trying to reach a TOTAL');
        var parentObjName = component.get("v.sObjectName");
        var prefix = component.get('v.orgInfo.namespacePrefix');
        var dPrefix = component.get('v.orgInfo.namespaceDashedPrefix');
        //debugger;
        var discountScope = component.get("v.discountScope");
        var totalQuoteTarget = component.get("v.dealAmountTarget");
        if (totalQuoteTarget == null) {return;}
        else {totalQuoteTarget = Number(totalQuoteTarget);}
        var currentTotalPrice = 0;
        var totalListPrice = 0;
        var reachedPrice = 0;
        
        if (isNaN(Number(totalQuoteTarget))) return;

        var sections=component.get("v.sections");


        for (var i=0;i<sections.length;i++){
            if (sections[i].isDeleted) continue;
            for  (var j=0;j<sections[i].lines.length;j++){
                var line = sections[i].lines[j];
                //console.log(line);
                if (line.isDeleted) continue ;
                if (discountScope=='Selection' && !line.isSelected) continue ;
                if (line && line.oLine && line.oLine.PricebookEntryId){
                    currentTotalPrice += Number(line.totalPrice);
                    totalListPrice +=Number(line.oLine.PricebookEntry.UnitPrice)*Number(line.oLine.Quantity);
                }
            }
        }
        
        //console.log('total quote target: '+totalQuoteTarget);
        //console.log('current Total Price: '+currentTotalPrice);
        var discountToApply = 0;
        if (currentTotalPrice!=0) discountToApply=  1-(totalQuoteTarget/currentTotalPrice);


        //console.log('Global discount to distribute on lines : '+discountToApply);
		//debugger;
        for (var i=0;i<sections.length;i++){
            if (sections[i].isDeleted) continue;
            for  (var j=0;j<sections[i].lines.length;j++){
                var line = sections[i].lines[j];
                if (line.isDeleted ) continue ;
                if (discountScope=='Selection' && !line.isSelected) continue ;
                if (line && line.oLine && line.oLine.PricebookEntryId){

                  line.oLine.UnitPrice = line.oLine.UnitPrice*(1-discountToApply);
                  line.totalPrice = line.oLine.UnitPrice*line.oLine.Quantity;
                  if (!isNaN(line.oLine.UnitPrice) && !isNaN(line.productCost) && line.productCost!=0)
                  	line.margin = (line.oLine.UnitPrice/line.productCost)-1;
                  else 
                  	line.margin = null;    
                  if (isNaN(line.discount)) line.discount=0;
                  line.discount = 1-((1-discountToApply)*(1-line.discount));
			      if (parentObjName == "Quote" || parentObjName == "Opportunity")
                       	 line.oLine.Discount = (line.discount*100).toFixed(2);
                  if (parentObjName == "Order")  
						 line.oLine[dPrefix+'Discount__c'] = (line.discount*100).toFixed(2);

                }
            }
        }
        
        component.set("v.sections",sections);
        var triggerSectionCalc = $A.get("e."+prefix+":PricerTriggerSectionCalculation");
        triggerSectionCalc.fire();
		
        if ($A.get("$Browser.formFactor")!='DESKTOP') helper.hideDistriModal(component);

    },
    scrollToLookup: function(component,event,helper){
        //This function reposition the browser scroll in the page 
        //to make sure that the product lookup menu is fully visible for the user
        // without requiring him to scroll. 
        //debugger;
        if (!component.get('v.autoScroll')) return;
        //console.log('Scroll event received');
        //debugger;
        var lookupGid=event.getParam("lookupGid");
        var sectionParam=event.getParam("whichSection");
        var whichSection=-1;
        
        if (sectionParam!=null && sectionParam !=-1) whichSection=sectionParam;
        var sectionCmp = component.find("PricerSection");
        
        //We need to find in which section is the lookup component requesting that we scroll to it.
        if (lookupGid != null){ 
            if (sectionCmp == null) return;
            else sectionCmp=(sectionCmp instanceof Array)?sectionCmp:[sectionCmp];
            for (var i = 0; i < sectionCmp.length; i++) { 
                var lineCmp = sectionCmp[i].publicFind("sectionLine");
               if (lineCmp == null) continue;
               else lineCmp = (lineCmp instanceof Array) ? lineCmp:[lineCmp];
               var lastLineCmp=lineCmp[lineCmp.length-1];
               var lookupCmp=lastLineCmp.publicFind("PricerLookupFieldCmp");
               if (lookupCmp==null) continue;
               if  (lookupCmp.getCmpId()==lookupGid) {
                 whichSection=i;
                 break;
               }
            }
        }    
        
        
        helper.scrollToSection(component,event,whichSection);
    },
   
   BtnGrpSelect : function (cmp, event,helper) {
        var value = event.getParam("value");
       	if (value=="choosePricebook") helper.choosePricebook(cmp);
        if (value=="reloadPricer") cmp.getEvent("reloadPricer").fire();
        if (value=="help") helper.startHelpModal(cmp);
        if (value=="distriDiscount") helper.showDistriModal(cmp);
        if (value=="navToRecord") helper.navToRecord(cmp);
        if (value=="quit") $A.get('e.force:refreshView').fire();

   },
    
   hideDistriModal : function (cmp, event,helper){
      helper.hideDistriModal(cmp);  
   },
    
   moveLines : function (cmp,event,helper) {
       if (event.getParam("action")=="openModal") helper.openMoveLinesModal(cmp,event);
       if (event.getParam("action")=="confirm") helper.performLinesMove(cmp,event);
   },
   handleAddLineEvent : function (component,event,helper) {   
       var productId=event.getParam("productId");
       var targetSectionIndex = event.getParam("sectionIndex");
       helper.addProductToSection(component,event,productId,targetSectionIndex);
   },
   openCatalog : function (cmp,event,helper) { 
       helper.openCatalogModal(cmp,event);
   },
   handleCatalogSelect : function (component,event,helper) {       
//       alert("ProductId: "+ event.getParam("productId")+"\n sendBackData: "+event.getParam("sendBackData"));
//	   debugger;
	   var sendBackData = JSON.parse(event.getParam("sendBackData"));
       var productId = event.getParam("productId");
       
       if (sendBackData.pricerGID != component.get('v.pricerGID')) return;
       if (!productId || productId.length<15) return;
       if (sendBackData.sectionIndex==null) sendBackData.sectionIndex=0;
       
       var modal=component.find('CatalogModal');
       if (modal) modal.hide();
  
       helper.addProductToSection(component,event,productId,sendBackData.sectionIndex);
       
       
   },
   handleMobileBackClick : function (component,event,helper) { 
      $A.get("e.force:closeQuickAction").fire(); 
   }  

})