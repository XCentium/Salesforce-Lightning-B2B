({
    doInit : function(component, event, helper) {
        //var tasksList = component.get('v.tasksList');
        //tasksList.push("{'Name' : '','Description' : ''}");
    },
    onClickAdd : function(component,event,helper){
        component.set('v.showDialog',true);
    },
    handleSuccess : function(component,event,helper){
        
    },
    handleSubmit : function(component,event,helper){
        
    },
    onclickCancel : function(component,event,helper){
        component.set('v.showDialog',false);
    },
    onclickSave : function(component,event,helper){
        var subject = component.get('v.subject');
        var description = component.get('v.description');
        var tasksList = component.get('v.tasksList');
        tasksList.push(
            {
                'Name' : subject,
                'Description' : description
            }
        );
        component.set('v.tasksList',tasksList);
        component.set('v.showDialog',false);
        component.set('v.description','');
        component.set('v.subject','');
        var taskListStringArr = [];
        for(var i=0;i<tasksList.length;i++){
            taskListStringArr.push(tasksList[i].Name);
        }
        component.set('v.taskListString',taskListStringArr.join());
    }
})