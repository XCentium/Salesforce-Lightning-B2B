({
  loadGoogleAnalytics: function (component, event, helper) {
    (function (i, s, o, g, r, a, m) {
      i["GoogleAnalyticsObject"] = r;
      (i[r] =
        i[r] ||
        function () {
          (i[r].q = i[r].q || []).push(arguments);
        }),
        (i[r].l = 1 * new Date());
      (a = s.createElement(o)), (m = s.getElementsByTagName(o)[0]);
      a.async = 1;
      a.src = g;
      m.parentNode.insertBefore(a, m);
    })(window, document, "script", "/resource/ga", "ga");

    let page = component.get("v.page");
    console.log("in ga", ga, page);
    ga("create", "UA-46606102-1", "auto");
    ga("send", {
      hitType: "event",
      eventCategory: "pageview",
      eventAction: "view",
      eventLabel: page
    });
    //ga("send", "pageview", page);
  }
});