global with sharing class PromoteCustomerSage300Controller {
 public String Taxgroup300 {get;set;} 

    public String Category300 {get;set;}
    public String IntegrationName {get;set;} 
    public String Synchronization{get;set;}
    public String ERPCompanyCode {get;set;}
    public String IntegrationKey {get;set;}
   
    public Account act {get;set;}
    public String IntegrationId{get;set;}
    public string Namespace{get;set;}
   
    public String AccountId{get;set;}
    public String ProfileName {get;set;}
   

    public String Tax_ruleObjectPrefix {get;set;}
    public Boolean customerNoDisable{get;set;}
    public String CategoryObjectPrefix{get;set;}
    public String ConfigObjectPrefix {get;set;}
    public String DefaulIntegrationID{get;set;}
    public Boolean bShowPromoteCustomer{get;set;} 

    public string ERPSystemName{get;set;}
    public boolean ispromoted{get;set;}
    public string DefaulIntegrationName{get;set;}
    public string configId{get;set;}
    
    public String CustomerNo300 {get;set;}
 
    private static final string ClassName='PromoteCustomerSage300Controller';
    
    public list<ERP_Config__c> ConfigList {get;set;}

    public PromoteCustomerSage300Controller (ApexPages.StandardController controller)
    {
        NameSpace = Utility.FetchNameSpace();
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) 
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
        }
        
        this.act=(Account)controller.getRecord();
        AccountId=ApexPages.currentPage().getParameters().get('id'); 
        

        if( AccountId != null)
            this.act =[select Id,ERP_Customer_Number__c,Integration_Key__c,Type from Account where Id=:AccountId];
           
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bShowPromoteCustomer = Boolean.valueOf(SM.Promote_Customer__c);
        ConfigId='';
       
        IntegrationId= act.Integration_Key__c;
        IntegrationName='';

        map<string,list<object>> SFObjectLists = new map<string,list<object>> ();

        ConfigList = new list<ERP_Config__c>();
        if(IntegrationId !='' && IntegrationId!=null)
       {
            
            ConfigList=[SELECT Id, Name,ERP_System__c,Web_Service_URL__c,Integration_Information__c,
                        Integration_Information_2__c,Integration_Information_3__c From ERP_Config__c Where Id =: IntegrationId limit 1];
            
            if(ConfigList.size() > 0)
            {
	            ERPSystemName =ConfigList[0].ERP_System__c ;
	
	            IntegrationName=ConfigList[0].Name;
	            IntegrationId = ConfigList[0].Id;
	            ConfigId=ConfigList[0].Id;
	            IntegrationKey = IntegrationId;
	
	            DefaulIntegrationName = ConfigList[0].ERP_System__c ; 
	            DefaulIntegrationID = ConfigList[0].Id;
            }
        }

        else
        {
            ConfigList = [SELECT Id, Name,ERP_System__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,
                          Integration_Information_3__c From ERP_Config__c Where Default__c =true limit 1];
            
            if(ConfigList.size() > 0 && ConfigList.size() == 1)
            {
                ERPSystemName = ConfigList[0].ERP_System__c ;   
                IntegrationName = ConfigList[0].Name;
                IntegrationId = ConfigList[0].Id;
                IntegrationKey = IntegrationId;
                GetERPName();
                DefaulIntegrationName = ConfigList[0].ERP_System__c ; 
                ConfigId=ConfigList[0].Id;
                DefaulIntegrationID = ConfigList[0].Id;
            }
        }

        if(string.isNotBlank(this.act.ERP_Customer_Number__c) && ConfigList.size() > 0)
            CustomerDetails(this.act.Integration_Key__c,this.act.ERP_Customer_Number__c,this.act.Type,ConfigList);

        ConfigObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Config__c');
        CategoryObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'CustomerCategory__c');
        Tax_ruleObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Tax_Group__c');

    }

    // fetching customer details from ERP
    public void CustomerDetails(String IntegrationKey, String UniqueKey, String AccountType,list<ERP_Config__c> ConfigList)
    {
        
       // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'UniqueKey'+UniqueKey));
        
        try
        {
            String[] CustomerNo = UniqueKey.split('-');
            if(IntegrationKey !=null)  
            {
                String EndPoint = ConfigList[0].Web_Service_URL__c;
                ERPSystemName = ConfigList[0].ERP_System__c;
                Map<String,String> ParamMap = Utility.FormatERPInfo(ConfigList[0].Integration_Information__c,ConfigList[0].Integration_Information_2__c,ConfigList[0].Integration_Information_3__c);

                string PublicationName = 'arCustomersFinder';
                
                baseIntegrationFramework integrationFramework= new Sage300IntegrationFramework();//IntegrationFactory.getIntegrationFramework();
                map<string,list<object>> AttribParams=new map<string,list<object>> ();
                
                AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'Customer', '' , Helper.MappingPurpose.DISPLAY);
                
                Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
                if(Test.isRunningTest()) 
                {                       
                    list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                    map<string,string>ERPDataMap = new map<string,string>();
                    ERPDataMap.put('CODETAXGRP','CALIF');
                    ERPDataMap.put('IDGRP','WHL');                  
                    ERPDataMapList.add(ERPDataMap);
                    resGUMU_Response.ERPDataMap=ERPDataMapList;
                    resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
                    
                }
                else
                    resGUMU_Response =integrationFramework.getData(integrationFramework.PrepareFieldParam(UniqueKey,UniqueKey), AttribParams);
               
                if(resGUMU_Response.statusCode =='100')             
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));
                else if(resGUMU_Response.statusCode =='0') 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resGUMU_Response.statusMessage));                               
                else if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Service Temporarily Unavailable.please check the Services.'));
                else
                {
                    CustomerNo300 = UniqueKey.toUpperCase();
                    
                    for (map<string,string> pmap : resGUMU_Response.ERPDataMap)
                    {
                        for(string fieldKey : pmap.keySet()) 
                        {
                            if(fieldKey=='CODETAXGRP')
                                Taxgroup300=pmap.get(fieldKey) ;
                            else if (fieldKey=='IDGRP')
                                Category300=pmap.get(fieldKey) ;
                        }
                    } 
                }
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'CustomerDetails',ex,true);
        }    
    }
        
        //This funciton is use to promote customer in Sage 300 ERP
    public pageReference PromoteCustomer_300()
    {
        try
        {   
            ispromoted=false;        
            map<String,String> PromotionFields = new map<String,String>();
            //String IntegrationKey = ConfigId;
            string sCustomerNumber = '';
            Dom.Document doc;
            ReadAndWriteXML.XmlNode objXmlNode ;        
            String CompanyCode='';
            string Password='';
            string UserID='';
            string AccountType= '';
            string PublicationName = 'arCustomersFinder';
            boolean IsErrorExist= false;
            
            if(CustomerNo300 == null || CustomerNo300 == '')
            {  
                if(customerNoDisable == false )
                {         
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Customer No is required field.')); 
                    IsErrorExist=true;
                }
            }

            if(Category300== null ||Category300== '')
            {             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Category required field.'));
                IsErrorExist=true;
            }

            if(Taxgroup300 == null || Taxgroup300 == '')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Taxgroup required field.')); 
                IsErrorExist=true;        
            }
            sCustomerNumber=CustomerNo300;
            if (IsErrorExist)
            {   
                return null;
            }

            list<ERP_Config__c> oIntegration = [SELECT Name, Synchronization__c,ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
             
            if(oIntegration.size()>0)
            {
                if(oIntegration[0].Synchronization__c =='ERP to Salesforce')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'You cannot sync data. Please select syncronization either "Both" or "Salesforce to ERP" in Configuration screen.'));
                    return null;
                }
            }
            else
            {
                
            }   
           
            list<Account> CurrentAccount = [Select 
                                            a.Type, a.Website, a.ShippingStreet,a.ShippingState,a.ShippingPostalCode,a.ShippingLongitude,a.ShippingLatitude,a.ShippingCountry,a.ShippingCity,
                                            a.Phone,a.ParentId,a.Name,a.MasterRecordId,a.Id,a.Fax,a.ERP_Customer__c,a.Integration_Key__c,a.Description,a.ERP_Customer_Number__c ,
                                            a.ERP_Company_Code__c,a.BillingStreet,a.BillingState,a.BillingPostalCode,a.BillingLongitude,a.BillingLatitude,a.BillingCountry,a.BillingCity
                                            From Account a Where a.Id=:AccountId limit 1 ];
            
           
            list<Contact> Contacts = [Select 
                                      Id,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,
                                      MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Phone,Fax,MobilePhone,HomePhone,
                                      OtherPhone,Email,Title,Birthdate,Description,ERP_Contact_Code__c 
                                      From Contact Where AccountId =:AccountId limit 100];


            list<Ship_To__c> Addresses = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
                                          Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
                                          Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
                                          From Ship_To__c where Account_Id__c =:AccountId LIMIT 100];
                                          
                                          
            
            
            PromotionFields.put('CustomerNo300',CustomerNo300);
            PromotionFields.put('Category',Category300);
            PromotionFields.put('Tax_group',Taxgroup300);

            CompanyCode=oIntegration[0].ERP_Company_Code__c;  
            Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration[0].Integration_Information__c,oIntegration[0].Integration_Information_2__c,oIntegration[0].Integration_Information_3__c);


            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            list<object>  AttribParam= new list<object>();
            AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Customer', '' , Helper.MappingPurpose.POST); 

            AttribParam= new list<object>();
            AttribParam.add(PublicationName);
            AttribParams.put('ERPFuncName',AttribParam);
            
            AttribParam= new list<object>();
            AttribParam.add('GETData');
            AttribParams.put('PostDataXml',AttribParam);

            map<string,list<object>> SFObjectLists = new map<string,list<object>> ();

            SFObjectLists.put('Accounts',CurrentAccount);
            SFObjectLists.put('Contacts',Contacts);
            SFObjectLists.put('Addresses',Addresses);
            
            
            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            baseIntegrationFramework integrationFramework= new Sage300IntegrationFramework();
            Helper.GUMU_Response resGUMU_Response = new Helper.GUMU_Response();
            
            if (Test.isRunningTest())
            {
                string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                resGUMU_Response.responseERPData=TestResponseData;
                resGUMU_Response.statusMessage='Ok';
                resGUMU_Response.statusCode =string.valueof(200);
            }
            else
                resGUMU_Response =integrationFramework.PostData(IntegrationKey,'Customer1', SFObjectLists,PromotionFields,AttribParams);

            if(resGUMU_Response.statusCode =='100')
            {               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));
            }
            else if(resGUMU_Response.statusCode =='0')
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resGUMU_Response.statusMessage));
            }
            else if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Service Temporarily Unavailable.please check the Services.'));
            }
           
            else if(resGUMU_Response.statusCode =='201' || resGUMU_Response.statusCode =='200')
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Promoted customer successfully from Salesforce to ERP'));
                ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,CustomerNo300,null); 
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while promoting customer from Salesforce to ERP:'+ resGUMU_Response.statusCode +'.'+ resGUMU_Response.statusMessage));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'' + Utility.parse(resGUMU_Response.responseERPData,'message')));
                return null;
            }  


           /* map<String,String> mapProData =resGUMU_Response.SFDataMap;
            string getResponse=resGUMU_Response.responseERPData;
           
           // result rs = (result)getCustomerNumber(getResponse);   
            
            if( rs.Error == 'null' || rs.Error == null)
            {
                if (rs.ContactCodes!=null)
                    ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,CustomerNo300,rs.ContactCodes);
                else
                    ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,CustomerNo300,null);  
            }
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, ''+ rs.Error));  */
            

        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'PromoteCustomer_300',ex,true);
        }
        return null;
    }

    //This function is used to unlink the customer
    public Pagereference UnlinkAccount()
    {
    
     // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'UnlinkAccount'));
        try
        {
            // Check if the user has update access on the Contact.Status__c field
            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable() 
                    || !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()
                    || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                        'Insufficient access to update Fields'));
                return null;
            }
            
            act.ERP_Customer_Number__c='';
            act.Integration_Key__c='';
            act.ERP_Company_Code__c='';
            
            update act;

           
            /*PageReference acctPage = new PageReference ('/'+act.id);
            acctPage.setRedirect(true);
            return acctPage;*/
            
            return null;
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
           
        }  
         return null;      
    }

  
    public PageReference GetCategoryValues()
    {
        try
        {
            map<string,string> CategoryValues = new map<string,string>();
            string IntegrationKey = ConfigId;
            string Category = Category300;

            baseIntegrationFramework integrationFramework=new Sage300IntegrationFramework();
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'CategoryList', '' , Helper.MappingPurpose.DISPLAY); 
            map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();

            listParams.add(Category);
            listParams.add(Category);

            parameter.put(string.valueOf(Helper.Operator.RANGE),listParams);
            fieldParameters.put('BCGCOD',parameter);
            
            Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
            if(Test.isRunningTest()) 
            {                       
                list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                map<string,string>ERPDataMap = new map<string,string>();
                ERPDataMap.put('REFCOU','abc');                 
                ERPDataMapList.add(ERPDataMap);
                resGUMU_Response.ERPDataMap=ERPDataMapList;
                resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
                
            }
            else
                resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
                
            customerNoDisable = false;
            if (resGUMU_Response.ERPDataMap !=null)
            {

                for (map<string,string> pmap : resGUMU_Response.ERPDataMap)
                {
                    if(pmap.get('REFCOU') !=null )
                    {
                        if (pmap.get('REFCOU') !='' )
                            customerNoDisable = true;
                    }
                }   
            }

        }

        catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'GetCategoryValues',ex,true);

        }
        return null;

    }

    public boolean UpdateCustomer(String IntegrationKey,String CompanyCode,String AccId,String CustomerNo,list<map<String,String>> ContactCodes)
    {
        boolean isSuccess=false;
        try
        {
            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable()|| 
                    !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()|| 
                    !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Fields'));
                return null;
            }

            ERP_Config__c oIntegration = [SELECT ERP_System__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
            string ERPSystemName = oIntegration.ERP_System__c;

            Account Act = [Select a.External_UId__c, a.Id,a.ERP_Customer__c,a.Integration_Key__c,a.ERP_Customer_Number__c ,
                           a.ERP_Company_Code__c
                           From Account a Where a.Id=:AccId limit 1];

            Act.Integration_Key__c = IntegrationKey;   

            Act.ERP_Customer_Number__c = CustomerNo;

            Act.ERP_Company_Code__c = CompanyCode;
            Act.External_UId__c = IntegrationKey +'-'+CustomerNo;
            Act.Sync_To_ERP__c=false;

            update Act;
            
            isSuccess=true;


            return isSuccess;

        }
        catch(Exception ex)
        {
            //system.debug('ex='+ex);      
            CustomException exc= new CustomException (className,'UpdateCustomer',ex,true);
            isSuccess=false;
            return isSuccess;
        }
    }

    public PageReference GetERPName() 
    {  
        // Check if the user has read access on the ERP_Configuration__c fields
        if (!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible() 
                || !Schema.sObjectType.ERP_Config__c.fields.ERP_Company_Code__c.isAccessible()
                || !Schema.sObjectType.ERP_Config__c.fields.ID.isAccessible()){
            return null;
        }
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'IntegrationKey:'+IntegrationKey));
        //system.debug('IntegrationKey '+IntegrationKey);
        ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Synchronization__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
        ERPSystemName= oIntegration.ERP_System__c;
        ERPCompanyCode = oIntegration.ERP_Company_Code__c;
        Synchronization = oIntegration.Synchronization__c;
        if(Synchronization =='ERP to Salesforce')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'You cannot sync data. Please select syncronization either "Both" or "Salesforce to ERP" in Configuration screen.' ));
            DefaulIntegrationID='';
            DefaulIntegrationName='';
        }
        return null;      
    }     

    public PageReference FetchERPName() 
    {  
        // Check if the user has read access on the ERP_Configuration__c fields
        if (!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible() 
                || !Schema.sObjectType.ERP_Config__c.fields.ERP_Company_Code__c.isAccessible()
                || !Schema.sObjectType.ERP_Config__c.fields.ID.isAccessible()){
            return null;
        }
        //system.debug('IntegrationKey '+IntegrationKey);
        ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Synchronization__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
        ERPSystemName= oIntegration.ERP_System__c;
        ERPCompanyCode = oIntegration.ERP_Company_Code__c;
        Synchronization = oIntegration.Synchronization__c;
        return null;      
    }     

    public class result
    {
        public string Error{get;set;}
        public string CustomereNumber{get;set;}
        public list<map<string,string>> ContactCodes{get;set;}  
    }

    public static object getCustomerNumber(string getResponse)
    {
        result rs = new result();
        map<string,string> CustomerDtls = new  map<string,string>();

        if(getResponse ==null || getResponse =='')
            return rs;


        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode ; 
        doc = new Dom.Document();
        doc.load(getResponse);                          
        Dom.XMLNode Envelope = doc.getRootElement();       
        Dom.XMLNode Body= Envelope.getChildElements()[0];       

        String strResponse='';
        string sReturn = '0';

        for(Dom.XMLNode childNode : Body.getChildElements()) 
        {
            for(Dom.XMLNode subchildNode : childNode.getChildElements()) 
            {

                if(subchildNode.getName() == 'resultXml')
                {
                    strResponse = string.valueof(subchildNode.getText());
                    if(strResponse !=null ||strResponse!='')
                        break;                              
                }
                else if(subchildNode.getName() == 'message' && childNode.getAttribute('id','')=='id1' && (strResponse ==null ||strResponse==''))
                {
                    strResponse = string.valueof(subchildNode.getText());
                    strResponse ='Error '+strResponse;
                    rs.Error = strResponse;
                    return rs;
                }               
            }           
        }

        list<ReadAndWriteXML.XmlNode> recordList = new list<ReadAndWriteXML.XmlNode>();
        ReadAndWriteXML.XmlNode eachrecords = new ReadAndWriteXML.XmlNode();

        objXmlNode = new ReadAndWriteXML.XmlNode();

        if(strResponse != '')
        {
            objXmlNode = ReadAndWriteXML.ParseXmlString(strResponse);

            list<ReadAndWriteXML.XmlNode> lstchildNode = objXmlNode.ChildXmlNodes;

            for(ReadAndWriteXML.XmlNode readCldNode:lstchildNode)
            {
                string strGetID = readCldNode.Attributes.get('ID');
                string strAttrName = readCldNode.Attributes.get('NAME');

                /*if(strGetID=='BPC0_1' || strGetID=='BPP0_1')
                {
                    list<ReadAndWriteXML.XmlNode> lstFldNodes = readCldNode.ChildXmlNodes;

                    for(ReadAndWriteXML.XmlNode lstFldNode:lstFldNodes )
                    {
                        if(lstFldNode.Attributes.get('NAME') == 'BPCNUM')
                        {
                            rs.CustomereNumber = lstFldNode.NodeValue;
                            break;
                        }
                    }
                }
                else if(strGetID =='CNTC_1')
                {

                    map<string,string> CntCodesMap = new map<string,string>();
                    list<map<string,string>> lstCntCodes = new list<map<string,string>>();

                    string ContactCode ='';
                    string firstName ='';
                    string lastName =''; 

                    list<ReadAndWriteXML.XmlNode> lstLineNodes = readCldNode.ChildXmlNodes;
                    for(ReadAndWriteXML.XmlNode linNode:lstLineNodes )
                    {
                        list<ReadAndWriteXML.XmlNode> lstFldNodes = linNode.ChildXmlNodes;
                        for(ReadAndWriteXML.XmlNode FldNodes:lstFldNodes)
                        {
                            CntCodesMap = new map<string,string>();
                            if(FldNodes.Attributes.get('NAME') == 'CCNCRM')
                            {                                                               
                                ContactCode=FldNodes.NodeValue;
                                //break;
                            }
                            else if(FldNodes.Attributes.get('NAME') == 'CNTLNA')
                            {                                                               
                                lastName=FldNodes.NodeValue;
                                if(lastName =='')
                                    lastName='-';
                                //break;
                            }
                            else if(FldNodes.Attributes.get('NAME') == 'CNTFNA')
                            {                                                               
                                firstName=FldNodes.NodeValue;
                                CntCodesMap.put('ContactName',firstName+' '+lastName);
                                CntCodesMap.put('ContactCode',ContactCode);
                                break;
                            }
                        }
                        lstCntCodes.add(CntCodesMap);
                    }
                    rs.ContactCodes = lstCntCodes;                                     
                }*/
            }
        }
        return rs;


    }

}