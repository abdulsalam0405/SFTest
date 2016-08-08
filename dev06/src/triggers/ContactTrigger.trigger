trigger ContactTrigger on Contact (after delete, after insert, after update, 
before delete, before insert, before update) {

 if (BatchableImport.RunTrigger==false)
    { 
      return;
    }
    
    if (trigger.isBefore)
    {
        if (trigger.isInsert ) 
        {
            ContactTriggerHelper.BeforeInsert(trigger.new,trigger.old);
        } 
        else if ( trigger.isUpdate) 
        {
           ContactTriggerHelper.BeforeUpdate(trigger.new,trigger.old);
        }
    }
    else if (trigger.isAfter) 
    {
        if (trigger.isInsert ) 
        {
            ContactTriggerHelper.AfterInsert(trigger.new,trigger.old);
        }
        else if ( trigger.isUpdate) 
        {
            ContactTriggerHelper.AfterUpdate(trigger.new,trigger.old);
        }
    }

}