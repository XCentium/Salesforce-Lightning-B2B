({
    afterRender: function (component, helper) {
        var afterRend = this.superAfterRender();
        
        helper.addListeners(component);
        return afterRend;
    }
})