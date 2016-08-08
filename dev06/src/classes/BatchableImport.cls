global class BatchableImport implements Database.Batchable<string>, Database.AllowsCallouts ,Database.Stateful {
     
    private static final string ClassName='BatchableImport';
    public Entity_Mapping_Header__c Entity_Mapping_Header {get;set;}
    public list<Entity_Sync_Filteration__c> Entity_Sync_Filter_Detail {get;set;}
    public string EntitySynID {get;set;}
    public list<Sobject> objAllRecords {get;set;}
    public string STARTAT='1';
    public string TOTALCOUNT='10';
    public string TOTALRECORDCOUNT='';
    public string FAILCOUNT{get;set;}
    public string NextRec{get;set;}
    public list<sObject> insObjectRecordList{get;set;}
    public list<sObject> upObjectRecordList{get;set;}
    list<string> ListOfStart = new list<string>();
    public list<Id> ListOfJobId{get;set;}
    public List<Log__c> logs=new List<Log__c>();
    public boolean RunFromStart=false;
    public boolean LastBatch=false;
    string Namespace ;
    global BatchableImport(){} 
    public static boolean RunTrigger=true;
    
    //This constructor will be used when first import will be done from here and remaining from other constructor
    global BatchableImport(string pEntityID,boolean showError,string pStart){  
            RunTrigger=false;
            STARTAT=pStart;
            EntitySynID=pEntityID;  
            Entity_Mapping_Header =[select Id,Entity_Id__c,Name,Next_EMH_Id__c,ERP_Function__c,Integration_Key__c,//ERP_System__c,
                Source_Entity__c,Sync_Direction__c,Target_Entity__c,Parent_Target_Entity__c,Size__c,
                Last_Sync_Date__c,Last_Sync_Field__c From Entity_Mapping_Header__c where Id=:EntitySynID];
            EntitySynID=  Entity_Mapping_Header.Id;  
            Entity_Sync_Filter_Detail=  [select  Id,Active__c   ,Entity_Mapping_Header_Id__c,Field__c,Operator__c,Value__c,IsSync__c From Entity_Sync_Filteration__c where Entity_Mapping_Header_Id__c  =: Entity_Mapping_Header.Id ];
            list<Entity_Detail__c> Enity_Details =[select  Name,Data_Type__c,Field_APIName__c, Values__c From Entity_Detail__c where Entity_Id__c =: Entity_Mapping_Header.Entity_Id__c order by  Field_APIName__c];
            if (STARTAT=='1')
                logs.Add(new Log__c(Order__c=integer.valueOf(STARTAT), LogDateTime__c=datetime.now(), Description__c ='Job Started:' ,StackTrace__c= '',Object__c=Entity_Mapping_Header.Name,Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntitySynID));
                
       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Entity_Mapping_Header '+Entity_Mapping_Header));
      //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Entity_Sync_Filter_Detail '+Entity_Sync_Filter_Detail));
       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Enity_Details '+Enity_Details));
         
            ImportNow(showError);
    }
    
    //This constructor will be used when all import will be done from here 
    global BatchableImport(string pEntityID,boolean showError,string pStart,boolean pRunFromStart){  
            RunTrigger=false;
            STARTAT=pStart;
            RunFromStart=true;
            EntitySynID=pEntityID;  
            Entity_Mapping_Header =[select Id,Entity_Id__c,Name,Next_EMH_Id__c,ERP_Function__c,Integration_Key__c,//ERP_System__c,
                 Source_Entity__c,Sync_Direction__c,Target_Entity__c,Parent_Target_Entity__c,Size__c,
                Last_Sync_Date__c,Last_Sync_Field__c From Entity_Mapping_Header__c where Id=:EntitySynID];
                                        
            EntitySynID=  Entity_Mapping_Header.Id;    
            Entity_Sync_Filter_Detail=  [select  Id,Active__c   ,Entity_Mapping_Header_Id__c,Field__c,Operator__c,Value__c,IsSync__c From Entity_Sync_Filteration__c where Entity_Mapping_Header_Id__c  =: Entity_Mapping_Header.Id ];
            if (STARTAT=='1')
                logs.Add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(), Description__c ='Job Started:' ,StackTrace__c= '',Object__c=Entity_Mapping_Header.Name,Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntitySynID));
            list<Entity_Detail__c> Enity_Details =[select  Name,Data_Type__c,Field_APIName__c, Values__c From Entity_Detail__c where Entity_Id__c =: Entity_Mapping_Header.Entity_Id__c order by  Field_APIName__c];
            
			            
    }
    
 
    //This constructor will not be used at first import    
    global BatchableImport(string pSTARTAT,string pTOTALRECORDCOUNT,boolean pLastBatch,Entity_Mapping_Header__c pEntity_Mapping_Header,list<Entity_Sync_Filteration__c> pEntity_Sync_Filter_Detail){
            RunTrigger=false;
            STARTAT=pSTARTAT;
            TOTALRECORDCOUNT=pTOTALRECORDCOUNT;
            LastBatch = pLastBatch;
            Entity_Mapping_Header =pEntity_Mapping_Header;
            EntitySynID=Entity_Mapping_Header.Id;  
            Entity_Sync_Filter_Detail=pEntity_Sync_Filter_Detail;
            if (STARTAT=='1')
                logs.Add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(), Description__c ='Job Started:' ,StackTrace__c= '',Object__c=Entity_Mapping_Header.Name,Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntitySynID));
    } 
    
    //Start Method
    //global Database.QueryLocator start(Database.BatchableContext BC){
    global Iterable<string> start(Database.BatchableContext BC){
        RunTrigger=false;
        try
        { 
            //return Database.getQueryLocator('');
            if (!(STARTAT=='1') || RunFromStart==true)
                ImportNow(false);  
            ListOfStart.add('1');   
        }
        catch(Exception ex)
        {
            ListOfStart.add('1');
        }
        return ListOfStart;
    }
      
    //Execute Logic   
    global void execute(Database.BatchableContext BC, List<string>scope){
        RunTrigger=false;
        integer a;
    }
     
    //Logic to be Executed at finish 
    global void finish(Database.BatchableContext BC){
      RunTrigger=false; 
       /* 
        Double itemsProcessed=0; 
        Double totalItems=0 ;
        list<AsyncApexJob > objAsyncApexJob = [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
            CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob where ApexClass.Name = 'BatchableImport' and 
            Status!='Completed' and Status!='Failed' and Status!='Aborted' order by CreatedDate desc];
            //Or we can check( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];   
              
        for(AsyncApexJob a :objAsyncApexJob){
            itemsProcessed += a.JobItemsProcessed;
            totalItems += a.TotalJobItems;
        }
        
        if(objAsyncApexJob.size()==0)
        {}*/
            //check if next record exist
            //There might be a case where current call fails but further record exist. 
            if(LastBatch || RunFromStart)
            {
            //Integer nextStart=integer.valueOf(TOTALCOUNT ) + integer.valueOf(STARTAT )  ; 
            //if (TOTALRECORDCOUNT !='')
            //{
            //  if (nextStart > Integer.valueof(TOTALRECORDCOUNT))
            //  {
                    if (NextRec=='1') 
                    {
                        ImporterMaintenanceController ObjEMH= new ImporterMaintenanceController(Entity_Mapping_Header.Id,STARTAT);
                        ObjEMH.ImportNow();
                    }
                    else
                    {
                        if (!String.IsEmpty(Entity_Mapping_Header.Next_EMH_Id__c))
                        { 
                            ImporterMaintenanceController ObjEMH= new ImporterMaintenanceController(Entity_Mapping_Header.Next_EMH_Id__c,'1');
                            ObjEMH.ImportNow();
                        }
                        logs.Add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c ='Job finished:' ,StackTrace__c= '' ,Object__c=Entity_Mapping_Header.Name,Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntitySynID));  
                    }  
            //    } 
            //} 
            }
        
        insert logs;
                
    }  
    
    
    public void ImportNow(boolean showError)
    {
        //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'showError '+showError));
    	 RunTrigger=false; 
    	ERP_Config__c Config = [select Synchronization__c from ERP_Config__c where Id=:Entity_Mapping_Header.Integration_Key__c];
    	
    	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Config '+Config));
    	
    	if(Config.Synchronization__c =='Salesforce to ERP')
        {
        	
        		
        } 
        else
        {    
	        insObjectRecordList = new list<sObject>() ; 
	        upObjectRecordList = new list<sObject>() ;
	        try
	        {       
	                Import(showError);
	                if(insObjectRecordList.size()>0)
	                {
	                    //insert insObjectRecordList;
	                }
	                
	                if(upObjectRecordList.size()>0)
	                { 
	                   //update upObjectRecordList;
	                }   
	                
	                List<Database.SaveResult> InsertResults;
	                List<Database.SaveResult> UpdateResults;
	                  
	                InsertResults=database.insert(insObjectRecordList,false);
	                
	                for(Integer i=0;i<InsertResults.size();i++){
	                    if (!InsertResults.get(i).isSuccess()){
	                        //DML operation failed
	                        Database.Error error = InsertResults.get(i).getErrors().get(0);
	                        String failedDML = error.getMessage();
	                        insObjectRecordList.get(i);//failed record from the list
	                        logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c =failedDML ,StackTrace__c= '',Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= ''+ insObjectRecordList.get(i),Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
	                    }
	                }	                
	                UpdateResults=database.update(upObjectRecordList,false);  
	                
	                for(Integer i=0;i<UpdateResults.size();i++){
	                    if (!UpdateResults.get(i).isSuccess()){
	                        //DML operation failed
	                        Database.Error error = UpdateResults.get(i).getErrors().get(0);
	                        String failedDML = error.getMessage();
	                        upObjectRecordList.get(i);//failed record from the list
	                        logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c =failedDML ,StackTrace__c= '',Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= ''+ upObjectRecordList.get(i),Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
	                    }
	                }
	                
	        }                                   
	        catch(Exception ex)
	        {
	            logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c = ex.getMessage() ,StackTrace__c= ex.getStackTraceString(),Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= ''+ insObjectRecordList + upObjectRecordList,Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
	            CustomException exc= new CustomException(ClassName,'ImportNow',ex,showError);
	        }
        }   
    }
    
    //method to import the Dropdowns for selected company with provided filter criteria.
    public void Import(boolean showError)
    {
    	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'showError12 '+showError));
    	
        NextRec='0';
        map<string,list<object>> AttribParams;
        list<object>AttribParam;
        map<string,map<string,list<string>>> fieldParameters; 
        try 
        {
             
            if(string.isNotBlank(string.valueOf(Entity_Mapping_Header.Size__c)))
                TOTALCOUNT =string.valueOf(Entity_Mapping_Header.Size__c);
                 
            baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(Entity_Mapping_Header.Integration_Key__c);

            AttribParams=new map<string,list<object>> ();
            AttribParams=Utility.getAttribParameters(STARTAT , TOTALCOUNT, Entity_Mapping_Header.Integration_Key__c, Entity_Mapping_Header.Source_Entity__c, '' , Helper.MappingPurpose.SYNC); 
            
             AttribParam= new list<object>();
             AttribParam.add(Entity_Mapping_Header.ERP_Function__c);
             AttribParams.put('DataFinder',AttribParam);
            //AttribParams=new map<string,list<object>> ();
            
             //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Entity_Mapping_Header89 '+Entity_Mapping_Header));
            
          //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'AttribParams 24'+AttribParams));
            
            fieldParameters = new map<string,map<string,list<string>>> ();
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();
            
            for(Entity_Sync_Filteration__c  Entity_Sync_Filter :Entity_Sync_Filter_Detail)
            {
            	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Entity_Sync_Filter' +Entity_Sync_Filter));
                listParams=new list<string> ();
                parameter = new map<string,list<string>>();
                if(Entity_Sync_Filter.Active__c == false ) //true
                {
                	   // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'IF')); 
                        listParams.add(Entity_Sync_Filter.Value__c);                    
                        Helper.Operator operator;
                        if(string.valueOf(Entity_Sync_Filter.Operator__c) =='equals')
                                operator = Helper.Operator.EQUAL;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='greater than')
                                operator = Helper.Operator.GREATER_THAN;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='less or equal')
                                operator = Helper.Operator.LESSER_OR_EQUAL;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='greater or equal')
                                operator = Helper.Operator.GREATER_OR_EQUAL;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='not equal to')
                                operator = Helper.Operator.NOT_EQUAL;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='less than')
                                operator = Helper.Operator.LESS_THAN;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='contains')
                                operator = Helper.Operator.LIKE_CALUSE;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='does not contain')
                                operator = Helper.Operator.DOES_NOT_CONTAIN;
                        else if(string.valueOf(Entity_Sync_Filter.Operator__c) =='starts with')
                                operator = Helper.Operator.STARTS_WITH;
                                                                         
                        parameter.put(string.valueOf(operator),listParams);                     
                       
                        string FilterField=Entity_Sync_Filter.Field__c;
                        //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldParameters:'+fieldParameters));
                        while( fieldParameters.get(FilterField)!=null) {
                            FilterField = FilterField+ BaseERPProvider.DuplicateFLDStr;
                        }
                        
                        //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'FilterField:'+FilterField +'parameter:'+parameter));
                        fieldParameters.put(FilterField,parameter);
                       /// apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldParameters:'+fieldParameters));
                        
                                                                      
                }
            }
            
            if(string.isNotBlank(Entity_Mapping_Header.Last_Sync_Field__c))
            {
            	apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'if'));
                string lastSycDate = string.valueOf(Entity_Mapping_Header.Last_Sync_Date__c).subString(0,10);
                list<string> strDate = new list<string>();
                strDate = lastSycDate.split('-');
                lastSycDate = strDate[0]+''+strDate[1]+''+strDate[2]; 
                                
                listParams=new list<string> ();
                listParams.add(lastSycDate);
                
                parameter = new map<string,list<string>>();
                Helper.Operator operator;
                operator = Helper.Operator.GREATER_OR_EQUAL;
                parameter.put(string.valueOf(operator),listParams);
                fieldParameters.put(Entity_Mapping_Header.Last_Sync_Field__c,parameter);
                //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldParameters' +fieldParameters));
            }
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldParameters  '+fieldParameters +'AttribParams' +AttribParams)); 
            Helper.GUMU_Response resGUMU_Response =integrationFramework.getData(fieldParameters , AttribParams);
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'resGUMU_Response :  '+resGUMU_Response));
           
            //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'resGUMU_Response1234 '+resGUMU_Response));
            
            if(resGUMU_Response.statusCode =='101')
            {       
                if (showError)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, resGUMU_Response.statusMessage));
                 //else
                    logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c = resGUMU_Response.statusMessage ,StackTrace__c= ClassName + '.Import.255',Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= '',Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
                return;                 
            }
            else if(resGUMU_Response.statusCode =='100')
            {       
                if (showError)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to connect ERP System. Please check the connection..'));
                //else
                    logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c ='Unable to connect ERP System. Please check the connection..' ,StackTrace__c= ClassName + '.Import.263',Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= '',Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
                //LastBatch=true;
                return;                 
            }
            else if(resGUMU_Response.statusCode =='0')
            {       
                if (showError)  
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, resGUMU_Response.statusMessage));
                //else
                    logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c = resGUMU_Response.statusMessage ,StackTrace__c= ClassName + '.Import.271' ,Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= '',Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
                //LastBatch=true;                                                   
                return; 
            }
            else if(resGUMU_Response.statusCode != '200')
            {    
                
                if (showError)  
                {
                    Utility.parse(resGUMU_Response.responseERPData,'message');
                }   
                //else
                    logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c = resGUMU_Response.responseERPData ,StackTrace__c= ClassName + '.Import.271' ,Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= '',Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
               //LastBatch=true;                                                    
               return; 
            }
            else if( resGUMU_Response.responseERPData!=null)
            {
                if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable.'))
                {   if (showError)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Service Temporarily Unavailable.Please check the Services..'));
                //else
                    logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c ='Unable to connect ERP System. Please check the connection..' ,StackTrace__c= ClassName + '.Import.280',Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= '',Log_Type__c='SYNC',Object_Id__c=EntitySynID ));
                    return; 
                } 
                //LastBatch=true;                   
            }
             Namespace = Utility.FetchNameSpace();
             if(!Entity_Mapping_Header.Target_Entity__c.endswith('__c'))
            	{
            		Namespace = '';
            		            		
            	}
            list<Sobject> objRecords=(list<Sobject>) resGUMU_Response.responseSFData;
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            //Schema.SObjectType sObjectSchema = schemaMap.get(Namespace + Entity_Mapping_Header.Target_Entity__c);
            Schema.SObjectType sObjectSchema = schemaMap.get(Entity_Mapping_Header.Target_Entity__c);
            Map<String, Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap();
            list <string > targetObjectExternalID=new list <string > (); 
           
            if (objRecords != null)
            {
                for (sObject obj :objRecords)
                {
                    targetObjectExternalID.add( (string)obj.get('External_UId__c'));
                }                    
            }
            
            string sQuery = 'select Id,External_UId__c from '+ Entity_Mapping_Header.Target_Entity__c+
            ' where External_UId__c != null and External_UId__c !=' + '\'\''  +' and External_UId__c in: targetObjectExternalID ';
            
            list<sObject> objList=Database.query(sQuery);
            
            map<string,string> mapId=new map<string,string>();
           
            for(sObject obj :objList)
                mapId.put((string)obj.get('External_UId__c'),(string) obj.get('Id'));
            
            if (objRecords != null)
            {
                for (sObject obj :objRecords)
                {
                    obj.put('Id',(string) mapId.get((string)obj.get('External_UId__c')) );
                }                    
            }
            
            if (objRecords != null)
            {
                if (objRecords.size()>0)
                { 
                   for(sObject obj : objRecords )
                   {    
                        try
                        {   
                            obj.put('Integration_Key__c',Entity_Mapping_Header.Integration_Key__c);
                        }catch (Exception Ex){}
                            
                        if(obj.Id ==null)
                        {
                            insObjectRecordList.add(obj);
                        }   
                        else
                        {
                            upObjectRecordList.add(obj);
                        }    
                    }   
                   
                    //Remove Duplicates from insert list
                    if(insObjectRecordList.size()>0)
                    {
                        Set<sobject> Sobjectset = new Set<sobject>();
                        List<sobject> result = new List<sobject>();
                        Sobjectset.addAll(insObjectRecordList);
                        result.addAll(Sobjectset);      
                        insObjectRecordList=result;
                    }
                    //Remove Duplicates from update list
                    if(upObjectRecordList.size()>0)
                    {
                        Set<sobject> Sobjectset = new Set<sobject>();
                        List<sobject> result = new List<sobject>();
                        Sobjectset.addAll(upObjectRecordList);
                        result.addAll(Sobjectset);      
                        upObjectRecordList=result;
                    }
                                  
                }
            }
            
            TOTALRECORDCOUNT=resGUMU_Response.TotalRecord;
            if (resGUMU_Response.TotalRecord == '' || resGUMU_Response.TotalRecord == null)
                NextRec ='0';
            else
            {
                Integer nextStart=Integer.valueof(STARTAT) + Integer.valueof(resGUMU_Response.itemPerPage);
                if (STARTAT=='1' && nextStart > Integer.valueof(resGUMU_Response.TotalRecord))
                {
                    LastBatch=true;
                }
                STARTAT= string.valueOf(nextStart);                
                if(nextStart > Integer.valueof(resGUMU_Response.TotalRecord))
                {
                    NextRec ='0';
                }   
                else
                    NextRec ='1';
            }                            
        }
        catch (Exception Ex){
             logs.add(new Log__c(Order__c=integer.valueOf(STARTAT),LogDateTime__c=datetime.now(),Description__c = Ex.getMessage() , StackTrace__c= Ex.getStackTraceString(),Object__c=Entity_Mapping_Header.Source_Entity__c,Data__c= 'fieldParameters'+fieldParameters +':'+'AttribParams'+AttribParams ,Log_Type__c='SYNC',Object_Id__c=EntitySynID));
             CustomException exc= new CustomException(ClassName,'Import',ex,showError);
             
        }
    }    

}