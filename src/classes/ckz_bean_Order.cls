/**
 * Created by brandon.rogers on 4/22/19.
 */

global with sharing class ckz_bean_Order implements Comparable {
    public String sfid { get; set; }
    public String orderId { get; set; }
    public String deliveryDateLong { get; set; }
    public String deliveryDateMonth { get; set; }
    public String deliveryDateDay { get; set; }
    public Date deliveryDate { get; set; }
    public List<ckz_bean_OrderItem> orderItems { get; set; }

    public ckz_bean_Order() {
    }

    public ckz_bean_Order(String deliveryDateLong, String deliveryDateMonth, String deliveryDateDay, DateTime deliveryDate, List<ckz_bean_OrderItem> items) {
        this.deliveryDateLong = deliveryDateLong;
        this.deliveryDateMonth = deliveryDateMonth;
        this.deliveryDateDay = deliveryDateDay;
        this.deliveryDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day());
        this.orderItems = items;
    }

    global Integer compareTo(Object other) {
        Date otherDOJ = other != null ? ((ckz_bean_Order) other).deliveryDate : System.today();
        return otherDOJ.daysBetween(this.deliveryDate);
    }
}