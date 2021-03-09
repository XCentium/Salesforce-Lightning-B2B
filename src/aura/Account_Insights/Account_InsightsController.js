({
    doInit : function(component, event, helper) {
        var id = component.get("v.recordId");

        console.log('ID: ' + id);
        var action = component.get("c.findAll");
        action.setParams({
            "accId": id
          });

        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log("controller results: " , result);

            console.log('CHECK annual_revenue: ' , !result[0].InsightGroup__r.Annual_Revenue_Big__c);
            console.log('CHECK employees: ' , !result[0].InsightGroup__r.Employees_Big__c);
            console.log('CHECK net_income: ' , !result[0].InsightGroup__r.Net_Income__c);

            if (result[0].InsightGroup__r.Annual_Revenue_Big__c) {
              component.set("v.annual_revenue", true);
              console.log('annual_revenue Not Null');
            } else {
              component.set("v.annual_revenue", false);
              console.log('annual_revenue Null');
            }
            if (result[0].InsightGroup__r.Employees_Big__c) {
              component.set("v.employees", true);
              console.log('employees Not Null');
            } else {
              component.set("v.employees", false);
              console.log('employees Null');
            }
            if (result[0].InsightGroup__r.Net_Income__c) {
              component.set("v.net_income", true);
              console.log('net_income Not Null');
            } else {
              component.set("v.net_income", false);
              console.log('net_income Null');
            }

            var rand = Math.floor(Math.random() * 9 + 2);
            component.set("v.randomInt", rand);

            component.set("v.articles", result);

            setTimeout(function() {
                $A.run(function() {
                  console.log('in run');
                    $('.articleBody').each( function(i,v) {
                      $(this).find('p').eq(0).css('font-weight', '900');
                    });

                    $('.carousel').slick({
                        dots: true,
                        infinite: false,
                        speed: 300,
                        slidesToShow: 4,
                        slidesToScroll: 1,
                        variableWidth: true
                      });

                });
            }, 2000);
            //prevent default "pull-to-refresh" behavior when running in S1
            $('.carousel').on("touchmove", function() {
                return false;
            });
        }, 'SUCCESS');
        $A.enqueueAction(action);
    },
    goNextSlide : function(cmp, event) {
      console.log('next');
      $('.slick-next').click();
    },
    goPrevSlide : function(cmp, event) {
      console.log('prev');
      $('.slick-prev').click();
    }

})