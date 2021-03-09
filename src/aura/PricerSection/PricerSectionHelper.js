({
    addLine : function(component,helper){
        //console.log('Adding Line to section');

        var section = component.get("v.section");
        var lines= section.lines;

        var emptyLine= helper.createNewLineObject(component,helper);
        var newLineList=[];
      	newLineList.push(emptyLine);

        lines= lines.concat(newLineList);
        //console.log(lines);

        component.set("v.section.lines",lines);

        //if we are on mobile we will ask the pricer to scroll so the line we added is visible.
        if ($A.get("$Browser.formFactor")!='DESKTOP') {
            var cmpEvent = component.getEvent("askPricerToScroll");
            cmpEvent.setParams({
                "whichSection" : component.get('v.sectionIndex') });
            setTimeout(function(){ cmpEvent.fire(); }, 100);  
            //Timer is to allow rerendering before scrolling. 
            //Could be done in cleaner way in a refactoring.  
        }    
        
    }  ,

    recalcSectionTotals : function(component, event, helper) {
        var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var section = component.get("v.section");
        var lines=section.lines;
        var maxDiscountLevel='Green';
        var greenFlag =false;
        var orangeFlag = false;
        var redFlag = false;

        var total=0;
        for (var i=0;i<lines.length;i++){
            if (lines[i].isDeleted) continue ;
            var line = lines[i];
            if (line.oLine && !isNaN(line.totalPrice)) total+=Number(line.totalPrice);
        }


        section.discountLevel = (redFlag?'Red':(orangeFlag?'Orange':'Green'));

        //console.log('Calculating section total=>'+total);
        section.total= total;
        component.set("v.section",section);

        
        var sectionUpdateEvent = $A.get("e.c:PricerSectionUpdated");
        sectionUpdateEvent.fire();



    },
    createNewLineObject : function(component,helper) {
        var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var line = function () {
            this.oLine=new function(){
                this.QuoteId= '';
                this.PriceBookEntryId= '';
                this.PriceBookEntry = {};
                this.UnitPrice = 0;
                this.discount = +0;
              
                this.Discount = +0;
                this.Quantity=0;
         
                this.totalPrice = 0;


            };
            this.quantity=0;
            this.initialApexQueryDone=false;
            this.oProduct={};
            this.oProduct[prefix+'Product_cost__c']=0;
            this.selected=false;
            this.product=new function(){
                this.Id='';
                this.Name='';
                this[prefix+'Product_cost__c']=0;
            };

            
        };
        return new line();
    },
    showPopupHelper: function(component, componentId, className){
        var modal = component.find(componentId);
        $A.util.removeClass(modal, className+'hide');
        $A.util.addClass(modal, className+'open');
    },
    hideCrossSell: function(component, event, helper){
         //called on clicking your button
        //run your form render code after that, run the following lines
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
        this.focusOnLastLineQtyField(component);  
    },

    hidePopupHelper: function(component, componentId, className){
        var modal = component.find(componentId);
        $A.util.addClass(modal, className+'hide');
        $A.util.removeClass(modal, className+'open');
       // component.set("v.body", "");
    },
    
    focusOnLastLineQtyField : function (component) {
        var sectionLine = component.find('sectionLine');
        var lastLine;
        if (sectionLine != null){
          var lastLineIndex=sectionLine.length - 2;
          if (lastLineIndex < 0) return;  
          lastLine= (sectionLine instanceof Array) ? sectionLine[lastLineIndex] : sectionLine;
          lastLine.focusOnQtyField();  
        }
    },
    
    setFocusOnPricerLookupField: function(component){
        //let's set the focus on the PricerLookupField
        var lineCmp = component.find("sectionLine");
        if (lineCmp == null) return;
        else lineCmp = (lineCmp instanceof Array) ? lineCmp:[lineCmp];
        var lastLineCmp=lineCmp[lineCmp.length-1];
        var lookupCmp=lastLineCmp.publicFind("PricerLookupFieldCmp");
        if (lookupCmp==null) return;
        lookupCmp.focus();
    },
    
    showToast : function(component, event, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": title,
        "message": message,
        "type" : type,
        "duration" : 10000
    });
    toastEvent.fire();
  },
    
  getSectionWidth : function(component) {
 		var section = component.find('section');
        if (section!=null) return section.getElement().clientWidth;
        else return 0;
  }  
    
    
})