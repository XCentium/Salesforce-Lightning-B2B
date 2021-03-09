({
    doInit : function(component, event, helper) {
        var section = component.get("v.section");

        helper.addLine(component,helper);
        component.set('v.calculateWidth',true);
        
    },
    displayCrossSell :  function(component, event, helper){
        var upsellProductList = event.getParam("productList")
        component.set("v.upsellLines",upsellProductList);
       // console.log('Displaying elements');
       // console.log(upsellProductList);

        helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.showPopupHelper(component,'backdrop','slds-backdrop--');
       	var field=component.find("CrossSellCancelButton");
        setTimeout(function(){ field.focus(); }, 200);
        
    },
    hideCrossSell :  function(component, event, helper){
       helper.hideCrossSell(component, event, helper);
       helper.focusOnLastLineQtyField(component);   
     
        
    },

    addUpsellProductsToLines: function(component, event, helper){
        var upsellProducts = component.get("v.upsellLines");



        for (var i=0;i<upsellProducts.length;i++){
            var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
            var section = component.get("v.section")
            var lines = section.lines;
            var newLine = lines[lines.length-1];
            //We cannot replace the section line because it is used in the aura iteration and 
            // the aura framework doesn't such a replace. 
            // A workaround is to replace all child properties
            if (upsellProducts[i].oLine.PricebookEntryId!=null){
                for (var property in upsellProducts[i]) {
                    if (upsellProducts[i].hasOwnProperty(property)) {
                        newLine[property]=upsellProducts[i][property];
                    }
                } 
                component.set("v.section",section);
                //console.log(section);
                helper.addLine(component,helper);
            } else {
                helper.showToast(component,event,
                                 $A.get("$Label.c.PricerError"),
                                 'Product recommendation was not added because it has no price in current quote pricebook.',
                                 'error' );
            }

        }

        helper.recalcSectionTotals(component, event, helper);



        helper.hideCrossSell(component,event,helper);

    },

    toggleSectionEditMode : function(component, event, helper) {
        var section = component.get("v.section");
        //Edit mode can only be exited by pressing the enter key

        if (event.type=='keyup' && event.which != 13 && section.isEditMode) return; 
        
        section.isEditMode= !section.isEditMode;



        component.set("v.section",section);
        //console.log(component.get("v.section"));

        if (section.isEditMode==false) {
            var sectionUpdateEvent = $A.get("e.c:PricerSectionUpdated");
            sectionUpdateEvent.fire();
            helper.setFocusOnPricerLookupField(component);
            

        } else {
            //let's set the focus on the section input field so we don't have to click twice
            var field=component.find("sectionField");
            setTimeout(function(){ field.focus(); }, 200);
        }




    },
    afterProductInsert : function(component, event, helper) {
        helper.addLine(component,helper);
        helper.recalcSectionTotals(component,event,helper);
        //
        //var requestNewLine = component.getEvent("newLineRequested");
    },
    
    recalcSectionTotals : function(component, event, helper) {
        helper.recalcSectionTotals(component, event, helper);


    },
    
	getSectionHeight : function(component, event, helper) {
        if (component.get('v.section.isDeleted')) return 0;
        var section = component.find('section');
        if (section!=null) return section.getElement().clientHeight;
        else return 0;
    },
    
    publicFind : function (component,event) {
        var params = event.getParam('arguments');
        if (params) {
            var toFind = params.cmp;
            if (toFind) return component.find(toFind);
        }
    },
    
    
    sectionTitleFieldBlur : function(component, event, helper) {
        var isSectionEditMode = component.get("v.section.isEditMode");
        if (isSectionEditMode) {
          var sectionUpdateEvent = $A.get("e.c:PricerSectionUpdated");
          sectionUpdateEvent.fire();
          component.set("v.section.isEditMode",false);
        }    
    },
    
    focusOnLookupField : function (component,event,helper) {
       helper.setFocusOnPricerLookupField(component);
    },
    onRender : function (component,event,helper) {
        if (component.get('v.calculateWidth')) {
            component.set('v.width',helper.getSectionWidth(component)); 
            component.set('v.calculateWidth',false)
        }
       
    },
    focusOnLastLineQtyFieldMethod : function (cmp, event,helper) {
      helper.focusOnLastLineQtyField(cmp);
    },
    sectionMenuSelect : function (cmp, event,helper) {
        var value = event.getParam("value");
        if (value=="newSection") 
            cmp.getEvent("newSectionRequested").fire();
        if (value=="deleteSection") {
            cmp.set('v.section.isDeleted',true);
            $A.get("e.c:PricerSectionUpdated").fire(); 
        } 
        if (value=="moveLines") {
            var scope="allLines";
            var lines = cmp.get("v.section.lines");
            for (var i=0;i<lines.length;i++){
                if (lines[i].isSelected) {
                    scope="selection";
                	break;
                }                          
            }    
            var moveLines = cmp.getEvent("moveLines");
            moveLines.setParams({
                'sourceSection' : cmp.get('v.sectionIndex'),
                'scope' : scope,
                'action' : 'openModal'
            });
            moveLines.fire();
        }

   } 

})