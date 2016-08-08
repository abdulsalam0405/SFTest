public with sharing class ConfigurationListController{
        
    public static BaseIntegrationFramework oFramework ;
    public ERP_Config__c oConfiguration;
    public list<ERP_Config__c> oConfigurationList{get;set;}
    public String ERPSystem{get;set;}
    public String ConfigObjectPrefix{get;set;}
    public String ProfileName {get;set;}
    public Boolean bAdministration{get;set;} 

public ConfigurationListController(ApexPages.StandardController controller) 
    {
        
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
            }
        }
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);
        
         oConfigurationList = [SELECT Id,ERP_System__c,Web_Service_URL__c,Synchronization__c,Integration_Information__c,
                                                        Integration_Information_2__c,Integration_Information_3__c,Name,Inactive__c, Default__c 
                                                        FROM ERP_Config__c limit 200 ];
    }
    
    public PageReference ConfigDetails()
     {
        string ConID= ApexPages.currentPage().getParameters().get('ConID');
        string pageMode= ApexPages.currentPage().getParameters().get('Mode');
        PageReference rPage ;
        if(pageMode == 'Edit' ||pageMode == 'View')
        {
           rPage = new PageReference('/apex/Configuration?id='+ConID+'&mode='+pageMode);
           rPage.getParameters().put('id',ConID); 
        }      
        else
        {
             rPage = new PageReference('/apex/Configuration');     
        }
                     
        rPage.setRedirect(true);
        return rPage;
     }
     
     public PageReference deleteConfiguration()
     {
                                
        string ConID= ApexPages.currentPage().getParameters().get('ConID');
        string pageMode= ApexPages.currentPage().getParameters().get('Mode');
        
        oConfigurationList = new list<ERP_Config__c>();
        ERP_Config__c  oConfiguration = [SELECT Id FROM ERP_Config__c where Id=:ConID limit 1 ];
            
        if(pageMode == 'Delete')
        {
            
            list<GUMU_Lite__Entity_Fields_Map_Parent__c> parent= [SELECT ID from GUMU_Lite__Entity_Fields_Map_Parent__c where Integration_Key__c=:oConfiguration.Id];
            delete parent; 
            
            list<GUMU_Lite__Entity_Sync_Filteration__c> filter= [SELECT ID from GUMU_Lite__Entity_Sync_Filteration__c where Integration_Key__c=:oConfiguration.Id];
            delete filter;   
            
            list<GUMU_Lite__Entity_Fields_Mapping_Detail__c> detail= [SELECT ID from GUMU_Lite__Entity_Fields_Mapping_Detail__c where Integration_Key__c=:oConfiguration.Id];
            delete detail;
            
            list<GUMU_Lite__Entity_Mapping_Header__c> header= [SELECT ID from GUMU_Lite__Entity_Mapping_Header__c where Integration_Key__c=:oConfiguration.Id];
            delete  header;
            
            list<GUMU_Lite__Entity_Detail_Field_Values__c> val= [SELECT ID from GUMU_Lite__Entity_Detail_Field_Values__c where Integration_Key__c=:oConfiguration.Id];
            delete val;
            
            list<GUMU_Lite__Entity_Key__c> key= [SELECT ID from GUMU_Lite__Entity_Key__c where Integration_Key__c=:oConfiguration.Id];
            delete key;
                
            list<GUMU_Lite__Entity_Detail__c> dtl= [SELECT ID from GUMU_Lite__Entity_Detail__c where Integration_Key__c=:oConfiguration.Id];
            delete dtl; 
            
            list<GUMU_Lite__Entity__c> CC= [SELECT ID from GUMU_Lite__Entity__c where Integration_Key__c=:oConfiguration.Id];
            delete CC;
            
            //delete data pages
            list<Data_Page__c> DataPageList= [SELECT ID from Data_Page__c where Integration_Key__c=:oConfiguration.Id];
            
            list<Data_Page_Detail__c> DataPageDetail = new list<Data_Page_Detail__c>();
            list<Data_Page_Section__c> DataPageSec = new list<Data_Page_Section__c>();
            
            if(DataPageList.size()>0)
            {
                for(Data_Page__c dataPage :DataPageList )
                {
                    DataPageDetail = new list<Data_Page_Detail__c>();
                    DataPageSec = new list<Data_Page_Section__c>();
                    
                    DataPageDetail = [select Id from Data_Page_Detail__c where Data_Page_Id__c =:dataPage.Id];
                    DataPageSec = [select Id from Data_Page_Section__c where Data_Page_Id__c =:dataPage.Id];
                    
                    delete DataPageDetail;
                    delete DataPageSec;
                }
                delete DataPageList;
            }
                                  
            delete [select id from ERP_Config__c where Id=:ConID];
            
        }
        
        oConfigurationList = [SELECT Id,ERP_System__c,Web_Service_URL__c,Synchronization__c,Integration_Information__c,
                                                        Integration_Information_2__c,Integration_Information_3__c,Name,Inactive__c, Default__c 
                                                        FROM ERP_Config__c limit 200 ]; 
                                                             
        return null;
     }

}