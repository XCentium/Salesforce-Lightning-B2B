({
    doInit: function(component,event,helper){
        component.set("v.pageTitle", document.title);
        component.set("v.pageUrl", window.location.href);
    },
    gplusShare: function(component,event,helper){
        var currURL = "https://plus.google.com/share?url=" + encodeURI(window.location.href);
        window.open(currURL);
    },     
    linkedinShare: function(component,event,helper){
        var currURL = "http://www.linkedin.com/shareArticle?url=" + encodeURI(window.location.href) + "&title=" + document.title;
        window.open(currURL);
    },    
    twitterShare: function(component,event,helper){
        var currURL = "http://twitter.com/share?url="+ encodeURI(window.location.href) + "&text=" + document.title;
        window.open(currURL);
    },
    
    fbShare: function(component,event,helper){
        var currURL = "http://www.facebook.com/sharer/sharer.php?u=" + encodeURI(window.location.href);
        window.open(currURL);
/*    Had to use window.open due to known issue with query string parsing with winter'16 release..    
 *    var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": currURL
        });
        urlEvent.fire();*/
    }
})