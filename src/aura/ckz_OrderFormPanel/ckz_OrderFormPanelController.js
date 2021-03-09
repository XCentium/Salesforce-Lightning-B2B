/**
 * Created by msobczak on 1/8/2019.
 */
({
    doInit: function(component, event, helper) {

        console.log('ckz_OrderFormPanel - begin init()');

        var recordId = component.get('v.recordId');
        console.log('recordId: ' + recordId);

        helper.getInfo(component);

    },
    renderPanel: function(component, event, helper) {
        var params = event.getParams();
        helper.renderPanel(component, params);
    },
})