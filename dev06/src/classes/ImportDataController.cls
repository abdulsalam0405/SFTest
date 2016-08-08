public with sharing class ImportDataController 
{
   /* public list<ERP> SageERPs {get;set;}
    public ERP_Config__c oConfiguration;
    public String ERPSystem{get;set;}
    public String ConfigObjectPrefix{get;set;}
    public Date UpdateDate {get;set;}
    public List<SelectOption> ERPOptions {get;set;}
    public static String ERPXMLJson {get;set;} 
    public static list<Map<String, String>> AccountRecordList =new list<Map<String, String>>();
    public static list<Map<String, String>> ContactRecordList =new list<Map<String, String>>();
    public static list<Map<String, String>> ShipToRecordList =new list<Map<String, String>>();
    public static list<Map<String, String>> ProductRecordList =new list<Map<String, String>>();
    public static list<Map<String, String>> PriceBookEntryList =new list<Map<String, String>>();
    public static list<String> ProductCodes =new list<String>();
    public static list<Map<String, String>> AddressRecordList = new list<Map<String, String>>();

    public static list<Map<String, String>> ProductFamRecordList =new list<Map<String, String>>();
    public static list<String> ProductFamCodes =new list<String>();
    public Boolean bAdministration{get;set;}
    public String NameSpace {get;set;} 
    public String IntegrationNames {get;set;} 
    public String ProfileName {get;set;} 
    public String ERPSystemName {get;set;}
    public String IntegrationKey {get;set;}
    public String ERPCompanyCode {get;set;}
    public String Synchronization{get;set;} 
    public String DefaulIntegrationID{get;set;}
    public String DefaulIntegrationName{get;set;}

    //ClassName
    private static final string className='ImportDataController';

    //parameteres for import routine
    public string ImportIntegrationKey {get;set;}
    public string ImportType{get;set;}
    public string ImportEntity{get;set;}
    public string Param1{get;set;}
    public string Param2 {get;set;}
    public string STARTAT{get;set;}
    public string TOTALCOUNT{get;set;}
    public string FAILCOUNT{get;set;}
    public string NextRec{get;set;}
    public string ErrorMessage{get;set;}
    
   
    public ImportDataController (ApexPages.StandardController controller) 
    {   
        try
        {
            FAILCOUNT='0';
            NextRec='0';
            ErrorMessage='';
            if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
            {   // Check if the user has read access on the Profile.name
                if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                    ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                }
            } 

            NameSpace=Utility.FetchNameSpace();
            Security_Matrix__c SM = Security_Matrix__c.getInstance();
            bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);
            ERPOptions = new List<SelectOption>();
            ERPOptions.add(new SelectOption(String.escapeSingleQuotes(''),String.escapeSingleQuotes('')));
            ConfigObjectPrefix = Utility.getSobjectKeyPrefix('GUMU_Lite__ERP_Config__c');         
            oConfiguration = (ERP_Config__c)controller.getRecord();
            LoadParams();
            List<ERP_Config__c> lstERPConfig =[select id,Name from ERP_Config__c where Default__c =true limit 1];
            DefaulIntegrationID ='';
            DefaulIntegrationName='';
            if(lstERPConfig.size() > 0)
            {
                DefaulIntegrationID = lstERPConfig[0].Id;
                DefaulIntegrationName = lstERPConfig[0].Name;
            }
        }
        catch(Exception ex)
        {
            CustomException exc = new CustomException (className,'ImportDataController',ex,true);
        }
    }

    //Get the content stored in the resource document by providing the name of resource.
    private static String getResourceContent(String staticResourceName)
    {
        String result='';
        try
        {
            // Check if the user has read access on the StaticResource.Bodyfield
            if (!Schema.sObjectType.StaticResource.fields.Body.isAccessible())
                return '';
            
            StaticResource sr = [select Body from StaticResource where Name = :staticResourceName];
            result= sr.Body.toString();
            return result;
        }
        catch(Exception ex)
        {
            result='';
            CustomException exc = new CustomException (className,'getResourceContent',ex,true);
            return result;
        }
    }

    //Prepares the various configuration settings for all the ERP systems provided by the product//
    public void LoadParams()
    {
        try
        {
            string XMLContent=getResourceContent('ParamConfig');
            list<ERP> ERPs =new list<ERP>(); 
            ReadAndWriteXML.XmlNode objXmlNode = ReadAndWriteXML.ParseXmlString(XMLContent);
            list<ReadAndWriteXML.XmlNode> lstNodes = objXmlNode.ChildXmlNodes;

            for(ReadAndWriteXML.XmlNode Node : lstNodes)
            {
                ERP currentERP=new ERP();
                string ERPName= String.escapeSingleQuotes(Node.Attributes.get('NAME'));
                ERPOptions.add(new SelectOption(ERPName,ERPName));
                currentERP.ERPName =ERPName;
                list<Param>currentERPParams=new list<Param>();

                list<ReadAndWriteXML.XmlNode> ParamNodes =Node.ChildXmlNodes[0].ChildXmlNodes;
                for(ReadAndWriteXML.XmlNode ParamNode: ParamNodes )
                {
                    Param ERPParam=new Param();
                    ERPParam.ParamName=ParamNode.NodeValue;
                    ERPParam.ParamCode=ParamNode.Attributes.get('CODE');
                    ERPParam.Length=string.isBlank(ParamNode.Attributes.get('LENGTH')) ? 0 : Integer.valueOf(ParamNode.Attributes.get('LENGTH'));
                    ERPParam.Width=string.isBlank(ParamNode.Attributes.get('WIDTH')) ? 0 : Integer.valueOf(ParamNode.Attributes.get('WIDTH'));
                    ERPParam.Required = ParamNode.Attributes.get('REQUIRED') == 'TRUE' ? true : false;

                    ERPParam.ParamType=ParamNode.Attributes.get('TYPE');
                    if (! string.isBlank(ParamNode.Attributes.get('OPTIONS')))
                        ERPParam.Options= ParamNode.Attributes.get('OPTIONS').split(',');
                    currentERPParams.add(ERPParam);                
                }
                currentERP.Params=currentERPParams;
                ERPs.add(currentERP);

            }
            ERPXMLJson=JSON.serialize(ERPs);
            SageERPs=ERPs;
        }
        catch(Exception ex)
        {
            CustomException exc = new CustomException (className,'LoadParams',ex,true);
        }        
    }

    //Remote action method to get configuration record//
    @RemoteAction
    public static configuration FetchConfig (String IntegrationKey)
    {
        ERP_Config__c ERPConfig;
        configuration config; 
        string IntInfo= '';
        try
        {
            ERPConfig=[SELECT id,Name,ERP_Customer_Last_Sync_Date__c,Inactive__c,Web_Service_URL__c,ERP_System__c,ERP_Company_Code__c,
                 Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c, ERP_Product_Last_Sync_Date__c 
                 FROM ERP_Config__c Where id=: IntegrationKey limit 1];

            config =new configuration();
            config.Id=ERPConfig.id;
            config.Name=ERPConfig.Name;
            config.WebServiceURL=ERPConfig.Web_Service_URL__c;
            IntInfo  += string.isNotBlank(ERPConfig.Integration_Information__c) ? ERPConfig.Integration_Information__c : '';

            if(string.isNotBlank(ERPConfig.Integration_Information_2__c))
            { 
                if(ERPConfig.Integration_Information_2__c.startsWith('NAME') || ERPConfig.Integration_Information_2__c.startsWith('VALUE'))
                    IntInfo  += ' ';
            }   

            IntInfo  += string.isNotBlank(ERPConfig.Integration_Information_2__c) ? ERPConfig.Integration_Information_2__c : '';

            if(string.isNotBlank(ERPConfig.Integration_Information_3__c))
            { 
                if(ERPConfig.Integration_Information_3__c.startsWith('NAME') || ERPConfig.Integration_Information_3__c.startsWith('VALUE'))
                    IntInfo  += ' ';
            } 
            
            IntInfo  += string.isNotBlank(ERPConfig.Integration_Information_3__c) ? ERPConfig.Integration_Information_3__c : '';
            config.IntegrationInformation=IntInfo;
            config.Inactive=ERPConfig.Inactive__c;
            config.ERPSystem=ERPConfig.ERP_System__c;
            config.CustomerLastSyncDate=ERPConfig.ERP_Customer_Last_Sync_Date__c;
            config.ProductLastSyncDate = ERPConfig.ERP_Product_Last_Sync_Date__c;
            config.CompanyCode=ERPConfig.ERP_Company_Code__c;
            return config;
        }
        catch(Exception ex)
        {
            CustomException exc = new CustomException (className,'FetchConfig',ex,false);
            return config;
        }               
    }
        
        
    public void ImportData()
    {
        if (ImportEntity=='Customer')
                ImportCustomer();
    }
    
    //method to import the customers for selected company with provided filter criteria.//
    public void ImportCustomer()
    {
        NextRec='0';
        ErrorMessage='';
        Database.UpsertResult [] dbUpsertResult;
        try 
        {
                //check Account field level security 
             if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable() 
                || !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()
                || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable()
                || !Schema.sObjectType.Account.fields.External_UId__c.isUpdateable())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                                                         'Insufficient access to update Fields'));
                   return ;
                }
                //check Contact field level security 
               if (!Schema.sObjectType.Contact.fields.External_UId__c.isUpdateable())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,                                                         'Insufficient access to update Fields'));
                   return ;
                } 
                
                if (!Schema.sObjectType.Ship_To__c.fields.External_UId__c.isUpdateable())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,                                                         'Insufficient access to update Fields'));
                   return ;
                } 
            
                if (STARTAT=='' ||STARTAT=='1')
                    FAILCOUNT='0';
                    
                baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework();
                map<string,list<object>> AttribParams=new map<string,list<object>> ();
                AttribParams=Utility.getAttribParameters(STARTAT , '100' , ImportIntegrationKey, 'Customer', '' , Helper.MappingPurpose.SYNC); 
                Helper.GUMU_Response resGUMU_Response =integrationFramework.getData(integrationFramework.PrepareFieldParam(Param1,Param2), AttribParams);
                
                if(resGUMU_Response.statusCode != '200')
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'Unable to connect ERP System!'));
                    return;
                }
                
                list<Account> objAccount=(list<Account>) resGUMU_Response.responseSFData;
                list<Contact> objContact=null;
                list<Ship_To__c> objAdress=null;
                

                if (objAccount!=null)
                {
                    if (objAccount.size()>0) 
                        dbUpsertResult = Database.Upsert(objAccount,Account.Fields.External_UId__c,false);
                
                    //Get the contacts
                    objContact= integrationFramework.GetContacts(ImportIntegrationKey,'Contacts',resGUMU_Response);
                    //In case of Sage300 no Address will be return but directly imported as it required saperate call
                    objAdress=integrationFramework.GetAddresses(ImportIntegrationKey,'ShipTo',resGUMU_Response);
                }

            if (objContact!=null)
            { 
                if (objContact.size()>0) 
                    Database.Upsert(objContact,Contact.Fields.External_UId__c,false);
            }
            
            if (objAdress!=null)
            { 
                if (objAdress.size()>0) 
                    Database.Upsert(objAdress,Ship_To__c.Fields.External_UId__c,false);
            }    
            
            if (STARTAT=='')
                STARTAT='1';
                
            TOTALCOUNT=resGUMU_Response.TotalRecord;
            if (resGUMU_Response.TotalRecord == '' || resGUMU_Response.TotalRecord == null)
                NextRec        ='0';
            else
            {
                Integer nextStart=Integer.valueof(STARTAT) + Integer.valueof(resGUMU_Response.itemPerPage);
                STARTAT= string.valueOf(nextStart);
                if(nextStart > Integer.valueof(resGUMU_Response.TotalRecord))
                    NextRec      ='0';
                else
                        NextRec      ='1';
            }
        }
        catch (Exception Ex)
        {
                CustomException exc = new CustomException (className,'ImportCustomers',ex,true);
                ErrorMessage=Ex.getMessage();
        }
    }
    
    //Get Already Linked Products for Listing//
    public PageReference GetERPName() 
    {
        try
        {
            // Check if the user has read access on the ERP_Config__c fields
            if (!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible() 
                    || !Schema.sObjectType.ERP_Config__c.fields.ERP_Company_Code__c.isAccessible()
                    || !Schema.sObjectType.ERP_Config__c.fields.ID.isAccessible()){
                return null;
            }

            ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Synchronization__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
            ERPSystemName= oIntegration.ERP_System__c;
            ERPCompanyCode = oIntegration.ERP_Company_Code__c;
            Synchronization = oIntegration.Synchronization__c;
            return null;
        }
        catch (Exception ex)
        {
                CustomException exc = new CustomException (className,'GetERPName',ex,true);
                return null;
        }               
    }

    //
    public class ERP 
    {
        public string ERPName{get;set;}
        public list<Param> Params{get;set;}       
    }

    public class configuration
    {
        public string Id {get;set;}
        public string Name {get;set;}
        public string CompanyCode {get;set;}
        public string ERPSystem {get;set;}
        public string IntegrationInformation {get;set;}
        public Boolean Inactive {get;set;}
        public Date CustomerLastSyncDate {get;set;}
        public Date ProductLastSyncDate {get;set;}
        public String WebServiceURL {get;set;}
    }

    public class Param
    {
        public string ParamName{get;set;}
        public string ParamCode{get;set;}
        public integer Length{get;set;}
        public integer Width{get;set;}
        public string ParamType{get;set;}
        public Boolean Required {get;set;}
        public list<string> Options{get;set;}
    }*/
}