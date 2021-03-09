({
    doInit : function(component, event, helper) 
    {
        window.addEventListener('message', $A.getCallback(function(postMessageEvent){
            var receivedSlot = postMessageEvent.data;
            //alert(receivedSlot);
            if (receivedSlot == 'getjson')
            {
                var theJSON = component.get('v.strJSON');
                if (component.find('theIframe') != null)
                {
                    var theiFrame = component.find('theIframe').getElement();
                    //alert(theJSON);
                    theiFrame.contentWindow.postMessage(theJSON, '*');
                }   
            }
            else if (receivedSlot.split(",").length == 2)
            {
                //Parse the chosen slot
                var outputID = receivedSlot.split(",")[0];
                var d = new Date(0); // The 0 there is the key, which sets the date to the epoch
                d.setMilliseconds(receivedSlot.split(",")[1]);
                //Parse as date
                //alert(d.toGMTString());
                component.set('v.idOutput', outputID);
                component.set('v.dtOutput', d);
            }
        }), false);
        
        //Load the date
        var lstDates = component.get('v.lstDateTimes');
        if (lstDates != null && lstDates.length > 0)
        {
            var theJSON = '[';
            //Use the List View to load the data
            for (var i=0; i < lstDates.length; i++) 
            {
                var newD = new Date(lstDates[i]); // months are 0-based
                //alert(newD);
                if (!theJSON.includes(newD.getTime()))
                {
                    theJSON += '{"id":"' + newD.getTime() + '","datetime":' + newD.getTime() + ',"displaytext":""},';
                }
            }
            var pos = theJSON.lastIndexOf(',');
            theJSON = theJSON.substring(0,pos) + '' + theJSON.substring(pos+1);
            theJSON += ']';
            
            //Set the component
            component.set('v.strJSON', theJSON);
            
            //alert(theJSON);
            //Post Message
            //var theiFrame = component.find('theIframe').getElement();
            //theiFrame.contentWindow.postMessage(theJSON, '*');
        }
    }
})