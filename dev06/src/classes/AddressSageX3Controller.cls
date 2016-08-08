public with sharing class AddressSageX3Controller {
    public list<Address> AddressList{get;set;}
    public Address Addr {get;set;}
    public Ship_To__c shipTo {get;set;}
    public string glERPSystemName{get;set;}
    public string pageMode{get;set;}
    public string status{get;set;}
    public static string glAccountID {get;set;} 
    
    public boolean isShipAddress{get;set;} 
    public boolean bEnableDefShipTo{get;set;}
    public boolean bDsiableDefAddr {get;set;}
    public boolean isShipToExists{get;set;}  
    public boolean bRenderDefaultShipTo{get;set;}
    public boolean bRenderShipping{get;set;}
    public boolean bRenderDefaultAddress{get;set;}
    public boolean bEnableShipping{get;set;}
    public Boolean bUpdateCustomer{get;set;}
    public AddressSageX3Controller(ApexPages.StandardController controller) 
    {
        isShipToExists=false;
        bEnableDefShipTo=true;
        bDsiableDefAddr =false; 
        bRenderDefaultShipTo = true;
        bRenderShipping = true;
        bRenderDefaultAddress = true;
        bEnableShipping = false;
        
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bUpdateCustomer = Boolean.valueOf(SM.Update_Customer__c); 
        
        AddressList = new list<Address>();       
        Addr = new Address();
        shipTo = new Ship_To__c();
        //get ShiptoId from URL
        string shipToId = ApexPages.currentPage().getParameters().get('id');
        
        //get Account id
        string AccountID = ApexPages.currentPage().getParameters().get('AccountID');
        
        //fetching Address details base on ship to Id
        if(string.isNotBlank(shipToId))
        {
            pageMode='Edit';
            isShipToExists=true;
            shipTo =[Select Id, isShipTo__c, Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
                    Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
                    Account_Id__r.Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c,Account_Id__r.Name,Account_Id__r.Type 
                    From Ship_To__c where Id=:shipToId LIMIT 1];
            
            Addr.ShipToId=shipTo.Id;
            Addr.isShipTo=shipTo.isShipTo__c;
            Addr.DefaultShipTo=shipTo.Default_ShipTo__c; 
            Addr.Warehouse_Code=shipTo.Warehouse_Code__c;
            Addr.Telephone_No=shipTo.Telephone_No__c;
            Addr.Telephone_Ext=shipTo.Telephone_Ext__c;
            Addr.Tax_Schedule=shipTo.Tax_Schedule__c;
            Addr.Ship_To_Zip_Code=shipTo.Ship_To_Zip_Code__c;
            Addr.Ship_To_State=shipTo.Ship_To_State__c;
            Addr.Ship_To_Name=shipTo.Ship_To_Name__c;
            Addr.Ship_To_Country_Code=shipTo.Ship_To_Country_Code__c;
            Addr.Ship_To_Code=shipTo.Ship_To_Code__c;
            Addr.Ship_To_City=shipTo.Ship_To_City__c;
            
            Addr.Ship_To_Address3=shipTo.Ship_To_Address3__c;
            Addr.Ship_To_Address2=shipTo.Ship_To_Address2__c;
            Addr.Ship_To_Address1=shipTo.Ship_To_Address1__c;
            Addr.Salesperson_No=shipTo.Salesperson_No__c;
            Addr.IsPrimary=shipTo.IsPrimary__c;
            Addr.Integration_Key=shipTo.Account_Id__r.Integration_Key__c;
            
            Addr.Fax_No=shipTo.Fax_No__c;
            Addr.Email_Address=shipTo.Email_Address__c;
            Addr.ERP_Customer_Number=shipTo.ERP_Customer_Number__c;
            Addr.ERP_Contact_Code=shipTo.ERP_Contact_Code__c;
            Addr.Account_Id=shipTo.Account_Id__c ;
            Addr.Account_Name=shipTo.Account_Id__r.Name;
            Addr.Account_Type=shipTo.Account_Id__r.Type;
            
            if(Addr.isShipTo == 'Yes')
                bEnableDefShipTo = false;
            else
                bEnableDefShipTo = true;
                
                       
            if(Addr.IsPrimary == 'Yes')    
                bDsiableDefAddr = true;
            
            if(Addr.isShipTo == 'Yes')
                bEnableShipping = true;
            if(string.isNotBlank(shipTo.Account_Id__r.Integration_Key__c))    
            	Addr.PromoteToERP = true;   
           // AddressList.add(Addr);
        }
        else
        {
            pageMode='New';
            if(string.isNotBlank(AccountID))
            {
                //fetching Account details base on Account Id
                Account Acc =[select Id,Name,ERP_Customer_Number__c,Integration_Key__c,Type from Account where Id=:AccountID LIMIT 1];
                Addr.Account_Id = Acc.Id;
                Addr.Account_Name=Acc.Name;
                Addr.ERP_Customer_Number=Acc.ERP_Customer_Number__c;          
                Addr.Integration_Key=Acc.Integration_Key__c;
                Addr.Account_Type=Acc.Type;
            }            
            bRenderDefaultShipTo = false;
        }
        
        string IntegrationKey=Addr.Integration_Key;
        if( string.isNotBlank(IntegrationKey))
            glERPSystemName = [SELECT ERP_System__c FROM ERP_Config__c WHERE ID =: IntegrationKey Limit 1].ERP_System__c;

        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Addr '+Addr));    
    }
    
    public boolean ApexMessages(Address addr)
    {
        if(addr.Ship_To_Country_Code =='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Country Code cannot be blank and should be valid code'));
            return false;
        }
       /* else if(addr.Ship_To_State=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'State Code cannot be blank and should be valid code'));
            return false;
        }*/
        else if(addr.Ship_To_Code=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Address Code cannot be blank.'));
            return false;
        }
        else if(addr.Ship_To_Zip_Code=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Postal Code cannot be blank.'));
            return false;
        }
        else if(addr.Ship_To_Code!='' && pageMode=='New')
        {
            list<Ship_To__c> AddrList = [select Id from Ship_To__c where Ship_To_Code__c=:addr.Ship_To_Code and Account_Id__c=:addr.Account_Id Limit 1];
            if(AddrList.size()>0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Address Code is already exist.'));
                return false;
            }
            else
                return true;
        }                         
        else
            return true;
                             
    }
    
    //Saving address locally and promoting to ERP
    public pageReference saveAddresses()
    {  
        
        boolean isAccessible =isAccessibleFields(); 
        if (!isAccessible)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Fields'));
            return null;
        }
        
        boolean isValid  = ApexMessages(Addr);
        if(!isValid)
            return null;
       
        string AccountId= string.valueOf(Addr.Account_Id);
        string ShipToId= string.valueOf(Addr.ShipToId);
                    
        SaveAddressToSF(Addr);
                
         glAccountID =Addr.Account_Id;
         return null;
    }
    
       
    public pageReference savePromoteAddresses()
    {  
        
         // Check if the user has read access on the Acccount fields
        boolean isAccessible =isAccessibleFields(); 
        if (!isAccessible)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Fields'));
            return null;
        }
        
        boolean isValid  = ApexMessages(Addr);
        if(!isValid)
            return null;
       
        AddressList = new list<Address>();
        Address newAddr = new Address();
        string AccountId= string.valueOf(Addr.Account_Id);
        string ShipToId= string.valueOf(Addr.ShipToId);
        
        AddressList.add(Addr);
        ERP_Config__c oIntegration = new ERP_Config__c(); 
        
        if(string.isNotBlank(Addr.Integration_Key))
        	oIntegration = [SELECT Id, Synchronization__c,ERP_System__c,Web_Service_URL__c,Integration_Information__c,
             Integration_Information_2__c,Integration_Information_3__c,Inactive__c FROM ERP_Config__c Where Id=:Addr.Integration_Key];
             
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Addr '+Addr));
        string response='';
        
         if(string.isBlank(Addr.Integration_Key))
         {
         	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'You cannot promote address to ERP. Account is not linked with ERP.'));
         	return null;
         }
         
         if(bUpdateCustomer == false)
         {
         	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'You cannot promote address to ERP. Please provide Permission to "Update customer" setting in Security matrix.'));
         	return null;
         }
                                         
         if(oIntegration != null)
         {
             string synchronization = oIntegration.Synchronization__c;
             if(synchronization =='both' || synchronization=='Salesforce to ERP')
                 response = PromoteAddressToERP_X3(Addr,oIntegration);                    
             else
             {
             	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You cannot promote address to ERP. Please select syncronization either "Both" or "Salesforce to ERP" in Configuration screen.'));
             	return null;
             }
        }
        
        if(response.startsWith('Error'))
         {
              status='Failed';
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while Promoting Address to ERP - '+response));
              //return null; 
         }
         else
            SaveAddressToSF(Addr);
                        
         glAccountID =Addr.Account_Id;
         return null;
    }
    
    public boolean isAccessibleFields()
    {
    	if (!Schema.sObjectType.Ship_To__c.fields.Id.isAccessible() 
                || !Schema.sObjectType.Ship_To__c.fields.isShipTo__c.isAccessible() || !Schema.sObjectType.Ship_To__c.fields.Default_ShipTo__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Warehouse_Code__c.isAccessible() || !Schema.sObjectType.Ship_To__c.fields.Telephone_No__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Telephone_Ext__c.isAccessible() || !Schema.sObjectType.Ship_To__c.fields.Tax_Schedule__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Ship_To_Zip_Code__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Ship_To_State__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Ship_To_Name__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Ship_To_Country_Code__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Ship_To_Code__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Ship_To_City__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Ship_To_Address3__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Ship_To_Address2__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Ship_To_Address1__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Salesperson_No__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.IsPrimary__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Integration_Key__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Fax_No__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.Email_Address__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.ERP_Customer_Number__c.isAccessible()|| !Schema.sObjectType.Ship_To__c.fields.ERP_Contact_Code__c.isAccessible()
                || !Schema.sObjectType.Ship_To__c.fields.Account_Id__c.isAccessible()
                )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Fields'));
            return false;
        }
        else
        	return true;
    }
    
    public void SaveAddressToSF(Address Addr)
    {
        Ship_To__c objShipTo = new Ship_To__c();
        Account Act = new Account();
        
        try
        {
            if(string.isNotBlank(Addr.ShipToId))// check whether Address is exist
                objShipTo.Id =Addr.ShipToId;
                 
            objShipTo.isShipTo__c=Addr.isShipTo;
            if(Addr.isShipTo == 'No')
                objShipTo.Default_ShipTo__c='No';
            else
                objShipTo.Default_ShipTo__c=Addr.DefaultShipTo;
                   
            objShipTo.Warehouse_Code__c=Addr.Warehouse_Code;
            objShipTo.Telephone_No__c=Addr.Telephone_No; 
            objShipTo.Telephone_Ext__c=Addr.Telephone_Ext;
            objShipTo.Tax_Schedule__c=Addr.Tax_Schedule;
            objShipTo.Ship_To_Zip_Code__c=Addr.Ship_To_Zip_Code; 
            objShipTo.Ship_To_State__c=Addr.Ship_To_State; 
            objShipTo.Ship_To_Name__c=Addr.Ship_To_Name;
            objShipTo.Ship_To_Country_Code__c=Addr.Ship_To_Country_Code;
            objShipTo.Ship_To_Code__c=Addr.Ship_To_Code; 
            objShipTo.Ship_To_City__c=Addr.Ship_To_City;
            objShipTo.Ship_To_Address3__c=Addr.Ship_To_Address3;
            objShipTo.Ship_To_Address2__c =Addr.Ship_To_Address2;
            objShipTo.Ship_To_Address1__c=Addr.Ship_To_Address1;
            objShipTo.IsPrimary__c=Addr.IsPrimary;
            objShipTo.Integration_Key__c =Addr.Integration_Key;
            objShipTo.Fax_No__c=Addr.Fax_No;
            objShipTo.Email_Address__c=Addr.Email_Address;
            if(pageMode=='New')
            	objShipTo.Account_Id__c=Addr.Account_Id;
            	
            objShipTo.External_UId__c=Addr.Integration_Key+'-'+Addr.ERP_Customer_Number+'-'+Addr.Ship_To_Code;
            
            upsert objShipTo; 
                    
            list<Ship_To__c> shipToLst = [Select Id, isShipTo__c,Default_ShipTo__c, Ship_To_Code__c,IsPrimary__c,Integration_Key__c, 
                Account_Id__c From Ship_To__c where Account_Id__c =:Addr.Account_Id and id !=:objShipTo.Id LIMIT 100];
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'shipToLst - '+shipToLst));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Addr.IsPrimary - '+Addr.IsPrimary));
                                            
            if(shipToLst.size()>0)
            {
                Ship_To__c addressTobeupdated = new Ship_To__c();
                 for(Ship_To__c shipToUpdate : shipToLst)
                 {
                    if(Addr.IsPrimary =='Yes')                    
                        shipToUpdate.IsPrimary__c='No';                  
                                 
                    if(Addr.DefaultShipTo=='Yes' )  
                        shipToUpdate.Default_ShipTo__c='No';                      
                 }                
                 update shipToLst;
            }
            
            Boolean bUpdateAccount = false;
            if(Addr.IsPrimary == 'Yes')
            {
                Act.Id = Addr.Account_Id;
                Act.BillingStreet = Addr.Ship_To_Address1+'\n'+Addr.Ship_To_Address2+'\n'+Addr.Ship_To_Address3;
                Act.BillingCity = Addr.Ship_To_City;
                Act.BillingState = Addr.Ship_To_State; 
                Act.BillingPostalCode = Addr.Ship_To_Zip_Code;
                Act.BillingCountry = Addr.Ship_To_Country_Code;
                bUpdateAccount = true;
            }
                          
            if(Addr.DefaultShipTo== 'Yes' && Addr.isShipTo == 'Yes')
            {
                Act.Id = Addr.Account_Id;
                Act.ShippingStreet= Addr.Ship_To_Address1+'\n'+Addr.Ship_To_Address2+'\n'+Addr.Ship_To_Address3;
                Act.ShippingCity= Addr.Ship_To_City;
                Act.ShippingState = Addr.Ship_To_State; 
                Act.ShippingPostalCode= Addr.Ship_To_Zip_Code;
                Act.ShippingCountry= Addr.Ship_To_Country_Code;
                bUpdateAccount = true;                
            }
            
            if(bUpdateAccount)
            {
                Utility.bRunTrigger = true;
                update Act;
                Utility.bRunTrigger = true;
            }
            status='Success';
        }
        catch(Exception ex)
        {
            status='Failed';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while Saving Record - '+ex)); 
        }
    }
    
    /*Promoting Addresses to sageERP X3*/
    public string PromoteAddressToERP_X3(Address Addr,ERP_Config__c oIntegration)
    {
        String strResponse = '' ;
        //return '';
        
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode ;
        string CompanyCode='';
        string UserID='';
        string Password='';
        string AccountType= '';
        string PublicationName = '';
        
        list<Ship_To__c> shipToLst = [Select Id, isShipTo__c,Default_ShipTo__c, Ship_To_Code__c,IsPrimary__c,Integration_Key__c, 
                Account_Id__c From Ship_To__c where Account_Id__c =:Addr.Account_Id LIMIT 100];
        
        string strParam =PrepareParams(Addr,shipToLst);
       // return '';
        
        /*if(defaultaddr!='2')
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There is No Default address set for this Customer. please select Is default address to "Yes".')); 
             return null;
        }  */
         
        String EndPoint= oIntegration.Web_Service_URL__c;
        String ERPSystem= oIntegration.ERP_System__c;
        
        map<string ,string> ParamMap =Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
                
        CompanyCode=ParamMap.get('poolAlias');
        UserID=ParamMap.get('codeUser');
        Password=Utility.Decrypt(ParamMap.get('Password'));
        
        Utility.ProgramList subProg = new Utility.ProgramList();
        if(Addr.Account_Type =='Prospect')
            PublicationName =subProg.YGTPROSDTL; 
        else
            PublicationName =subProg.YGTCUSTDTL;    
        
        string RequestXML = '';
        RequestXML +='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:wss="http://www.adonix.com/WSS" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        RequestXML +='<soapenv:Header /><soapenv:Body>';
        RequestXML +='<wss:modify soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><callContext xsi:type="wss:CAdxCallContext">';
        RequestXML +='<codeLang xsi:type="xsd:string">ENG</codeLang><codeUser xsi:type="xsd:string">'+UserID+'</codeUser><password xsi:type="xsd:string">'+Password+'</password><poolAlias xsi:type="xsd:string">'+CompanyCode+'</poolAlias>';
        RequestXML +='<poolId xsi:type="xsd:string"></poolId><requestConfig xsi:type="xsd:string"></requestConfig></callContext>';
        RequestXML +='<publicName xsi:type="xsd:string">'+ PublicationName +'</publicName>';
        RequestXML +='<objectKeys xsi:type="wss:ArrayOfCAdxParamKeyValue" soapenc:arrayType="wss:CAdxParamKeyValue[1]">';
        RequestXML +='<PARAM>';
        RequestXML +='<key>BPCNUM</key>';
        RequestXML +='<value>'+ Addr.ERP_Customer_Number+'</value>';
        RequestXML +='</PARAM>';
        RequestXML +='</objectKeys>';
        RequestXML +='<objectXml xsi:type="xsd:string">';
        RequestXML +='<![CDATA['+ strParam +']]>';
        RequestXML +='</objectXml>';
        RequestXML +='</wss:modify>';
        RequestXML +='</soapenv:Body></soapenv:Envelope>';
        
        system.debug('RequestXML  '+RequestXML);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'RequestXML  '+RequestXML));
        string getRqResponse;
        if(Test.isRunningTest()) 
        {
            getRqResponse='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:modifyResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><modifyReturn href="#id0"/></ns1:modifyResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;GRP ID=&quot;BPC0_1&quot;&gt;&lt;FLD NAME=&quot;BCGCOD&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;ZBCGCOD&quot; TYPE=&quot;Char&quot;&gt;North American customers&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPCSTA&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPRC_1&quot;&gt;&lt;FLD NAME=&quot;BPRSHO&quot; TYPE=&quot;Char&quot;&gt;Amalgamate&lt;/FLD&gt;&lt;FLD NAME=&quot;BPRLOG&quot; TYPE=&quot;Char&quot;&gt;Almagamate&lt;/FLD&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;LEGETT&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;ZCRY&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;FLD NAME=&quot;LAN&quot; TYPE=&quot;Char&quot;&gt;ENG&lt;/FLD&gt;&lt;FLD NAME=&quot;ZLAN&quot; TYPE=&quot;Char&quot;&gt;English - American&lt;/FLD&gt;&lt;FLD NAME=&quot;CRN&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;NAF&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;ZCUR&quot; TYPE=&quot;Char&quot;&gt;US Dollar&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPRFBDMAG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPRC_2&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BETFCY&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;FCY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZFCY&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPRC_3&quot;&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPCFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;REPFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;PPTFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPSFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPRACC&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;PRVFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPTFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;DOOFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPAC_5&quot;&gt;&lt;FLD NAME=&quot;NUMBPA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;IDENT&quot; TYPE=&quot;Char&quot;&gt;1NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;TRTBPAB&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;30&quot; ID=&quot;BPAC_1&quot; SIZE=&quot;3&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;CODADR&quot; TYPE=&quot;Char&quot;&gt;Ad001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPACRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;FLD NAME=&quot;ADDLIG1&quot; TYPE=&quot;Char&quot;&gt;700, Northside Street&lt;/FLD&gt;&lt;FLD NAME=&quot;ADDLIG2&quot; TYPE=&quot;Char&quot;&gt;700, Northside Street&lt;/FLD&gt;&lt;FLD NAME=&quot;ADDLIG3&quot; TYPE=&quot;Char&quot;&gt;700, Northside Street&lt;/FLD&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EXTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMOD&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMODFONC&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;CODADR&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Corporate&lt;/FLD&gt;&lt;FLD NAME=&quot;BPACRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;FLD NAME=&quot;ADDLIG1&quot; TYPE=&quot;Char&quot;&gt;136 Wexford Run Road&lt;/FLD&gt;&lt;FLD NAME=&quot;ADDLIG2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ADDLIG3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;15143&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Sewickley&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;PA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL1&quot; TYPE=&quot;Char&quot;&gt;7244443819&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL2&quot; TYPE=&quot;Char&quot;&gt;7249991313&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EXTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMOD&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMODFONC&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;CODADR&quot; TYPE=&quot;Char&quot;&gt;CORP1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPACRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;FLD NAME=&quot;ADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ADDLIG2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ADDLIG3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;00602&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Aguada&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;TEL5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WEB5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EXTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMOD&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ADRVAL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMODFONC&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;BPC1_1&quot;&gt;&lt;FLD MENULAB=&quot;Class A&quot; MENULOCAL=&quot;212&quot; NAME=&quot;ABCCLS&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;WORDMINAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;XCUR&quot; TYPE=&quot;Char&quot;&gt;EUR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ORDCLE&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;LNDAUZ&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ODL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Allowed&quot; MENULOCAL=&quot;414&quot; NAME=&quot;DME&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Exclude tax&quot; MENULOCAL=&quot;243&quot; NAME=&quot;PRITYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC1_2&quot;&gt;&lt;FLD MENULAB=&quot;Invoiced&quot; MENULOCAL=&quot;402&quot; NAME=&quot;FREINV&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;One/Shipment&quot; MENULOCAL=&quot;408&quot; NAME=&quot;IME&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Per request&quot; MENULOCAL=&quot;406&quot; NAME=&quot;INVPER&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Invoice date&quot; MENULOCAL=&quot;407&quot; NAME=&quot;DUDCLC&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC1_3&quot;&gt;&lt;FLD MENULAB=&quot;Category 1&quot; MENULOCAL=&quot;403&quot; NAME=&quot;COMCAT&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;LST NAME=&quot;REP&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;NA102&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;MORREP&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC1_4&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;WORDTEX&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;WINVTEX&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC1_5&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;OCNFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;TPMCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZTPMCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;30&quot; ID=&quot;BPC1_6&quot; SIZE=&quot;3&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;INVDTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Discount %&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;%&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;WWCUR&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;INVDTA&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Freight char&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Tax excl&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;WWCUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;INVDTA&quot; TYPE=&quot;Integer&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Insurance&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Tax excl&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;WWCUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;BPC2_1&quot;&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCBPSNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC2_2&quot;&gt;&lt;FLD MENULAB=&quot;No Check&quot; MENULOCAL=&quot;234&quot; NAME=&quot;OSTCTL&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;WOSTAUZ&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;XCUR&quot; TYPE=&quot;Char&quot;&gt;EUR&lt;/FLD&gt;&lt;FLD NAME=&quot;XOST&quot; TYPE=&quot;Decimal&quot;&gt;495245.29&lt;/FLD&gt;&lt;FLD NAME=&quot;WCDTISR&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCCDTISR&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC2_3&quot;&gt;&lt;FLD NAME=&quot;BPCNOTE&quot; TYPE=&quot;Char&quot;&gt;117&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC2_4&quot;&gt;&lt;FLD NAME=&quot;BUS&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZBUS&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ORIPPT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZORIPPT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCSNCDAT&quot; TYPE=&quot;Date&quot;&gt;20150208&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC2_5&quot;&gt;&lt;FLD NAME=&quot;PITCDT&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;PITCPT&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;TOTPIT&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCPITDEB&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;NULPIO&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;COTCHX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;COTPITRQD&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC2_6&quot;&gt;&lt;LST NAME=&quot;TSCCOD&quot; SIZE=&quot;2&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;700&lt;/ITM&gt;&lt;ITM&gt;710&lt;/ITM&gt;&lt;/LST&gt;&lt;LST NAME=&quot;ZTSCCOD&quot; SIZE=&quot;2&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;General&lt;/ITM&gt;&lt;ITM&gt;Computer&lt;/ITM&gt;&lt;/LST&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC3_1&quot;&gt;&lt;FLD NAME=&quot;BPCINV&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAINV&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCPYR&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAPYR&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;FCTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCGRU&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCRSK&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;ACCCOD&quot; TYPE=&quot;Char&quot;&gt;LOCAL&lt;/FLD&gt;&lt;FLD NAME=&quot;ZACCCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;DIA&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZDIA&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC3_2&quot;&gt;&lt;FLD NAME=&quot;VACBPR&quot; TYPE=&quot;Char&quot;&gt;NTX&lt;/FLD&gt;&lt;FLD NAME=&quot;ZVACBPR&quot; TYPE=&quot;Char&quot;&gt;No Tax&lt;/FLD&gt;&lt;FLD NAME=&quot;VATEXN&quot; TYPE=&quot;Char&quot;&gt;987321&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;BPC3_3&quot;&gt;&lt;FLD NAME=&quot;PTE&quot; TYPE=&quot;Char&quot;&gt;CH30NET&lt;/FLD&gt;&lt;FLD NAME=&quot;ZPTE&quot; TYPE=&quot;Char&quot;&gt;30 Days&lt;/FLD&gt;&lt;FLD NAME=&quot;J1&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;J2&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;J3&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;J4&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;J5&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;J6&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;UVYCOD2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZUVYCOD2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;DEP&quot; TYPE=&quot;Char&quot;&gt;SGL01&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDEP&quot; TYPE=&quot;Char&quot;&gt;2%10 InvDa&lt;/FLD&gt;&lt;FLD NAME=&quot;PAYBAN&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZPAYBAN&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;GRP&quot; TYPE=&quot;Char&quot;&gt;NA01&lt;/FLD&gt;&lt;FLD NAME=&quot;ZGRP&quot; TYPE=&quot;Char&quot;&gt;NA01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;By invoice&quot; MENULOCAL=&quot;235&quot; NAME=&quot;FUPTYP&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;FUPMINAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;FUPCUR&quot; TYPE=&quot;Char&quot;&gt;EUR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Per Request&quot; MENULOCAL=&quot;404&quot; NAME=&quot;SOIPER&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;SEBPC&quot; TYPE=&quot;Char&quot;&gt;214&lt;/FLD&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;BPC3_4&quot; SIZE=&quot;4&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;CCT&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDIE&quot; TYPE=&quot;Char&quot;&gt;Cost Cente&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;PRJ&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDIE&quot; TYPE=&quot;Char&quot;&gt;Projects&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;PRO&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDIE&quot; TYPE=&quot;Char&quot;&gt;Product&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;MAR&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDIE&quot; TYPE=&quot;Char&quot;&gt;Market&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;&gt;WHOLESALE&lt;/FLD&gt;&lt;FLD NAME=&quot;ZCCE&quot; TYPE=&quot;Char&quot;&gt;Wholesale&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;30&quot; ID=&quot;BPC4_1&quot; SIZE=&quot;1&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Corporate&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDNAM0&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDNAM1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;LAN&quot; TYPE=&quot;Char&quot;&gt;ENG&lt;/FLD&gt;&lt;FLD NAME=&quot;STOFCY&quot; TYPE=&quot;Char&quot;&gt;NA011&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCLOC&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCOLOC&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;RCPFCY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Route Code 1&quot; MENULOCAL=&quot;409&quot; NAME=&quot;DRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;410&quot; NAME=&quot;DLVPIO&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;MDL&quot; TYPE=&quot;Char&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;DAYLTI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;EECINCRAT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;NPRFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;NDEFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;REP0&quot; TYPE=&quot;Char&quot;&gt;NA102&lt;/FLD&gt;&lt;FLD NAME=&quot;PREREP0&quot; TYPE=&quot;Char&quot;&gt;NA102&lt;/FLD&gt;&lt;FLD NAME=&quot;REP1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PREREP1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PRPTEX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;DLVTEX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY1&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY2&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY3&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY4&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY5&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY6&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;UVYDAY7&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;UVYCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECICT&quot; TYPE=&quot;Char&quot;&gt;FOB&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Other EU&quot; MENULOCAL=&quot;236&quot; NAME=&quot;EECLOC&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ENAFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;VACBPD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ICTCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SSTENTCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPDCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDPOSCOD&quot; TYPE=&quot;Char&quot;&gt;15143&lt;/FLD&gt;&lt;FLD NAME=&quot;FFWNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FFWADD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPDADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;FLMOD&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;EXPNUM&quot; TYPE=&quot;Integer&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;CREUSR&quot; TYPE=&quot;Char&quot;&gt;ADMIN&lt;/FLD&gt;&lt;FLD NAME=&quot;CREDAT&quot; TYPE=&quot;Date&quot;&gt;20090216&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDUSR&quot; TYPE=&quot;Char&quot;&gt;ADMIN&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDAT&quot; TYPE=&quot;Date&quot;&gt;20160309&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;CNTC_3&quot;&gt;&lt;FLD NAME=&quot;TRTBPAB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;IDENT&quot; TYPE=&quot;Char&quot;&gt;1NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;NUMBPA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADXTEC&quot;&gt;&lt;FLD NAME=&quot;WW_MODSTAMP&quot; TYPE=&quot;Char&quot;&gt;20160309124418&lt;/FLD&gt;&lt;FLD NAME=&quot;WW_MODUSER&quot; TYPE=&quot;Char&quot;&gt;ADMIN&lt;/FLD&gt;&lt;/GRP&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.0732</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">1.0865</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">619.3491</poolExecDuration><poolRequestDuration xsi:type="xsd:double">621.9145</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">1.4726</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">634.8842</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
        }
        else
            getRqResponse = Utility.httpRequest(EndPoint, RequestXML);
       
       //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'getRqResponse  '+getRqResponse)); 
       system.debug('getRqResponse  '+getRqResponse);   
        try
        {
            doc = new Dom.Document();// reading response
            doc.load(getRqResponse);
            Dom.XMLNode Envelope = doc.getRootElement();       
            Dom.XMLNode Body= Envelope.getChildElements()[0];       
               
            for(Dom.XMLNode child : Body.getChildElements()) 
            {
                for(Dom.XMLNode subchild : child.getChildElements()) 
                {
                    if(subchild.getName() == 'resultXml')
                    {
                        strResponse = string.valueof(subchild.getText());
        
                        if(strResponse !=null ||strResponse!='')
                            break;                        
                    }
                    else if(subchild.getName() == 'message' && child.getAttribute('id','')=='id1' && (strResponse ==null ||strResponse==''))
                    {
                        strResponse = string.valueof(subchild.getText());
                        strResponse ='Error '+strResponse;                        
                    }
                }
            }
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
        
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'strResponse  '+strResponse));           
        return strResponse;
        
    }
    
    public string defaultaddr='';
    /*preparing XML parameters for request*/
   /*preparing XML parameters for request*/
    public string PrepareParams(Address Addr,list<Ship_To__c> shipToLst)
    {    
        String IntegrationKey =string.valueOf(Addr.Integration_Key);
        list<Map<string,string>>AddressLines = readAddressLine(Addr.ERP_Customer_Number,Addr.Account_Type,IntegrationKey);      
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'AddressLines  '+AddressLines));
        // return '';
         String strParam ='';
         strParam += '<PARAM>';
         if(Addr.Account_Type =='Prospect')
         {
             strParam += '<GRP ID="BPP0_1" >';
             strParam += '<FLD NAME="BPCNUM" TYPE="Char" >'+Addr.ERP_Customer_Number+'</FLD>';
             strParam += '<FLD NAME="BPCNAM" TYPE="Char" >'+Addr.Account_Name+'</FLD>';
             strParam += '</GRP>';
         }
         else
         {
             strParam += '<GRP ID="BPC0_1" >';
             strParam += '<FLD NAME="BPCNUM" TYPE="Char" >'+Addr.ERP_Customer_Number+'</FLD>';
             strParam += '<FLD NAME="BPCNAM" TYPE="Char" >'+Addr.Account_Name+'</FLD>';
             strParam += '</GRP>';
         }
         
         //for Addresses
         string addrSize = '';
         boolean addrExistInERP = false;
         
         for(map<string,string> AddressLine:AddressLines)
         {
            addrSize =AddressLine.get('Size');
            if(string.isNotBlank(addrSize))
                break;                                  
         }
             
         if(pageMode =='Edit')
         {          
             for(map<string,string> AddressLine:AddressLines)
             {
                string addrCode =AddressLine.get('AddrCode');
                if(Addr.Ship_To_Code.toUpperCase() == addrCode)
                {
                    addrExistInERP= true;
                    break;
                }           
             }
            
             if(addrExistInERP == false)
             {
                addrSize = string.valueOf(integer.valueOf(addrSize)+1);
             }
             
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'addrSize  '+addrSize));
             if(addrSize =='')
                addrSize='15';
            
              if(Addr.Account_Type =='Prospect')
                strParam += '<TAB DIM="30" ID="BPAP_1" NBLIG="'+addrSize+'">';
              else
                strParam += '<TAB DIM="30" ID="BPAC_1" NBLIG="'+addrSize+'" >';
         }
         else
         {
            if(Addr.Account_Type =='Prospect')
                strParam += '<TAB DIM="30" ID="BPAP_1">';
              else
                strParam += '<TAB DIM="30" ID="BPAC_1">';
         }
         
         string Ship_To_Address1 = string.isBlank(Addr.Ship_To_Address1) ? ' ' : Addr.Ship_To_Address1;
         string Ship_To_Address2 = string.isBlank(Addr.Ship_To_Address2) ? ' ' : Addr.Ship_To_Address2;
         string Ship_To_Address3 = string.isBlank(Addr.Ship_To_Address3) ? ' ' : Addr.Ship_To_Address3;
            
        string Telephone_No='';
        if(string.isNotBlank(Addr.Telephone_No))
                Telephone_No = Utility.phoneformat(Addr.Telephone_No);
            
        string faxNo='';    
        if(string.isNotBlank(Addr.Fax_No))
            faxNo = Utility.phoneformat(Addr.Fax_No);
            
            if(addrSize =='')
                addrSize='0';
            if(pageMode =='Edit')
            {
                string addrCode = '';
                string lineNo='';
                 for(map<string,string> AddressLine:AddressLines)
                 {
                    addrCode =AddressLine.get('AddrCode');
                    lineNo =AddressLine.get('Line');
                    //AddressSize =integer.valueOf(AddressLine.get('Size'));
                    if(Addr.Ship_To_Code == addrCode)
                        break;                                  
                 }
                 
                if(addrCode ==Addr.Ship_To_Code)
                    strParam += '<LIN NUM="'+lineNo+'" >';
                else
                {    
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'AddressLines.size()  '+AddressLines.size()));                  
                    integer lineSize = integer.valueOf(addrSize);
                    strParam += '<LIN NUM="'+string.valueOf(lineSize)+'" >';                    
                }
            }
            else
            {
                integer lineNo = integer.valueOf(addrSize)+1;
                strParam += '<LIN NUM="'+string.valueOf(lineNo)+'" >';
            }
             
             strParam += '<FLD NAME="CODADR" TYPE="Char" >'+ Addr.Ship_To_Code +'</FLD>';
             strParam += '<FLD NAME="BPADES" TYPE="Char" >'+ Addr.Ship_To_Name +'</FLD>';
             strParam += '<FLD NAME="BPACRY" TYPE="Char" >'+ Addr.Ship_To_Country_Code +'</FLD>';
             //strParam += '<FLD NAME="CRYNAM" TYPE="Char" >United States of America</FLD>';
             strParam += '<FLD NAME="ADDLIG1" TYPE="Char" >'+ Ship_To_Address1.left(32) +'</FLD>';
             strParam += '<FLD NAME="ADDLIG2" TYPE="Char" >'+ Ship_To_Address2.left(32) +'</FLD>';
             strParam += '<FLD NAME="ADDLIG3" TYPE="Char" >'+ Ship_To_Address3.left(32) +'</FLD>';
             strParam += '<FLD NAME="POSCOD" TYPE="Char" >'+ Addr.Ship_To_Zip_Code +'</FLD>';
             strParam += '<FLD NAME="CTY" TYPE="Char" >'+ Addr.Ship_To_City +'</FLD>';
             strParam += '<FLD NAME="SAT" TYPE="Char" >'+ Addr.Ship_To_State +'</FLD>';
             strParam += '<FLD NAME="TEL1" TYPE="Char" >'+ Telephone_No +'</FLD>';
             strParam += '<FLD NAME="TEL2" TYPE="Char" >'+faxNo+'</FLD>';
             
             string Email = string.isBlank(Addr.Email_Address) ? ' ' : Addr.Email_Address;            
             strParam += '<FLD NAME="WEB1" TYPE="Char" >'+ Email +'</FLD>';
             
             string primary='';            
             if(Addr.IsPrimary =='Yes')
             {
                 primary='2';
                 defaultaddr='2';
                 //strParam += '<FLD MENULAB="'+Addr.IsPrimary+'" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer" >'+primary+'</FLD>';
             }
             else
                 primary='1';
                                                                               
             strParam += '<FLD MENULAB="'+Addr.IsPrimary+'" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer" >'+primary+'</FLD>';
             strParam += '</LIN>';
             strParam += '</TAB>';
                  
            //count for shipTo
          integer shipToCnt=0;
          for(Ship_To__c readAddr : shipToLst)
          {
            if(readAddr.isShipTo__c =='Yes')
             {
                 shipToCnt++;
             }
          }
          
         //for Shipping addresses 
         string isShipTo='';
         if(Addr.Account_Type !='Prospect')
         {   
            if(Addr.isShipTo =='Yes')
            {
                //getting shipping address size from ERP
                string ShipAddrSize = '';
                for(map<string,string> AddressLine:AddressLines)
                 {
                    ShipAddrSize =AddressLine.get('ShipAddrSize');
                    if(string.isNotBlank(ShipAddrSize))
                        break;                                  
                 }
                 
                 string ERPAddrCode='';
                 string ERPLineNo='';
                 if(pageMode =='Edit')
                 {                  
                    for(map<string,string> ERPAddressCode:AddressLines)
                    {
                        ERPAddrCode =ERPAddressCode.get('AddrCode');
                        ERPLineNo  = ERPAddressCode.get('ShipLine');
                        if(ERPAddrCode == Addr.Ship_To_Code)
                            break;
                    }
                    
                    if(Addr.Ship_To_Code == ERPAddrCode && string.isNotBlank(ERPLineNo))
                    {
                        strParam += '<TAB DIM="30" ID="BPC4_1" NBLIG="'+ShipAddrSize+'" >';
                    }
                    else
                    {
                        ShipAddrSize = string.valueOf(integer.valueOf(ShipAddrSize)+1);
                        strParam += '<TAB DIM="30" ID="BPC4_1" NBLIG="'+ShipAddrSize+'" >';
                    }                                                            
                 }
                 else
                 {
                        strParam += '<TAB DIM="30" ID="BPC4_1">';
                 }
                 
                 if(Addr.Ship_To_Code == ERPAddrCode && string.isNotBlank(ERPLineNo))
                 {                                                              
                    strParam += '<LIN NUM="'+ERPLineNo+'" >';
                    
                 }
                 else
                 {
                 	integer shipSize;
                 	if(string.isNotBlank(ShipAddrSize))
                 		shipSize = integer.valueOf(ShipAddrSize)+1;
                 	else
                 		shipSize = integer.valueOf(ShipAddrSize);
                 	
                    strParam += '<LIN NUM="'+string.valueOf(shipSize)+'" >';
                 }
                strParam += '<FLD NAME="BPAADD" TYPE="Char" >'+Addr.Ship_To_Code+'</FLD>';
                string defaultshipTo='';
                isShipTo =Addr.DefaultShipTo;
                 if(Addr.DefaultShipTo=='Yes' )
                     defaultshipTo='2';
                 else
                     defaultshipTo='1';
                 
                 string strDefaultShipTo = string.isblank(Addr.DefaultShipTo)? 'No' : Addr.DefaultShipTo;
                 
                 strParam += '<FLD MENULAB="'+ strDefaultShipTo +'" MENULOCAL="1" NAME="BPDADDFLG" TYPE="Integer" >'+defaultshipTo+'</FLD>';
                 strParam += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="ENAFLG" TYPE="Integer" >2</FLD>';
                 strParam += '</LIN>';
                                        
                strParam += '</TAB>';                   
            }              
         }
        
         strParam +='</PARAM>';        
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'prepare XML '+strParam));
         //system.debug('strParam '+strParam);
         return strParam;
         
    }
    
    public list<map<string,string>> readAddressLine(string custno,string AccountType,string IntegrationKey)
    {
        list<map<string,string>> readAddressLines = new list<map<string,string>> ();
        map<string,string> readAddressLine = new map<string,string>();
        map<string,string> ERPShipToDataMap         =   new map<string,string>();
        list<map<string,string>> ERPShipToDataMapList = new list<map<string,string>>();
        
        Utility.ProgramList sbr = new Utility.ProgramList(); 
        
        string publicName='';
        if(AccountType =='Prospect')
            publicName = sbr.YGTPROSDTL;
        else 
            publicName = sbr.YGTCUSTDTL;
        
        baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(IntegrationKey);
        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'Customer', '' , Helper.MappingPurpose.DISPLAY); 
        
        list<object> obj = new list<object>();
        obj.add(AccountType) ;
        AttribParams.put('AccountType',obj);
        Helper.GUMU_Response resGUMU_Response = new Helper.GUMU_Response(); 
        if(Test.isRunningTest())
        {
            resGUMU_Response.responseERPData ='<?xml version="1.0" encoding="UTF-8"?><RESULT><GRP ID="BPC0_1"><FLD NAME="BCGCOD" TYPE="Char">US</FLD><FLD NAME="ZBCGCOD" TYPE="Char">North American customers</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCSTA" TYPE="Integer">2</FLD><FLD NAME="BPCNUM" TYPE="Char">NA002</FLD><FLD NAME="BPCNAM" TYPE="Char">Amalgamate Supply</FLD></GRP><GRP ID="BPRC_1"><FLD NAME="BPRSHO" TYPE="Char">Amalgamate</FLD><FLD NAME="BPRLOG" TYPE="Char">Almagamate</FLD><LST NAME="BPRNAM" SIZE="1" TYPE="Char"><ITM>Amalgamate Supply</ITM></LST><FLD MENULAB="No" MENULOCAL="1" NAME="LEGETT" TYPE="Integer">1</FLD><FLD NAME="CRY" TYPE="Char">US</FLD><FLD NAME="ZCRY" TYPE="Char">United States of America</FLD><FLD NAME="LAN" TYPE="Char">ENG</FLD><FLD NAME="ZLAN" TYPE="Char">English - American</FLD><FLD NAME="CRN" TYPE="Char"/><FLD NAME="NAF" TYPE="Char"/><FLD NAME="EECNUM" TYPE="Char"/><FLD NAME="CUR" TYPE="Char">USD</FLD><FLD NAME="ZCUR" TYPE="Char">US Dollar</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="BPRFBDMAG" TYPE="Integer">1</FLD></GRP><GRP ID="BPRC_2"><FLD MENULAB="No" MENULOCAL="1" NAME="BETFCY" TYPE="Integer">1</FLD><FLD NAME="FCY" TYPE="Char"/><FLD NAME="ZFCY" TYPE="Char"/></GRP><GRP ID="BPRC_3"><FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCFLG" TYPE="Integer">2</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="REPFLG" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="PPTFLG" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="BPSFLG" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="BPRACC" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="PRVFLG" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="BPTFLG" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="DOOFLG" TYPE="Integer">1</FLD></GRP><GRP ID="BPAC_5"><FLD NAME="NUMBPA" TYPE="Integer">1</FLD><FLD NAME="IDENT" TYPE="Char">1NA002</FLD><FLD NAME="TRTBPAB" TYPE="Char"/></GRP><TAB DIM="30" ID="BPAC_1" SIZE="2"><LIN NUM="1"><FLD NAME="CODADR" TYPE="Char">CORP</FLD><FLD NAME="BPADES" TYPE="Char">Corporate</FLD><FLD NAME="BPACRY" TYPE="Char">US</FLD><FLD NAME="CRYNAM" TYPE="Char">United States of America</FLD><FLD NAME="ADDLIG1" TYPE="Char">136 Wexford Run Road</FLD><FLD NAME="ADDLIG2" TYPE="Char"/><FLD NAME="ADDLIG3" TYPE="Char"/><FLD NAME="POSCOD" TYPE="Char">15143</FLD><FLD NAME="CTY" TYPE="Char">Sewickley</FLD><FLD NAME="SAT" TYPE="Char">PA</FLD><FLD NAME="TEL1" TYPE="Char">7244443819</FLD><FLD NAME="TEL2" TYPE="Char">7249991313</FLD><FLD NAME="TEL3" TYPE="Char"/><FLD NAME="TEL4" TYPE="Char"/><FLD NAME="TEL5" TYPE="Char"/><FLD NAME="WEB1" TYPE="Char"/><FLD NAME="WEB2" TYPE="Char"/><FLD NAME="WEB3" TYPE="Char"/><FLD NAME="WEB4" TYPE="Char"/><FLD NAME="WEB5" TYPE="Char"/><FLD NAME="FCYWEB" TYPE="Char"/><FLD NAME="EXTNUM" TYPE="Char"/><FLD MENULAB="Yes" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer">2</FLD><FLD NAME="FLMOD" TYPE="Integer">0</FLD><FLD NAME="FLMODFONC" TYPE="Integer">0</FLD></LIN><LIN NUM="2"><FLD NAME="CODADR" TYPE="Char">CORP1</FLD><FLD NAME="BPADES" TYPE="Char"/><FLD NAME="BPACRY" TYPE="Char">US</FLD><FLD NAME="CRYNAM" TYPE="Char">United States of America</FLD><FLD NAME="ADDLIG1" TYPE="Char"/><FLD NAME="ADDLIG2" TYPE="Char"/><FLD NAME="ADDLIG3" TYPE="Char"/><FLD NAME="POSCOD" TYPE="Char">00602</FLD><FLD NAME="CTY" TYPE="Char">Aguada</FLD><FLD NAME="SAT" TYPE="Char">PR</FLD><FLD NAME="TEL1" TYPE="Char"/><FLD NAME="TEL2" TYPE="Char"/><FLD NAME="TEL3" TYPE="Char"/><FLD NAME="TEL4" TYPE="Char"/><FLD NAME="TEL5" TYPE="Char"/><FLD NAME="WEB1" TYPE="Char"/><FLD NAME="WEB2" TYPE="Char"/><FLD NAME="WEB3" TYPE="Char"/><FLD NAME="WEB4" TYPE="Char"/><FLD NAME="WEB5" TYPE="Char"/><FLD NAME="FCYWEB" TYPE="Char"/><FLD NAME="EXTNUM" TYPE="Char"/><FLD MENULAB="No" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer">1</FLD><FLD NAME="FLMOD" TYPE="Integer">0</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="ADRVAL" TYPE="Integer">1</FLD><FLD NAME="FLMODFONC" TYPE="Integer">0</FLD></LIN></TAB><GRP ID="BPC1_1"><FLD MENULAB="Class A" MENULOCAL="212" NAME="ABCCLS" TYPE="Integer">1</FLD><FLD NAME="WORDMINAMT" TYPE="Decimal">0</FLD><FLD NAME="XCUR" TYPE="Char">EUR</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="ORDCLE" TYPE="Integer">2</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="LNDAUZ" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="ODL" TYPE="Integer">1</FLD><FLD MENULAB="Allowed" MENULOCAL="414" NAME="DME" TYPE="Integer">1</FLD><FLD MENULAB="Exclude tax" MENULOCAL="243" NAME="PRITYP" TYPE="Integer">1</FLD></GRP><GRP ID="BPC1_2"><FLD MENULAB="Invoiced" MENULOCAL="402" NAME="FREINV" TYPE="Integer">1</FLD><FLD MENULAB="One/Shipment" MENULOCAL="408" NAME="IME" TYPE="Integer">1</FLD><FLD MENULAB="Per request" MENULOCAL="406" NAME="INVPER" TYPE="Integer">1</FLD><FLD MENULAB="Invoice date" MENULOCAL="407" NAME="DUDCLC" TYPE="Integer">1</FLD></GRP><GRP ID="BPC1_3"><FLD MENULAB="Category 1" MENULOCAL="403" NAME="COMCAT" TYPE="Integer">1</FLD><LST NAME="REP" SIZE="1" TYPE="Char"><ITM>NA102</ITM></LST><FLD NAME="MORREP" TYPE="Char"/></GRP><GRP ID="BPC1_4"><FLD MENULAB="No" MENULOCAL="1" NAME="WORDTEX" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="WINVTEX" TYPE="Integer">1</FLD></GRP><GRP ID="BPC1_5"><FLD MENULAB="No" MENULOCAL="1" NAME="OCNFLG" TYPE="Integer">1</FLD><FLD NAME="TPMCOD" TYPE="Char"/><FLD NAME="ZTPMCOD" TYPE="Char"/></GRP><TAB DIM="30" ID="BPC1_6" SIZE="3"><LIN NUM="1"><FLD NAME="INVDTA" TYPE="Integer">1</FLD><FLD NAME="SHO" TYPE="Char">Discount %</FLD><FLD NAME="INVDTAAMT" TYPE="Decimal">0</FLD><FLD MENULAB="%" MENULOCAL="2227" NAME="INVDTATYP" TYPE="Integer">3</FLD><FLD NAME="WWCUR" TYPE="Char"/></LIN><LIN NUM="2"><FLD NAME="INVDTA" TYPE="Integer">2</FLD><FLD NAME="SHO" TYPE="Char">Freight char</FLD><FLD NAME="INVDTAAMT" TYPE="Decimal">0</FLD><FLD MENULAB="Tax excl" MENULOCAL="2227" NAME="INVDTATYP" TYPE="Integer">1</FLD><FLD NAME="WWCUR" TYPE="Char">USD</FLD></LIN><LIN NUM="3"><FLD NAME="INVDTA" TYPE="Integer">3</FLD><FLD NAME="SHO" TYPE="Char">Insurance</FLD><FLD NAME="INVDTAAMT" TYPE="Decimal">0</FLD><FLD MENULAB="Tax excl" MENULOCAL="2227" NAME="INVDTATYP" TYPE="Integer">1</FLD><FLD NAME="WWCUR" TYPE="Char">USD</FLD></LIN></TAB><GRP ID="BPC2_1"><FLD MENULAB="Normal" MENULOCAL="401" NAME="BPCTYP" TYPE="Integer">1</FLD><FLD NAME="BPCBPSNUM" TYPE="Char"/><FLD MENULAB="Daily Rate" MENULOCAL="202" NAME="CHGTYP" TYPE="Integer">1</FLD></GRP><GRP ID="BPC2_2"><FLD MENULAB="No Check" MENULOCAL="234" NAME="OSTCTL" TYPE="Integer">2</FLD><FLD NAME="WOSTAUZ" TYPE="Decimal">0</FLD><FLD NAME="XCUR" TYPE="Char">EUR</FLD><FLD NAME="XOST" TYPE="Decimal">495245.29</FLD><FLD NAME="WCDTISR" TYPE="Decimal">0</FLD><FLD NAME="BPCCDTISR" TYPE="Char"/></GRP><GRP ID="BPC2_3"><FLD NAME="BPCNOTE" TYPE="Char">117</FLD></GRP><GRP ID="BPC2_4"><FLD NAME="BUS" TYPE="Char"/><FLD NAME="ZBUS" TYPE="Char"/><FLD NAME="ORIPPT" TYPE="Char"/><FLD NAME="ZORIPPT" TYPE="Char"/><FLD NAME="BPCSNCDAT" TYPE="Date">20150208</FLD></GRP><GRP ID="BPC2_5"><FLD NAME="PITCDT" TYPE="Integer">0</FLD><FLD NAME="PITCPT" TYPE="Integer">0</FLD><FLD NAME="TOTPIT" TYPE="Integer">0</FLD><FLD NAME="BPCPITDEB" TYPE="Integer">0</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="NULPIO" TYPE="Integer">1</FLD><FLD NAME="COTCHX" TYPE="Char"/><FLD NAME="COTPITRQD" TYPE="Integer">0</FLD></GRP><GRP ID="BPC2_6"><LST NAME="TSCCOD" SIZE="2" TYPE="Char"><ITM>700</ITM><ITM>710</ITM></LST><LST NAME="ZTSCCOD" SIZE="2" TYPE="Char"><ITM>General</ITM><ITM>Computer</ITM></LST></GRP><GRP ID="BPC3_1"><FLD NAME="BPCINV" TYPE="Char">NA002</FLD><FLD NAME="BPAINV" TYPE="Char">CORP</FLD><FLD NAME="BPCPYR" TYPE="Char">NA002</FLD><FLD NAME="BPAPYR" TYPE="Char">CORP</FLD><FLD NAME="FCTNUM" TYPE="Char"/><FLD NAME="BPCGRU" TYPE="Char">NA002</FLD><FLD NAME="BPCRSK" TYPE="Char">NA002</FLD><FLD NAME="ACCCOD" TYPE="Char">LOCAL</FLD><FLD NAME="ZACCCOD" TYPE="Char"/><FLD NAME="DIA" TYPE="Char"/><FLD NAME="ZDIA" TYPE="Char"/></GRP><GRP ID="BPC3_2"><FLD NAME="VACBPR" TYPE="Char">NTX</FLD><FLD NAME="ZVACBPR" TYPE="Char">No Tax</FLD><FLD NAME="VATEXN" TYPE="Char">987321</FLD></GRP><GRP ID="BPC3_3"><FLD NAME="PTE" TYPE="Char">CH30NET</FLD><FLD NAME="ZPTE" TYPE="Char">30 Days</FLD><FLD NAME="J1" TYPE="Integer">0</FLD><FLD NAME="J2" TYPE="Integer">0</FLD><FLD NAME="J3" TYPE="Integer">0</FLD><FLD NAME="J4" TYPE="Integer">0</FLD><FLD NAME="J5" TYPE="Integer">0</FLD><FLD NAME="J6" TYPE="Integer">0</FLD><FLD NAME="UVYCOD2" TYPE="Char"/><FLD NAME="ZUVYCOD2" TYPE="Char"/><FLD NAME="DEP" TYPE="Char">SGL01</FLD><FLD NAME="ZDEP" TYPE="Char">2%10 InvDa</FLD><FLD NAME="PAYBAN" TYPE="Char"/><FLD NAME="ZPAYBAN" TYPE="Char"/><FLD NAME="GRP" TYPE="Char">NA01</FLD><FLD NAME="ZGRP" TYPE="Char">NA01</FLD><FLD MENULAB="By invoice" MENULOCAL="235" NAME="FUPTYP" TYPE="Integer">2</FLD><FLD NAME="FUPMINAMT" TYPE="Decimal">0</FLD><FLD NAME="FUPCUR" TYPE="Char">EUR</FLD><FLD MENULAB="Per Request" MENULOCAL="404" NAME="SOIPER" TYPE="Integer">1</FLD><FLD NAME="SEBPC" TYPE="Char">214</FLD></GRP><TAB DIM="20" ID="BPC3_4" SIZE="4"><LIN NUM="1"><FLD NAME="DIE" TYPE="Char">CCT</FLD><FLD NAME="ZDIE" TYPE="Char">Cost Cente</FLD><FLD NAME="CCE" TYPE="Char"/><FLD NAME="ZCCE" TYPE="Char"/></LIN><LIN NUM="2"><FLD NAME="DIE" TYPE="Char">PRJ</FLD><FLD NAME="ZDIE" TYPE="Char">Projects</FLD><FLD NAME="CCE" TYPE="Char"/><FLD NAME="ZCCE" TYPE="Char"/></LIN><LIN NUM="3"><FLD NAME="DIE" TYPE="Char">PRO</FLD><FLD NAME="ZDIE" TYPE="Char">Product</FLD><FLD NAME="CCE" TYPE="Char"/><FLD NAME="ZCCE" TYPE="Char"/></LIN><LIN NUM="4"><FLD NAME="DIE" TYPE="Char">MAR</FLD><FLD NAME="ZDIE" TYPE="Char">Market</FLD><FLD NAME="CCE" TYPE="Char">WHOLESALE</FLD><FLD NAME="ZCCE" TYPE="Char">Wholesale</FLD></LIN></TAB><TAB DIM="30" ID="BPC4_1" SIZE="1"><LIN NUM="1"><FLD NAME="BPAADD" TYPE="Char">CORP</FLD><FLD NAME="BPADES" TYPE="Char">Corporate</FLD><FLD NAME="BPDNAM0" TYPE="Char">Amalgamate Supply</FLD><FLD NAME="BPDNAM1" TYPE="Char"/><FLD NAME="LAN" TYPE="Char">ENG</FLD><FLD NAME="STOFCY" TYPE="Char">NA011</FLD><FLD NAME="BPCLOC" TYPE="Char"/><FLD NAME="SCOLOC" TYPE="Char"/><FLD NAME="RCPFCY" TYPE="Char"/><FLD MENULAB="Route Code 1" MENULOCAL="409" NAME="DRN" TYPE="Integer">1</FLD><FLD MENULAB="Normal" MENULOCAL="410" NAME="DLVPIO" TYPE="Integer">1</FLD><FLD NAME="BPTNUM" TYPE="Char"/><FLD NAME="MDL" TYPE="Char">3</FLD><FLD NAME="DAYLTI" TYPE="Integer">1</FLD><FLD NAME="EECINCRAT" TYPE="Decimal">0</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="NPRFLG" TYPE="Integer">2</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="NDEFLG" TYPE="Integer">2</FLD><FLD NAME="REP0" TYPE="Char">NA102</FLD><FLD NAME="PREREP0" TYPE="Char">NA102</FLD><FLD NAME="REP1" TYPE="Char"/><FLD NAME="PREREP1" TYPE="Char"/><FLD NAME="PRPTEX" TYPE="Char"/><FLD NAME="DLVTEX" TYPE="Char"/><FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY1" TYPE="Integer">2</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY2" TYPE="Integer">2</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY3" TYPE="Integer">2</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY4" TYPE="Integer">2</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY5" TYPE="Integer">2</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="UVYDAY6" TYPE="Integer">1</FLD><FLD MENULAB="No" MENULOCAL="1" NAME="UVYDAY7" TYPE="Integer">1</FLD><FLD NAME="UVYCOD" TYPE="Char"/><FLD NAME="EECICT" TYPE="Char">FOB</FLD><FLD MENULAB="Other EU" MENULOCAL="236" NAME="EECLOC" TYPE="Integer">2</FLD><FLD MENULAB="Yes" MENULOCAL="1" NAME="ENAFLG" TYPE="Integer">2</FLD><FLD NAME="VACBPD" TYPE="Char"/><FLD NAME="ICTCTY" TYPE="Char"/><FLD NAME="SSTENTCOD" TYPE="Char"/><FLD NAME="BPDCRY" TYPE="Char">US</FLD><FLD NAME="BPDPOSCOD" TYPE="Char">15143</FLD><FLD NAME="FFWNUM" TYPE="Char"/><FLD NAME="FFWADD" TYPE="Char"/><FLD NAME="EECNUM" TYPE="Char"/><FLD MENULAB="Yes" MENULOCAL="1" NAME="BPDADDFLG" TYPE="Integer">2</FLD><FLD NAME="FLMOD" TYPE="Integer">0</FLD><FLD NAME="EXPNUM" TYPE="Integer">3</FLD><FLD NAME="CREUSR" TYPE="Char">ADMIN</FLD><FLD NAME="CREDAT" TYPE="Date">20090216</FLD><FLD NAME="UPDUSR" TYPE="Char">ADMIN</FLD><FLD NAME="UPDDAT" TYPE="Date">20160222</FLD></LIN></TAB><GRP ID="CNTC_3"><FLD NAME="TRTBPAB" TYPE="Char"/><FLD NAME="IDENT" TYPE="Char">1NA002</FLD><FLD NAME="NUMBPA" TYPE="Integer">1</FLD></GRP><GRP ID="ADXTEC"><FLD NAME="WW_MODSTAMP" TYPE="Char">20160222061143</FLD><FLD NAME="WW_MODUSER" TYPE="Char">ADMIN</FLD></GRP></RESULT>';
        } 
        else
            resGUMU_Response =integrationFramework.getData(integrationFramework.PrepareFieldParam(custno,custno), AttribParams);
                    
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'resGUMU_Response '+resGUMU_Response.responseERPData)); 

        string strCustResponse=resGUMU_Response.responseERPData;
        ReadAndWriteXML.XmlNode objXmlNode = new ReadAndWriteXML.XmlNode();
        objXmlNode = ReadAndWriteXML.ParseXmlString(strCustResponse);
        list<ReadAndWriteXML.XmlNode> lstRsltNode = objXmlNode.ChildXmlNodes;
        for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
        {
            list<ReadAndWriteXML.XmlNode> lstTabNodes = readRsltNode.ChildXmlNodes;
            if(readRsltNode.Attributes.get('ID')=='BPAC_1' || readRsltNode.Attributes.get('ID')=='BPAP_1')
            {     
                 string AddrSize = readRsltNode.Attributes.get('SIZE');
                 readAddressLine = new map<string,string>();
                 readAddressLine.put('Size',AddrSize);
                 readAddressLines.add(readAddressLine);
                            
                 for(ReadAndWriteXML.XmlNode readAddrNode:lstTabNodes)
                 {
                    readAddressLine = new map<string,string>();
                    string LineNo = readAddrNode.Attributes.get('NUM');
                    if(readAddrNode.NodeName == 'LIN')
                    {
                        readAddressLine.put('Line',LineNo);
                        for(ReadAndWriteXML.XmlNode readFldAddrNode:readAddrNode.ChildXmlNodes)
                        {
                            if(readFldAddrNode.Attributes.get('NAME')=='CODADR')
                            {
                                readAddressLine.put('AddrCode',readFldAddrNode.NodeValue);
                            }
                        }
                    }
                     readAddressLines.add(readAddressLine);
                 }
                
            }
            else if(readRsltNode.Attributes.get('ID') == 'BPC4_1')
            {
                string ShipAddrSize = readRsltNode.Attributes.get('SIZE');
                ERPShipToDataMap=   new map<string,string>();
                ERPShipToDataMap.put('ShipAddrSize',ShipAddrSize);
                readAddressLines.add(ERPShipToDataMap);
                for(ReadAndWriteXML.XmlNode readLineNode:lstTabNodes)
                { 
                    
                    ERPShipToDataMap=   new map<string,string>();
                    string LineNo = readLineNode.Attributes.get('NUM');
                    if(readLineNode.NodeName == 'LIN')
                    {
                        ERPShipToDataMap.put('ShipLine',LineNo);
                        for(ReadAndWriteXML.XmlNode LineNode:readLineNode.ChildXmlNodes)
                        {
                            if( LineNode.Attributes.get('NAME')=='BPAADD')
                                ERPShipToDataMap.put(LineNode.Attributes.get('NAME'),LineNode.NodeValue);
                        }
                    }
                    ERPShipToDataMapList.add(ERPShipToDataMap);                     
                }                   
            }
            
        }
               
        for(map<string,string> readAddrLine:readAddressLines)
        {
            for(map<string,string> readERPShipToDataMap:ERPShipToDataMapList)
            {
                if(readAddrLine.get('AddrCode') == readERPShipToDataMap.get('BPAADD'))
                {
                    readAddrLine.put('ShipLine',readERPShipToDataMap.get('ShipLine'));
                }
            }
        }
        
        return readAddressLines;
    }
    
    public pageReference cancelProcess()
    {
        
        pageReference page = new pageReference('/'+Addr.Account_Id+'');
        return page; 
    }
    
    //Wrapper class to store addresses
    public class Address
    {
        public string ShipToId{get;set;}
        public string isShipTo{get;set;}
        public string DefaultShipTo{get;set;}
        public string Warehouse_Code{get;set;}
        public string Telephone_No{get;set;}
        public string Telephone_Ext{get;set;}
        public string Tax_Schedule{get;set;}
        public string Ship_To_Zip_Code{get;set;}
        public string Ship_To_State{get;set;}
        public string Ship_To_Name{get;set;}
        public string Ship_To_Country_Code{get;set;}
        public string Ship_To_Code{get;set;}
        public string Ship_To_City{get;set;}
        
        public string Ship_To_Address3{get;set;}
        public string Ship_To_Address2{get;set;}
        public string Ship_To_Address1{get;set;}
        public string Salesperson_No{get;set;}
        public string IsPrimary{get;set;}
        public string Integration_Key{get;set;}
        
        public string Fax_No{get;set;}
        public string Email_Address{get;set;}
        public string ERP_Customer_Number{get;set;}
        public string ERP_Contact_Code{get;set;}
        public string Account_Id{get;set;}
        public string Account_Name{get;set;}
        public string Account_Type{get;set;}
        public boolean PromoteToERP{get;set;}
    }
}