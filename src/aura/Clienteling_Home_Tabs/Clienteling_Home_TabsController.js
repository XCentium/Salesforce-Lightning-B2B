({
	  tabOneAction: function(component, event, helper) {
		var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');

		$A.util.addClass(tab1, 'slds-active');
		$A.util.addClass(showTab1, 'slds-show');
		$A.util.removeClass(showTab1, 'slds-hide');

		$A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
      },
    tabTwoAction: function(component, event, helper) {

		var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');

		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');

        $A.util.addClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-hide');
		$A.util.addClass(showTab2, 'slds-show');
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
	}, 
    
    tabThreeAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');

        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.addClass(tab3, 'slds-active');
        $A.util.removeClass(showTab3, 'slds-hide'); 
		$A.util.addClass(showTab3, 'slds-show');
        
    },
})