//This class is used by the custom Gantt charts on the Projects and Milestones object page layouts.  Added in April 2016.  

public with sharing class GanttChartHelper {
  public String myId {get;set;}
  public Boolean allowView {get;set;}
  
  ApexPages.StandardController stdCont;
  
  public GanttChartHelper(ApexPages.StandardController stc){
    myId = stc.getId();
    allowView = Apexpages.currentPage().getParameters().get('p') == null;
  }
}