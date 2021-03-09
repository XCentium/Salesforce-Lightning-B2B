({
	  tabOneAction: function(component, event, helper) {
		var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
          
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
          
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
          
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
          
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');

		$A.util.addClass(tab1, 'slds-active');
		$A.util.addClass(showTab1, 'slds-show');
		$A.util.removeClass(showTab1, 'slds-hide');

		$A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
          
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
          
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide');
          
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide');
          
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
          
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
      },
    tabTwoAction: function(component, event, helper) {

		var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
		
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');

        $A.util.addClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-hide');
		$A.util.addClass(showTab2, 'slds-show');
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide');
        
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
        
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
	}, 
    
    tabThreeAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.addClass(tab3, 'slds-active');
        $A.util.removeClass(showTab3, 'slds-hide'); 
		$A.util.addClass(showTab3, 'slds-show');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide');
        
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
        
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
    },
    tabFourAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.addClass(tab4, 'slds-active');
        $A.util.removeClass(showTab4, 'slds-hide'); 
		$A.util.addClass(showTab4, 'slds-show');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide');
        
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
        
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
    },
    tabFiveAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.addClass(tab5, 'slds-active');
        $A.util.removeClass(showTab5, 'slds-hide'); 
		$A.util.addClass(showTab5, 'slds-show');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide');
        
		$A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 

		$A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide');         
    },
    tabSixAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.addClass(tab6, 'slds-active');
        $A.util.removeClass(showTab6, 'slds-hide'); 
		$A.util.addClass(showTab6, 'slds-show');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide'); 
        
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
        
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
    },
    tabSevenAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide'); 
        
        $A.util.addClass(tab7, 'slds-active');
        $A.util.removeClass(showTab7, 'slds-hide'); 
		$A.util.addClass(showTab7, 'slds-show');
        
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
        
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
    },
    tabEightAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide'); 
        
        $A.util.addClass(tab8, 'slds-active');
        $A.util.removeClass(showTab8, 'slds-hide'); 
		$A.util.addClass(showTab8, 'slds-show');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide'); 
        
        $A.util.removeClass(tab9, 'slds-active');
		$A.util.removeClass(showTab9, 'slds-show');
		$A.util.addClass(showTab9, 'slds-hide'); 
    },
    tabNineAction : function(component,event,helper){
        var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
        var tab3 = component.find('t3');
		var showTab3 = component.find('tab3');
          
        var tab4 = component.find('t4');
		var showTab4 = component.find('tab4');
          
        var tab5 = component.find('t5');
		var showTab5 = component.find('tab5');
        
        var tab6 = component.find('t6');
		var showTab6 = component.find('tab6');
        
        var tab7 = component.find('t7');
		var showTab7 = component.find('tab7');
        
        var tab8 = component.find('t8');
		var showTab8 = component.find('tab8');
        
        var tab9 = component.find('t9');
		var showTab9 = component.find('tab9');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');  
        
        $A.util.removeClass(tab3, 'slds-active');
		$A.util.removeClass(showTab3, 'slds-show');
		$A.util.addClass(showTab3, 'slds-hide');
        
        $A.util.removeClass(tab4, 'slds-active');
		$A.util.removeClass(showTab4, 'slds-show');
		$A.util.addClass(showTab4, 'slds-hide');
        
        $A.util.removeClass(tab5, 'slds-active');
		$A.util.removeClass(showTab5, 'slds-show');
		$A.util.addClass(showTab5, 'slds-hide');
        
        $A.util.removeClass(tab6, 'slds-active');
		$A.util.removeClass(showTab6, 'slds-show');
		$A.util.addClass(showTab6, 'slds-hide'); 
        
        $A.util.addClass(tab9, 'slds-active');
        $A.util.removeClass(showTab9, 'slds-hide'); 
		$A.util.addClass(showTab9, 'slds-show');
        
        $A.util.removeClass(tab7, 'slds-active');
		$A.util.removeClass(showTab7, 'slds-show');
		$A.util.addClass(showTab7, 'slds-hide'); 
        
        $A.util.removeClass(tab8, 'slds-active');
		$A.util.removeClass(showTab8, 'slds-show');
		$A.util.addClass(showTab8, 'slds-hide'); 
    },
})