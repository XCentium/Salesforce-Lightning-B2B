({
    afterRender : function(component, helper) {
        var afterRender = this.superAfterRender();
        helper.onResize(component, helper);
        window.addEventListener('resize', $A.getCallback(function() {
            helper.onResize(component, helper);
        }));
        return afterRender;
    }
})