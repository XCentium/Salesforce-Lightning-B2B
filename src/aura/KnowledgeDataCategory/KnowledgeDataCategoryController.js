({
    getDataCategories : function(component, event, helper){
    	var action = component.get("c.getDataCategories_ct");
        $A.enqueueAction(action);

		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.data_category_records", response.getReturnValue());
           }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
	},
    toggleSubcategories : function(component, event, helper){
        var clicked_elem = event.srcElement || event.target;
        helper.toggleSubcategories(clicked_elem, helper);
        helper.hideOtherSubcategories(clicked_elem, helper);
    },
    showCategoryArticles : function(component, event, helper) {
        var clicked_elem = event.srcElement || event.target;
        var category_api_name = clicked_elem.dataset.categoryApiName;
        var subcategory_api_name = clicked_elem.dataset.subcategoryApiName;

        if(subcategory_api_name === 'none'){
	        category_api_name = '';
    	    subcategory_api_name = '';
            helper.hideCurrentItem(clicked_elem, helper);
        }else{
            helper.showCurrentItem(clicked_elem, helper); //set top category name to chosen category
        }
        helper.hideAllSubcategories();
        $A.getEvt("c:KnowledgeDataCategoryEvent").setParams({
            data_category: helper.getSelectedDataCategories(helper)
        }).fire();

    }
})