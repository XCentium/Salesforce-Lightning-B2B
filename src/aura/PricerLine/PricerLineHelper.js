({
    updateLineWithProductDetails : function(component,helper) {
        var remoteAct = component.get("c.getLineDetails");

        remoteAct.setParams({
            parentObjName : component.get("v.sObjectName"),
            parentRecId : component.get("v.recordId")   ,
            productId : component.get("v.line.product.Id")
        });



        //Set up the callback
        var self = this;
        remoteAct.setCallback(this, function(response) { console.log('ABORTED!!');}, "ABORTED");

        remoteAct.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
               // console.log("line details retrieval fired - Success");
               // console.log(actionResult.getReturnValue());
                var currentLine = component.get("v.line");
                var newLine = actionResult.getReturnValue();

			//We cannot replace the  line because it is used in the aura iteration and 
            // the aura framework doesn't such a replace. 
            // A workaround is to replace all child properties
                for (var property in newLine) {
                    if (newLine.hasOwnProperty(property)) {
                        currentLine[property]=newLine[property];
                    }
                }    
                    
                component.set("v.line",currentLine);

                helper.recalcLineTotal(component,helper);

                if (currentLine.oLine.PricebookEntryId != null){

                  var productRetrieveSuccess = component.getEvent("productAddedToLine");
                  productRetrieveSuccess.fire();


                } else {
                  helper.showToast(component,event,
                                   $A.get("$Label.c.PricerError"),
                                   $A.get("$Label.c.PricerNoPriceInPricebook")+' ('+newLine.pricebookName+')',
                                   'error' );
                }

                // console.log(newLine.upsellProductList.length);
                if (newLine.upsellProductList.length>0){
                  //  console.log('UpSell Products available -- DISPLAY THEM!');
                    var upsellProductAvailable = component.getEvent("upsellProductAvailable");
                    upsellProductAvailable.setParams({
                        productList: newLine.upsellProductList
                    });
                    upsellProductAvailable.fire();
                } else {
                  //set focus on qty field now that the line is ready
                  var field=component.find("qtyField");
                  if (field!=null) setTimeout(function(){ field.focus(); }, 100);  
                }


            } else if (state === "INCOMPLETE") {
               // console.log('Requete INCOMPLETE');
            }
             else if (state === "INCOMPLETE") {
               // console.log('Requete INCOMPLETE');
            }
                else if (state === "ERROR") {

                    var errors = actionResult.getError();
                    console.log("line details retrieval fired - ERROR");


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
        //console.log('Requete ENVOYEE');
    },
	
    requestNewUnitPriceAndRecalculate:function(component, helper){
      var prefix = component.get('v.orgInfo.namespaceDashedPrefix');  
      var line= component.get("v.line");
      var qty=line.oLine.Quantity;
      //var productId = component.get("v.line.product.Id");
      var productId = component.get("v.line.oProduct.Id");
      var listPrice = line.oLine.PricebookEntry.UnitPrice;
      var discount = Number(line.discount);
      discount = (discount || 0) ;

      var action = component.get("c.queryNewUnitPrice");
      action.setParams({ productId : productId,
                         parentObjName : component.get("v.sObjectName"),
                         parentRecId : component.get("v.recordId"),
                         pricebookId: line.pricebookId,
                         qty : qty,
                         listPrice : listPrice});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var result = response.getReturnValue();
              var returnPrice = result.UnitPrice;

              //console.log("UnitPrice returned by server: " + returnPrice);
              component.set("v.line.oLine.UnitPrice",returnPrice*(1-discount));
              component.set("v.line.UPQR",result);
              
             helper.recalcLineMargin(component,helper);
              helper.recalcLineTotal(component, helper);
              helper.recalcLineDiscount(component, helper);
             
          }

      });
      $A.enqueueAction(action);


    },


    recalcLineTotal:function(component, helper){
        var prefix = component.get('v.orgInfo.namespaceDashedPrefix');  
        var line= component.get("v.line");
        
        line.totalPrice = (Number(line.oLine.Quantity)*Number(line.oLine.UnitPrice)).toFixed(2);
        
        component.set("v.line",line);

        var priceEvent = component.getEvent("priceUpdate");
        priceEvent.fire();
    },
	
    recalcLineMargin:function(component, helper){
		var prefix = component.get('v.orgInfo.namespaceDashedPrefix');  
        
        var ProductCost=Number(component.get("v.line.productCost"));
        var UnitPrice=Number(component.get("v.line.oLine.UnitPrice"));
        if (isNaN(ProductCost) || isNaN(UnitPrice) || (ProductCost==0) || (UnitPrice==0)) {
            component.set("v.line.margin",null);
            return;
        }
            
        var Margin=(((UnitPrice/ProductCost)-1)).toFixed(4);
        component.set("v.line.margin",Margin);
        //console.log('Margin: '+Margin);

    },


    recalcLineDiscount:function(component, helper){

      //  var ListPrice=Number(component.get("v.line.oLine.PricebookEntry.UnitPrice"));
      //  var UnitPrice=Number(component.get("v.line.oLine.UnitPrice"));
      //  var Discount
      //  if (ListPrice!=0) Discount=((1-(UnitPrice/ListPrice))*100).toFixed(2);
      //  else Discount=0;
      //  component.set("v.line.oLine.Discount",Discount);
      //  console.log('Discount: '+Discount);
		var prefix = component.get('v.orgInfo.namespaceDashedPrefix');
        var parentObjName = component.get('v.sObjectName');
        var Discount = Number(component.get("v.line.discount"));
        if (isNaN(Discount)) Discount=0;
        Discount = ( Discount*100).toFixed(2);
        if (parentObjName=="Quote" || parentObjName=="Opportunity")
        	component.set("v.line.oLine.Discount",Discount);
        if (parentObjName=="Order")
            component.set("v.line.oLine."+prefix+"Discount__c",Discount);
       // console.log('Discount: '+Discount);

    },


    showToast : function(component, event, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": title,
        "message": message,
        "type" : type,
        "duration" : 8000
    });
    toastEvent.fire();
  },
  navToRecord : function (component, event, id) {
      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
        "recordId": id,
        //"slideDevName": "related"
      });
      navEvt.fire();
  },
  incrementField : function (cmp, field, increment) {
      var value = cmp.get(field);
      var saneValue = Number(value);
      if (isNaN(saneValue)) saneValue=0;
      saneValue+=increment;
      if (Number.isInteger(increment)){
          var mod = saneValue % increment;
          if (mod!=0) saneValue-=mod;
      }
      cmp.set(field,saneValue);
  }  
    

})