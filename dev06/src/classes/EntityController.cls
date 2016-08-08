global with sharing class EntityController {

    public Entity__c Enity {get;set;}
    public boolean showSaveButton {get;set;}
    public list<Entity_Detail__c> Enity_Details {get;set;}
    public list<Entity_Detail_Field_Values__c> Entity_Detail_Field_Values  {get;set;}
    public list<Entity_Key__c> Entity_Keys  {get;set;}
    public string ErrorMessage;
    private static final string ClassName='EntityController';
    private string EntityID;
    public  List<SelectOption> options {get;set;}
    public  List<SelectOption> GroupOptions {get;set;}
    public string APIName {get;set;}
    public  List<SelectOption> IntegrationList {get;set;}
    public list<ERP_Config__c>ERPConfigList{get;set;}
    public string IntegrationKey {get;set;}
     public string IntegrationName{get;set;}
    public Entity__c Enity1  = new Entity__c();//{get;set;}
          
    public EntityController(ApexPages.StandardController controller) 
    {
        try
        {  
            showSaveButton=false; 
            EntityID= ApexPages.currentPage().getParameters().get('Id');
            string IntName= Apexpages.currentPage().getParameters().get('Integration_Key__c');
            if(string.isNotBlank(EntityID))
            { 
                Enity =[select Id,Name,API_Method__c,Entity_Code__c,Group_Name__c,Parent_Entity_Id__c,Entity_Detail_Id__c,Integration_Key__c
                                         From Entity__c  where Id=:EntityID];
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:Enity.Integration_Key__c:'+Enity.Integration_Key__c ));
                if(string.isNotBlank(Enity.Integration_Key__c))
                {
                    IntegrationName = [select Name from ERP_Config__c where Id =:Enity.Integration_Key__c].Name;
                    
                }   
            }
            else
                Enity = new Entity__c();
                            
            Enity_Details               =[select  Name,Data_Type__c,Field_APIName__c,Field_Label__c, Values__c,Source_Type__c,Group_Name__c From Entity_Detail__c where Entity_Id__c=: EntityID ];
            Entity_Detail_Field_Values  =[select  Key__c,Value__c From Entity_Detail_Field_Values__c where Entity_Id__c=: EntityID];
            Entity_Keys                 =[select Id, isSyncKey__c,Key_Field__c,Key_Order__c From Entity_Key__c where Entity_Id__c=: EntityID];
                        
            //if (Enity_Details.size()==0)
            //    RefereshDetail(); 
           
            options = new List<SelectOption>(); 
            options.add(new SelectOption('', '-- Select One --'));
            for(Entity_Detail__c Enity_Detail :Enity_Details  )
            {
                options.add(new SelectOption(Enity_Detail.Field_APIName__c, Enity_Detail .Field_APIName__c));    
            }

            list<ERP_Config__c> ERPConfigList = [select Id,Name,ERP_System__c from ERP_Config__c where Inactive__c =false];//select Id,ERP_System__c,Name from ERP_Config__c limit 100
            IntegrationList = new List<SelectOption>();
            IntegrationList.add(new SelectOption('', '-- Select One --'));
            for(ERP_Config__c ERP :ERPConfigList )
            {
                IntegrationList.add(new SelectOption(ERP.Id, ERP.Name));
            }
            
            GroupOptions = new List<SelectOption>(); 
            GroupOptions.add(new SelectOption('', '-- Select One --'));
            
            if(Enity_Details.size()>0)
            {
                string ExstnggroupName='';
                for(Entity_Detail__c Enity_Detail:Enity_Details)
                {
                    string groupName = string.valueOf(Enity_Detail.Group_Name__c);
                    if(string.isNotBlank(groupName))
                    {
                        if(groupName !=ExstnggroupName)
                        {
                            ExstnggroupName=groupName;
                            GroupOptions.add(new SelectOption(groupName,groupName));
                        }
                    }
                }
            }
                                     
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'EntityController',ex,true);
        }           
    }
    
    //Method to refresh fields
    public void RefereshDetail()
    {
        try
        {  
            showSaveButton=true;               
            string APIMethod= string.valueOf(Enity.API_Method__c);
            if(string.isBlank(APIMethod))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Enter value in API Method.'));
                return ;
            }
            IntegrationKey=Enity.Integration_Key__c;
            if(string.isBlank(Enity.Integration_Key__c))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Select integration from the list.'));
                return;
            }


            Helper.GUMU_Response oGUMU_Response;

            baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(IntegrationKey);
           //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'integrationFramework  '+integrationFramework));
             /*if (Test.isRunningTest())
             {
                oGUMU_Response.statusCode = '0';
                oGUMU_Response.responseERPData = '<title>abc</title>';
             }
             else*/
                oGUMU_Response =integrationFramework.ReadSchema(APIMethod,IntegrationKey);
                        
            if(oGUMU_Response.statusCode =='0')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, oGUMU_Response.statusMessage));
            }
            else if(oGUMU_Response.statusCode !='201' && oGUMU_Response.statusCode !='200')
            {
                if (oGUMU_Response.statusCode =='101' || oGUMU_Response.statusCode =='100')
                {
                     //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, oGUMU_Response.statusMessage));
                     //return;
                }
                else if(oGUMU_Response.responseERPData !=null || oGUMU_Response.responseERPData !='')
                {                	
                   ErrorMessage = Utility.parse(oGUMU_Response.responseERPData,'title'); 
                   ErrorMessage = Utility.parse(oGUMU_Response.responseERPData,'h1'); 
                   ErrorMessage = Utility.parse(oGUMU_Response.responseERPData,'h2'); 
                   ErrorMessage = Utility.parse(oGUMU_Response.responseERPData,'h3');                     
                } 
            }
             
            else
            {
                if (Test.isRunningTest())
                {
                    list<Entity_Detail__c> Entity_Details = new list<Entity_Detail__c>() ;
                    Entity_Detail__c Entity_Detail = new Entity_Detail__c ();
                    Entity_Detail.Name= 'Title';
                    Entity_Detail.Data_Type__c='Char';
                    Entity_Detail.Field_APIName__c='Title';
                    Entity_Detail.Values__c=null;
                    Entity_Detail.Group_Name__c='abc';
                    Entity_Details.add(Entity_Detail);
                    oGUMU_Response.responseSFData=Entity_Details;
                    Enity_Details=(list<Entity_Detail__c>)oGUMU_Response.responseSFData;
                }
                else
                    Enity_Details=(list<Entity_Detail__c>)oGUMU_Response.responseSFData;
                    
                //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'responseSFData '+oGUMU_Response.responseSFData));
                //list<String> GroupNames = new list<String>();
                Map<String,String> GroupNameMap = new Map<String,String>();
                
                GroupOptions = new List<SelectOption>(); 
                GroupOptions.add(new SelectOption('', '-- Select One --'));
                for(Entity_Detail__c Enity_Detail :Enity_Details  )
                {
                    if(Enity_Detail.Group_Name__c != '')
                    {
                        if(!GroupNameMap.containsKey(Enity_Detail.Group_Name__c))
                        {
                            GroupNameMap.put(Enity_Detail.Group_Name__c,Enity_Detail.Group_Name__c);
                            GroupOptions.add(new SelectOption(Enity_Detail.Group_Name__c, Enity_Detail.Group_Name__c));
                        }
                    }    
                }
                
            options = new List<SelectOption>(); 
            options.add(new SelectOption('', '-- Select One --'));
            for(Entity_Detail__c Enity_Detail :Enity_Details  )
            {
                options.add(new SelectOption(Enity_Detail.Field_APIName__c, Enity_Detail .Field_APIName__c));    
            }
                                 
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RefereshDetail',ex,true);
        }
    }
    
    public void AddMaintainanceKeyRow()
    {
        try 
        {  
            Entity_Key__c  ObjEntity_Key = new Entity_Key__c();
            Entity_Keys.Add(ObjEntity_Key); 
        }                                  
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AddMaintainanceKeyRow',ex,true);
        }
    }
    
    public void RemoveKeyRow()
    {
        try 
        {  
            Integer j = 0;
            boolean IsDeleted = false;
            
            while (j < Entity_Keys.size())
            {
              if(Entity_Keys.get(j).isSyncKey__c == true)
              {
                Entity_Keys.remove(j);
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
            CustomException exc= new CustomException(ClassName,'RemoveFilterRow',ex,true);
        }
    }
    
    //Method to save the field list
    public pageReference SaveSourceField()
    {
        try
        {             
            showSaveButton=false;
            
            List<Entity__c > entitylst =[select Id,Integration_Key__c from Entity__c where Entity_Code__c =:Enity.Entity_Code__c ];
            Enity.Name = Enity.Entity_Code__c;
            
            IntegrationKey = Enity.Integration_Key__c ;
              

            
            if(Entity_Keys.Size()>0)
            {   string EntityKey='';
                system.debug('Entity_Keys '+Entity_Keys);
                for (Entity_Key__c objEntity_Keys : Entity_Keys )
                {
                    system.debug('objEntity_Keys '+objEntity_Keys);
                    EntityKey = string.valueOf(objEntity_Keys.Key_Field__c);
                    if(string.isBlank(EntityKey))
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'No Key selected in Primary key tab. cannot insert blank record.'));      
                        return null;
                    }
                }
            }
            
            
            if(Enity.Id == null)
            {
                if(entitylst.size()>0)
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'Entity code is already exists in Database.'));      
                     return null;      
                }
                insert Enity;
            }
            else    
                upsert Enity;
                            
            list<Entity_Detail__c> EDs =new list<Entity_Detail__c> ();
            Entity_Detail__c  ED;
            list<Entity_Detail_Field_Values__c> EDFVs =new list<Entity_Detail_Field_Values__c> ();
            Entity_Detail_Field_Values__c EDFV;
            list <Entity_Key__c>  objEntityKeyList =new list <Entity_Key__c>();  
            Entity_Key__c objEntityKey = new Entity_Key__c();
            
            delete [select Id from Entity_Detail__c  where Entity_Id__c=:Enity.Id ];
            for (Entity_Detail__c Enity_Detail : Enity_Details)
            {
                ED = new Entity_Detail__c();
                ED.Data_Type__c =Enity_Detail.Data_Type__c;
                ED.Entity_Id__c   = Enity.Id  ;
               // ED.External_UId__c= Enity.Id + '-'  + Enity_Detail.Field_APIName__c; 
                ED.Field_APIName__c =Enity_Detail.Field_APIName__c;
                ED.Field_Label__c=Enity_Detail.Field_Label__c;
                ED.Source_Type__c =Enity_Detail.Source_Type__c;
                ED.Values__c =Enity_Detail.Values__c;
                ED.Name=Enity_Detail.Name;
                ED.Group_Name__c=Enity_Detail.Group_Name__c;
                //ED.Integration_Key__c=Enity.Integration_Key__c;  //Enity
                EDs.Add(Ed);
            }

            upsert EDs;
                               
            //code to insert entity keys
            delete [select Id from Entity_Key__c where Entity_Id__c=: Enity.Id];
            
            if(Entity_Keys.Size()>0)
            {
                
                integer i=1;    
                for (Entity_Key__c objEntity_Keys : Entity_Keys )
                {
                    objEntityKey = new Entity_Key__c();
                    objEntityKey.Key_Field__c=objEntity_Keys.Key_Field__c;
                    objEntityKey.Entity_Id__c=Enity.Id;              
                    objEntityKey.isSyncKey__c=false;
                    objEntityKey.Key_Order__c=i;
                    objEntityKeyList.Add(objEntityKey); 
                    i++;
                }
                upsert objEntityKeyList;
            }
            PageReference rPage = new PageReference('/apex/EntityView?id='+Enity.Id);
            rPage.getParameters().put('id',Enity.Id); 
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
    
    public PageReference CancelUpsert()
    {
        EntityID= ApexPages.currentPage().getParameters().get('Id');
        PageReference rPage;
        if(string.isNotBlank(EntityID))
        {
            rPage = new PageReference('/apex/EntityView?Id='+EntityID);
            rPage.getParameters().put('id',EntityID);
        }
        else
        {
            rPage = new PageReference('/apex/EntityList');
        }
         
        rPage.setRedirect(true);
        return rPage;
    }
    
    public PageReference EditRecord()
    {
        string entityId = Apexpages.currentPage().getParameters().get('Id');       
        
        PageReference rPage;
        rPage = new PageReference('/apex/Entity?Id='+entityId);
        rPage.setRedirect(true);
        return rPage;
    }    
    
    public PageReference deleteRecord()
    {
        string entityId = Apexpages.currentPage().getParameters().get('Id');       
        if(string.isNotBlank(entityId))
        {
            delete [select Id From Entity_Key__c where Entity_Id__c=: entityId];
            delete [select Id From Entity_Detail__c where Entity_Id__c=: entityId];
            delete [select Id from Entity__c where Id =:entityId];
        }
        
        PageReference rPage;
        rPage = new PageReference('/apex/EntityList');
        rPage.setRedirect(true);
        return rPage;
    }          
   
}