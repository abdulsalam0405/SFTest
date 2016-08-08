public with sharing class EntityListController 
{
    public Integer PAGE_SIZE{get;set;}
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public list<Entity__c> EntityMappings {get;set;}
    public String ProfileName {get;set;}   
    public Integer OffsetSize {get;set;}
    public Integer QueryLimit =10; 
    public Integer CountTotalRecords{get;set;}
    public string ERPSystemName{get;set;}
    public Boolean bAdministration{get;set;}
    
   // public string IntegrationName{get;set;}
    public list<ERP_Config__c> ERPConfigList  {get;set;}
    public  List<SelectOption> IntegrationList {get;set;}
    public String selectedERP{get;set;}
    public EntityListController () 
    {
       
        //Constructor calling with default values set.
        OffsetSize = 0;

        //CountTotalRecords= [select count() from Entity_Mapping_Header__c where Active__c=true];
        this.EntityMappings = new list<Entity__c>();
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
              
        IntegrationList = new List<SelectOption>();
        IntegrationList.add(new SelectOption('All', 'All Integrations'));
        
        list<ERP_Config__c> config = [select Id,ERP_System__c,Name from ERP_Config__c where Default__c= true];
        ERPSystemName ='';
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
        
        String query='SELECT ID ,Name,API_Method__c,Group_Name__c from Entity__c'; //Entity_Code__c,
        
        if(selectedERP !='All')
        {
            query+=' where Integration_Key__c = \''+ string.escapeSingleQuotes(selectedERP)  +'\'';
           
            CountTotalRecords= [select count() from Entity__c where Integration_Key__c =: selectedERP];
        
        }  
        else
        {
            CountTotalRecords= [select count() from Entity__c limit 50000];
                      
        }  
        
        query+=' ORDER BY Name limit '+ QueryLimit +' offset '+ OffsetSize +'';
                
       

        list<Entity__c> lstEntity = Database.Query(query);
        EntityMappings = new list<Entity__c>(); 
        if(lstEntity.size() > 0)
        {
            for(Entity__c oEntity : lstEntity)
            {
                EntityMappings.add(oEntity );
                //count the total number of records
                this.totalRecords++;
            }
        }  
        //calculate total pages
        this.totalRecords=this.CountTotalRecords;
        //ABDS:Added below code
        //CountTotalRecords=lstEntityMappings.size() ;
        //this.totalRecords=lstEntityMappings.size() ;
        
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '***** '+Decimal.valueOf(this.CountTotalRecords)));
        
        Decimal pages = Decimal.valueOf(this.CountTotalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);

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

    //Advance to next page
    public void doNext()
    {
        OffsetSize += QueryLimit;
        this.page++;
        GetEntityMappings();
    }
    
    //Advance to previous page
    public void doPrevious()
    {
        OffsetSize -= QueryLimit;
        this.page--;  
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
            rPage = new PageReference('/apex/Entity');            
        rPage.setRedirect(true); 
        return rPage;
    }
    
    public PageReference deleteRecord()
    {
        string headerId = Apexpages.currentPage().getParameters().get('Id');
        string Action  = Apexpages.currentPage().getParameters().get('Action');
        for(Entity__c EntityMapping:EntityMappings)
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