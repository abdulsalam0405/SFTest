global class AccountTriggerHelper {

    private static final string ClassName='AccountTriggerHelper';

    public static void BeforeInsert(list<Account> NewAccounts,list<Account> OldAccounts)
    {       
        try
        {
            for(Account Act : NewAccounts)
            {
                
                if(Utility.bRunTrigger)
                {

                }
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'BeforeInsert',ex,false);
        } 
    }

    public static void AfterInsert(list<Account> NewAccounts,list<Account> OldAccounts)
    {
        try
        {
            for(Account Act : NewAccounts)
            {
                if(Utility.bRunTrigger)
                    UpsertAddresses(Act);   
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AfterInsert',ex,false);
        } 
    }

    public static void BeforeUpdate(list<Account> NewAccounts,list<Account> OldAccounts)
    {
        try
        {
             system.debug('NewAccounts '+NewAccounts);
             
            Map<ID, ERP_Config__c> lstIntegration = new Map<ID, ERP_Config__c>([SELECT Id, Synchronization__c FROM ERP_Config__c LIMIT 10]);
            
            system.debug('lstIntegration '+json.serialize(lstIntegration));
            for(Account Act : NewAccounts)
            {
                if(Utility.bRunTrigger)
                {
                    if(String.isNotBlank(Act.Integration_Key__c))
                    {
                        ERP_Config__c oIntegration = lstIntegration.get(Act.Integration_Key__c);
                        
                        system.debug('oIntegration '+oIntegration);
                        if(oIntegration == null)
                            continue;

                        string synchronization = oIntegration.Synchronization__c;
                        if(synchronization =='both' || synchronization=='Salesforce to ERP')
                        {
                            Decimal decTime =Decimal.valueOf(Datetime.now().getTime() - Act.LastModifiedDate.getTime());
                            system.debug('decTime '+decTime);
                            
                            if(decTime > 500)
                            {                               
                                if(Act.Sync_To_ERP__c)
                                {
                                    string serializeAcc = JSON.serialize(Act);
                                    system.debug('serializeAcc '+serializeAcc);
                                   // UpsertAddresses(Act);      
                                    UpdateERPCustomer(serializeAcc);
                                }
                                else
                                    Act.Sync_To_ERP__c=true;
                            }
                        }
                    }
                    else
                        UpsertAddresses(Act);      
                }
            } 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'BeforeUpdate',ex,false);
        } 
    }

    public static void AfterUpdate(list<Account> NewAccounts,list<Account> OldAccounts)
    {
        system.debug('NewAccounts****'+NewAccounts);
        try
        {   
            
            for(Account Act : NewAccounts)
            {
                if(Utility.bRunTrigger)
                {
                    
                }
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AfterUpdate',ex,false);
        } 

    }

    /*Updating and inserting Addresses for Salesforce Account*/
    private static void UpsertAddresses(Account Act)
    {
        String Address1 = '';
        String Address2 = '';
        String Address3 = '';
        String BillingCity = '';
        String BillingState= '';
        String BillingCountry = '';
        String BillingPostalCode = '';

        //variables for Ship to adddress
        String ShipAddress1 = '';
        String ShipAddress2 = '';
        String ShipAddress3 = '';
        String ShipCity = '';
        String ShipState= '';
        String ShipCountry = '';
        String ShipPostalCode = '';

        try
        {
            if(Act.BillingStreet != null)
            {
                String[] Address = Act.BillingStreet.split('\n');
                if (Address.size() > 2)
                { 
                    Address1 = Address[0]==null? '' : Address[0];
                    Address2 = Address[1]==null? '' : Address[1];
                    Address3 = Address[2]==null? '' : Address[2];
                }
                else if (Address.size() > 1)
                { 
                    Address1 = Address[0]==null? '' : Address[0];
                    Address2 = Address[1]==null? '' : Address[1];
                }
                else if (Address.size() > 0)
                { 
                    Address1 = Address[0]==null? '' : Address[0];
                }
            }
    
            if(Act.ShippingStreet != null)
            {
                String[] ShipAddress = Act.ShippingStreet.split('\n');
                if (ShipAddress.size() > 2)
                { 
                    ShipAddress1 = ShipAddress[0]==null? '' : ShipAddress[0];
                    ShipAddress2 = ShipAddress[1]==null? '' : ShipAddress[1];
                    ShipAddress3 = ShipAddress[2]==null? '' : ShipAddress[2];
                }
                else if (ShipAddress.size() > 1)
                { 
                    ShipAddress1 = ShipAddress[0]==null? '' : ShipAddress[0];
                    ShipAddress2 = ShipAddress[1]==null? '' : ShipAddress[1];
                }
                else if (ShipAddress.size() > 0)
                { 
                    ShipAddress1 = ShipAddress[0]==null? '' : ShipAddress[0];
                }
            }
            
            string Phone='';
            if(Act.Phone != null)
                Phone=string.valueOf(Act.Phone);    
           
            string Fax='';
            if(Act.Fax != null)
                Fax=string.valueOf(Act.Fax);
    
            BillingCity = string.isBlank(Act.BillingCity) ? '' : Act.BillingCity;
            BillingState = string.isBlank(Act.BillingState) ? '' : Act.BillingState;
            BillingCountry = string.isBlank(Act.BillingCountry) ? '' : Act.BillingCountry;
            BillingPostalCode= string.isBlank(Act.BillingPostalCode) ? '' : Act.BillingPostalCode;
    
            ShipCity = string.isBlank(Act.ShippingCity) ? '' : Act.ShippingCity;
            ShipState = string.isBlank(Act.ShippingState) ? '' : Act.ShippingState;
            ShipCountry = string.isBlank(Act.ShippingCountry) ? '' : Act.ShippingCountry;
            ShipPostalCode= string.isBlank(Act.ShippingPostalCode) ? '' : Act.ShippingPostalCode;
            
            String IntegrationKey= string.isBlank(Act.Integration_Key__c) ? '' : Act.Integration_Key__c;
    
            Ship_To__c updateShipTo  = new Ship_To__c();
            list<Ship_To__c> updateShipToList  = new list<Ship_To__c>();
    
    
            list<Contact> Contacts = [Select 
                                          Id,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,
                                          MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Phone,Fax,MobilePhone,HomePhone,
                                          OtherPhone,Email,Title,Birthdate,Description,ERP_Contact_Code__c 
                                          From Contact Where AccountId =:Act.Id limit 100];
            
            list<Ship_To__c> ShipToLst = [Select Id, IsPrimary__c,Default_ShipTo__c, Telephone_No__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Country_Code__c,  
                                          Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Fax_No__c, Email_Address__c
                                          From Ship_To__c where Account_Id__c =:Act.Id LIMIT 10];
    
            if(ShipToLst.size() >0)
            {
                updateShipToList  = new list<Ship_To__c>();
                for(Ship_To__c shipTo:ShipToLst)
                {
                    string IsPrimary = string.isBlank(shipTo.IsPrimary__c) ? '':shipTo.IsPrimary__c;
                    string IsDefaultShipTo = string.isBlank(shipTo.Default_ShipTo__c) ? '':shipTo.Default_ShipTo__c;
                    system.debug('shipTo '+shipTo);
                    system.debug('Act '+Act);
                    if(IsPrimary == 'Yes' && IsDefaultShipTo =='Yes')
                    {
                        updateShipTo  = new Ship_To__c();
                       updateShipTo.Id = ShipTo.Id;                        
                       updateShipTo.Ship_To_Address1__c = Address1;
                       updateShipTo.Ship_To_Address2__c = Address2;
                       updateShipTo.Ship_To_Address3__c = Address3;
                       updateShipTo.Ship_To_City__c = BillingCity;
                       updateShipTo.Ship_To_State__c = BillingState;
                       updateShipTo.Ship_To_Country_Code__c = BillingCountry;
                       updateShipTo.Ship_To_Zip_Code__c = BillingPostalCode;
                       updateShipTo.Telephone_No__c=Phone;
                       updateShipTo.Fax_No__c=Fax;
                       updateShipTo.Account_Id__c = act.Id;
                       updateShipTo.Integration_Key__c =IntegrationKey;
                       updateShipToList.add(updateShipTo);
                        
                    }
                    else if(IsPrimary == 'Yes' && IsDefaultShipTo =='No')
                    {
                        updateShipTo  = new Ship_To__c();
                       updateShipTo.Id = ShipTo.Id;                        
                       updateShipTo.Ship_To_Address1__c = Address1;
                       updateShipTo.Ship_To_Address2__c = Address2;
                       updateShipTo.Ship_To_Address3__c = Address3;
                       updateShipTo.Ship_To_City__c = BillingCity;
                       updateShipTo.Ship_To_State__c = BillingState;
                       updateShipTo.Ship_To_Country_Code__c = BillingCountry;
                       updateShipTo.Ship_To_Zip_Code__c = BillingPostalCode;
                       updateShipTo.Telephone_No__c=Phone;
                       updateShipTo.Fax_No__c=Fax;
                       updateShipTo.Account_Id__c = act.Id;
                       updateShipTo.Integration_Key__c =IntegrationKey;
                       updateShipToList.add(updateShipTo);
                    }
                    else if(IsPrimary == 'No' && IsDefaultShipTo =='Yes')
                    {
                        updateShipTo  = new Ship_To__c();
                       updateShipTo.Id = ShipTo.Id;                        
                       updateShipTo.Ship_To_Address1__c = ShipAddress1;
                       updateShipTo.Ship_To_Address2__c = ShipAddress2;
                       updateShipTo.Ship_To_Address3__c = ShipAddress3;
                       updateShipTo.Ship_To_City__c = ShipCity;
                       updateShipTo.Ship_To_State__c = ShipState;
                       updateShipTo.Ship_To_Country_Code__c = ShipCountry;
                       updateShipTo.Ship_To_Zip_Code__c = ShipPostalCode;
                       updateShipTo.Telephone_No__c=Phone;
                       updateShipTo.Fax_No__c=Fax;
                       updateShipTo.Account_Id__c = act.Id;
                       updateShipTo.Integration_Key__c =IntegrationKey;
                       updateShipToList.add(updateShipTo);
                    }               
                }
    
            }
            else
            {   
                Standard_Setting__c AddressCodes = [select Address_Code_1__c,Address_Code_2__c from Standard_Setting__c LIMIT 1];
                
                string AddressCode1 =string.isBlank(AddressCodes.Address_Code_1__c) ? 'AD01' : AddressCodes.Address_Code_1__c;
                string AddressCode2 =string.isBlank(AddressCodes.Address_Code_2__c) ? 'AD02' : AddressCodes.Address_Code_2__c;
                
                updateShipTo  = new Ship_To__c(); 
                updateShipTo.Ship_To_Code__c = AddressCode1;
                updateShipTo.IsPrimary__c = 'Yes';
                updateShipTo.Default_ShipTo__c = 'No';
                updateShipTo.isShipTo__c = 'No';                   
                updateShipTo.Ship_To_Address1__c = Address1;
                updateShipTo.Ship_To_Address2__c = Address2;
                updateShipTo.Ship_To_Address3__c = Address3;
                updateShipTo.Ship_To_City__c = BillingCity;
                updateShipTo.Ship_To_State__c = BillingState;
                updateShipTo.Ship_To_Country_Code__c = BillingCountry;
                updateShipTo.Ship_To_Zip_Code__c = BillingPostalCode;
                updateShipTo.Telephone_No__c=Phone;
                updateShipTo.Fax_No__c=Fax;
                updateShipTo.Account_Id__c = act.Id;
                updateShipTo.Integration_Key__c =IntegrationKey;
                updateShipToList.add(updateShipTo);
    
                updateShipTo  = new Ship_To__c(); 
                updateShipTo.Ship_To_Code__c = AddressCode2;
                updateShipTo.IsPrimary__c = 'No';
                updateShipTo.Default_ShipTo__c = 'Yes';
                updateShipTo.isShipTo__c = 'Yes';                   
                updateShipTo.Ship_To_Address1__c = ShipAddress1;
                updateShipTo.Ship_To_Address2__c = ShipAddress2;
                updateShipTo.Ship_To_Address3__c = ShipAddress3;
                updateShipTo.Ship_To_City__c = ShipCity;
                updateShipTo.Ship_To_State__c = ShipState;
                updateShipTo.Ship_To_Country_Code__c = ShipCountry;
                updateShipTo.Ship_To_Zip_Code__c = ShipPostalCode;
                updateShipTo.Account_Id__c = act.Id;
                updateShipTo.Integration_Key__c =IntegrationKey;
                updateShipToList.add(updateShipTo);
            }
    
            if(updateShipToList.size()>0)
                upsert updateShipToList;
        }
        catch(Exception ex)
        {
            if(Test.isRunningTest())
            {
                
            }
            else
            {
                Act.GUMU_Lite__Last_Sync_Message__c= 'Insert failed while inserting data into Addresses \n '+ex.getMessage();
                update Act;
            }
        }
    }

    @future (callout=true)
    public static void UpdateERPCustomer( string AccountList)
    {
        Account Act = (Account) JSON.deserialize(AccountList,Account.class);
        
        try
        {
            string IntegrationKey=Act.Integration_Key__c;
    
            string MAXCOUNT='';
            string STARTAT='';
            string TOTALCOUNT='';
            string RETCOUNT='';
            string HASNEXT='';
            string HASPREV='';
            string CompanyCode='';
            String ErrorMessage='';
    
            /************ Create Header part*************/
            ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c,Inactive__c FROM ERP_Config__c WHERE ID =: IntegrationKey Limit 1];
            String EndPoint= oIntegration.Web_Service_URL__c;
            String ERPSystemName= oIntegration.ERP_System__c;
    
            Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
    
            system.debug('ParamMap '+ParamMap);
            CompanyCode = ParamMap.get('CompanyCode');
    
            if(ERPSystemName == 'SageERPX3')
            {
                ErrorMessage = UpdateERPCustomer_X3(Act,oIntegration);
            }
            else if(ERPSystemName == 'Sage300ERP')
            {
                ErrorMessage = UpdateERPCustomer_300(Act,oIntegration);
            }
            else if(ERPSystemName == 'Sage100ERP')
            {
                ErrorMessage = UpdateERPCustomer_100(Act,oIntegration);
            }
            
            system.debug('ErrorMessage '+ErrorMessage);
            String ImageURL='';
            String ResourceName='';
            String SyncMessage='';
    
            if(String.isNotBlank(ErrorMessage))
            {
                ResourceName='Failure';
                SyncMessage='Error occurred - ' + ErrorMessage +' : ';
            }
            else
            {   
                ResourceName='Success';
                SyncMessage='';
            }
    
            // Pass the resource name
            List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :ResourceName];
    
             system.debug('resourceList '+resourceList);
            // Getting namespace
            string namespace ; 
            if (!(Test.isRunningTest()))
            {
                if (resourceList.size()>0)
                    {
                        namespace=resourceList[0].NamespacePrefix;
                        // Resource URL
                        ImageURL= '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + ResourceName;
                    } 
            }
            
            Act.Sync_To_ERP__c=false;
            Act.Last_Sync_Message__c = '<img alt="success" width="12" height="12" src="'+ImageURL+'"> ' + ResourceName + ' : ' + String.valueOf(Datetime.now()) + SyncMessage;      
            update Act; 
        }
        catch(Exception ex)
        {
            Act.GUMU_Lite__Last_Sync_Message__c= 'Insert failed while inserting data into Addresses \n '+ex.getMessage();
            update Act;
        } 
    }

    /* Update ERP Customer data for Sage X3*/
    public static string UpdateERPCustomer_X3(Account Act, ERP_Config__c oIntegration)
    {
        system.debug('Act '+json.serialize(Act));
        string sCustomerNumber = '';
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode ;        
        String CompanyCode='';
         
        
        string AccountType= '';
        string PublicationName = '';

        if(Act != null)
        {
            AccountType = Act.Type;
            if(AccountType == 'Prospect')
                PublicationName = 'YGTPROSDTL';
            else
                PublicationName = 'YGTCUSTDTL';
        }

        String EndPoint= oIntegration.Web_Service_URL__c;
        String ERPSystemName= oIntegration.ERP_System__c;
        CompanyCode=oIntegration.ERP_Company_Code__c;
        Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
        
         
        string Version = ParamMap.get('version');

        list<Contact> Contacts     =new list<Contact>();
        list<Ship_To__c> Addresses = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
                                      Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
                                      Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
                                      From Ship_To__c where Account_Id__c =:Act.Id LIMIT 100]; 

        //Set required field
        map<String,String> PromotionFields = new map<String,String>();
        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        list<object>  AttribParam= new list<object>();
        //AttribParams=Utility.getAttribParameters('', '' , Act.Integration_Key__c, 'Customer', '' , Helper.MappingPurpose.POST); 
         AttribParams=Utility.getAttribParameters('', '' , Act.Integration_Key__c, 'Customer', '' , Helper.MappingPurpose.MODIFY); 
               
        AttribParam= new list<object>();
        AttribParam.add(PublicationName);
        AttribParams.put('ERPFuncName',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add(Version);
        AttribParams.put('Version',AttribParam);
        
        //set the attributes
        map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
        list<Account> CurrentAccount = new list<Account> ();
        CurrentAccount.Add(Act);
        SFObjectLists.put('Accounts',CurrentAccount);
        SFObjectLists.put('Contacts',Contacts);
        SFObjectLists.put('Addresses',Addresses);
        
        string Customer_No='';
         Customer_No=Act.ERP_Customer_Number__c;
        
        string key='';
         key='BPCNUM';
        
        //SFObjectLists.put('Contacts',NULL);
        //SFObjectLists.put('Addresses',NULL);
        
        AttribParam= new list<object>();
        AttribParam.add(Customer_No);
        AttribParams.put('CustomerNo',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add(key);
        AttribParams.put('include',AttribParam);
         
        AttribParam= new list<object>();
        AttribParam.add(Version);
        AttribParams.put('Version',AttribParam);
        
        system.debug('AttribParams90 '+AttribParams);
        map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
        baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(Act.Integration_Key__c);
        
        Helper.GUMU_Response resGUMU_Response = new Helper.GUMU_Response();  
        if (Test.isRunningTest())
        {
            map<String,String> mapProData = new map<String,String>();
            mapProData.put('Account','Mady');
            resGUMU_Response.SFDataMap = mapProData;
            string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
            resGUMU_Response.responseERPData = TestResponseData;
        }
        else
            resGUMU_Response =integrationFramework.PostData( Act.Integration_Key__c,'Customer', SFObjectLists,PromotionFields,AttribParams);
       
       system.debug('resGUMU_Response '+resGUMU_Response);
        
        map<String,String> mapProData =resGUMU_Response.SFDataMap;
        string getResponse=resGUMU_Response.responseERPData;
        
        String strResponse='';
        if(getResponse !='')
        {
            doc = new Dom.Document();
            doc.load(getResponse);                          
            Dom.XMLNode Envelope = doc.getRootElement();       
            Dom.XMLNode Body= Envelope.getChildElements()[0];       

            string sReturn = '0';

            for(Dom.XMLNode respChild : Body.getChildElements()) 
            {
                for(Dom.XMLNode subchildNode : respChild.getChildElements()) 
                {    
                    if(subchildNode.getName() == 'resultXml')
                    {
                        strResponse = string.valueof(subchildNode.getText());
                        if(strResponse !=null ||strResponse!='')
                        {
                            strResponse = '';
                            return strResponse;
                            // break;
                        }
                    }
                    else if(subchildNode.getName() == 'message' && respChild.getAttribute('id','')=='id1' && (strResponse ==null ||strResponse==''))
                    {
                        strResponse = string.valueof(subchildNode.getText());
                        strResponse ='Error '+strResponse;

                        return strResponse;
                    }                    
                }               
            }

        }
        return strResponse;
    }
    
  public static string UpdateERPCustomer_100(Account Act, ERP_Config__c oIntegration)
    {
        string strResponse='';
        try
        {
            string sCustomerNumber = '';
            Dom.Document doc;
            ReadAndWriteXML.XmlNode objXmlNode ;        
                        
            string AccountType= '';
            string PublicationName = '';
               
            String EndPoint= oIntegration.Web_Service_URL__c;
            String ERPSystemName= oIntegration.ERP_System__c;
            
           // list<Ship_To__c> Addresses = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
                                          //Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
                                         // Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
                                         // From Ship_To__c where Account_Id__c =:Act.Id LIMIT 100]; 
            
           
            Map<String,String> ParamMap =Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
            
            system.debug('ParamMap '+ParamMap);
            map<String,String> PromotionFields = new map<String,String>();
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            list<object>  AttribParam= new list<object>();
            AttribParams=Utility.getAttribParameters('', '' , Act.Integration_Key__c, 'Sage100Customer', '' , Helper.MappingPurpose.MODIFY); 
            system.debug('AttribParams0 '+AttribParams);
            
            
            PublicationName='AR_Customer';       
            AttribParam= new list<object>();
            AttribParam.add(PublicationName);
            AttribParams.put('ERPFuncName',AttribParam);
            system.debug('AttribParams1 '+AttribParams);
            
            /*AttribParam= new list<object>();
            AttribParam.add('GETData');
            AttribParams.put('PostDataXml',AttribParam);*/
                  
            //set the attributes
            map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
            list <Account> CurrentAccount = new list<Account> ();
            CurrentAccount.Add(Act);
            //system.debug('CurrentAccount'+CurrentAccount);
            
            AttribParam= new list<object>();
            //String xml=
            AttribParam.add(AccountXML(CurrentAccount[0]));
            AttribParams.put('RequestXML',AttribParam);
            system.debug('AttribParamsXML '+AttribParams);
             
            SFObjectLists.put('Accounts',CurrentAccount);
            SFObjectLists.put('Contacts',null);
            SFObjectLists.put('Addresses',null);
            
            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(Act.Integration_Key__c);
            
            
            if(Test.isRunningTest())
            {
               return '';  
            }
           
           system.debug('AttribParams1111'+AttribParams);
            Helper.GUMU_Response resGUMU_Response =integrationFramework.PostData( Act.Integration_Key__c,'Sage100Customer', SFObjectLists,PromotionFields,AttribParams);
            system.debug('resGUMU_Response '+resGUMU_Response);
            if (string.isNotBlank(resGUMU_Response.statusCode))
            {
                if (resGUMU_Response.statusCode =='200'  || resGUMU_Response.statusCode =='201')
                {// TODO:For success
                }
                else
                {
                    strResponse = resGUMU_Response.statusCode + '\n' + resGUMU_Response.statusMessage + '\n'+resGUMU_Response.responseERPData;
                    //update Act; 
                }
            }
            return strResponse;
        }
        catch(Exception ex)
        {
             throw ex;
        }
   }
   
    private static string AccountXML(Account act) 
    {
        system.debug('act567678'+json.serialize(act));
        string Address1=' ';
        string Address2=' ';
        string Address3=' ';
        
     
                        
        if(act.BillingStreet != null)
        {
            String[] BillingStreet = act.BillingStreet.split('\n');
            
            if (BillingStreet.size() > 2)
            { 
                Address1 = BillingStreet[0]==null? ' ' : BillingStreet[0];
                Address2 = BillingStreet[1]==null? ' ' : BillingStreet[1];
                Address3 = BillingStreet[2]==null? ' ' : BillingStreet[2];
            }
            else if (BillingStreet.size() > 1)
            { 
                Address1 = BillingStreet[0]==null? ' ' : BillingStreet[0];
                Address2 = BillingStreet[1]==null? ' ' : BillingStreet[1];
            }
            else if (BillingStreet.size() > 0)
            { 
                Address1 = BillingStreet[0]==null? ' ' : BillingStreet[0];
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
        strObjXML +='<AR_Customer xmlns="">';
        strObjXML +='<ARDivisionNo>'+act.GUMU_Lite__AR_DivisonNo__c+'</ARDivisionNo>';
        //strObjXML +='<CustomerNo>'+ CustomerNo+'</CustomerNo>';
        strObjXML +='<CustomerNo>'+act.ERP_Customer_Number__c+'</CustomerNo>';
        strObjXML +='<CustomerName>'+act.Name +'</CustomerName>';  
        strObjXML +='<ZipCode>'+ act.BillingPostalCode+'</ZipCode>';
        strObjXML +='<CountryCode>'+ act.BillingCountry+'</CountryCode>';
        strObjXML +='<State>'+ act.BillingState+'</State>';
        strObjXML +='<City>'+ act.BillingCity+'</City>';
        strObjXML +='<AddressLine1>'+Address1+'</AddressLine1>';
        strObjXML +='<AddressLine2>'+Address2+'</AddressLine2>';
        strObjXML +='<AddressLine3>'+Address3+'</AddressLine3>';
        strObjXML +='<TelephoneNo>'+act.Phone+' </TelephoneNo>';        
        strObjXML +='<FaxNo>'+act.Fax+'</FaxNo>';         
        strObjXML +='<URLAddress>'+act.Website+'</URLAddress>';
        strObjXML +='</AR_Customer>';
        strObjXML +='</sdata:payload>';
        strObjXML +='</entry>';
        system.debug('strObjXML '+strObjXML);
        return strObjXML; 
    } 
    
    
    /* Update ERP Customer data for Sage X3*/
    public static string UpdateERPCustomer_300(Account Act, ERP_Config__c oIntegration)
    {
        string sCustomerNumber = '';
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode ;        
        
        string AccountType= '';
        string PublicationName = '';
        String EndPoint= oIntegration.Web_Service_URL__c;
        String ERPSystemName= oIntegration.ERP_System__c;
       
        Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
        
        //list<Contact> Contacts     =new list<Contact>();
        //list<Ship_To__c> Addresses = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
        //                              Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
        //                              Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
        //                              From Ship_To__c where Account_Id__c =:Act.Id LIMIT 100]; 

        //Set required field
        map<String,String> PromotionFields = new map<String,String>();
        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        list<object>  AttribParam= new list<object>();
        AttribParams=Utility.getAttribParameters('', '' , Act.Integration_Key__c, 'Customer', '' , Helper.MappingPurpose.MODIFY); 
        
        PublicationName='arCustomersFinder';       
        AttribParam= new list<object>();
        AttribParam.add(PublicationName);
        AttribParams.put('ERPFuncName',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('GETData');
        AttribParams.put('PostDataXml',AttribParam);
              
        //set the attributes
        map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
        list<Account> CurrentAccount = new list<Account> ();
        CurrentAccount.Add(Act);
        SFObjectLists.put('Accounts',CurrentAccount);
        SFObjectLists.put('Contacts',null);
        SFObjectLists.put('Addresses',null);
        
        map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
        baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(Act.Integration_Key__c);
         
        if (Test.isRunningTest())
        {
            return '';  
        }
        
        Helper.GUMU_Response resGUMU_Response =integrationFramework.PostData( Act.Integration_Key__c,'Customer', SFObjectLists,PromotionFields,AttribParams);
        string strResponse='';
        
        if (string.isNotBlank(resGUMU_Response.statusCode))
        {
            if (resGUMU_Response.statusCode =='200'  || resGUMU_Response.statusCode =='201')
            {
                // TODO:For success
            }
            else
            {
                strResponse = resGUMU_Response.statusCode + ':' + resGUMU_Response.statusMessage + '.';
                //update Act; 
            }
        }
     
        return strResponse;
    }

}