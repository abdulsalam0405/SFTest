global with sharing class ImporterMaintenanceController
 {
    public Entity_Mapping_Header__c Entity_Mapping_Header {get;set;}
    public boolean showSaveButton {get;set;}
    public list<Entity_Fields_Mapping_Detail__c> Entity_Fields_Mapping_Detail {get;set;}
    public list<Entity_Sync_Filteration__c> Entity_Sync_Filter_Detail {get;set;}
    public list<Entity_Fields_Map_Parent__c> Entity_Fields_Map_Parent  {get;set;}
    public list<Log__c> LogDetails  {get;set;}
    public list<ERP_Config__c> ERPConfigList  {get;set;}
    
    private static final string ClassName='ImporterMaintenanceController';
    private string EntityID;
    public  List<SelectOption> options {get;set;}  
    public  List<SelectOption> targetoptions {get;set;}
    public  List<SelectOption> sfObjectsList {get;set;}
    public  List<SelectOption> IntegrationList {get;set;}
    
    public list<Sobject> objAllRecords {get;set;}
    public string STARTAT='1';
    public string TOTALCOUNT='10';
    public integer TotalAllowedBatches=90;
    public string FAILCOUNT{get;set;}
    public string NextRec{get;set;}
    public string ErrorMessage{get;set;}
    public list<Id> ListOfJobId{get;set;}
    public BatchableImport objBatchableImport ; 
    public boolean ShowError;
    public boolean ShowCloneButton{get;set;}
    public boolean ShowDeleteButton{get;set;} 
    public boolean ShowSyncButton{get;set;}   
    public string ActionName{get;set;}
    
    public string IntegrationKey{get;set;}
    public string IntegrationName{get;set;}     
        
     //properties for Header controllers
    public boolean ShowName{get;set;} 
    public boolean ShowTarget{get;set;} 
    public boolean ShowEntity{get;set;} 
    public boolean ShowChainTo{get;set;} 
    public boolean ShowSyncDirection{get;set;} 
    public boolean ShowScheduleId{get;set;} 
    public boolean ShowScheduleStart{get;set;} 
    public boolean ShowScheduleType{get;set;}    
    public boolean ShowErpSystem{get;set;} 
    
    //properties for Header controllers
    public boolean disabledSync{get;set;}
    public boolean disabledSourceField{get;set;}
    public boolean disabledDefaultValue{get;set;}
    public boolean disabledFilterSelect{get;set;}
    public boolean disabledFilterActive{get;set;}
    public boolean disabledFilterSourceFld{get;set;}
    public boolean disabledFilterOperator{get;set;}
    public boolean disabledFilterValue{get;set;}
    public boolean disabledRAccountID{get;set;}
    public boolean disabledRSourceFld{get;set;}
    public boolean disabledRParentObj{get;set;}
    
    public ERP_Config__c ERPConfig{get;set;}
    //string Namespace='';
    
    public ImporterMaintenanceController(string pEntityID,string pSTARTAT)
     {
        EntityID=pEntityID;     
        objBatchableImport = new BatchableImport();
        STARTAT=pSTARTAT;
        ShowError=false;
        Entity_Mapping_Header =[select Id,Active__c,Entity_Id__c,IsSync__c,Name,Next_EMH_Id__c,ERP_Function__c,Sync_Type__c,Integration_Key__c,Size__c ,
                                Source_Entity__c,Sync_Direction__c,Target_Entity__c,Parent_Target_Entity__c,Schedule_Id__c,Schedule_Start__c,
                                Schedule_Type__c,IsStandardPB__c
                                From Entity_Mapping_Header__c where Id=:EntityID];
                                
        //checking inactive integration
        ERPConfig = new ERP_Config__c();    
        if(string.isNotBlank(Entity_Mapping_Header.Integration_Key__c))
        {
            ERPConfig=[select id,Inactive__c,Name from ERP_Config__c where Id =:Entity_Mapping_Header.Integration_Key__c];
            IntegrationName = ERPConfig.Name;
        }
        
         
    }

    //Constructor
    public ImporterMaintenanceController(ApexPages.StandardController controller)
     {
        try
        {  
            LogMessage = 'Overall remaining batch to be process: 0.';    
            objBatchableImport = new BatchableImport();
            batchProcessed=false;
            ShowError=true;
            showSaveButton=true;
            ShowCloneButton = true;
            ShowSyncButton  = true;
            ShowDeleteButton= false;
            EntityID= ApexPages.currentPage().getParameters().get('Id');            
            ActionName = Apexpages.currentPage().getParameters().get('Action');          
            if(string.isNotBlank(EntityID))
            {  
                Entity_Mapping_Header =[select Id,Active__c,IsSync__c,Entity_Id__c,Name,Next_EMH_Id__c,ERP_Function__c,Sync_Type__c,Integration_Key__c,Size__c ,
                                        Source_Entity__c,Sync_Direction__c,Target_Entity__c,Parent_Target_Entity__c,Schedule_Id__c,Schedule_Start__c,
                                        Schedule_Type__c,IsStandardPB__c From Entity_Mapping_Header__c where Id=:EntityID];
                                        
               
                                       
                //ERP_System__c,
                ShowCloneButton = false;
                ShowSyncButton  = false;
                EntityID=Entity_Mapping_Header.Id;                               
            }
            else
                Entity_Mapping_Header = new Entity_Mapping_Header__c();
                
            //checking inactive integration
            ERPConfig = new ERP_Config__c();    
            if(string.isNotBlank(Entity_Mapping_Header.Integration_Key__c))
            {
                ERPConfig=[select id,Inactive__c,Name from ERP_Config__c where Id =:Entity_Mapping_Header.Integration_Key__c];
                IntegrationName = ERPConfig.Name;
            }
             //default values for clone record
            if(ActionName =='clone')
            {
                Entity_Mapping_Header.Sync_Type__c = 'Custom';
                Entity_Mapping_Header.Schedule_Id__c = '';
                Entity_Mapping_Header.Schedule_Start__c = null;
                Entity_Mapping_Header.Schedule_Type__c = '';
            }
            
            if(string.isNotBlank(Entity_Mapping_Header.Sync_Type__c) && string.valueOf(Entity_Mapping_Header.Sync_Type__c)=='System')
            {
                ShowName=true;
                ShowTarget=true;
                ShowEntity=true;
                ShowChainTo=true;
                ShowSyncDirection=true;
                ShowScheduleId=true;
                ShowScheduleStart=true;
                ShowScheduleType=true;
                ShowDeleteButton=true;
                ShowErpSystem = true;
                //For Mapping Tab
                disabledSync = true;
                disabledSourceField= true;
                disabledDefaultValue= true;
                
                //for Filter Tab
                disabledFilterSelect= true;
                disabledFilterActive= true;
                disabledFilterSourceFld= true;
                disabledFilterOperator= true;
                disabledFilterValue= true;
                
                //for relationship tab
                disabledRAccountID= true;
                disabledRSourceFld= true;
                disabledRParentObj= true;
            }
            
            
            Entity_Fields_Mapping_Detail =[select  Id,Name,ERP_Field__c,ERP_System__c,Salesforce_Field__c,Data_Type__c,IsSync__c,Default_Value__c,
                                            Salesforce_Field_Label__c,ERP_Field_Label__c,Entity_Mapping_Id__c From Entity_Fields_Mapping_Detail__c 
                                            where Entity_Mapping_Id__c =: Entity_Mapping_Header.Id ];
                                            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, 'Entity_Fields_Mapping_Detail :' +json.serialize(Entity_Fields_Mapping_Detail)));                                  
                                              
            Entity_Sync_Filter_Detail=  [select  Id,Active__c,Entity_Mapping_Header_Id__c,Field__c,Operator__c,Value__c,IsSync__c From Entity_Sync_Filteration__c 
                                         where Entity_Mapping_Header_Id__c  =: Entity_Mapping_Header.Id ];
                                         
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Entity_Sync_Filter_Detail .'+Entity_Sync_Filter_Detail));                             
            
            Entity_Fields_Map_Parent =  [select  Id,IsSync__c,Order__c,Source_Field__c,Target_Field__c,Parent_Object_Name__c,Entity_Fields_Map_Header_Id__c 
                                        From Entity_Fields_Map_Parent__c where Entity_Fields_Map_Header_Id__c  =: Entity_Mapping_Header.Id ];
            
            list<Entity_Detail__c> Enity_Details =[select  Name,Data_Type__c,Field_APIName__c, Values__c From Entity_Detail__c
                                                   where Entity_Id__c =: Entity_Mapping_Header.Entity_Id__c order by  Field_APIName__c];
             
            LogDetails  = [select Data__c,Description__c,Log_Type__c,StackTrace__c,Object__c,LogDateTime__c from Log__c where Object_Id__c=:EntityID 
                            order by LogDateTime__c desc,Order__c limit 100];
            
            //query to fetch all integration
            ERPConfigList = [select Id,ERP_System__c,Name from ERP_Config__c limit 100];//select Id,ERP_System__c,Name from ERP_Config__c
            IntegrationList = new List<SelectOption>();
            IntegrationList.add(new SelectOption('', '-- Select One --'));
            
            for(ERP_Config__c ERP :ERPConfigList )
            {
                IntegrationList.add(new SelectOption(ERP.Id, ERP.Name));
            }
           // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Entity_Sync_Filter_Detail1 .'+Entity_Sync_Filter_Detail));
            for(Entity_Sync_Filteration__c objEntity_Sync_Filteration :Entity_Sync_Filter_Detail)
            {
                 objEntity_Sync_Filteration.IsSync__c=false; 
            }
                                                          
            options = new List<SelectOption>(); 
            options.add(new SelectOption('', '-- Select One --'));

            targetoptions = new List<SelectOption>(); 
            targetoptions.add(new SelectOption('', '-- Select One --'));
            
            if(Entity_Mapping_Header.Target_Entity__c != null)
            {                               
                //SObjectType objToken = Schema.getGlobalDescribe().get(Namespace + Entity_Mapping_Header.Target_Entity__c);
                SObjectType objToken = Schema.getGlobalDescribe().get( Entity_Mapping_Header.Target_Entity__c);
               
                DescribeSObjectResult objDef = objToken.getDescribe();
                Map<String, SObjectField> objfields = objDef.fields.getMap(); 
                Set<String> fieldSet = objfields.keySet();
                   
                for(String s:fieldSet)
                {
                    SObjectField fieldToken = objfields.get(s);
                    DescribeFieldResult selectedField = fieldToken.getDescribe();
                   if ( selectedField.getName() =='External_UId__c' )
                        continue;
   
                    if ( selectedField.isCreateable() && selectedField.isAccessible() && !selectedField.IsCalculated())
                        targetoptions.add(new SelectOption(selectedField.getName(), selectedField.getName()));
                }
        
                //Code to get Salesforce object list
                List<Schema.SObjectType> SfObjects = Schema.getGlobalDescribe().Values();    
                sfObjectsList = new List<SelectOption>();
                sfObjectsList.add(new SelectOption('', '-- Select One --'));
                for(Schema.SObjectType SfObject : SfObjects)
                {
                    sfObjectsList.add(new SelectOption(SfObject.getDescribe().getName(),SfObject.getDescribe().getLabel()));
                }
    
                for(Entity_Detail__c Enity_Detail :Enity_Details  )
                {
                    options.add(new SelectOption(Enity_Detail.Field_APIName__c, Enity_Detail.Name+' ('+Enity_Detail.Field_APIName__c+')'));    
                }
        
                if (Entity_Fields_Mapping_Detail.size()==0 )
                {
                   // objToken = Schema.getGlobalDescribe().get(Namespace+Entity_Mapping_Header.Target_Entity__c);
                     objToken = Schema.getGlobalDescribe().get(Entity_Mapping_Header.Target_Entity__c);
                    objDef = objToken.getDescribe();
                    objfields  = objDef.fields.getMap(); 
                    fieldSet = objfields.keySet();
                    for(String s:fieldSet)
                    {
                        SObjectField fieldToken = objfields.get(s);
                        DescribeFieldResult selectedField = fieldToken.getDescribe();
                    }
                }
           }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'ImporterMaintenanceController',ex,true);
        }           
    }

    //Method to refresh fields 
    public void RefereshDetail()
    {
        try
        {   
            if(ERPConfig.Inactive__c == true)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Respective integration is inactive. Cannot sync records.'));
                return;
            }
            
            if(string.isBlank(Entity_Mapping_Header.Entity_Id__c))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Select Entity from the Popup.' ));
                return;
            }
            
            //delete [select Id from Contact];        
            showSaveButton=true; 
            Entity__c Enity =[select Id,Name,API_Method__c,Entity_Code__c From Entity__c  where Id =:Entity_Mapping_Header.Entity_Id__c];
            
             
            if(string.isBlank(Entity_Mapping_Header.Target_Entity__c))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Enter the target Entity' ));
                return;
            }

            list<Entity_Detail__c> Enity_Details =[select  Name,Data_Type__c,Field_APIName__c, Values__c,Field_Label__c From Entity_Detail__c where Entity_Id__c=: Enity.ID  ];
            
            Entity_Fields_Mapping_Detail =[select  Id,Name,ERP_Field__c,ERP_System__c,Salesforce_Field__c,Data_Type__c,IsSync__c,Default_Value__c,Salesforce_Field_Label__c 
                                          From Entity_Fields_Mapping_Detail__c where Entity_Mapping_Id__c =: Entity_Mapping_Header.Id ORDER BY Salesforce_Field_Label__c ASC, Salesforce_Field__c ASC ];
            
            // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning, 'Entity_Fields_Mapping_Detail when refresg '+jSon.serialize(Entity_Fields_Mapping_Detail)));
            
            options = new List<SelectOption>();
            
            options.add(new SelectOption('', '-- Select One --'));
                        
            for(Entity_Detail__c Enity_Detail :Enity_Details)
            {
                if(string.isNotBlank(Enity_Detail.Name))
                    options.add(new SelectOption(Enity_Detail.Field_APIName__c,Enity_Detail.Name +' ('+Enity_Detail.Field_APIName__c+')'));
                else
                    options.add(new SelectOption(Enity_Detail.Field_APIName__c,Enity_Detail.Field_APIName__c)); 
            }   

            Entity_Fields_Mapping_Detail__c objEFMD = new Entity_Fields_Mapping_Detail__c(); 
            
            
            //SObjectType objToken = Schema.getGlobalDescribe().get(NameSpace + Entity_Mapping_Header.Target_Entity__c);
            SObjectType objToken = Schema.getGlobalDescribe().get(Entity_Mapping_Header.Target_Entity__c);
            
            if(objToken == null)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning, 'Enter valid target Entity name.'));
                return;
            }
            
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap(); 

            Set<String> fieldSet = fields.keySet();
            map<string,string> existingMap=new  map<string,string>();

            for (Entity_Fields_Mapping_Detail__c EntityFieldsMappingDetail : Entity_Fields_Mapping_Detail )
                existingMap.put(EntityFieldsMappingDetail.Salesforce_Field__c,'Exist');

            integer i=0;
            for(String s:fieldSet)
            {
                SObjectField fieldToken = fields.get(s);
                DescribeFieldResult selectedField = fieldToken.getDescribe();

                if ( existingMap.get(selectedField.getName()) !=null)
                    continue; 

                if ( selectedField.getName() =='External_UId__c' )
                    continue;

                objEFMD = new Entity_Fields_Mapping_Detail__c();
                objEFMD.Salesforce_Field__c=selectedField.getName();
                objEFMD.Salesforce_Field_Label__c=selectedField.getLabel();
                objEFMD.IsSync__c=false;
                Schema.DisplayType fielddataType = selectedField.getType();
                objEFMD.Data_Type__c=   '' ;
                
                if(fielddataType == Schema.DisplayType.TextArea || fielddataType == Schema.DisplayType.STRING
                        || fielddataType == Schema.DisplayType.Picklist || fielddataType == Schema.DisplayType.REFERENCE)
                    objEFMD.Data_Type__c= 'string' ;
                else if(fielddataType == Schema.DisplayType.Date   )
                    objEFMD.Data_Type__c= 'Date' ;
                else if(fielddataType == Schema.DisplayType.DATETIME)
                    objEFMD.Data_Type__c= 'DateTime' ;
                else if(fielddataType == Schema.DisplayType.DOUBLE || fielddataType == Schema.DisplayType.CURRENCY)
                    objEFMD.Data_Type__c= 'Number' ;

                //Put other data type too and include default datatype (string) if missed data type or for new data type   
                if (selectedField.isCreateable() && selectedField.isAccessible() && !selectedField.IsCalculated())
                        targetoptions.add(new SelectOption(selectedField.getName(), selectedField.getName()));
                        
                Entity_Fields_Mapping_Detail.add(objEFMD);
                    
                    
            }
            
            //Code to get Salesforce object list
            List<Schema.SObjectType> SfObjects = Schema.getGlobalDescribe().Values();    
            sfObjectsList = new List<SelectOption>();
            sfObjectsList.add(new SelectOption('', '-- Select One --'));
            for(Schema.SObjectType SfObject : SfObjects)
            {
                sfObjectsList.add(new SelectOption(SfObject.getDescribe().getName(),SfObject.getDescribe().getLabel()));
            }
            
             //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning, 'Entity_Fields_Mapping_Detail when rferash 2 '+jSon.serialize(Entity_Fields_Mapping_Detail)));
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RefereshDetail',ex,true);
        }
    }

    //Method to save the field list
    public PageReference SaveSourceField()
    {
       
        try
        {  
            showSaveButton=true;
            ShowCloneButton = false;
            
            if(Entity_Mapping_Header.Target_Entity__c != null)
            {
                
               SObjectType objToken = Schema.getGlobalDescribe().get( Entity_Mapping_Header.Target_Entity__c);
                               
                if(objToken == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning, 'Enter valid target Entity name.'));
                    return null;
                }               
            }
                                   
            if(Entity_Mapping_Header.Integration_Key__c == null || Entity_Mapping_Header.Integration_Key__c == '-- Select One --' )
            {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning, 'Enter valid Integration'));
                    return null;
                    
            } 
            if(ActionName =='clone')
                cloneExistingRecords(); 
            
            list<Entity_Mapping_Header__c> EntityMappingHdrList = [select Id from Entity_Mapping_Header__c 
                                                                  where Source_Entity__c=:Entity_Mapping_Header.Source_Entity__c];
            
            if(Entity_Mapping_Header.Id == null)
            {
                
                if(EntityMappingHdrList.size()>0) 
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'Source entity name is already exists in Database.'));
                    return null;
                }
                insert Entity_Mapping_Header;
            }
            else        
                upsert Entity_Mapping_Header;
                         
            
            EntityID = Entity_Mapping_Header.Id;
            
            if(string.isBlank(EntityID))
                return null;
                
                                                  
           for(Entity_Fields_Map_Parent__c EFMP:Entity_Fields_Map_Parent)
            {
              
              for( Entity_Fields_Mapping_Detail__c EFMD:Entity_Fields_Mapping_Detail)
               {
                  if((EFMP.Target_Field__c==EFMD.Salesforce_Field__c) &&(EFMD.IsSync__c==true))
                   {
                     apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Duplicate target fields'));
                     return null;
                   }
               }
               if(EFMP.Target_Field__c == null || EFMP.Parent_Object_Name__c ==null)
               {
                 apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Please Select the Target field and Parent Object In RelationShip Tab '));                     
                 return null;
               }
            
            }
               
            Entity_Fields_Mapping_Detail__c objEFMD ;
            list<Entity_Fields_Mapping_Detail__c> objEFMDs = new list<Entity_Fields_Mapping_Detail__c> () ;

            delete [select Id from Entity_Fields_Mapping_Detail__c where Entity_Mapping_Id__c=: EntityID];
            
            
            //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Entity_Fields_Mapping_Detail :' +jSon.serialize(Entity_Fields_Mapping_Detail)));
            
            for (Entity_Fields_Mapping_Detail__c EntityFieldsMappingDetail : Entity_Fields_Mapping_Detail )
            {
                
                if ( EntityFieldsMappingDetail.IsSync__c ==false)
                    continue;
                    
                objEFMD = new Entity_Fields_Mapping_Detail__c();
                objEFMD.Data_Type__c = EntityFieldsMappingDetail.Data_Type__c;
                objEFMD.Entity_Mapping_Id__c = Entity_Mapping_Header.Id;
                objEFMD.ERP_Field__c = EntityFieldsMappingDetail.ERP_Field__c;
                objEFMD.IsSync__c = EntityFieldsMappingDetail.IsSync__c;
                objEFMD.Salesforce_Field__c = EntityFieldsMappingDetail.Salesforce_Field__c;
                objEFMD.Salesforce_Field_Label__c = EntityFieldsMappingDetail.Salesforce_Field_Label__c;
                objEFMD.Default_Value__c= EntityFieldsMappingDetail.Default_Value__c; 
                objEFMDs.Add(objEFMD); 
            }
            
           //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Entity_Fields_Mapping_Detail :' +jSon.serialize(objEFMDs)));
            upsert objEFMDs; 

            delete [select Id from Entity_Sync_Filteration__c where Entity_Mapping_Header_Id__c=: EntityID];
            list <Entity_Sync_Filteration__c>  objEntity_Sync_Filter_Details=new list <Entity_Sync_Filteration__c>();  

            Entity_Sync_Filteration__c objFFMD = new Entity_Sync_Filteration__c();
           
            for (Entity_Sync_Filteration__c objEntity_Sync_Filter_Detail : Entity_Sync_Filter_Detail )
            {
                objFFMD = new Entity_Sync_Filteration__c();
                objFFMD.Active__c=objEntity_Sync_Filter_Detail.Active__c;
                objFFMD.Entity_Mapping_Header_Id__c=Entity_Mapping_Header.Id;
                objFFMD.Field__c=objEntity_Sync_Filter_Detail.Field__c;
                objFFMD.Operator__c=objEntity_Sync_Filter_Detail.Operator__c;
                objFFMD.Value__c=objEntity_Sync_Filter_Detail.Value__c;
                objFFMD.IsSync__c=true;
                if(string.isNotBlank(objEntity_Sync_Filter_Detail.Field__c))
                    objEntity_Sync_Filter_Details.Add(objFFMD); 
                 
            }
             //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'objEntity_Sync_Filter_Details :' +objEntity_Sync_Filter_Details));
             upsert objEntity_Sync_Filter_Details;
            
            delete [select Id from Entity_Fields_Map_Parent__c where Entity_Fields_Map_Header_Id__c =: EntityID];
            list <Entity_Fields_Map_Parent__c>  objEntity_Fields_Map_Parents=new list <Entity_Fields_Map_Parent__c>();  

            Entity_Fields_Map_Parent__c objEFMP = new Entity_Fields_Map_Parent__c();
            integer counterOrder=1;
            for (Entity_Fields_Map_Parent__c objEntity_Fields_Map_Parent : Entity_Fields_Map_Parent )
            {               
                objEFMP = new Entity_Fields_Map_Parent__c();
                objEFMP.Order__c=counterOrder++;
                objEFMP.Entity_Fields_Map_Header_Id__c= Entity_Mapping_Header.Id;
                objEFMP.Source_Field__c=objEntity_Fields_Map_Parent.Source_Field__c;
                objEFMP.Target_Field__c=objEntity_Fields_Map_Parent.Target_Field__c;
                objEFMP.Parent_Object_Name__c=objEntity_Fields_Map_Parent.Parent_Object_Name__c;
                objEntity_Fields_Map_Parents.Add(objEFMP);     
            }
            upsert objEntity_Fields_Map_Parents;   
                                 
           // return null;
            
            //s:create CRON Expression 
            ScheduleImport objScheduleImport = new ScheduleImport(EntityID);
            if (Entity_Mapping_Header.Schedule_Start__c != null)
            {
                    String hour = String.valueOf(Entity_Mapping_Header.Schedule_Start__c.hour());
                    String min = String.valueOf(Entity_Mapping_Header.Schedule_Start__c.minute());
                    String ss = String.valueOf(Entity_Mapping_Header.Schedule_Start__c.second()); 
                    String dd = String.valueOf(Entity_Mapping_Header.Schedule_Start__c.day());
                    String mm = String.valueOf(Entity_Mapping_Header.Schedule_Start__c.month());
                    String yyyy = String.valueOf(Entity_Mapping_Header.Schedule_Start__c.year());
                    string singleSpace=' '; 
                    String nextFireTime='';
                    String ScheduleName='ScheduleImport:' + Entity_Mapping_Header.Source_Entity__c + '.ID:' + EntityID;
                    //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
                    //(*) means match any
                    //X means "every X"
                    //? ("no specific value") 
                    //Class runs every day at 1 PM.
                    //0 0 13 * * ?
                    
                    //if (! string.ISBLANK(Entity_Mapping_Header.Schedule_Id__c ) )
                    //{
                    list<CronJobDetail> CJDs= [Select Name, JobType, Id From CronJobDetail   WHERE Name = :ScheduleName and CronJobDetail.JobType = '7'];
                    if (CJDs.size()>0)
                    {
                        list<CronTrigger> CTs = [SELECT Id,TimesTriggered, NextFireTime  FROM CronTrigger WHERE CronJobDetailId = :CJDs[0].Id];
                        for(CronTrigger CT:CTs) 
                        {       
                                System.abortJob(CT.Id);
                        }       
                    }   
                    //}
                    
                    string jobID ; 
                    if (Entity_Mapping_Header.Schedule_Type__c =='Daily')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'SUN-SAT'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Hourly')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + '1/1' + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'SUN-SAT'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Monthly')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + dd  + singleSpace + '*' + singleSpace + '?'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Sunday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'SUN-SUN'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Monday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'MON-MON'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Tuesday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'TUE-TUE'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Wednesday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'WED-WED'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Thursday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'THU-THU'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Friday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'FRI-FRI'  ;
                    }
                    else if (Entity_Mapping_Header.Schedule_Type__c =='Weekly-Saturday')
                    {         
                            nextFireTime= '0'  + singleSpace + min + singleSpace + hour + singleSpace + '?'  + singleSpace + '*' + singleSpace + 'SAT'  ;
                    }
                    
                    if (nextFireTime!='')
                    {
                        jobID=system.schedule(ScheduleName , nextFireTime  , objScheduleImport);
                        Entity_Mapping_Header.Schedule_Id__c = jobID;
                        update Entity_Mapping_Header;
                    }       
            }
          
            PageReference rPage;     
            rPage = new PageReference('/apex/ImporterMaintenanceView?id='+EntityID); //'/apex/ImporterMaintenanceView?id='+EntityID
            rPage.getParameters().put('id',EntityID); 
            rPage.setRedirect(true); 
            return rPage;
            
         // return null;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'SaveSourceField',ex,true);
            return null;
        }
    }
    
    public PageReference CloneRecord()
    {
        string headerId = Apexpages.currentPage().getParameters().get('Id');
        PageReference rPage;     
        rPage = new PageReference('/apex/ImporterMaintenance?id='+headerId+'&Action=clone');
        rPage.getParameters().put('id',headerId); 
        rPage.setRedirect(true); 
        return rPage;
        
    }
     public void cloneExistingRecords()
     {
         Entity_Mapping_Header = Entity_Mapping_Header.clone();
         
         list<Entity_Fields_Mapping_Detail__c> Entity_Fld_Mapping_DtlCLnList = new list<Entity_Fields_Mapping_Detail__c>();
         list<Entity_Sync_Filteration__c> Entity_Sync_FilterCLnList = new list<Entity_Sync_Filteration__c>();
         list<Entity_Fields_Map_Parent__c> Entity_Fields_Map_Parentlist = new list<Entity_Fields_Map_Parent__c>(); 
         
         //cloning details for Entity_Fields_Mapping_Detail__c
         for(Entity_Fields_Mapping_Detail__c  Entity_Fields_Mapping_Detail_cloning:Entity_Fields_Mapping_Detail)
         {
                 Entity_Fields_Mapping_Detail_cloning=Entity_Fields_Mapping_Detail_cloning.clone();
                 Entity_Fld_Mapping_DtlCLnList.add(Entity_Fields_Mapping_Detail_cloning);
         }       
         Entity_Fields_Mapping_Detail=Entity_Fld_Mapping_DtlCLnList;
         
         //cloning details for Entity_Sync_Filteration__c
         for(Entity_Sync_Filteration__c Entity_Sync_Filter_Detail_cloning:Entity_Sync_Filter_Detail)
         {
                 Entity_Sync_Filter_Detail_cloning=Entity_Sync_Filter_Detail_cloning.clone();
                 Entity_Sync_FilterCLnList.add(Entity_Sync_Filter_Detail_cloning);
         }
         Entity_Sync_Filter_Detail = Entity_Sync_FilterCLnList;
         //cloning details for Entity_Fields_Map_Parent__c
         for(Entity_Fields_Map_Parent__c Entity_Fields_Map_Parent_cloning:Entity_Fields_Map_Parent)
         {
                 Entity_Fields_Map_Parent_cloning=Entity_Fields_Map_Parent_cloning.clone();
                 Entity_Fields_Map_Parentlist.add(Entity_Fields_Map_Parent_cloning);
         }
         Entity_Fields_Map_Parent = Entity_Fields_Map_Parentlist;
         
     }

    public void ImportNow()
    {
       
      if(ERPConfig.Inactive__c == true)
      {
        if(ShowError == true)
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Respective integration is inactive. Cannot sync records.'));
          return;
      }
      
      if(Entity_Mapping_Header.Active__c == false)
      {
        if(ShowError == true)
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Entity mapping is inactive. Please activate entity mapping to sync.'));
          return;
      }
      if(string.isNotBlank(Entity_Mapping_Header.Integration_Key__c))
        {
            ERP_Config__c Config = [select Synchronization__c from ERP_Config__c where Id=:Entity_Mapping_Header.Integration_Key__c];
            
           
            if(Config.Synchronization__c =='Salesforce to ERP')
            {
                if(ShowError == true)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'You cannot sync data. Please select syncronization either "Both" or "ERP to Salesforce" in Configuration screen.')); 
                return ;
            }   
        }   
    
      if(string.isNotBlank(string.valueOf(Entity_Mapping_Header.Size__c)))
          TOTALCOUNT =string.valueOf(Entity_Mapping_Header.Size__c);
          
          system.debug('TOTALCOUNT '+TOTALCOUNT);
       
        integer k;
        if(integer.valueOf(STARTAT)==1)
            k=1;
        else
            k=integer.valueOf(STARTAT)/integer.valueOf(TOTALCOUNT);        
               
       
        integer NoBatchProcessed=1;             
        Id batchinstanceid;
        list<AsyncApexJob > objAsyncApexJob;
        Log__c oLog;
        try
        {
           objAsyncApexJob = [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
           CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob where ApexClass.Name = 'BatchableImport' and 
           Status!='Completed' and Status!='Failed' and Status!='Aborted' order by CreatedDate desc];
           
           
         system.debug('objAsyncApexJob '+objAsyncApexJob);
          
            if (objAsyncApexJob.size()>=90 )
            {
                if (ShowError==true)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'There are already pending batches to be process. Please wait some time..'));
                }       
                else
                {
                    //oLog=new Log__c(LogDateTime__c=datetime.now(),Description__c = 'There are already pending batches to be process.' ,StackTrace__c= '',Object__c='Entity_Mapping_Header__c',Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntityID);
                    //insert oLog;
                }       
                return;
            }
                        
            LogMessage='';
            LogMessage += 'Overall remaining batch to be process: ' + objAsyncApexJob.size() + '.';
            ListOfJobId = new list<Id>();
            batchProcessed = true;
            
            objBatchableImport = new BatchableImport(EntityID,ShowError,STARTAT);
           
            batchinstanceid = database.executeBatch(objBatchableImport,1);
            system.debug('batchinstanceid '+batchinstanceid);
            ListOfJobId.add(batchinstanceid);
            system.debug('ListOfJobId '+ListOfJobId);
            LogMessage+= 'Total Records:' + objBatchableImport.TOTALRECORDCOUNT;
            //return;
        }
        catch(Exception ex){
                system.debug('ex');
            oLog=new Log__c(LogDateTime__c=datetime.now(),Description__c = ex.getMessage() ,StackTrace__c= ex +'' ,Object__c='Entity_Mapping_Header__c',Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntityID);
            insert oLog;
            return;
        }  
                   
        if (integer.valueOf(objBatchableImport.NextRec) > 0 )
        {
            NextRec=objBatchableImport.NextRec;
            system.debug('NextRec '+NextRec);
            while(integer.valueOf(NextRec) >0)
            {  
                if ((NoBatchProcessed + objAsyncApexJob.size() ) >= TotalAllowedBatches)
                {
                    /*
                    if (ShowError==true)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'There are already pending batches to be process.. Please wait some time...'));
                    }       
                    else
                    {
                        oLog=new Log__c(LogDateTime__c=datetime.now(),Description__c = 'There are already pending batches to be process.' + ShowError + NoBatchProcessed + objAsyncApexJob.size()  ,StackTrace__c= ClassName+'.ImportNow.321',Object__c='Entity_Mapping_Header__c',Data__c= '' ,Log_Type__c='SYNC',Object_Id__c=EntityID);
                        insert oLog;
                    }
                    */
                    return;
                }
                                
                //New Code Start
                                   
                Integer nextStart=((integer.valueOf(TOTALCOUNT ) * (k+1) ) + 1); 
                system.debug('nextStart '+nextStart);
                BatchableImport objBatchableImportRec;
                if (nextStart > Integer.valueof(objBatchableImport.TOTALRECORDCOUNT) || ( NoBatchProcessed + objAsyncApexJob.size() ) >= (TotalAllowedBatches-1))
                {
                    objBatchableImportRec = new BatchableImport(string.valueOf((integer.valueOf(TOTALCOUNT ) * k) + 1),objBatchableImport.TOTALRECORDCOUNT,true,objBatchableImport.Entity_Mapping_Header,objBatchableImport.Entity_Sync_Filter_Detail);
                   system.debug('objBatchableImportRec1 '+objBatchableImportRec);
                }
                else
                {
                     objBatchableImportRec = new BatchableImport(string.valueOf((integer.valueOf(TOTALCOUNT ) * k) + 1),objBatchableImport.TOTALRECORDCOUNT,false,objBatchableImport.Entity_Mapping_Header,objBatchableImport.Entity_Sync_Filter_Detail);
                    system.debug('objBatchableImportRec2 '+objBatchableImportRec);
                  //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'objBatchableImportRec: '+ objBatchableImportRec));
                }
                //BatchableImport objBatchableImportRec = new BatchableImport(string.valueOf((integer.valueOf(TOTALCOUNT ) * k) + 1),objBatchableImport.Entity_Mapping_Header,objBatchableImport.Entity_Sync_Filter_Detail);
                //New code End
                batchinstanceid = database.executeBatch(objBatchableImportRec,1);
                system.debug('batchinstanceid3 '+batchinstanceid);
                ListOfJobId.add(batchinstanceid); 
                system.debug('ListOfJobId3 '+ListOfJobId);
                k++;
                NoBatchProcessed++;
                nextStart=((integer.valueOf(TOTALCOUNT ) * k) + 1); 

                if (nextStart > Integer.valueof(objBatchableImport.TOTALRECORDCOUNT))
                {
                    break;
                }   
            }
        }
    }

    public SObject getNewSobject(String t)
    {
        // Call global describe to get the map of string to token.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        // Get the token for the sobject based on the type.
        Schema.SObjectType st = gd.get(t);
        // Instantiate the sobject from the token.
        Sobject s = st.newSobject();
        return s;
    }


    public void AddFilterRow()
    {
        try 
        {  
           // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Entity_Sync_Filter_Detail'+Entity_Sync_Filter_Detail)); 
             
            if(Entity_Sync_Filter_Detail.size() == 0)
                Entity_Sync_Filter_Detail = new list<Entity_Sync_Filteration__c>();
                
            Entity_Sync_Filteration__c  ObjEntity_Sync_Filter_Detail = new Entity_Sync_Filteration__c();            
            Entity_Sync_Filter_Detail.Add(ObjEntity_Sync_Filter_Detail); 
                              
        }                                  
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AddFilterRow',ex,true);
        }
    }

    public void RemoveFilterRow()
    {
        try 
        {  
            Integer j = 0;
            boolean IsDeleted = false;
           
            while (j < Entity_Sync_Filter_Detail.size())
            {
                if(Entity_Sync_Filter_Detail.get(j).IsSync__c == true)
                {
                    Entity_Sync_Filter_Detail.remove(j);
                    IsDeleted = true;                  
                }
                else
                    j++;
            }
            
            if(Entity_Sync_Filter_Detail.size() == 0)
                Entity_Sync_Filter_Detail = new list<Entity_Sync_Filteration__c>();


            if (IsDeleted==false)
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Please select row to delete.'));      

        }                                  
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RemoveFilterRow',ex,true);
        }
    }

    public void AddParentRow()
    {
        try 
        {               
            Entity_Fields_Map_Parent__c  objEntity_Fields_Map_Parent = new Entity_Fields_Map_Parent__c();
            Entity_Fields_Map_Parent.Add(objEntity_Fields_Map_Parent); 

        }                                  
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AddParentRow',ex,true);
        }
    }
    public void RemoveParentRow()
    {
        try 
        {  
            Integer j = 0;
            boolean IsDeleted = false;

             while (j <Entity_Fields_Map_Parent.size())
            {
                if(Entity_Fields_Map_Parent.get(j).IsSync__c == true)
                {
                    Entity_Fields_Map_Parent.remove(j);
                    IsDeleted = true;
                }
                else
                    j++;
            }
        
        if (IsDeleted==false)
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Please select row to delete.'));      

        }                                  
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RemoveParentRow',ex,true);
        }
    }

    public boolean batchProcessed=false;
    public string LogMessage {get;set;}     
    public integer logCount=0;     

    public void getMessage()
    {        
        LogMessage='';
        if(batchProcessed)
        {
            Double itemsProcessed=0;
            Double totalItems=0 ;
            for(AsyncApexJob a : [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
                                  CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name 
                                  From AsyncApexJob where ApexClass.Name = 'BatchableImport' and Id IN : ListOfJobId  order by CreatedDate desc ]){
                itemsProcessed += a.JobItemsProcessed;
                totalItems += a.TotalJobItems;
            }
                        
            //Determine the percent complete based on the number of batches complete and set message
            if(totalItems == 0)
            {
                //A little check here as we don't want to divide by 0.
                LogMessage += 'Current Batch 0% Completed.' ;
            }
            else
            {
                LogMessage += 'Current Batch ' + String.valueof(((itemsProcessed  / ListOfJobId.size()) * 100.0).intValue())+'% Completed (Total Batch:' + ListOfJobId.size() +' Total Records:' +  objBatchableImport.TOTALRECORDCOUNT +')';
            }

        }
                 
        Double itemsProcessed=0;
        Double totalItems=0 ;
        list<AsyncApexJob > objAsyncApexJob = [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
                                               CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob where ApexClass.Name = 'BatchableImport' and 
                                               Status!='Completed' and Status!='Failed' and Status!='Aborted' order by CreatedDate desc];

                LogDetails  = [select Data__c,Description__c,Log_Type__c,StackTrace__c,Object__c,LogDateTime__c from Log__c where Object_Id__c=:EntityID order by LogDateTime__c desc Limit 100];
                LogMessage += 'Overall remaining batch to be process: ' + objAsyncApexJob.size() + '.';
                
                if (!string.isBlank(objBatchableImport.TOTALRECORDCOUNT))
                {
                        //LogMessage+= 'Total Records:' + objBatchableImport.TOTALRECORDCOUNT;
                }       
              
    }
    
    public PageReference RedirectOncancel()
    {
        PageReference rPage;     
        rPage = new PageReference('/apex/EntityMapping');            
        rPage.setRedirect(true); 
        return rPage;   
    }
    
    public PageReference EditMapping()
    {
        PageReference rPage;
        string headerId = Apexpages.currentPage().getParameters().get('Id');     
        rPage = new PageReference('/apex/ImporterMaintenance?id='+headerId);
        rPage.getParameters().put('id',headerId); 
        rPage.setRedirect(true); 
        return rPage; 
    }
    
    public PageReference clearLog()
    {
        try
        {
            string headerId = Apexpages.currentPage().getParameters().get('Id');     
            delete LogDetails;
            LogDetails  = [select Data__c,Description__c,Log_Type__c,StackTrace__c,Object__c,LogDateTime__c from Log__c where Object_Id__c=:EntityID order by LogDateTime__c desc limit 100];
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Log deleted successfully.'));
        }
        catch(Exception ex)
        {
            //CustomException exc= new CustomException(ClassName,'deleteRecord',ex,true);
        }
        return null;
    }
    
    public PageReference deleteRecord()
    {
        string headerId = Apexpages.currentPage().getParameters().get('Id');
        PageReference rPage;
        try
        {       
                if(string.isNotBlank(headerId))
                {
                    delete [select Id from Entity_Fields_Mapping_Detail__c where Entity_Mapping_Id__c=: headerId];
                    delete [select Id from Entity_Sync_Filteration__c where Entity_Mapping_Header_Id__c=: headerId];
                    delete [select Id from Entity_Fields_Map_Parent__c where Entity_Fields_Map_Header_Id__c =: headerId];
                    delete Entity_Mapping_Header;                     
                        rPage = new PageReference('/apex/EntityMapping');            
                        rPage.setRedirect(true);                        
                }
                return rPage; 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'deleteRecord',ex,true);
            return null;
        }
        
    }    

}