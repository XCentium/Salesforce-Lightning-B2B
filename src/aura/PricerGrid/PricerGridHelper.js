({
    
    loadLines : function(component,helper) {
        var remoteAct = component.get("c.loadLines");
        remoteAct.setParams({
            parentObjName : component.get("v.sObjectName"),
            parentRecId : component.get("v.recordId")
            
        });


        var self = this;
        remoteAct.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                //console.log("Load Lines retrieval fired - Success");
                console.log(actionResult.getReturnValue());
                var sections = actionResult.getReturnValue();
                if (sections.length==0 ) sections=[helper.createNewSectionObject(component,helper)];
                sections[0].isFirstSection=true;
                component.set("v.sections",sections);
                var triggerSectionCalc = $A.get("e.c:PricerTriggerSectionCalculation");
                triggerSectionCalc.fire();
				helper.loadingSpinner(component,'hide');

            } else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {

                    var errors = actionResult.getError();
                    console.log("LoadLines retrieval fired - ERROR");


                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }

        });
        $A.enqueueAction(remoteAct);

    },
    saveLines : function(component,event,helper) {
        //console.log('toBeSaved:');
		//console.log(component.get("v.sections"));        
        var remoteAct = component.get("c.saveLines");
        var parentObjName = component.get("v.sObjectName");
        var sections = JSON.parse(JSON.stringify(component.get("v.sections")));
        var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var sectionsTBS = [];
        
        for (var i=0;i<sections.length;i++){
            if (sections[i].isDeleted) continue;
            var sectionTBS = {oSection:sections[i].oSection,isDeleted:sections[i].isDeleted,lines:[]};
            sectionTBS.oSection[prefix+parentObjName+'__c'] = component.get("v.recordId");
            for  (var j=0;j<sections[i].lines.length;j++){
                var line = sections[i].lines[j];
                if (line && line.oLine && (line.oLine.PricebookEntryId!=null)){
                    var quantity=Number(line.oLine.Quantity);
                    line.oLine.Quantity=isNaN(quantity)?0:quantity;
                    if (parentObjName == "Quote" || parentObjName == "Opportunity") {
                        var qDiscount=Number(line.oLine.Discount);
                        line.oLine.Discount=isNaN(qDiscount)?0:qDiscount;
                    }
                    if (parentObjName == "Order") {
                        var qDiscount=Number(line.oLine[prefix+'Discount__c']);
                        line.oLine[prefix+'Discount__c']=isNaN(qDiscount)?0:qDiscount;
                    }
                    //LET'S HELP APEX JSON PARSER TO DESERIALIZE oLine TO THE RIGHT SOBJECT 
                    if (parentObjName == "Quote") line.oLine.attributes={"type":"QuoteLineItem"};
                    if (parentObjName == "Opportunity") line.oLine.attributes={"type":"OpportunityLineItem"};
                    if (parentObjName == "Order") line.oLine.attributes={"type":"OrderItem"};
                    var lineTBS = {isDeleted:line.isDeleted,oLine:line.oLine};
                    delete lineTBS.oLine.TotalPrice;
                    delete lineTBS.oLine.PricebookEntry;
					sectionTBS.lines.push(lineTBS);                    
                }
                //sections[i].lines[j] = line;
            }
          sectionsTBS.push(sectionTBS);  
        }
        
        
        
		//console.log('sections to save');        
        //console.log(sections);
        remoteAct.setParams({
            linesJSON :  JSON.stringify(sectionsTBS),
            parentObjName : component.get("v.sObjectName"),
            parentRecId: component.get("v.recordId")
        });



        //Set up the callback
        var self = this;
        remoteAct.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
           	helper.loadingSpinner(component,'hide');
           	var statsImgSrc_save = component.get('v.orgInfo.statsUrl') +'&Action=save&ActionResult='+state+'&ParentObj='+component.get("v.sObjectName");
        	component.set('v.statsImgSrc_save',statsImgSrc_save);
            
            if (state === "SUCCESS") {
                if (component.get('v.source')!='tab') $A.get('e.force:refreshView').fire();
               // On salesforce 1, tab is refreshed when calling e.force:refreshView
                helper.showToast(component,event,$A.get("$Label.c.PricerSuccess"),$A.get("$Label.c.Pricer_Saved_Success"),'success');


            } else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {

                    var errors = actionResult.getError();
                    console.log("Save Lines retrieval fired - ERROR");
                    helper.showToast(component,event,$A.get("$Label.c.PricerError"),$A.get("$Label.c.PricerErrorWhileSaving"),'error');
                    console.log(errors);


                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            helper.showToast(component,event,'Error',errors[0].message,'error');
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }

        });
        
       helper.loadingSpinner(component,'show');
        
        $A.enqueueAction(remoteAct);

    },
    getOrgInfo : function(component,helper) {
    	 var actionFetchOrgInfo = component.get("c.fetchOrgInfo");
         actionFetchOrgInfo.setParams({
            parentObjName : component.get("v.sObjectName"),
            parentRecId: component.get("v.recordId")
         });
	        
	     actionFetchOrgInfo.setCallback(this, function(a) {
               var state = a.getState();
               if (state === "SUCCESS") {
                   var result = a.getReturnValue();
                   var namespace = {};
                   result.namespacePrefix = (result.namespace == null) ? "c" : result.namespace;
                   result.namespaceDashedPrefix = (result.namespace == null) ? "" : result.namespace+"__";
                   var statsImgSrc_load = result.statsUrl +'&Action=load&formFactor='+$A.get("$Browser.formFactor")+'&ParentObj='+component.get("v.sObjectName");
                   component.set('v.orgInfo',result);
                   component.set('v.statsImgSrc_load',statsImgSrc_load);
                   //console.log('orgInfo');
                   //console.log(result);
               }
           });
        $A.enqueueAction(actionFetchOrgInfo);  
    },    
    

    createNewSectionObject : function(component,helper) {
        var section = function () {
            this.isEditMode=false;
            this.isDeleted=false;
            this.lines=[

            ];
            this.oSection=new function(){
                var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
                var sObjectName = component.get("v.sObjectName");
                this[prefix+sObjectName+'__c'] = component.get("v.recordId");
                this.Name=$A.get("$Label.c.Pricer_NewSection");
                if (component.get('v.hideSections')) this.Name=$A.get("$Label.c.Pricer_1st_section_title_when_sections_disabled");
                
            };
            this.sequence=null;
            this.total=0;
            this.discountLevel='Green';

            console.log('section instantiated');
        };

        return new section();

    },

    showToast : function(component, event, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": title,
        "message": message,
        "type" : type,
        "duration" : 5000
    });
    toastEvent.fire();
  },
    
  getPosition : function(element) {
        var xPosition = 0;
        var yPosition = 0;
        
        while(element) {
            xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
            yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
            element = element.offsetParent;
        }
        
        return { x: xPosition, y: yPosition };
        
        
    },
    
   choosePricebook : function (component){
        $A.createComponent(
            component.get("v.orgInfo.namespacePrefix")+":PricerChoosePricebook",
            {
                "aura:id": "Pricebook Modal",
                "recordId": component.get("v.recordId"),
                "sObjectName": component.get("v.sObjectName"),
                "currentPricebookId" : component.get("v.orgInfo.recordPricebook.Id"),
            	"currentPricebookName" : component.get("v.orgInfo.recordPricebook.Name")
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var targetCmp = component.find('modalArea');
                    var body = targetCmp.get("v.body");
                    body.push(newCmp);
                    targetCmp.set("v.body", body);
                }
            }
        );         
   },
    
   loadingSpinner : function (component, action){
        var savingSpinner = component.find('savingSpinner');
        var saveBtnGrp = component.find('saveBtnGrp');
        if (savingSpinner && saveBtnGrp && action=='show') {
    	$A.util.removeClass(savingSpinner, 'slds-hide');
        $A.util.addClass(saveBtnGrp, 'slds-hide');
        }
        if (savingSpinner && saveBtnGrp && action=='hide') {
    	 $A.util.addClass(savingSpinner, 'slds-hide');
         $A.util.removeClass(saveBtnGrp, 'slds-hide');
        }   
	},
    
    openMoveLinesModal : function (component,event){
        $A.createComponent(
            component.get("v.orgInfo.namespacePrefix")+":PricerMoveLinesModal",
            {
                "aura:id": "Move Lines Modal",
                "sections": component.get("v.sections"),
                "sourceSection": event.getParam("sourceSection"),
                "scope": event.getParam("scope")
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var targetCmp = component.find('modalArea');
                    var body = targetCmp.get("v.body");
                    body.push(newCmp);
                    targetCmp.set("v.body", body);
                }
            }
        );         
   },
    
   performLinesMove : function (component,event){
       var sections = component.get("v.sections");
       var scope = event.getParam("scope");
       var sourceSectionIndex = event.getParam("sourceSection");
       var destSectionIndex = event.getParam("destSection");
       var sourceSectionLines = JSON.parse(JSON.stringify(sections[sourceSectionIndex].lines));
       var targetSectionLines = JSON.parse(JSON.stringify(sections[destSectionIndex].lines));
       var newTargetSectionLines = JSON.parse(JSON.stringify(sections[destSectionIndex].lines));
       var newSourceSectionLines = [];
       newTargetSectionLines.pop();
       for  (var i=0;i<sourceSectionLines.length-1;i++){
           if ((scope=="selection" && sourceSectionLines[i].isSelected) || scope=="allLines") {
             newTargetSectionLines.push(sourceSectionLines[i]); 
           } 
           else{
             newSourceSectionLines.push(sourceSectionLines[i]);  
           }          
       }
       newSourceSectionLines.push(sourceSectionLines[sourceSectionLines.length-1]);
       newTargetSectionLines.push(targetSectionLines[targetSectionLines.length-1]);
       sections[sourceSectionIndex].lines=newSourceSectionLines;
       sections[destSectionIndex].lines=newTargetSectionLines;
       component.set("v.sections",sections);
       //recalculate totals for all sections
       var prefix = component.get('v.orgInfo.namespacePrefix');
       var triggerSectionCalc = $A.get("e."+prefix+":PricerTriggerSectionCalculation");
       triggerSectionCalc.fire();
   },

    addProductToSection : function(component,event,productId,targetSectionIndex) {
        
        var remoteAct = component.get("c.getLineDetails");

        remoteAct.setParams({
            parentObjName : component.get("v.sObjectName"),
            parentRecId : component.get("v.recordId")   ,
            productId : productId
        });

        //Set up the callback
        var self = this;
        remoteAct.setCallback(this, function(response) { console.log('ABORTED!!');}, "ABORTED");

        remoteAct.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            
            if (state === "SUCCESS") {
               //debugger;
               var sections = component.get("v.sections"); 
               var retrievedLine= actionResult.getReturnValue();
               if (retrievedLine.oLine.PricebookEntryId){
                   targetSectionIndex = targetSectionIndex || 0;
                   if (targetSectionIndex > (sections.length-1)) return;           
                   var targetSectionLines =  JSON.parse(JSON.stringify(sections[targetSectionIndex].lines));
                   var lastLine =  targetSectionLines.pop();
                   targetSectionLines.push(retrievedLine);
                   targetSectionLines.push(lastLine);
                   sections[targetSectionIndex].lines= targetSectionLines;
                   component.set("v.sections",sections);
                   console.log(targetSectionLines);
                   var prefix = component.get('v.orgInfo.namespacePrefix');
                   var triggerSectionCalc = $A.get("e."+prefix+":PricerTriggerSectionCalculation");
                   triggerSectionCalc.fire();  
                   //Let's try to set the focus on the quantity field of the line we just added.
                   var sectionCmp = component.find("PricerSection");        
				   sectionCmp=(sectionCmp instanceof Array)?sectionCmp:[sectionCmp];
                   sectionCmp[targetSectionIndex].focusOnLastLineQtyField();
                   
               } else {
                   this.showToast(component,event,
                                   $A.get("$Label.c.PricerError"),
                                   $A.get("$Label.c.PricerNoPriceInPricebook")+' ('+retrievedLine.pricebookName+')',
                                   'error' );
                }
               
            } else if (state === "ERROR") {

                    var errors = actionResult.getError();
                    console.log("Lightning pricer error when receiving event to add product - ERROR");
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Couldn't add product: " + errors[0].message);
                            this.showToast(component,event,
                                           $A.get("$Label.c.PricerError"),
                                           "Couldn't add product: " + errors[0].message,
                                           'error' );
                        }
                    }
             } 
           if (targetSectionIndex!=null) this.scrollToSection(component,event,targetSectionIndex); 
        });
        if (productId)
        	$A.enqueueAction(remoteAct);
        //console.log('Requete ENVOYEE');
    },
   startHelpModal : function (component){
        $A.createComponent(
            component.get("v.orgInfo.namespacePrefix")+":PricerHelpModal",
            {
                "aura:id": "HelpModal",
                "packageVersion":component.get("v.orgInfo.packageVersion"),
                "appVersion":component.get("v.orgInfo.appVersion"),
                "prefix":component.get("v.orgInfo.namespaceDashedPrefix")
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var targetCmp = component.find('modalArea');
                    var body = targetCmp.get("v.body");
                    body.push(newCmp);
                    targetCmp.set("v.body", body);
                }
            }
        );         
   },
    
    showDistriModal : function (cmp,event){
        var modalDiv = cmp.find('distributeModal');
        $A.util.addClass(modalDiv, 'slds-fade-in-open');
        var greyZone = cmp.find('distributeModalGreyzone');
        $A.util.addClass(greyZone, 'slds-backdrop--open');
	},
    
    hideDistriModal : function (cmp,event){
        var modalDiv = cmp.find('distributeModal');
        $A.util.removeClass(modalDiv, 'slds-fade-in-open');
        var greyZone = cmp.find('distributeModalGreyzone');
        $A.util.removeClass(greyZone, 'slds-backdrop--open');
	},
    
   openCatalogModal : function (component,event){
       var sendBackData = {};
       sendBackData.sectionIndex = event.getParam("sectionIndex");
       sendBackData.pricerGID = component.get('v.pricerGID');
       var JSONData = JSON.stringify(sendBackData);
       var pricebookId = component.get('v.orgInfo.recordPricebook.Id');
       var pricebookName = component.get('v.orgInfo.recordPricebook.Name');
       
       var modal=component.find('CatalogModal');
       if (modal) {
           modal.show(pricebookId,JSONData);
           return;
       }
       
       $A.createComponent(
            component.get("v.orgInfo.namespacePrefix")+":PricerCatalogModal",
            {
                "aura:id": "CatalogModal",
                "customFilterFields" : component.get('v.catalogCustomFilterFields'),
                "searchResultImageField" : component.get('v.catalogSearchResultImageField'),
                "pricebookId" : pricebookId,
                "pricebookName" : pricebookName,
                "sendBackData":JSONData
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var targetCmp = component.find('modalArea');
                    var body = targetCmp.get("v.body");
                    body.push(newCmp);
                    targetCmp.set("v.body", body);
                }
            }
        );         
   },
    scrollToSection :  function (component,event,whichSection) {
        
        //console.log('whichSection='+i);
        if (!component.get('v.autoScroll')) return;
        if (whichSection==-1) return;
        var sectionCmp = component.find("PricerSection");
        sectionCmp=(sectionCmp instanceof Array)?sectionCmp:[sectionCmp];
        //totalHeight is the sum of all sections height until the one we have found. 
        var totalHeight = 0;
        for (var i = 0; i <= whichSection; i++) { 
             totalHeight += sectionCmp[i].getSectionHeight();
             //console.log('totalHeight:'+totalHeight);
        }
       	
        //DistanceFromTop is the distance between the div above the section iteration and browser top.  
        var firstSectionElem=component.find('secContainer').getElement();
        //var distanceFromTop= helper.getPosition(firstSectionElem).y;
        var distanceFromTop=window.pageYOffset + firstSectionElem.getBoundingClientRect().top
        
        //viewPortHeight is the height of the user screen.
        var viewPortHeight = document.documentElement.clientHeight;
        //targetScroll is where we want to reposition the browser scroll to make sure
        //the lookup menu is displayed on screen.
        var targetScrollDesktop=distanceFromTop+totalHeight-viewPortHeight/2-85;
        var targetScrollMobile=totalHeight-viewPortHeight/2-58;
        /*console.log('viewPortHeight:'+viewPortHeight);
        console.log('distanceFromTop:'+distanceFromTop);
        console.log('totalHeight:'+totalHeight);
        console.log('currentScroll:'+document.scrollingElement.scrollTop);
        console.log('targetScroll:'+targetScroll);*/
        //debugger;
        if ($A.get("$Browser.formFactor") =='DESKTOP') {
        document.scrollingElement.scrollTop=targetScrollDesktop;
        }    
        if ($A.get("$Browser.formFactor")!='DESKTOP') {
            var scroller = component.find('scroller');
            //scroller.getElement().scrollTop=targetScroll;
            scroller.getElement().scrollTop=targetScrollMobile;
        }        
        
    },
    navToRecord :  function (cmp) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.recordId'),
        });
        navEvt.fire();
    },
    checkIfDesktopLargeEnough : function (cmp) {
       var div1 = cmp.find('desktopSectionsContainer');
       var div2 = cmp.find('isWidthTooSmallDiv'); 
       var width1=0;
       var width2=0;  
       if (div1 && div1.getElement())
         width1=div1.getElement().clientWidth;  
        
       if (div2 && div2.getElement())
         width2=div2.getElement().clientWidth;         
        
       if (width1 >= 820 || width2 >= 820) cmp.set('v.isWidthTooSmall',false);
       else cmp.set('v.isWidthTooSmall',true);
	}
})