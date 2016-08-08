global class ScheduleImport implements Schedulable,Database.AllowsCallouts {
    
    string ImporterId;
    
    global ScheduleImport (string SyncId){                 
        ImporterId=string.ValueOf(SyncId).substring(0,15);
    } 
    
    global void execute(SchedulableContext SC){  

        BatchableImport  objBatchableImport = new BatchableImport(ImporterId,false,'1',true);
        database.executeBatch(objBatchableImport,1);

    }
     
}