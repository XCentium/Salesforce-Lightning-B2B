({
	doInit : function(component, event, helper) {
        helper.getNetworkName(component);
        helper.getNetworkId(component);
	},
    getNext: function(component,event,helper) {
        helper.showLoading(component);
        var currentPage = component.get('v.currentPage');
        component.set('v.currentPage', currentPage + 1);
        helper.getShownUsers(component);
	},
    getPrev: function(component,event,helper) {
        helper.showLoading(component);
        var currentPage = component.get('v.currentPage');
        component.set('v.currentPage', currentPage - 1);
        helper.getShownUsers(component);
	}
})