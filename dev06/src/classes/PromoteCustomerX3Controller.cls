global with sharing class PromoteCustomerX3Controller {
    public String ERPSystemName {get;set;}
    public String IntegrationKey {get;set;}

    public Account act {get;set;}

    public String ConfigObjectPrefix {get;set;}
    public String NameSpace {get;set;}
    public String ERPCompanyCode {get;set;}
    public String Synchronization{get;set;}

    //Lookup X3
    public String CategoryObjectPrefix {get;set;}
    public String CurrencyObjectPrefix {get;set;}
    public String LanguageObjectPrefix {get;set;}
    public String Tax_ruleObjectPrefix {get;set;}
    public String Terms_CodeObjectPrefix {get;set;}
    public String SalesPersonObjectPrefix {get;set;}

    public String CustomerNoX3 {get;set;}
    public String CategoryX3 {get;set;}
    public String CurrencyX3 {get;set;}
    public String LanguageX3 {get;set;}
    public String TaxRuleX3 {get;set;}
    public String TermsCodeX3 {get;set;}
    public String SalesPersonX3 {get;set;}

    public String Salesperson {get;set;}
    public String TermsCode {get;set;}
    public String ShipMethod {get;set;}
    public String TaxSchedule {get;set;}
    public String ConfigId {get;set;} 
    public String Division  {get;set;}
    public String IntegrationId {get;set;}
    public String IntegrationName {get;set;}   
    public Boolean bShowPromoteCustomer{get;set;}  
    public String ProfileName {get;set;}

    public String DefaulIntegrationID{get;set;}
    public String DefaulIntegrationName{get;set;}

    public String AccountId{get;set;} 
    public boolean ispromoted{get;set;}
    
    public Boolean customerNoDisable{get;set;}
    
    private static final string ClassName='PromoteCustomerX3Controller';
    
    public list<ERP_Config__c> ConfigList {get;set;}

    public PromoteCustomerX3Controller(ApexPages.StandardController controller)
    { 
         NameSpace = Utility.FetchNameSpace();
        ConfigObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Config__c');
        CategoryObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'CustomerCategory__c');
        CurrencyObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Currency__c');
        LanguageObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Language__c');
        Tax_ruleObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'TaxRule__c');
        Terms_CodeObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Terms_Code__c');
        SalesPersonObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Salesperson__c');
        
       
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) 
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
        }
        
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bShowPromoteCustomer = Boolean.valueOf(SM.Promote_Customer__c);

        this.act=(Account)controller.getRecord();

        AccountId= ApexPages.currentPage().getParameters().get('Id'); 
          
        if( AccountId != null)
            this.act =[select Id,ERP_Customer_Number__c,Integration_Key__c,Type from Account where Id=:AccountId];
        

        ConfigId='';
        Division='';
        Salesperson ='';
        TermsCode ='';
        ShipMethod ='';
        TaxSchedule ='';
        IntegrationId= act.Integration_Key__c;
        IntegrationName='';
        ConfigList = new list<ERP_Config__c>();
        if(string.isNotBlank(IntegrationId))
        {
            list<ERP_Config__c> cfg=[SELECT Id, Name,ERP_System__c From ERP_Config__c Where Id =: IntegrationId limit 1];
            if(cfg.size()>0)
            {
                ERPSystemName =cfg[0].ERP_System__c ;
                IntegrationName=cfg[0].Name;
                ConfigId=cfg[0].Id;
                IntegrationKey = cfg[0].Id;
            }
            else
                IntegrationId='';
            
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
                //GetERPName();
                DefaulIntegrationName = ConfigList[0].Name; 
                ConfigId=ConfigList[0].Id;
                DefaulIntegrationID = ConfigList[0].Id;
            }
        }

        if(string.isNotBlank(this.act.ERP_Customer_Number__c))
            CustomerDetails(IntegrationId,this.act.ERP_Customer_Number__c,this.act.Type);

        AssignSalesperson(); 
        customerNoDisable = false; 
    }
    
    public void CustomerDetails(String IntegrationKey, String UniqueKey, String AccountType)
    {
        
        system.debug('AccountType '+AccountType);
        try
        {
            string[] CustomerNo = UniqueKey.split('-');
            if(string.isNotBlank(IntegrationKey))   
            {
                CustomerNoX3 = UniqueKey;
                ERP_Config__c oIntegration = [SELECT ERP_System__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
                                
                String EndPoint = oIntegration.Web_Service_URL__c;
                ERPSystemName = oIntegration.ERP_System__c;
                Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
                string Version = ParamMap.get('version');
    
                if(ERPSystemName == 'SageERPX3')
                {
                    string PublicationName = '';
                    Utility.ProgramList sbr = new Utility.ProgramList();
                    
                    if(AccountType == 'Prospect')
                        PublicationName = sbr.YGTPROSDTL;
                    else
                        PublicationName = sbr.YGTCUSTDTL;
            
            
            
            
                    baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(IntegrationKey);
                    map<string,list<object>> AttribParams=new map<string,list<object>> ();
                    AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'Customer', '' , Helper.MappingPurpose.DISPLAY); 
                    
                    list<object> obj = new list<object>();
                    obj.add(AccountType) ;
                    AttribParams.put('AccountType',obj);
                    Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
                    if(Test.isRunningTest()) 
                    {                       
                        list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                        map<string,string>ERPDataMap = new map<string,string>();
                        ERPDataMap.put('BCGCOD','US');
                        ERPDataMap.put('LAN','ENG');
                        ERPDataMap.put('CUR','USD');
                        ERPDataMap.put('VACBPR','NTX');
                        ERPDataMap.put('PTE','CH30NET');
                        ERPDataMap.put('PRE','abc');
                        ERPDataMapList.add(ERPDataMap);
                        resGUMU_Response.ERPDataMap=ERPDataMapList;
                        resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
                        
                    }
                    else
                        resGUMU_Response =integrationFramework.getData(integrationFramework.PrepareFieldParam(UniqueKey,UniqueKey), AttribParams);
                    
                    system.debug('resGUMU_Response_cust '+resGUMU_Response);
                   
                   system.debug('ERPDataMap '+json.serialize(resGUMU_Response.ERPDataMap));
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
                    else
                    {
                        system.debug('ERPDataMap  '+resGUMU_Response.ERPDataMap);
                        for (map<string,string> pmap : resGUMU_Response.ERPDataMap)
                        {
                            
                            for(string fieldKey : pmap.keySet()) {
                                if (fieldKey=='BCGCOD')
                                    CategoryX3=pmap.get(fieldKey) ;
                                else if (fieldKey=='LAN')
                                    LanguageX3=pmap.get(fieldKey) ;
                                else if(fieldKey=='CUR')
                                    CurrencyX3=pmap.get(fieldKey) ;
                                else if(fieldKey=='VACBPR')
                                    TaxRuleX3=pmap.get(fieldKey) ;
                                else if(fieldKey=='PTE')
                                    TermsCodeX3=pmap.get(fieldKey) ;
                                /*else if(fieldKey=='PRE')
                                     SalesPersonX3=pmap.get(fieldKey) ;
                                    */
                                 else if(fieldKey=='REP')
                                    {
                                        SalesPersonX3=pmap.get(fieldKey) ;
                                        system.debug('SalesPersonX334 '+SalesPersonX3);
                                    }
                            }
                        } 
                    }  
                }    
            }
       }
       catch (Exception ex)
       {
             CustomException exc= new CustomException(ClassName,'CustomerDetails',ex,true);
       }             
    }
    
    //Unlink Accounts
    public Pagereference UnlinkAccount()
    {
        try
        {
            // Check if the user has update access on the Contact.Status__c field
            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable() 
                    || !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()
                    || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Fields'));
                return null;
            }
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Insufficient access to update Fields'+act));
            //act.Id = act.Id;
            act.ERP_Customer_Number__c='';
            act.Integration_Key__c='';
            act.ERP_Company_Code__c='';
            act.External_UId__c='';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'act :'+act));
            update act;
            return null;
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'UPDATE :'+act));
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
        return null;
                
    }
    
    
    
    //Assgined sales person
    public Pagereference AssignSalesperson()
    {
        try
        {
        
            Id UserID = UserInfo.getUserId();
            Salesperson='';
            // Check if the user has read access on the Salesperson_Mapping__c fields
            if (!Schema.sObjectType.Salesperson_Mapping__c.fields.User_Id__c.isAccessible() 
                    || !Schema.sObjectType.Salesperson_Mapping__c.fields.Salesperson_Id__c.isAccessible()
                    || !Schema.sObjectType.Salesperson_Mapping__c.fields.Integration_Key__c.isAccessible()
                    || !Schema.sObjectType.Salesperson_Mapping__c.fields.Id.isAccessible()){
                return null;
            }
    
            list<Salesperson_Mapping__c> Mapping = [Select User_Id__c, Salesperson_Id__c, Id,Integration_Key__c
                                                    From Salesperson_Mapping__c
                                                    where User_Id__c =: UserID AND Integration_Key__c =:ConfigId limit 1];
    
            if(Mapping.size() > 0)
            {
                // Check if the user has read access on the Salesperson_Mapping__c fields
                if (!Schema.sObjectType.Salesperson__c.fields.Salesperson_Description__c.isAccessible() 
                        || !Schema.sObjectType.Salesperson__c.fields.Salesperson_Code__c.isAccessible()
                        || !Schema.sObjectType.Salesperson__c.fields.Email__c.isAccessible()
                        || !Schema.sObjectType.Salesperson__c.fields.Integration_Key__c.isAccessible()
                        || !Schema.sObjectType.Salesperson__c.fields.AR_Division_Code__c.isAccessible()
                        || !Schema.sObjectType.Salesperson__c.fields.Id.isAccessible()){
                    return null;
                }
    
                list<Salesperson__c> SalesPersons=[Select Salesperson_Description__c, Salesperson_Code__c, Id, Email__c,Integration_Key__c,AR_Division_Code__c 
                                                   From Salesperson__c 
                                                   where Id =: Mapping[0].Salesperson_Id__c]; 
    
                if(SalesPersons.size() > 0)
                {
                    if(SalesPersonX3 == null)
                    {
                        SalesPersonX3 = SalesPersons[0].Salesperson_Code__c; 
                    }
                    
                }
            }
        }   
        catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'AssignSalesperson',ex,true);
        } 
        return null;
    }
    
    public pageReference PromoteCustomer_X3()
    {
        
        try
        {
            map<String,String> PromotionFields = new map<String,String>();
            //String IntegrationKey = ConfigId;
            string sCustomerNumber = '';
            Dom.Document doc;
            ReadAndWriteXML.XmlNode objXmlNode ;        
            String CompanyCode='';
            string Password='';
            string UserID='';
            string AccountType= '';
            string PublicationName = '';
            boolean IsErrorExist= false;
            
            if(string.isBlank(CategoryX3))
            {             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Category required field.'));
                IsErrorExist=true;
            }
            
            if(string.isBlank(CurrencyX3))
            {  
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Currency required field.'));  
                IsErrorExist=true;    
            }
            
            if(string.isBlank(LanguageX3))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Language required field.'));
                IsErrorExist=true;          
            }
            
            if(string.isBlank(TaxRuleX3))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Taxrule required field.')); 
                IsErrorExist=true;        
            }
            
            if(string.isBlank(CustomerNoX3))
            {   
                if(customerNoDisable == false )
                {         
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Customer No is required field.')); 
                     IsErrorExist=true;
                }
            }
            sCustomerNumber=CustomerNoX3;
            if (IsErrorExist)
            {   
                if (Test.isRunningTest()){
                }
                else
                    return null;
            }
            
            if(string.isBlank(IntegrationKey))
                IntegrationKey= ApexPages.currentPage().getParameters().get('IntegrationKey');
            
            ERP_Config__c oIntegration = [SELECT Name, Synchronization__c,ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,
                    Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c 
                     FROM ERP_Config__c WHERE ID =: IntegrationKey];
            
            system.debug('oIntegration '+oIntegration);
            if(oIntegration.Synchronization__c =='ERP to Salesforce')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'You Cannot promote customer. change the configuration Setting for Synchronization.')); 
                 return null;
            }
            
            //TODO check WHY LIMIT 100
           
            list<Account> CurrentAccount = [Select 
                           a.Type, a.Website, a.ShippingStreet,a.ShippingState,a.ShippingPostalCode,a.ShippingLongitude,a.ShippingLatitude,a.ShippingCountry,a.ShippingCity,
                           a.Phone,a.ParentId,a.Name,a.MasterRecordId,a.Id,a.Fax,a.ERP_Customer__c,a.Integration_Key__c,a.Description,a.ERP_Customer_Number__c ,
                           a.ERP_Company_Code__c,a.BillingStreet,a.BillingState,a.BillingPostalCode,a.BillingLongitude,a.BillingLatitude,a.BillingCountry,a.BillingCity
                           From Account a Where a.Id=:AccountId limit 1];                          
                                      
            list<Contact> Contacts = [Select 
                                      Id,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,
                                      MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Phone,Fax,MobilePhone,HomePhone,
                                      OtherPhone,Email,Title,Birthdate,Description,ERP_Contact_Code__c,Department 
                                      From Contact Where AccountId =:AccountId limit 100];
    
    
            list<Ship_To__c> Addresses = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
                                          Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
                                          Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
                                          From Ship_To__c where Account_Id__c =:AccountId LIMIT 100]; 
                      
            //Set required field
            PromotionFields.put('CustomerNoX3',CustomerNoX3);
            PromotionFields.put('Category',CategoryX3);
            PromotionFields.put('Currency',CurrencyX3);
            PromotionFields.put('Language',LanguageX3);
            PromotionFields.put('Tax_rule',TaxRuleX3);
            PromotionFields.put('Terms_Code',TermsCodeX3);
            PromotionFields.put('SalesPersonX3',SalesPersonX3); 
          
            if(CurrentAccount.size()>0 )
            {
                AccountType = CurrentAccount[0].Type;
                if(AccountType==null)
                {
                    AccountType='Prospect';
                
                }
                /*if(String.IsBlank(AccountType))
                {
                    AccountType='Prospect';
                }*/
              
                Utility.ProgramList sbr = new Utility.ProgramList();
                if(AccountType == 'Prospect')
                    PublicationName = sbr.YGTPROSDTL;
                else
                    PublicationName = sbr.YGTCUSTDTL;
            }
            else 
               return null;
           
           system.debug('PublicationName '+PublicationName);
            //////////////////TODO:Remove below code
            //string EndPoint= oIntegration.Web_Service_URL__c;
            //string ERPSystemName= oIntegration.ERP_System__c;
            //string IntegrationName = oIntegration.name;
            CompanyCode=oIntegration.ERP_Company_Code__c;   
            Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
            string Version = ParamMap.get('version');
                        
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            list<object>  AttribParam= new list<object>();
            AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Customer', '' , Helper.MappingPurpose.POST); 
                   
            AttribParam= new list<object>();
            AttribParam.add(PublicationName);
            AttribParams.put('ERPFuncName',AttribParam);
            
            AttribParam= new list<object>();
            AttribParam.add(Version);
            AttribParams.put('Version',AttribParam);
            
            //set the attributes
            map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
                     
            SFObjectLists.put('Accounts',CurrentAccount);
            SFObjectLists.put('Contacts',Contacts);
            SFObjectLists.put('Addresses',Addresses);
            
            AttribParam= new list<object>();
            AttribParam.add(Version);
            AttribParams.put('Version',AttribParam);
            
            
            
            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(IntegrationKey);
            Helper.GUMU_Response resGUMU_Response= new  Helper.GUMU_Response();

            if (Test.isRunningTest())
            {
                string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                resGUMU_Response.responseERPData=TestResponseData;
               // resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
            }
            else
                resGUMU_Response =integrationFramework.PostData(IntegrationKey,'Customer', SFObjectLists,PromotionFields,AttribParams);
            
            system.debug('resGUMU_Response '+resGUMU_Response);
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
            
            map<String,String> mapProData =resGUMU_Response.SFDataMap;
            
            
            string getResponse=resGUMU_Response.responseERPData;
          
            result rs = (result) getCustomerNumber(getResponse);
            system.debug('rs34 '+rs);
           
            if( rs.Error == 'null' || rs.Error == null)
            {
                if (rs.ContactCodes!=null)
                    ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,sCustomerNumber,rs.ContactCodes,AccountType);
                else
                    ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,sCustomerNumber,null,AccountType);  
            }
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, ''+ rs.Error));                             
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'PromoteCustomer_X3',ex,true);
        }                   
        return null;   
    }

    //Fetching customer number after promoting customer
    public static object getCustomerNumber(string getResponse)
    {
    
        system.debug('getResponse12 '+getResponse);
         
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

                if(strGetID=='BPC0_1' || strGetID=='BPP0_1')
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
                }
            }
        }
        return rs;
    }
    
    //Update Contact and it will be called when unlink customer is called
    public boolean UpdateCustomer(String IntegrationKey,String CompanyCode,String AccId,String CustomerNo,list<map<String,String>> ContactCodes,string Account_Type)
    {       
        
        boolean isSuccess=false;
        try
        {
            // Check if the user has update access on the Contact.Status__c field
            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable()|| 
                !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()|| 
                !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Fields'));
                return null;
            }

            ERP_Config__c oIntegration = [SELECT ERP_System__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
            
            system.debug('oIntegration '+oIntegration);
            string ERPSystemName = oIntegration.ERP_System__c;
            system.debug('ERPSystemName '+ERPSystemName);
            Account Act = [Select Id,External_UId__c,ERP_Customer__c,Integration_Key__c,ERP_Customer_Number__c ,
                           ERP_Company_Code__c From Account Where Id=:AccId limit 1];
                           
            system.debug('Act '+Act);               
           
            //Act.Id = Act.Id;
            Act.Integration_Key__c = IntegrationKey;             
            Act.ERP_Customer_Number__c = CustomerNo;
            Act.ERP_Company_Code__c = CompanyCode;
            Act.External_UId__c = IntegrationKey +'-'+CustomerNo;
            Act.Sync_To_ERP__c=false;
            Act.Type=Account_Type;
            
            system.debug('Act updated '+Act);
           
            update Act;
                       
            if (ERPSystemName == 'SageERPX3' &&  ContactCodes != null)
            {
                for(map<string ,string> readContactCode :ContactCodes)
                {
                    String ContactName = readContactCode.get('ContactName');
                    String ContactCode = readContactCode.get('ContactCode');
                    // Check if the user has update access on the Contact fields
                    if (!Schema.sObjectType.Contact.fields.ERP_Contact_Code__c.isUpdateable() || 
                        !Schema.sObjectType.Contact.fields.Sync_To_ERP__c.isUpdateable())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Fields'));
                        return false;
                    }
                            
                    Contact Cnt=[Select 
                         Id,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,
                         MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Phone,Fax,MobilePhone,HomePhone,
                         OtherPhone,Email,Title,Birthdate,Description,ERP_Contact_Code__c 
                         From Contact Where AccountId=:AccId and  Name=:ContactName ];
    
                    Cnt.ERP_Contact_Code__c = ContactCode;
                    Cnt.Sync_To_ERP__c=false;
                    Cnt.External_UId__c= IntegrationKey+'-'+CustomerNo+'-'+ContactCode;
                    update Cnt;
                }
                        
                list<Ship_To__c> shipToList=[Select 
                Id,Account_Id__c,ERP_Customer_Number__c,External_UId__c ,Ship_To_Code__c,Integration_Key__c
                     From Ship_To__c Where Account_Id__c=:AccId];
                             
                if(shipToList.size()>0)
                {
                    for(Ship_To__c shipTo:shipToList)
                    {
                            //Ship_To__c shipToUpdate = new Ship_To__c();
                            //shipToUpdate.Id =  shipTo.Id;
                            shipTo.External_UId__c = IntegrationKey+'-'+CustomerNo+'-'+shipTo.Ship_To_Code__c;
                            shipTo.Integration_Key__c = IntegrationKey;                             
                    }
                    update shipToList;
                }
                                            
            }                     
            isSuccess=true;
            return isSuccess;
        }
        catch (Exception ex)
        {
            CustomException exc= new CustomException (className,'UpdateCustomer',ex,true);
            isSuccess=false;
            return isSuccess;
        }
    }
    
    public PageReference GetCategoryValues()
    {
        try
        {
            map<string,string> CategoryValues = new map<string,string>();
            string IntegrationKey = ConfigId;
            string Category = CategoryX3;
            baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(IntegrationKey);
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'CategoryList', '' , Helper.MappingPurpose.DISPLAY); 
            map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();
            listParams.add(Category);
            listParams.add(Category);
            parameter.put(string.valueOf(Helper.Operator.RANGE),listParams);
            fieldParameters.put('BCGCOD',parameter);
            Helper.GUMU_Response resGUMU_Response = new Helper.GUMU_Response();
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'ConfigId '+ConfigId));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'AttribParams '+AttribParams));
            
            if(Test.isRunningTest())
            {                       
                list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                map<string,string>ERPDataMap = new map<string,string>();
                ERPDataMap.put('BCGCOD','US');
                ERPDataMap.put('LAN','ENG');
                ERPDataMap.put('CUR','USD');
                ERPDataMap.put('VACBPR','NTX');
                ERPDataMap.put('PTE','CH30NET');
                ERPDataMap.put('PRE','abc');
                ERPDataMapList.add(ERPDataMap);
                resGUMU_Response.ERPDataMap=ERPDataMapList;
                resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
                
            }
            else
                resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
            
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'resGUMU_Response.ERPDataMap '+jSon.Serialize(resGUMU_Response)));    
            customerNoDisable = false;
            if (resGUMU_Response.ERPDataMap !=null)
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'resGUMU_Response.ERPDataMap '+jSon.Serialize(resGUMU_Response.ERPDataMap)));
                for (map<string,string> pmap : resGUMU_Response.ERPDataMap){
                      if(pmap.get('CUR') !=null )
                            CurrencyX3= pmap.get('CUR'); 
                      if(pmap.get('LAN') !=null)
                            LanguageX3= pmap.get('LAN'); 
                      if(pmap.get('VACBPR') !=null )
                            TaxRuleX3 = pmap.get('VACBPR'); 
                      if(pmap.get('PTE') !=null )
                            TermsCodeX3= pmap.get('PTE'); 
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
    
   /* public PageReference GetERPName() 
    {  
        // Check if the user has read access on the ERP_Configuration__c fields
        if (!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible() 
                || !Schema.sObjectType.ERP_Config__c.fields.ERP_Company_Code__c.isAccessible()
                || !Schema.sObjectType.ERP_Config__c.fields.ID.isAccessible()){
            return null;
        }
        
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
    }    */ 
    
    public class result
    {
        public string Error{get;set;}
        public string CustomereNumber{get;set;}
        public list<map<string,string>> ContactCodes{get;set;}  
    }

}