({
   init : function(component, event, helper) {
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        component.set('v.today', monthDigit + "/" + today.getDate() + "/" + today.getFullYear() );
       
       var startdate = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        component.set('v.startdate', monthDigit + "/" + today.getDate() + "/" + (today.getFullYear()+ 1));
    }
})