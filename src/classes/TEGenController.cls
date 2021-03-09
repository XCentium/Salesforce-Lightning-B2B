public class TEGenController {

    


mTask[] ts = new mTask[]{}; 
mEvent[] es = new mEvent[]{};
Date d = Date.Today(); 

Account ac = [Select Id from Account limit 1]; 
Opportunity oc = [Select Id from Opportunity limit 1];
Lead ld = [Select Id from lead limit 1 ];
Case cs = [Select Id from Case limit 1];
Contact con = [Select Id from Contact limit 1]; 

Integer adds = 0; 


public void init(){
    for(Integer k=0; k<5; k++)
    {
        ts.add( new mTask(MakeTask()));
        es.add( new mEvent(MakeEvent()));
        adds++; 
    }
}




public mEvent[] getEs() {
        return es;
    }


    public mTask[] getTs() {
        return ts;
    }




public Task MakeTask(){
    Task t = new Task();
    t.Status = 'Not Started'; 
   t.Priority = 'Normal';

    t.ActivityDate = d; 
    if(adds ==0)
    {
        t.Subject = 'Call new Lead'; 
        t.WhoId = ld.Id;
    }
    else if (adds == 1)
    {
        t.Subject = 'Account Review'; 
        t.WhatId= ac.Id;
    }
    else if (adds == 2)
    {
        t.Subject = 'Next Steps'; 
        t.WhatId=  oc.Id;
    }
    else if (adds == 3)
    {
        t.Subject = 'Call back regarding Issue'; 
        t.WhatId = cs.Id;

    }
    else if (adds == 4)
    {
        t.Subject = 'Follow Up'; 
        t.WhoId = con.Id;
    }    
    
    return t; 
}


public Event MakeEvent(){
    DateTime start = DateTime.newInstance(d.year(),d.month(),d.day(), 13+adds, 0, 0); 
    DateTime ends = DateTime.newInstance(d.year(),d.month(),d.day(), 14+adds, 0, 0); 
   
    Event e = new Event(); 
 //   e.StartDateTime = start; 
 //   e.EndDateTime = ends;
    if(adds ==0)
    {
        e.Subject = 'Meeting with Lead'; 
        e.WhoId = ld.Id;
    }
    else if (adds == 1)
    {
        e.Subject = 'Account Review'; 
        e.WhatId= ac.Id;
        e.location = 'Hawaii Conference Room';
    }
    else if (adds == 2)
    {
        e.Subject = 'Meeting w/ CEO'; 
        e.WhatId=  oc.Id;
        e.location = 'On Site'; 
    }
    else if (adds == 3)
    {
        e.Subject = 'Investigate Open Case'; 
        e.WhatId = cs.Id;
    }
    else if (adds == 4)
    {
        e.Subject = 'Conference Call'; 
        e.WhoId = con.Id;
    }    
   
   e.ActivityDateTime = start; 
   e.DurationInMinutes = 60; 
   
   return e; 

}

public PageReference save() {
    PageReference consPage = new PageReference('/apex/TEGenThanks');

    Task[] TIn = new Task[]{};
    Event[] EIn = new Event[]{};
    
    for(Integer l=0; l<5; l++)
    {
        if(ts[l].selected)
        {
            TIn.add(ts[l].t);
        }
        
        if(es[l].sel)
        {
            EIn.add(es[l].e);
        }
    }
    
    insert TIn;
    insert EIn;

    System.debug('Adding '+Ein.size());
//    return null;
    return consPage;
}

public PageReference clearAll() {
    Ts = new mTask[]{};
    Es = new mEvent[]{};
    
    for(Integer k=0; k<5; k++)
    {
            Task t = new Task();
            t.Status = 'Not Started'; 
            t.Priority = 'Normal';
        
        Ts.add(new mTask(t));
        Es.add(new mEvent(new Event())); 
    }
    
    return null; 
}



        public class mTask{
            Task t;
            boolean selected = true;
            public mTask( Task adl){t=adl;}
            public boolean getSelected() {return selected;}
            public Task gett(){ return t; }
            public void setSelected(boolean sb){ selected = sb;}
        }
        
        public class mEvent{
            Event e;
            boolean sel = true;
            public mEvent( Event adl){e=adl;}
            public boolean getSel() {return sel;}
            public Event gete(){ return e; }
            public void setSel(boolean sb){ sel = sb;}
        }

}