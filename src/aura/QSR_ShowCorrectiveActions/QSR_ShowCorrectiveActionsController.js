({
    doInit : function(component, event, helper) {
        var taskList = [];
        var taskListString = component.get('v.taskListString');
        var taskList1 = [];
        if(taskListString){
           taskList1 = taskListString.split(',');
        }
        var taskListString2 = component.get('v.taskListString2');
        var taskList2 = [];
        if(taskListString2){
            taskList2 = taskListString2.split(',');
        }
        taskList = taskList1.concat(taskList2);
        component.set('v.taskList',taskList);
    }
})