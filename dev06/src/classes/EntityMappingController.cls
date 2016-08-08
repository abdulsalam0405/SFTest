global with sharing class EntityMappingController {

    public Boolean bAdministration { get; set;}
    public Integer PAGE_SIZE{get;set;}
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public list<Entity_Mapping_Header__c> EntityMappings {get;set;}
    public String ProfileName {get;set;}   
    public Integer OffsetSize {get;set;}
    public Integer QueryLimit =10; 
    public Integer CountTotalRecords{get;set;}
    public string ERPSystemName{get;set;}
    public string Action{get;set;}
    public string SyncId{get;set;}
    public list<Id> ListOfJobId{get;set;}
    public BatchableImport objBatchableImport ;
    
    public string IntegrationName{get;set;}
    public list<ERP_Config__c> ERPConfigList  {get;set;}
    public  List<SelectOption> IntegrationList {get;set;}
    public String selectedERP{get;set;}
     
    public EntityMappingController() 
    {
        LogMessage = 'Batch to be processed:0.';
        //Constructor calling with default values set.
        OffsetSize = 0;

        this.EntityMappings = new list<Entity_Mapping_Header__c>();
        //set initial page
        this.page = 1;
        this.PAGE_SIZE=10;
     
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible())
            {
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
            }
        } 
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);
        
       // ERPConfigList = [select Id,ERP_System__c,Name,Default__c  from ERP_Config__c limit 100];
        IntegrationList = new List<SelectOption>();
        IntegrationList.add(new SelectOption('All', 'All Integrations'));
        
        list<ERP_Config__c> config = [select Id,ERP_System__c,Name from ERP_Config__c where Default__c= true];
        ERPSystemName = '';
        if (config.size()>0)
        {
            ERPSystemName = config[0].ERP_System__c;
            selectedERP=config[0].Id;
         }
         else
            selectedERP='All';
            
        list<ERP_Config__c> ERPConfigList = [select Id,Name,ERP_System__c from ERP_Config__c where Inactive__c =false];   
        for(ERP_Config__c ERP :ERPConfigList )
        {
          IntegrationList.add(new SelectOption(ERP.Id, ERP.Name));
        }
        
        GetEntityMappings();
        
    } 

    //Advance to next page
    public void doNext()
    {
        

        if(OffsetSize + QueryLimit > CountTotalRecords)
            return;
                
        OffsetSize += QueryLimit;
        this.page++;
        GetEntityMappings();
       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'NEXT - OffsetSize : ' + OffsetSize));
       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'NEXT - QueryLimit : ' + QueryLimit));
       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'NEXT - CountTotalRecords : ' + CountTotalRecords));

    }
    
    //Advance to previous page
    public void doPrevious()
    {          
        if(OffsetSize == 0)
            return;
                
        OffsetSize -= QueryLimit;
        this.page--;
        
      //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'PRE - OffsetSize : ' + OffsetSize));
      //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'PRE - QueryLimit : ' + QueryLimit));
      //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'PRE - CountTotalRecords : ' + CountTotalRecords));
          
        GetEntityMappings();
    } 
    
    
    //Returns whether the previous page exists
    public Boolean getHasPrevious()
    { 
        
        if(OffsetSize ==0)
        {
            return false;
        }
        else
            return true;
    }
    
    //Returns whether the next page exists
    public Boolean getHasNext()
    {
        
        if(OffsetSize + QueryLimit < countTotalRecords)
        {
            return true;          
        }
        else 
            return false;
    } 
    
    public PageReference GetEntityMappings() 
    {  
        if(Apexpages.hasMessages())
            Apexpages.getMessages().clear();

        //calculate range of records for capture
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        QueryLimit = PAGE_SIZE;
        // Check if the user has read access on the Order fields
        if (!Schema.sObjectType.Entity_Mapping_Header__c.fields.Name.isAccessible() 
                || !Schema.sObjectType.Entity_Mapping_Header__c.fields.Source_Entity__c.isAccessible()
                || !Schema.sObjectType.Entity_Mapping_Header__c.fields.Target_Entity__c.isAccessible()
                || !Schema.sObjectType.Entity_Mapping_Header__c.fields.ERP_Function__c.isAccessible()
                //|| !Schema.sObjectType.Entity_Mapping_Header__c.fields.ERP_System__c.isAccessible()
                || !Schema.sObjectType.Entity_Mapping_Header__c.fields.Id.isAccessible())
        { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access to Fields'));
            return null;
        }
        String query='SELECT Id,Name,Source_Entity__c,Target_Entity__c,Entity_Id__r.API_Method__c,Sync_Type__c,Active__c FROM Entity_Mapping_Header__c ';     //where Active__c=true
        //ERP_System__c,
        
        if(selectedERP !='All')
        {
            query+=' where Integration_Key__c = \''+ string.escapeSingleQuotes(selectedERP)  +'\'';  //and
            CountTotalRecords= [select count() from Entity_Mapping_Header__c where  Integration_Key__c =: selectedERP  ];//Active__c=true and
        }  
        else
        {
            CountTotalRecords= [select count() from Entity_Mapping_Header__c ];//where Active__c=true
          //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 'CountTotalRecords : ' + CountTotalRecords));
        }  

        query+=' ORDER BY Name limit '+ QueryLimit +' offset '+ OffsetSize +'';
        
        
        system.debug('query '+query);
        
        list<Entity_Mapping_Header__c> lstEntityMappings = Database.Query(query);
        EntityMappings = new list<Entity_Mapping_Header__c>(); 
        
        if(lstEntityMappings.size() > 0)
        {
            for(Entity_Mapping_Header__c oOrder : lstEntityMappings)
            {
                EntityMappings.add(oOrder);
                //count the total number of records
                this.totalRecords++;
            }
        }  
        //calculate total pages
        this.totalRecords=this.CountTotalRecords;
        //ABDS:Added below code
        //CountTotalRecords=lstEntityMappings.size() ;
        //this.totalRecords=lstEntityMappings.size() ;
        
        Decimal pages = Decimal.valueOf(this.CountTotalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'pages: ' +pages +' totalPages: '+totalPages));
        //adjust start index e.g. 1, 11, 21, 31
        this.startIdx++;
       
        //adjust end index
        if(this.endIdx>this.totalRecords)
        {
            this.endIdx = this.totalRecords;
        }
        if(this.totalRecords == 0)
        {
            this.totalPages=1;
            this.totalPages=0;
            this.startIdx=0;
            this.endIdx=0;
        }
        return null;    
    }
     
     //Call the sync method
    public PageReference SyncNow()
    {
        
        string NextRec;
        string STARTAT ;
        if (Action =='Sync')
        {
            list<Entity_Mapping_Header__c> Entity_Mapping_Header =[select Id,Integration_Key__c,Active__c From Entity_Mapping_Header__c where Id=:SyncId];
            
            if(Entity_Mapping_Header[0].Active__c == false)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'The mapping is inactive. please activate before syncing data.')); 
                return null;
            }
                        
            if(string.isNotBlank(Entity_Mapping_Header[0].Integration_Key__c))
            {
                ERP_Config__c Config = [select Synchronization__c,Inactive__c from ERP_Config__c where Id=:Entity_Mapping_Header[0].Integration_Key__c];
                
                if(Config.Synchronization__c =='Salesforce to ERP')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'You cannot sync data. Please select syncronization either "Both" or "ERP to Salesforce" in Configuration screen.')); 
                    return null;
                }
                else if(Config.Inactive__c == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'The mapping is inactive. please activate before syncing data.')); 
                    return null;
                }       
            }   
            
            BatchableImport  objBatchableImport = new BatchableImport(SyncId,false,'1',true);
            database.executeBatch(objBatchableImport,1);
            return null;
        
        }
        else
        {
            PageReference pageRef = new PageReference('/'+SyncId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        
    } 
   
    public boolean batchProcessed=false;
    public string LogMessage {get;set;}     
    public integer logCount=0;     
    
    public void getMessage()
    {
        LogMessage='';
        Double itemsProcessed=0;
        Double totalItems=0 ;
        list<AsyncApexJob > objAsyncApexJob = [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
                        CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob where ApexClass.Name = 'BatchableImport' and 
                        Status!='Completed' and Status!='Failed' and Status!='Aborted' order by CreatedDate desc];
        LogMessage += 'Batch to be processed:' + objAsyncApexJob.size() + '.';
        
    }
        
    public PageReference RedirectPage()
    {
        string headerId = Apexpages.currentPage().getParameters().get('Id');
        string Action  = Apexpages.currentPage().getParameters().get('Action');
        PageReference rPage; 
       if(Action == 'Edit')     
                    rPage = new PageReference('/apex/ImporterMaintenance?id='+headerId);
       else
            rPage = new PageReference('/apex/ImporterMaintenanceView?id='+headerId);
        
        rPage.getParameters().put('id',headerId); 
        rPage.setRedirect(true); 
        return rPage;
    }
    
    public PageReference RedirectNewPage()
    {
        PageReference rPage;     
            rPage = new PageReference('/apex/ImporterMaintenance');            
        rPage.setRedirect(true); 
        return rPage;
    }
    
    public PageReference deleteRecord()
    {
        string headerId = Apexpages.currentPage().getParameters().get('Id');
        string Action  = Apexpages.currentPage().getParameters().get('Action');
        for(Entity_Mapping_Header__c EntityMapping:EntityMappings)
        {
            if(headerId ==EntityMapping.Id )
            {
                delete [select Id from Entity_Fields_Mapping_Detail__c where Entity_Mapping_Id__c=: EntityMapping.Id];
                delete [select Id from Entity_Sync_Filteration__c where Entity_Mapping_Header_Id__c=: EntityMapping.Id];
                delete [select Id from Entity_Fields_Map_Parent__c where Entity_Fields_Map_Header_Id__c =: EntityMapping.Id];
                delete EntityMapping; 
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Record has been deleted.'));
            }
        }
        return null;
    }          
    
}