({
	doInit : function(component, event, helper) {
		component.getEvent('getSettings').setParams({
			callback: function(data){
				helper.setup_flowItems(component, event, data);
			}
		}).fire();
	},


	urlSelected : function(component, event, helper) {
		var selectedMenuItemValue = event.getParam("value");
		sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: selectedMenuItemValue }, callback: function() {
			console.log('popped something open');
		}});
	}
})