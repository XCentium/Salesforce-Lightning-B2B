/**
 * Created by brandon.rogers on 4/22/19.
 */

global with sharing class ckz_bean_OrderBuilderWrapper {
    public List<ckz_bean_OrderBuilderMap> orderBuilderMap { get; set; }
    public List<ckz_bean_Order> orders { get; set; }

    public ckz_bean_OrderBuilderWrapper() {
    }

    public ckz_bean_OrderBuilderWrapper(List<ckz_bean_OrderBuilderMap> orderBuilderMap, List<ckz_bean_Order> orders) {
        this.orderBuilderMap = orderBuilderMap;
        this.orders = orders;
    }
}