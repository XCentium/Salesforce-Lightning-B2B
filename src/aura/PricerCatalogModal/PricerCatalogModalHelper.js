({
	helperMethod : function() {
		
	},
    hideModal: function(component, event){
        this.toggleDisplay(component,'hide', 'modaldialog', 'slds-fade-in-');
        this.toggleDisplay(component, 'hide' ,'backdrop', 'slds-backdrop--');
    },
    
    showModal: function(component, event){
        this.toggleDisplay(component,'show', 'modaldialog', 'slds-fade-in-');
        this.toggleDisplay(component, 'show' ,'backdrop', 'slds-backdrop--');
    },

    toggleDisplay: function(component, action ,componentId, className){
        var modal = component.find(componentId);
        if (action == 'hide') {
            $A.util.addClass(modal, className+'hide');
            $A.util.removeClass(modal, className+'open');
        }
        if (action == 'show') {
            $A.util.removeClass(modal, className+'hide');
            $A.util.addClass(modal, className+'open');
        }
    }
})