({ 
    doInit : function(component, event, helper) {

    },
    
   
    getTypeAheadResult : function(component, event, helper) {
        var productId = event.getParam("Id");
        var productName = event.getParam("Value");


        component.set("v.line.product.Id",productId);

        helper.updateLineWithProductDetails(component,helper);

    },
    setProductId :  function(component, event, helper){
        //console.log("Adding UpsellProduct !!");
        var params = event.getParam('arguments');
        if (params) {
            //console.log(params[0]);
            var productId = params[0];
            component.set("v.lookupProductId",productId);
        }
    },

    retrieveProductDetails : function(component, event, helper){
        var productId = component.get('v.lookupProductId');
        if (!productId) return;
        component.set("v.line.product.Id",productId);
        //console.log("Selected ProductId");
        //console.log(productId);
        if (productId){
            helper.updateLineWithProductDetails(component,helper);
        }

    },
    calcUnitPrice : function(component, event, helper){
        //console.log("Unit Price calc");
        helper.requestNewUnitPriceAndRecalculate(component,helper);
        helper.recalcLineTotal(component, helper);
   
        var priceEvent = component.getEvent("priceUpdate");
        priceEvent.fire();

    },
    calcDiscount : function(component, event, helper){
        var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var line= component.get("v.line");
        //console.log(line);
        var discount =  -((1-(line.oLine.UnitPrice/ line.oLine.PricebookEntry.UnitPrice))*100).toFixed(2);
        //console.log('calculating discount=>'+line.oLine.UnitPrice);
        //console.log('calculating discount=>'+line.oLine.PricebookEntry.UnitPrice);
        //console.log('calculating discount=>'+discount);
        line.margin = discount;
        line.totalPrice = line.oLine.Quantity*line.oLine.UnitPrice;
        
         component.set("v.line",line);
        

        var priceEvent = component.getEvent("priceUpdate");
        priceEvent.fire();

    },
    recalcBasedOnQuantity:function(component, event, helper){
     // var line= component.get("v.line");
     // var qty=line.oLine.Quantity;
      //console.log(qty);
        helper.requestNewUnitPriceAndRecalculate(component,helper);
        helper.recalcLineTotal(component, helper);
    },
    deleteLine:function(component, event, helper){
        var line= component.get("v.line");
        line.isDeleted = true;
        component.set("v.line.isDeleted",true);
        var priceEvent = component.getEvent("priceUpdate");
        priceEvent.fire();

    },
    debugLine:function(component, event, helper){
        var line= component.get("v.line");
        //console.log(line);

    },

    redirectToRec: function(component, event, helper){
      var id = component.get("v.line.oProduct.Id");
      helper.navToRecord(component,event,id);

    },
    
    focusOnQty : function(component, event, helper) {
         var field=component.find("qtyField");
         if (field!=null) setTimeout(function(){ field.focus(); }, 100);
	},
    
    fieldKeyUp : function(cmp, event, helper) {
       var keyCode = event.keyCode;
       var ctrlKey = event.ctrlKey; //true if ctrl is pressed
       if (keyCode===78 && ctrlKey) {
            //request new section if user press ctrl+n
            var newSectionEvent= cmp.getEvent("newSectionRequested");
	        newSectionEvent.fire();
            return;
        }
        if (keyCode===13) {
            //request new section if user press ctrl+n
            var newEvent= cmp.getEvent("focusOnLookupField");
	        newEvent.fire();
            return;
        }  
    } ,
    
    publicFind : function (component,event) {
        var params = event.getParam('arguments');
        if (params) {
            var toFind = params.cmp;
            if (toFind) return component.find(toFind);
        }
    },
    
    openCatalogClick : function (component,event) {
        var openCatalogEvent = component.getEvent("openCatalog");
        openCatalogEvent.setParams({
                'sectionIndex' : component.get('v.sectionIndex')
        });
        openCatalogEvent.fire();
    },

    tileTouchStart : function (cmp,event,helper) {
        var swipe = {startX: 0,startY: 0,endX: 0,endY: 0,
        minX: 30,   // min X swipe for horizontal swipe
        maxX: 30,   // max X difference for vertical swipe
        minY: 50,   // min Y swipe for vertial swipe
        maxY: 60,    // max Y difference for horizontal swipe
        direction : null                 
    	};
        
        var touch = event.touches[0]; 
        swipe.startX = touch.screenX;
        swipe.startY = touch.screenY;
        cmp.set('v.swipe',swipe);
        console.log('TouchStart');
        console.log(swipe);
    },
    
    tileTouchMove : function (cmp,event,helper) {
        
        //event.preventDefault();
        var touch = event.touches[0]; 
        if (!touch) return;
        var swipe = cmp.get('v.swipe');
        //debugger;
        
        swipe.endX = touch.screenX;
        swipe.endY = touch.screenY;
        cmp.set('v.swipe',swipe);
        console.log('TouchMove');
        console.log(swipe);
        
        var mobileTile=cmp.find('mobileTile');
        if (!mobileTile) return;
        var distanceX = Math.abs(swipe.endX - swipe.startX);
        var distanceY = Math.abs(swipe.endY - swipe.startY);
        var mobileTileWidth = mobileTile.getElement().clientWidth;
        if ((distanceX < (0.7*mobileTileWidth)) && (distanceX > distanceY) && (swipe.endX < swipe.startX ))
	        mobileTile.getElement().setAttribute("style","left:-"+distanceX+"px");
    },
    
    tileTouchEnd : function (cmp,event,helper) {
       console.log('TouchEnd');
       var mobileTile=cmp.find('mobileTile'); 
       if (!mobileTile) return; 
       var swipe = cmp.get('v.swipe'); 
       if ((Math.abs(swipe.endX - swipe.startX) > swipe.minX)
            && (Math.abs(swipe.endY - swipe.startY) < swipe.maxY))
       {
         swipe.direction = (swipe.endX > swipe.startX) ? 'right' : 'left';  
       }
        console.log('swipe direction: '+swipe.direction);
       
       if (swipe.direction==null || swipe.direction=='right'){ 
           if  (Math.abs(mobileTile.getElement().offsetLeft) > 10) cmp.set('v.protectSelect',true);
           mobileTile.getElement().setAttribute("style","left:0px");
       }     
    },
    
    onRender : function (cmp,event,helper) {
        if  ($A.get("$Browser.formFactor")!='DESKTOP'){
            var mobileTileContainer=cmp.find('mobileTileContainer');
            var mobileTile=cmp.find('mobileTile');
            if (!mobileTileContainer || !mobileTile) return;
            mobileTile=(mobileTile instanceof Array)?mobileTile[0]:mobileTile;
            mobileTileContainer=(mobileTileContainer instanceof Array)?mobileTileContainer[0]:mobileTileContainer;
            //if ( !mobileTile.getElement() || !mobileTileContainer.getElement() ) return;
            var clientHeight=mobileTile.getElement().clientHeight;
            mobileTileContainer.getElement().setAttribute("style","height:"+(clientHeight+3)+"px");
//            debugger;
        }
	},
    mobileQtyOnFocus : function (cmp,event,helper) {
            var modalDiv = cmp.find('editLineModal');
            $A.util.removeClass(modalDiv, 'slds-hide');
            $A.util.addClass(modalDiv, 'editLineModal ');
            window.scrollTo(0, 0);
		    document.body.scrollTop = 0;
        	var ModalField = cmp.find('ModalQtyField');
        	setTimeout(function(){ ModalField.focus(); }, 50);
        	
    },
    mobileDiscOnFocus : function (cmp,event,helper) {
            var modalDiv = cmp.find('editLineModal');
            $A.util.removeClass(modalDiv, 'slds-hide');
            $A.util.addClass(modalDiv, 'editLineModal ');
            window.scrollTo(0, 0);
		    document.body.scrollTop = 0;
        	var ModalField = cmp.find('ModalDiscField');
        	setTimeout(function(){ ModalField.focus(); }, 50);
        	
    },
    
    editLineContentClick: function (cmp,event,helper) {
    	    var modalDiv = cmp.find('editLineModal');
            $A.util.addClass(modalDiv, 'slds-hide');
            $A.util.removeClass(modalDiv, 'editLineModal ');
	},
    reduceQtyClick: function (cmp,event,helper) {
        helper.incrementField(cmp,'v.line.oLine.Quantity',(-1*Number(cmp.get('v.line.increment'))));
        if (cmp.get('v.line.oLine.Quantity')<0) cmp.set('v.line.oLine.Quantity',0);
        helper.requestNewUnitPriceAndRecalculate(cmp,helper);
        //let's refresh the input field to make sure that a potential invalid increment 
        //error message is cleared.
        var ModalField = cmp.find('ModalQtyField');
        ModalField.focus();ModalField.blur();
        
    },
    increaseQtyClick: function (cmp,event,helper) {
        helper.incrementField(cmp,'v.line.oLine.Quantity',Number(cmp.get('v.line.increment')));
        helper.requestNewUnitPriceAndRecalculate(cmp,helper);
        //let's refresh the input field to make sure that a potential invalid increment 
        //error message is cleared.
        var ModalField = cmp.find('ModalQtyField');
        ModalField.focus();ModalField.blur();
    },
    reduceDiscClick: function (cmp,event,helper) {
        helper.incrementField(cmp,'v.line.discount',-0.01);
        helper.requestNewUnitPriceAndRecalculate(cmp,helper);
    },
    increaseDiscClick: function (cmp,event,helper) {
        helper.incrementField(cmp,'v.line.discount',0.01);
        helper.requestNewUnitPriceAndRecalculate(cmp,helper);
    },
    selectLine: function (cmp,event,helper) {
        if (cmp.get('v.protectSelect')) { cmp.set('v.protectSelect',false); } 
        else { cmp.set('v.line.isSelected',!cmp.get('v.line.isSelected')); }
    }
    
    

})