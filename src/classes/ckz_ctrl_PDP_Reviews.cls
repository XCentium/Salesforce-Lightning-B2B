/**
 * Created by brandon.rogers on 4/11/19.
 *
 * Controller to fetch and create CC Review objects related to a sku. To be used on the PDP by default.
 */

global with sharing class ckz_ctrl_PDP_Reviews {
    global String SKU { get; set; }
    global String emptyStr { get {return '';} set; }
    global static String REVIEW_LIST = 'reviews';
    global String extendedProdJSON { get; set; }

    global ckz_ctrl_PDP_Reviews() {
        ccrz.ccLog.log('ckz_ctrl_PDP_Reviews');

        SKU = ApexPages.currentPage().getParameters().get('sku');
        //reviewList = [select ccrz__Product__c,ccrz__Rating__c,ccrz__RatingCode__c,ccrz__ReviewDate__c,ccrz__ReviewId__c,ccrz__Status__c,ccrz__Subject__c,ccrz__User__c,ccrz__UserReview__c from ccrz__E_Review__c where ccrz__Status__c = 'Accepted' and ccrz__Product__r.ccrz__SKU__c =:SKU];
        //if(reviewList != null && reviewList.size() >0){

        // for(cc_bean_review item:reviewList){
        //    cc_bean_review reviewBean = new cc_bean_review();
        //    reviewBean.userReview = item.ccrz__UserReview__c;
        //    reviews.add(reviewBean);
        // }
        //}
        try {
            ccrz__E_Product__c product = [
                    SELECT Id,
                            ccrz__NumberOfReviews__c,
                            ccrz__LongDesc__c,
                            ccrz__AverageRating__c
                    FROM ccrz__E_Product__c
                    WHERE ccrz__SKU__c = :SKU
                    LIMIT 1
            ];
            final Map<String, Object> customProdData = new Map<String, Object>{
                    'avgRating' => product.ccrz__AverageRating__c,
                    'NumberOfReviews' => product.ccrz__NumberOfReviews__c,
                    'LongDesc' => product.ccrz__LongDesc__c
            };
            extendedProdJSON = JSON.serialize(new Map<String, Object>{
                    'extProdData' => customProdData
            });
        } catch (Exception e) {
            extendedProdJSON = '';
        }

        ccrz.ccLog.log('ckz_ctrl_PDP_Reviews:extendedProdJSON: ' + extendedProdJSON);
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult fetchReviews(ccrz.cc_RemoteActionContext ctx, String sku) {
        ccrz.ccLog.log('ckz_ctrl_PDP_Reviews:fetchReviews');
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.inputContext = ctx;
        result.success = false;
        List<cc_bean_review> reviewBeanList = new List<cc_bean_review>();
        try {
            List<ccrz__E_Review__c> reviewList = [
                    select ccrz__Product__c,
                            ccrz__Rating__c,
                            ccrz__RatingCode__c,
                            ccrz__ReviewDate__c,
                            ccrz__ReviewId__c,
                            ccrz__Status__c,
                            ccrz__Subject__c,
                            ccrz__User__c,
                            ccrz__User__r.FirstName,
                            ccrz__User__r.LastName,
                            ccrz__UserReview__c
                    from ccrz__E_Review__c
                    where ccrz__Status__c = 'Accepted' and ccrz__Product__r.ccrz__SKU__c = :SKU
            ];

            ccrz.ccLog.log('ckz_ctrl_PDP_Reviews:fetchReviews:reviewList.size: ' + reviewList.size());

            if (reviewList != null && reviewList.size() > 0) {
                for (ccrz__E_Review__c item : reviewList) {
                    cc_bean_review reviewBean = new cc_bean_review();
                    reviewBean.userReview = item.ccrz__UserReview__c;
                    reviewBean.subject = item.ccrz__Subject__c;
                    reviewBean.userName = item.ccrz__User__r.FirstName + ' ' + item.ccrz__User__r.LastName;
                    reviewBean.reviewDate = item.ccrz__ReviewDate__c.format();
                    reviewBean.rating = item.ccrz__Rating__c;
                    reviewBean.diffRating = 5 - item.ccrz__Rating__c;
                    reviewBeanList.add(reviewBean);
                }
            }
        } catch (Exception e) {
            result.data = new List<cc_bean_review>();
            result.success = false;
        } finally {
            ccrz.ccLog.close(result);
        }

        //result.data = reviewBeanList;
        result.data = new Map<String, Object>{
                REVIEW_LIST => reviewBeanList
        };
        result.success = true;
        ccrz.ccLog.log(LoggingLevel.INFO, 'ckz_ctrl_PDP_Reviews:result.data=', result.data);
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveReview(ccrz.cc_RemoteActionContext ctx, String sku, String subject, String reviewText, String rating) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.inputContext = ctx;
        result.success = false;
        try {
            System.debug(LoggingLevel.INFO, 'ckz_ctrl_PDP_Reviews:ccrz.cc_CallContext.currUserId=' + ccrz.cc_CallContext.currUserId);
            if (String.isNotEmpty(sku)) {
                ccrz__E_Product__c prod = [select id from ccrz__E_Product__c where ccrz__SKU__c = :sku limit 1];
                ccrz__E_Review__c review = new ccrz__E_Review__c();
                review.ccrz__Product__c = prod.Id;
                review.ccrz__Status__c = 'New';
                review.ccrz__Subject__c = subject;
                review.ccrz__UserReview__c = reviewText;
                review.ccrz__User__c = ccrz.cc_CallContext.currUserId;
                review.ccrz__RatingCode__c = rating;
                insert review;
                result.success = true;
            }

        } catch (Exception e) {
            ccrz.ccLog.log('ckz_ctrl_PDP_Reviews:Error Saving = ' + e.getStackTraceString());
            System.debug(LoggingLevel.INFO, 'ckz_ctrl_PDP_Reviews:Error=' + e.getStackTraceString());
        } finally {
            ccrz.ccLog.close(result);
        }

        return result;
    }

    public class cc_bean_review {
        public string userReview { get; set; }
        public string subject { get; set; }
        public string reviewId { get; set; }
        public String reviewDate { get; set; }
        public double rating { get; set; }
        public double helpfulCount { get; set; }
        public double numberOfViewers { get; set; }
        public DateTime createdDate { get; set; }
        public DateTime lastModifiedDate { get; set; }
        public string productId { get; set; }
        public string userName { get; set; }
        public double diffRating { get; set; }

        public cc_bean_Review() {
            diffRating = 0;
        }
    }
}