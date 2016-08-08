trigger AccountTrigger on Account (after delete, after insert,  
after update, before delete, before insert, before update) {
    
    system.debug('RunTrigger'+BatchableImport.RunTrigger);
    
    if (BatchableImport.RunTrigger==false)
    { 
    	return;
    }
    
    if (trigger.isBefore)
    {
        if(Utility.bRunTrigger ==true)
        {
            if (trigger.isInsert ) 
            {
                AccountTriggerHelper.BeforeInsert(trigger.new,trigger.old);                
            }  
            else if ( trigger.isUpdate) 
            {
                AccountTriggerHelper.BeforeUpdate(trigger.new,trigger.old);
            }
        }
    }
    else if (trigger.isAfter) 
    {
        if(Utility.bRunTrigger ==true)
        {
            if (trigger.isInsert ) 
            {
                AccountTriggerHelper.AfterInsert(trigger.new,trigger.old);
            }
            else if ( trigger.isUpdate) 
            {
                AccountTriggerHelper.AfterUpdate(trigger.new,trigger.old);
            }
         }
    }
}