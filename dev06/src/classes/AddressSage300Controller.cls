public with sharing class AddressSage300Controller 
{
    public String CustomerNo300 {get;set;}

    public list<Address> AddressList{get;set;}
    public Address Addr {get;set;}
    public Ship_To__c shipTo {get;set;}
    public string glERPSystemName{get;set;}
    public string pageMode{get;set;}
    public string status{get;set;}
    public string glAccountID {get;set;} 

    public boolean isShipAddress{get;set;} 
    public boolean bEnableDefShipTo{get;set;}
    public boolean bDsiableDefAddr {get;set;}
    public boolean isShipToExists{get;set;}  
    public boolean bRenderDefaultShipTo{get;set;}
    public boolean bRenderShipping{get;set;}
    public boolean bRenderDefaultAddress{get;set;}
    public boolean bEnableShipping{get;set;}
    public Boolean bUpdateCustomer{get;set;}
    private static final string ClassName='AddressSage300Controller';

    public AddressSage300Controller(ApexPages.StandardController controller) 
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
                     Account_Id__r.Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c,
                     Account_Id__r.Name,Account_Id__r.Type 
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
        }

        string IntegrationKey=Addr.Integration_Key;
        ERP_Config__c oIntegration;
        if( string.isNotBlank(IntegrationKey))
        {
            oIntegration = [SELECT ERP_System__c FROM ERP_Config__c WHERE ID =: IntegrationKey Limit 1];
            glERPSystemName= oIntegration.ERP_System__c;
        }
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
        // Check if the user has read access on the Acccount fields
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
                return null;
             }
                
        //system.debug('adddress '+Addr);
        boolean isValid  = ApexMessages(Addr);

        if(!isValid)
            return null;

        string AccountId=string.valueOf(Addr.Account_Id); //string.valueOf(Addr.Account_Id);
        string ShipToId= string.valueOf(Addr.ShipToId);
        
        SaveAddressToSF(Addr);
        glAccountID =Addr.Account_Id;
        return null;
    }
    public pageReference SavepromoteAddress()
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
                 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Addr '+Addr));
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
                 {
                    response = PromoteAddressToERP_300(Addr,oIntegration);  
                 }
                        
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
            objShipTo.Account_Id__c=Addr.Account_Id;
            objShipTo.External_UId__c=Addr.Integration_Key+'-'+Addr.ERP_Customer_Number+'-'+Addr.Ship_To_Code;

            upsert objShipTo; 
            
            list<Ship_To__c> shipToLst = [Select Id, isShipTo__c,Default_ShipTo__c, Ship_To_Code__c,IsPrimary__c,Integration_Key__c, 
                Account_Id__c From Ship_To__c where Account_Id__c =:objShipTo.Account_Id__c and id !=:objShipTo.Id LIMIT 100];
                                            
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
            status=Status;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Address Save Successfully '));
        }
        catch(Exception ex)
        {
            status='Failed';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while Saving Record - '+ex)); 
        }
    }
    
    
    /*Promoting Addresses to sageERP 300*/
    public string PromoteAddressToERP_300(Address Addr,ERP_Config__c oIntegration)
    {
    	
        string Response ='';
        try
        {  
            string AccountID=Addr.Account_Id;
            map<String,String> PromotionFields = new map<String,String>();
            list<Account> CurrentAccount = new list<Account>(); 
    
            list<Contact> Contacts = new list<Contact>();     
            list<Ship_To__c> Addresses=new list<Ship_To__c> () ;
            
             
            Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
            
            string IntegrationKey=Addr.Integration_Key;
            
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            list<object>  AttribParam= new list<object>();
            AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Address300', '' , Helper.MappingPurpose.POST); 
            
            AttribParam= new list<object>();
            AttribParam.add('arshiptolocationsfinder');
            AttribParams.put('ERPFuncName',AttribParam);
            
            AttribParam= new list<object>();
            AttribParam.add('GETData');
            AttribParams.put('PostDataXml',AttribParam);
            
           
          
            map<string,list<object>> SFObjectLists = new map<string,list<object>> ();

            SFObjectLists.put('Accounts',CurrentAccount);
            SFObjectLists.put('Contacts',Contacts);
            SFObjectLists.put('Addresses',Addresses); //Addresses

            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();
            
            Helper.Operator operator= Helper.Operator.EQUAL;
            listParams.add(Addr.ERP_Customer_Number);  
            parameter.put(string.valueOf(operator),listParams);                     
            WhereParams.put('IDCUST',parameter);
            
            parameter = new map<string,list<string>>();
            listParams=new list<string> ();
            listParams.add(Addr.Ship_To_Code); 
            parameter.put(string.valueOf(operator),listParams);
            WhereParams.put('IDCUSTSHPT',parameter);
                        
            baseIntegrationFramework integrationFramework= new Sage300IntegrationFramework();
            Helper.GUMU_Response resGUMU_Response ; 
            
            resGUMU_Response =integrationFramework.getData(WhereParams,AttribParams);
            
           
            if (resGUMU_Response.statusCode!='200' && resGUMU_Response.statusCode!='201')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error retrieving address information from ERP.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,resGUMU_Response.statusCode + ':'+  resGUMU_Response.statusMessage));
            }   
            else
            {
                AttribParam= new list<object>();
               
                //KeyValue.add(Addr.ERP_Customer_Number);
               // KeyValue.add(Addr.Ship_To_Code);
                
               
                //AttribParams.put('KeyValue',KeyValue);
                    
                //insert record
                if (resGUMU_Response.totalRecord=='' || resGUMU_Response.totalRecord=='0'){                   
                
                AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Address1', '' , Helper.MappingPurpose.POST);
                }else
                {
                    AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Address1', '' , Helper.MappingPurpose.MODIFY);
                    
                }   
                
                     AttribParam= new list<object>();
                    
                    AttribParam.add(setAccountAddressXML(Addr));
                    AttribParams.put('RequestXML',AttribParam);
                        
                    AttribParam= new list<object>();
                    AttribParam.add('arshiptolocationsfinder');
                    AttribParams.put('ERPFuncName',AttribParam);
                    
                    AttribParam= new list<object>();
                    AttribParam.add('GETData');
                    AttribParams.put('PostDataXml',AttribParam);
                    
                    list<string> KeyValue= new list<string>();
                    KeyValue.add(Addr.ERP_Customer_Number);
                    KeyValue.add(Addr.Ship_To_Code);
                    AttribParams.put('KeyValue',KeyValue);
                //Post the reocord 
                
                 resGUMU_Response =integrationFramework.PostData(IntegrationKey,'Address1', SFObjectLists,PromotionFields,AttribParams);
                 
                if (resGUMU_Response.statusCode!='200' && resGUMU_Response.statusCode!='201' )
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while promoting address.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,resGUMU_Response.statusCode + ':'+  resGUMU_Response.statusMessage));
                    if (string.isNotBlank(resGUMU_Response.responseERPData))
                    {
                        Utility.parse(resGUMU_Response.responseERPData,'message');
                    }  
                    Response='Error';
                    
                }
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Address promoted successfully.'));
            }   
        }
         catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'PromoteCustomer_300',ex,true);
        }
        system.debug('Response '+Response);
        return Response; 
    }

   private string setAccountAddressXML(Address Addr) 
    { 
       string CustomerNo300 = Addr.ERP_Customer_Number;
       string strObjXML='';
       if (Addr !=null)
        {
            strObjXML +='<entry>';
            strObjXML +='<sdata:payload>';
            strObjXML +='<arshiptolocationsfinder>';
            strObjXML +='<IDCUSTSHPT>'+Addr.Ship_To_Code+'</IDCUSTSHPT>';
            strObjXML +='<NAMELOCN>'+Addr.Ship_To_Name+'</NAMELOCN>';
            strObjXML +='<NAMECITY>'+Addr.Ship_To_City+'</NAMECITY>';
            strObjXML +='<CODESTTE>'+Addr.Ship_To_State+'</CODESTTE>';
            strObjXML +='<CODEPSTL>'+Addr.Ship_To_Zip_Code+'</CODEPSTL>';
            strObjXML +='<CODECTRY>'+Addr.Ship_To_Country_Code+'</CODECTRY>';
            strObjXML +='<IDCUST>'+ CustomerNo300 +'</IDCUST>';
            strObjXML += '<TEXTSTRE1>'+Addr.Ship_To_Address1+'</TEXTSTRE1>';
            strObjXML +='<TEXTSTRE2>'+Addr.Ship_To_Address2+'</TEXTSTRE2>';
            strObjXML +='<TEXTSTRE3>' +Addr.Ship_To_Address3+'</TEXTSTRE3> ';
            //strObjXML_1 += '<TEXTSTRE4>'+Ship_To_Address4__c+'</TEXTSTRE2> ';
            strObjXML  +='<SWACTV>1</SWACTV>';
            strObjXML +='</arshiptolocationsfinder>';
            strObjXML +='</sdata:payload>';
            strObjXML +='</entry>';
                
           // strObjXML +='<CODECTRY>'+Addr.Ship_To_Country_Code+'</CODECTRY>';
            
            //strObjXML_1 += '<SHPVIACODE>'+shipTo.Ship_To_Code__c+ '</SHPVIACODE>';
            //strObjXML_1 += '<NAMECTAC></NAMECTAC>';
            //strObjXML_1 += '<CODETERR>US</CODETERR>';
            
            //strObjXML_1 +='<FOB xsi:nil="false" />;
            //strObjXML_1+= <SHPVIADESC xsi:nil="false" />;
           system.debug('strObjXML:'+strObjXML);
        } 
         return strObjXML;       
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
    }
}