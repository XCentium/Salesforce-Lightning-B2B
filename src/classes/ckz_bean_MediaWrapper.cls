/**
 * Created by brandon.rogers on 4/22/19.
 */

public with sharing class ckz_bean_MediaWrapper {

    public String uri { get; set; }
    public String sourceType { get; set; }
    public String altMessage { get; set; }
    public String mediaName { get; set; }
    public String imageFullPath { get; set; }
    public String description { get; set; }
    public Integer position { get; set; }

    public ckz_bean_MediaWrapper() {
    }
}