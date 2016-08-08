global with sharing class PromoteCustomerSage100Controller
{      
    public String ArDivisionObjectPrefix{get;set;}
    public String TermsCodeObjectPrefix{get;set;}
    public String ShipMethodObjectPrefix{get;set;}
    public String TaxScheduleObjectPrefix{get;set;}
    public String SalesPersonObjectPrefix{get;set;}
    public Boolean customerNoDisable{get;set;}
    public String SalesPerson100{get;set;}
    public String TaxSchedule100{get;set;}
    public String ShipMethod100{get;set;}
    public String ArDivision100{get;set;}
    public String CustomerNo100{get;set;}
    public String TermsCode100{get;set;}
    private static final string ClassName='PromoteCustomerSage100Controller';

    public String Taxgroup100 {get;set;} 
    public list<ERP_Config__c> ConfigList {get;set;}
    public String IntegrationName {get;set;} 
    public String IntegrationId{get;set;}
    public String AccountId{get;set;}
    public Account act {get;set;}
    public String NameSpace {get;set;}
    public String ProfileName {get;set;}
    public boolean ispromoted{get;set;}
    public Boolean bShowPromoteCustomer{get;set;} 
    public String Integration_Name {get;set;}
    public String IntegrationKey {get;set;}
    public String InteKey {get;set;}
    
    public string ERPSystemName{get;set;}
    public String ERPCompanyCode {get;set;}
    public String Synchronization{get;set;}
    public String DefaulIntegrationID{get;set;}
    public string DefaulIntegrationName{get;set;}
    
    public String ConfigObjectPrefix {get;set;}
    public string configId{get;set;}
    public PromoteCustomerSage100Controller(ApexPages.StandardController controller)
    {

        NameSpace = Utility.FetchNameSpace();
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) 
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
        }

        this.act=(Account)controller.getRecord();
        AccountId= ApexPages.currentPage().getParameters().get('id');
        if( AccountId != null)
            this.act =[select Id,ERP_Customer_Number__c,Integration_Key__c,Type from Account where Id=:AccountId];
            
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bShowPromoteCustomer = Boolean.valueOf(SM.Promote_Customer__c);
        ConfigId='';
        IntegrationId= act.Integration_Key__c;
        IntegrationName='';

        map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
        ConfigList = new list<ERP_Config__c>();
        
        ArDivision100='';
        ShipMethod100='';
        TermsCode100='';
        SalesPerson100='';
        TaxSchedule100='';

       
       if(IntegrationId!='' && IntegrationId!=null)
       {
            
            ConfigList=[SELECT Id, Name,ERP_System__c,Web_Service_URL__c,Integration_Information__c,
                        Integration_Information_2__c,Integration_Information_3__c From ERP_Config__c Where Id =: IntegrationId limit 1];
            
            if(ConfigList.size() >  0) 
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
                DefaulIntegrationName = ConfigList[0].Name ; 
                ConfigId=ConfigList[0].Id;
                DefaulIntegrationID = ConfigList[0].Id;
            }
        }

        if(string.isNotBlank(this.act.ERP_Customer_Number__c) && ConfigList.size() > 0)
        {   
            CustomerDetails(this.act.Integration_Key__c,this.act.ERP_Customer_Number__c,this.act.Type,ConfigList,AccountId);
        }   

        ConfigObjectPrefix = Utility.getSobjectKeyPrefix('GUMU_Lite__ERP_Config__c');
        ArDivisionObjectPrefix = Utility.getSobjectKeyPrefix('GUMU_Lite__AR_Division__c');  
        TermsCodeObjectPrefix = Utility.getSobjectKeyPrefix('GUMU_Lite__Terms_Code__c');  
        ShipMethodObjectPrefix = Utility.getSobjectKeyPrefix('GUMU_Lite__Ship_Method__c');   
        SalesPersonObjectPrefix= Utility.getSobjectKeyPrefix('GUMU_Lite__Salesperson__c');   
        TaxScheduleObjectPrefix = Utility.getSobjectKeyPrefix('GUMU_Lite__Tax_Schedule__c');   
    }  
    // fetching customer details from ERP
    public void CustomerDetails(String IntegrationKey, String UniqueKey, String AccountType,list<ERP_Config__c> ConfigList,String Account_Id)
    {
        try
        {
            String[] CustomerNo = UniqueKey.split('-');
            if(IntegrationKey !=null)  
            {
                String EndPoint = ConfigList[0].Web_Service_URL__c;
                ERPSystemName = ConfigList[0].ERP_System__c;
                Map<String,String> ParamMap = Utility.FormatERPInfo(ConfigList[0].Integration_Information__c,ConfigList[0].Integration_Information_2__c,ConfigList[0].Integration_Information_3__c);
                list<object>  AttribParam= new list<object>();

                string PublicationName = 'AR_Customer';

                baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
                map<string,list<object>> AttribParams=new map<string,list<object>> ();
                
                Account acn=[select AR_DivisonNo__c from Account where Id=:Account_Id];
                
                String Ar_no=String.valueOf(acn.AR_DivisonNo__c);
                AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'Customer', '' , Helper.MappingPurpose.DISPLAY);
                
               // AttribParam= new list<object>();
                AttribParam.add(PublicationName);
                AttribParams.put('ERPFuncName',AttribParam); 
                
                
                
                map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();             
                map<string,list<string>> parameter = new map<string,list<string>>();
                list<string> listParams=new list<string> ();
                listParams.add(UniqueKey.touppercase());
                parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
                fieldParameters.put('CustomerNo',parameter);
                
                parameter = new map<string,list<string>>(); 
                listParams=new list<string> ();
                listParams.add(Ar_no);
                parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
                
                fieldParameters.put('ARDivisionNo',parameter);
                
                Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
                if(Test.isRunningTest()) 
                {                       
                    list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                    map<string,string>ERPDataMap = new map<string,string>();
                    ERPDataMap.put('ARDivisionNo','02');
                    ERPDataMap.put('TermsCode','01');
                    ERPDataMap.put('ShipMethod','UPS BLUE');
                    ERPDataMap.put('TaxSchedule','CA');
                    ERPDataMap.put('SalespersonNo','0400');                 
                    ERPDataMapList.add(ERPDataMap);
                    resGUMU_Response.ERPDataMap=ERPDataMapList;
                    resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
                }
                else
                    {
                    resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
                    //system.debug('resGUMU_Response:  '+json.serialize(resGUMU_Response.ERPDataMap) );
                    
                    }
                if(resGUMU_Response.statusCode =='100')             
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));
                else if(resGUMU_Response.statusCode =='0') 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resGUMU_Response.statusMessage));                               
                else if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Service Temporarily Unavailable.please check the Services.'));
                else
                {
                    CustomerNo100 = UniqueKey;
                    for (map<string,string> pmap : resGUMU_Response.ERPDataMap)
                    {
                        for(string fieldKey : pmap.keySet()) 
                        {
                            if(fieldKey=='ARDivisionNo')
                                {
                                  ArDivision100=pmap.get(fieldKey) ;
                                  system.debug('ArDivision100 '+ArDivision100);
                                }

                            else if (fieldKey=='TermsCode')
                                TermsCode100=pmap.get(fieldKey) ;
                            else if (fieldKey=='ShipMethod')
                                ShipMethod100=pmap.get(fieldKey) ;

                            else if (fieldKey=='TaxSchedule')
                                TaxSchedule100=pmap.get(fieldKey) ;

                            else if (fieldKey=='SalespersonNo')
                                SalesPerson100=pmap.get(fieldKey) ;
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

    public pageReference PromoteCustomer_100()
    {
        try
        {           
            map<String,String> PromotionFields = new map<String,String>();
            String IntegrationKey = ConfigId;
            string sCustomerNumber = '';
            Dom.Document doc;
            ReadAndWriteXML.XmlNode objXmlNode ;        
            String CompanyCode='';
            string Password='';
            string UserID='';
            string AccountType= '';
            string PublicationName = 'AR_Customer';
            boolean IsErrorExist= false;

            if(CustomerNo100 == null || CustomerNo100 == '')
            {  
                if(customerNoDisable == false )
                {         
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: Customer No is required field.')); 
                    IsErrorExist=true;
                }
            }

            if(TaxSchedule100== null ||TaxSchedule100== '')
            {             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: TaxSchedule required field.'));
                IsErrorExist=true;
            }

            if(SalesPerson100== null || SalesPerson100== '')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: SalesPerson required field.')); 
                IsErrorExist=true;        
            }

            if(ArDivision100== null ||ArDivision100== '')
            {             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: ArDivision required field.'));
                IsErrorExist=true;
            }

            if(TermsCode100 == null ||TermsCode100 == '')
            {             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: TermsCode required field.'));
                IsErrorExist=true;
            }

            if(ShipMethod100== null ||ShipMethod100== '')
            {             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error: ShipMethod required field.'));
                IsErrorExist=true;
            }

            sCustomerNumber=CustomerNo100;
            if (IsErrorExist)
                return null;
            
            ERP_Config__c o_Integration = [SELECT Name, Synchronization__c,ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =:InteKey];
            
            if(o_Integration.Synchronization__c =='ERP to Salesforce')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'You Cannot promote customer. change the configuration Setting for Synchronization.'));
               return null;
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

            PromotionFields.put('CustomerNo100',CustomerNo100);
            PromotionFields.put('ArDivision100',ArDivision100);
            PromotionFields.put('TermsCode100',TermsCode100);
            PromotionFields.put('ShipMethod100',ShipMethod100);
            PromotionFields.put('TaxSchedule100',TaxSchedule100);
            PromotionFields.put('SalesPerson100',SalesPerson100);

            CompanyCode=o_Integration.ERP_Company_Code__c;  
            
            Map<String,String> ParamMap = Utility.FormatERPInfo(o_Integration.Integration_Information__c,o_Integration.Integration_Information_2__c,o_Integration.Integration_Information_3__c);

            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            list<object>  AttribParam= new list<object>();
            AttribParams=Utility.getAttribParameters('', '' , InteKey, 'Customer', '' , Helper.MappingPurpose.POST); 

            AttribParam= new list<object>();
            AttribParam.add(PublicationName);
            AttribParams.put('ERPFuncName',AttribParam);
            
            map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
            SFObjectLists.put('Accounts',CurrentAccount);
            SFObjectLists.put('Contacts',Contacts);
            SFObjectLists.put('Addresses',Addresses);
            
            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            string custNo='';
            list< map<string,string>> conNo=new list<map <string,string>>();
           // list <map<String,String>> res=new list<map<string,string>>();
            baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
               
               AttribParam= new list<object>();
               AttribParam.add(setAccountXML(CurrentAccount[0],PromotionFields,Contacts,Addresses));
               AttribParams.put('RequestXML',AttribParam); 
               system.debug('Response99 ');

              Helper.GUMU_Response resGUMU_Response =integrationFramework.PostData(InteKey,'Customer', SFObjectLists,PromotionFields,AttribParams);

             if (Test.isRunningTest())
            {
                string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                resGUMU_Response.responseERPData=TestResponseData;
                resGUMU_Response.statusMessage='Ok';
                resGUMU_Response.statusCode =string.valueof(200);
            }

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
            else if(resGUMU_Response.statusCode =='201'|| resGUMU_Response.statusCode == '200')
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Promoted customer successfully from Salesforce to ERP'));
                ispromoted=UpdateCustomer(InteKey,CompanyCode,AccountId,sCustomerNumber,null,ArDivision100);  

            }
            
            else
            {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while promoting customer from Salesforce to ERP:'+ resGUMU_Response.statusCode +'.'+ resGUMU_Response.statusMessage));
              Utility.parse(resGUMU_Response.responseERPData,'message');
              ispromoted=false;
              return null;

            }
               
              map<String,String> mapProData =resGUMU_Response.SFDataMap;
              string getResponse=resGUMU_Response.responseERPData;   
              system.debug('getResponse12 '+getResponse);
           
               /*  AttribParam= new list<object>();
                AttribParam.add('AR_CustomerContact');
                AttribParams.put('ERPFuncName',AttribParam);
                list<object> AttribParam1= new list<object>();
                AttribParam1.add('Contact');
                AttribParams.put('SourceEntity',AttribParam1);
            AttribParam= new list<object>();
            AttribParam.add(setAccountContactXML(CurrentAccount[0],PromotionFields,Contacts,Addresses));
            
            AttribParams.put('RequestXML',AttribParam);             
             
            
           Helper.GUMU_Response resGUMU_Response_1 =integrationFramework.PostData(IntegrationKey,'Contact', SFObjectLists,PromotionFields,AttribParams);
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'resGUMU_Response_1 '+resGUMU_Response_1));
            
            map<String,String> mapProData =resGUMU_Response.SFDataMap;
            string getResponse=resGUMU_Response_1.responseERPData;
            list <map<String,String>> getres =resGUMU_Response_1.ERPDataMap;
            custNo=getres[0].get('CustomerNo');
             
              for( map<String,String>res:getres)
              { 
                string cncode=res.get('ContactCode');
                conNo.put('ContactCode1',cncode);
              }
            // string CustomerNumber=getres[0].get('CustomerNo');
             //string ConCodes=getres[0].get('ContactCode');
             
           // result rs = (result) getCustomerNumber(getResponse);   
                if (conNo!=null)
                {
                    ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,custNo,conNo);
                }
                else 
                {
                    ispromoted=UpdateCustomer(IntegrationKey,CompanyCode,AccountId,custNo,null); 
                }
            
            /*else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, ''+ rs.Error));  
                }*/
        }

        catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'PromoteCustomer_100',ex,true);
        }
        return null;
    }
  
    public boolean UpdateCustomer(String IntegrationKey,String CompanyCode,String AccId,String CustomerNo, list<map<string,String>> ContactCodes,string ar_no)
    {
        System.debug('UpdateCustomer');
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

            Account Act = [Select a.External_UId__c,a.AR_DivisonNo__c,
                           a.Website, a.ShippingStreet,a.ShippingState,a.ShippingPostalCode,a.ShippingLongitude,a.ShippingLatitude,a.ShippingCountry,a.ShippingCity,
                           a.Phone,a.ParentId,a.Name,a.MasterRecordId,a.Id,a.Fax,a.ERP_Customer__c,a.Integration_Key__c,a.Description,a.ERP_Customer_Number__c ,
                           a.ERP_Company_Code__c,a.BillingStreet,a.BillingState,a.BillingPostalCode,a.BillingLongitude,a.BillingLatitude,a.BillingCountry,a.BillingCity
                           From Account a Where a.Id=:AccId limit 1];

            Act.Integration_Key__c = IntegrationKey;  
            Act.AR_DivisonNo__c = ar_no;
            Act.ERP_Customer_Number__c = CustomerNo;
            Act.ERP_Company_Code__c = CompanyCode;
            Act.External_UId__c = IntegrationKey +'-'+CustomerNo;
            Act.Sync_To_ERP__c=false;
            update Act;

            if (ERPSystemName == 'Sage100ERP' &&  ContactCodes != null)
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
                        shipTo.External_UId__c = IntegrationKey+'-'+CustomerNo+'-'+shipTo.Ship_To_Code__c;
                        shipTo.Integration_Key__c = IntegrationKey;                             
                    }
                    update shipToList;
                }
            }
            isSuccess=true;
            return isSuccess;

        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'UpdateCustomer',ex,true);
            isSuccess=false;
            return isSuccess;
        }
    }

     public Pagereference funGetIntegrationKey()
      {
          ConfigList = new list<ERP_Config__c>();
        
           ConfigList = [SELECT Id, Name,ERP_System__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,
                         Integration_Information_3__c From ERP_Config__c Where Id=:IntegrationKey limit 1];
                          
          DefaulIntegrationID = ConfigList[0].Id;
         return null;
      }

    public PageReference GetERPName() 
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
        return null;      
    }  

    public Pagereference UnlinkAccount()
    {
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
            return null;
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }  
        return null; 
    }   

    public class result
    {
        public string Error{get;set;}
        public string CustomereNumber{get;set;}
        public list<map<string,string>> ContactCodes{get;set;}  
    }
    
    private string setAccountXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst) 
    {
       string CustomerNo = PromotionFields.get('CustomerNo100');
        if (CustomerNo ==null ||CustomerNo=='null' ) 
            CustomerNo =Act.ERP_Customer_Number__c;

        //system.debug('PromotionFields '+PromotionFields);
        string ARDivision= PromotionFields.get('ArDivision100');
        string TermsCode= PromotionFields.get('TermsCode100');
        string ShipMethod = PromotionFields.get('ShipMethod100');
        string TaxSchedule = PromotionFields.get('TaxSchedule100');
        string SalesPerson = PromotionFields.get('SalesPerson100');
        
         String Address1 = ' ';
        String Address2 = ' ';
        String Address3 = ' ';
        String BillingCity = '';
        String BillingState= '';
        String BillingCountry = '';
        String BillingPostalCode = '';

        
            if(Act.BillingStreet != null)
            {
                String[] Address = Act.BillingStreet.split('\n');
                if (Address.size() > 2)
                { 
                    Address1 = Address[0]==null? ' ' : Address[0];
                    Address2 = Address[1]==null? ' ' : Address[1];
                    Address3 = Address[2]==null? ' ' : Address[2];
                }
                else if (Address.size() > 1)
                { 
                    Address1 = Address[0]==null? ' ' : Address[0];
                    Address2 = Address[1]==null? ' ' : Address[1];
                }
                else if (Address.size() > 0)
                { 
                    Address1 = Address[0]==null? ' ' : Address[0];
                }
            }
    
                string strObjXML='';        
                strObjXML +='<entry xmlns:atom="http://www.w3.org/2005/Atom" ';
                strObjXML +='xmlns:xs="http://www.w3.org/2001/XMLSchema" ';
                strObjXML +='xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005" ';
                strObjXML +='xmlns="http://www.w3.org/2005/Atom" ';
                strObjXML +='xmlns:sdata="http://schemas.sage.com/sdata/2008/1" ';
                strObjXML +='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
                strObjXML +='xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1" ';
                strObjXML +='xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1" ';
                strObjXML +='xmlns:sme="http://schemas.sage.com/sdata/sme/2007" ';
                strObjXML +='xmlns:http="http://schemas.sage.com/sdata/http/2008/1"> ';
                strObjXML +='<sdata:payload>';
                strObjXML +='<Ar_Customer xmlns="">';
        
                strObjXML +='<ARDivisionNo>'+ARDivision+'</ARDivisionNo>';
                strObjXML +='<SalespersonNo>'+SalesPerson+'</SalespersonNo>';
                strObjXML +='<TermsCode>'+TermsCode+'</TermsCode>';
                strObjXML +='<TaxSchedule>'+TaxSchedule+'</TaxSchedule>';
                strObjXML +='<ShipMethod>'+ShipMethod+'</ShipMethod>';
                strObjXML +='<CustomerNo>'+ CustomerNo+'</CustomerNo>';
        
                strObjXML +='<CustomerName>'+ act.Name +'</CustomerName>';
                strObjXML +='<ZipCode>'+ act.BillingPostalCode+'</ZipCode>';
                strObjXML +='<CountryCode>'+ act.BillingCountry+'</CountryCode>';
                strObjXML +='<State>'+ act.BillingState+'</State>';
                strObjXML +='<City>'+ act.BillingCity+'</City>';
                strObjXML +='<AddressLine1>'+ Address1 +'</AddressLine1>';
                strObjXML +='<AddressLine2>'+ Address2 +'</AddressLine2>';
                strObjXML +='<AddressLine3>'+ Address3 +'</AddressLine3>';
                strObjXML +='<TelephoneNo>'+act.Phone+'</TelephoneNo>';        
                strObjXML +='<FaxNo>'+act.Fax+'</FaxNo>';         
                strObjXML +='<URLAddress>'+act.Website+'</URLAddress>';
                strObjXML +='</Ar_Customer>';
                strObjXML +='</sdata:payload>';
                strObjXML +='</entry>';
                
                return strObjXML;
        
    } 
    
      private string setAccountContactXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst) 
      {
        string CustomerNo100 = PromotionFields.get('CustomerNo100');
        string Ar_DivisionNo = PromotionFields.get('ArDivision100');

        if (CustomerNo100 ==null ||CustomerNo100 =='null' ) 
            CustomerNo100 =Act.ERP_Customer_Number__c;
            
        string strObjXML_CONT='';

        strObjXML_CONT +='<entry xmlns:atom="http://www.w3.org/2005/Atom" ';
        strObjXML_CONT +='xmlns:xs="http://www.w3.org/2001/XMLSchema" ';
        strObjXML_CONT +='xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005" ';
        strObjXML_CONT +='xmlns="http://www.w3.org/2005/Atom" ';
        strObjXML_CONT +='xmlns:sdata="http://schemas.sage.com/sdata/2008/1" ';
        strObjXML_CONT +='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
        strObjXML_CONT +='xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1" ';
        strObjXML_CONT +='xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1" ';
        strObjXML_CONT +='xmlns:sme="http://schemas.sage.com/sdata/sme/2007" ';
        strObjXML_CONT +='xmlns:http="http://schemas.sage.com/sdata/http/2008/1"> ';

        strObjXML_CONT +='<sdata:payload>';
        strObjXML_CONT +='<AR_CustomerContact xmlns="" >';
        for(Contact Cont:Contacts)
        {   
            String CnCode=getRandom();
            Cont.ERP_Contact_Code__c= CnCode ;
            string contactCode = string.isblank(Cont.ERP_Contact_Code__c) ? '':Cont.ERP_Contact_Code__c;
            
            //string Salutation = string.isblank(Cont.Salutation) ? '':Cont.Salutation;
            strObjXML_CONT += '<ARDivisionNo>'+Ar_DivisionNo+'</ARDivisionNo>';
            strObjXML_CONT += '<CustomerNo>'+CustomerNo100+'</CustomerNo>';
            strObjXML_CONT += '<ContactCode>'+contactCode+'</ContactCode>';
            strObjXML_CONT += '<ContactName>'+Cont.Name+'</ContactName>';
            
            strObjXML_CONT +='<City>'+Cont.OtherCity+'</City>';
            strObjXML_CONT += '<AddressLine1>'+Cont.MailingAddress+'</AddressLine1>';
            strObjXML_CONT += '<AddressLine2>'+Cont.MailingAddress+'</AddressLine2>';
            strObjXML_CONT += '<ZipCode>'+Cont.OtherPostalCode+'</ZipCode>';
            strObjXML_CONT += '<State>'+Cont.OtherState+'</State>';
            strObjXML_CONT += '<Salutation>' +Cont.Salutation+'</Salutation> ';
            strObjXML_CONT += '<TelephoneNo1>'+Cont.Phone+'</TelephoneNo1> ';
            strObjXML_CONT += '<TelephoneNo2>'+Cont.HomePhone+'</TelephoneNo2> ';
            strObjXML_CONT += '<FaxNo>'+Cont.Fax+'</FaxNo> ';
            strObjXML_CONT += '<EmailAddress>'+Cont.Email+'</EmailAddress> ';
           // strObjXML_CONT +='<CountryCode>USA</CountryCode>';
            //strObjXML_CONT += '<ContactNotes>'+Ship_To_Address4__c+'</ContactNotes> ';

            //strObjXML_1 += '<TelephoneExt1>'+Cont.MobilePhone+'</TelephoneExt1> ';
            //strObjXML_1 += '<ContactTitle>'+Ship_To_Address4__c+'</ContactTitle> ';

            //strObjXML_1 += '<TimeCreated>'+Ship_To_Address4__c+'</TimeCreated> ';
            //strObjXML_1 += '<DateCreated>'+Ship_To_Address4__c+'</DateCreated> ';
            //strObjXML_1 += '<UserCreatedKey>'+Ship_To_Address4__c+'</UserCreatedKey> ';
            //strObjXML_1 += '<DateUpdated>'+Ship_To_Address4__c+'</DateUpdated> ';
            //strObjXML_1 += '<TimeUpdated>'+Ship_To_Address4__c+'</TimeUpdated> ';
            //strObjXML_1 += '<UserUpdatedKey>'+Ship_To_Address4__c+'</UserUpdatedKey> ';


            //strObjXML_CONT += '<TelephoneExt2>'+Ship_To_Address4__c+'</TelephoneExt2> ';

            //strObjXML_CONT  +='<SWACTV>1</SWACTV>';
            //strObjXML_CONT +='<FOB xsi:nil="false" />;
            //strObjXML_CONT+= <SHPVIADESC xsi:nil="false" />;
        }

       strObjXML_CONT +='</AR_CustomerContact>';
       strObjXML_CONT +='</sdata:payload>';
       strObjXML_CONT+='</entry>';
        
        return strObjXML_CONT;
    }  
    
     public String getRandom() 
     {
        Integer len = 10;
        final String chars = '0123456789';
        String randStr = '';
        
        while (randStr.length() < len)
        {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
     } 

}