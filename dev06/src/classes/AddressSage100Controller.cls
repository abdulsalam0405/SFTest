public with sharing class AddressSage100Controller
{
	public String CustomerNo100 {get;set;}
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
	private static final string ClassName='AddressSage100Controller';

	public AddressSage100Controller(ApexPages.StandardController controller) 
	{
		isShipToExists=false;
		bEnableDefShipTo=true;
		bDsiableDefAddr =false;
		bRenderDefaultShipTo = true;
		bRenderShipping = true;
		bRenderDefaultAddress = true;
		bEnableShipping = false; 

		AddressList = new list<Address>();       
		Addr = new Address();
		shipTo = new Ship_To__c();
		//get ShiptoId from URL
		string shipToId = ApexPages.currentPage().getParameters().get('id');

		//get Account id
		string AccountID = ApexPages.currentPage().getParameters().get('AccountID');
		try
		{
			//fetching Address details base on ship to Id
			if(string.isNotBlank(shipToId))
			{    
				pageMode='Edit';
				isShipToExists=true;
				shipTo =[Select Id, isShipTo__c, Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
				         Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
				         Account_Id__r.Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c,
				         Account_Id__r.Name,Account_Id__r.Type ,Integration_Key__c
				         From Ship_To__c where Id=:shipToId LIMIT 1];

				//  system.debug('Ship_To_State__c '+shipTo[0].Ship_To_State__c);

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
				Addr.Integration_Key=shipTo.Integration_Key__c;

				Addr.Fax_No=shipTo.Fax_No__c;
				Addr.Email_Address=shipTo.Email_Address__c;
				Addr.ERP_Customer_Number=shipTo.ERP_Customer_Number__c;
				Addr.ERP_Contact_Code=shipTo.ERP_Contact_Code__c;
				Addr.Account_Id=shipTo.Account_Id__c ;
				glAccountID=AccountID;
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
					glAccountID=AccountID;
				}
				bRenderDefaultShipTo = false;
			}
			string IntegrationKey=Addr.Integration_Key;

			ERP_Config__c oIntegration;
			if( string.isNotBlank(IntegrationKey))
			{  
				oIntegration = [SELECT ERP_System__c FROM ERP_Config__c WHERE ID =: IntegrationKey Limit 1];
				glERPSystemName= oIntegration.ERP_System__c;
			}
		}
		catch(Exception ex)
		{
			CustomException exc= new CustomException(className,'AddressSage100Controller',ex,true);
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

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
					'Insufficient access to Fields'));
			return null;
		}

		boolean isValid  = ApexMessages(Addr);

		if(!isValid)
			return null;

		AddressList = new list<Address>();
		Address newAddr = new Address();
		string AccountId=Addr.Account_Id; //string.valueOf(Addr.Account_Id);
		string ShipToId= string.valueOf(Addr.ShipToId);

		if(string.isNotBlank(AccountId))// && string.isNotBlank(ShipToId)
		{
			// getting all addresses related to account and avoiding updated account.
			list<Ship_To__c> shipToLst = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
			                              Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
			                              Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
			                              From Ship_To__c where Account_Id__c =:AccountId and id =:ShipToId LIMIT 100];

			if(shipToLst.size() >0)
			{
				for(Ship_To__c shipTo :shipToLst)
				{
					newAddr = new Address();
					if(string.isNotBlank(shipTo.id))
					{ 
						newAddr.ShipToId=shipTo.Id;
						newAddr.isShipTo=shipTo.isShipTo__c;
						newAddr.DefaultShipTo=shipTo.Default_ShipTo__c;

						newAddr.Warehouse_Code=shipTo.Warehouse_Code__c;
						newAddr.Telephone_No=string.isBlank(shipTo.Telephone_No__c) ? '' : shipTo.Telephone_No__c;
						newAddr.Telephone_Ext=shipTo.Telephone_Ext__c;
						newAddr.Tax_Schedule=shipTo.Tax_Schedule__c;
						newAddr.Ship_To_Zip_Code=string.isBlank(shipTo.Ship_To_Zip_Code__c) ? '' : shipTo.Ship_To_Zip_Code__c;
						newAddr.Ship_To_State=string.isBlank(shipTo.Ship_To_State__c) ? '' : shipTo.Ship_To_State__c;
						newAddr.Ship_To_Name=string.isBlank(shipTo.Ship_To_Name__c) ? '' : shipTo.Ship_To_Name__c; 
						newAddr.Ship_To_Country_Code=string.isBlank(shipTo.Ship_To_Country_Code__c) ? '' : shipTo.Ship_To_Country_Code__c;
						newAddr.Ship_To_Code= string.isBlank(shipTo.Ship_To_Code__c) ? '' : shipTo.Ship_To_Code__c;
						newAddr.Ship_To_City= string.isBlank(shipTo.Ship_To_City__c) ? '' : shipTo.Ship_To_City__c;

						newAddr.Ship_To_Address3= string.isBlank(shipTo.Ship_To_Address3__c) ? '' : shipTo.Ship_To_Address3__c; 
						newAddr.Ship_To_Address2= string.isBlank(shipTo.Ship_To_Address2__c) ? '' : shipTo.Ship_To_Address2__c; 
						newAddr.Ship_To_Address1= string.isBlank(shipTo.Ship_To_Address1__c) ? '' : shipTo.Ship_To_Address1__c ;
						newAddr.Salesperson_No=shipTo.Salesperson_No__c;
						newAddr.IsPrimary= string.isBlank(shipTo.IsPrimary__c) ? 'No' : shipTo.IsPrimary__c ;
						newAddr.Integration_Key=shipTo.Integration_Key__c;

						newAddr.Fax_No= string.isBlank(shipTo.Fax_No__c) ? '' : shipTo.Fax_No__c;
						newAddr.Email_Address=shipTo.Email_Address__c;
						newAddr.ERP_Customer_Number=shipTo.ERP_Customer_Number__c;
						newAddr.ERP_Contact_Code=shipTo.ERP_Contact_Code__c;
						newAddr.Account_Id=shipTo.Account_Id__c ;
						newAddr.Account_Name=shipTo.Account_Id__r.Name;
						newAddr.Account_Type=shipTo.Account_Id__r.Type;

						AddressList.add(newAddr);
					}                   
				}
			}
		}
		//Add updated Address to Address List.
		AddressList.add(Addr);
		/*if(string.isNotBlank(Addr.Integration_Key))
        {
            string response='';
            ERP_Config__c oIntegration = [SELECT Id,Name, Synchronization__c,ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c Where Id=:Addr.Integration_Key];
            if(oIntegration != null)
            {
                string synchronization = oIntegration.Synchronization__c;
                if(synchronization =='both' || synchronization=='Salesforce to ERP')
                {
                    if(glERPSystemName =='Sage100ERP')
                        response = PromoteAddressToERP_100(AddressList,oIntegration);
                    if(string.isNotBlank(response))
                    {
                        if(response.startsWith('Error'))
                        {
                            status='Failed';
                            apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Internal server error.Please try after some time'));

                            SaveAddressToSF(Addr);
                        }
                        else
                            SaveAddressToSF(Addr);// Update address in shipto on salesforce.
                    }
                    else
                        SaveAddressToSF(Addr);
                }
                else
                    SaveAddressToSF(Addr);// Update address in shipto on salesforce.
            }
            else
                SaveAddressToSF(Addr);// Update address in shipto on salesforce.
        }
        else*/
		SaveAddressToSF(Addr);

		glAccountID =Addr.Account_Id;

		// pageReference page = new pageReference('/'+AccountId+'');
		//return page;
		//return pgref;
		return null;
	}

	public pageReference savePromoteAddresses()
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

			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
					'Insufficient access to Fields'));
			return null;
		}

		boolean isValid  = ApexMessages(Addr);

		if(!isValid)
			return null;

		AddressList = new list<Address>();
		Address newAddr = new Address();
		string AccountId=Addr.Account_Id; //string.valueOf(Addr.Account_Id);
		string ShipToId= string.valueOf(Addr.ShipToId);

		if(string.isNotBlank(AccountId))// && string.isNotBlank(ShipToId)
		{
			// getting all addresses related to account and avoiding updated account.
			list<Ship_To__c> shipToLst = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
			                              Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
			                              Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
			                              From Ship_To__c where Account_Id__c =:AccountId and id =:ShipToId LIMIT 100];

			if(shipToLst.size() >0)
			{
				for(Ship_To__c shipTo :shipToLst)
				{
					newAddr = new Address();
					if(string.isNotBlank(shipTo.id))
					{ 
						newAddr.ShipToId=shipTo.Id;
						newAddr.isShipTo=shipTo.isShipTo__c;
						newAddr.DefaultShipTo=shipTo.Default_ShipTo__c;

						newAddr.Warehouse_Code=shipTo.Warehouse_Code__c;
						newAddr.Telephone_No=string.isBlank(shipTo.Telephone_No__c) ? '' : shipTo.Telephone_No__c;
						newAddr.Telephone_Ext=shipTo.Telephone_Ext__c;
						newAddr.Tax_Schedule=shipTo.Tax_Schedule__c;
						newAddr.Ship_To_Zip_Code=string.isBlank(shipTo.Ship_To_Zip_Code__c) ? '' : shipTo.Ship_To_Zip_Code__c;
						newAddr.Ship_To_State=string.isBlank(shipTo.Ship_To_State__c) ? '' : shipTo.Ship_To_State__c;
						newAddr.Ship_To_Name=string.isBlank(shipTo.Ship_To_Name__c) ? '' : shipTo.Ship_To_Name__c; 
						newAddr.Ship_To_Country_Code=string.isBlank(shipTo.Ship_To_Country_Code__c) ? '' : shipTo.Ship_To_Country_Code__c;
						newAddr.Ship_To_Code= string.isBlank(shipTo.Ship_To_Code__c) ? '' : shipTo.Ship_To_Code__c;
						newAddr.Ship_To_City= string.isBlank(shipTo.Ship_To_City__c) ? '' : shipTo.Ship_To_City__c;

						newAddr.Ship_To_Address3= string.isBlank(shipTo.Ship_To_Address3__c) ? '' : shipTo.Ship_To_Address3__c; 
						newAddr.Ship_To_Address2= string.isBlank(shipTo.Ship_To_Address2__c) ? '' : shipTo.Ship_To_Address2__c; 
						newAddr.Ship_To_Address1= string.isBlank(shipTo.Ship_To_Address1__c) ? '' : shipTo.Ship_To_Address1__c ;
						newAddr.Salesperson_No=shipTo.Salesperson_No__c;
						newAddr.IsPrimary= string.isBlank(shipTo.IsPrimary__c) ? 'No' : shipTo.IsPrimary__c ;
						newAddr.Integration_Key=shipTo.Integration_Key__c;

						newAddr.Fax_No= string.isBlank(shipTo.Fax_No__c) ? '' : shipTo.Fax_No__c;
						newAddr.Email_Address=shipTo.Email_Address__c;
						newAddr.ERP_Customer_Number=shipTo.ERP_Customer_Number__c;
						newAddr.ERP_Contact_Code=shipTo.ERP_Contact_Code__c;
						newAddr.Account_Id=shipTo.Account_Id__c ;
						newAddr.Account_Name=shipTo.Account_Id__r.Name;
						newAddr.Account_Type=shipTo.Account_Id__r.Type;

						AddressList.add(newAddr);
					}                   
				}
			}
		}

		AddressList.add(Addr);
		if(string.isNotBlank(Addr.Integration_Key))
		{
			string response='';
			ERP_Config__c oIntegration = [SELECT Id,Name, Synchronization__c,ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c Where Id=:Addr.Integration_Key];
			if(oIntegration != null)
			{
				string synchronization = oIntegration.Synchronization__c;
				if(synchronization =='both' || synchronization=='Salesforce to ERP')
				{
					if(glERPSystemName =='Sage100ERP')
						response = PromoteAddressToERP_100(AddressList,oIntegration);
					system.debug('response '+response);
					status='';
					if(string.isNotBlank(response))
					{
						if(response.startsWith('Error'))
						{
							status='Failed';
							apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Internal server error.Please try after some time'));
							SaveAddressToSF(Addr);
						}
						else
							SaveAddressToSF(Addr);// Update address in shipto on salesforce.
					}
					else
						SaveAddressToSF(Addr);
				}
				else
					SaveAddressToSF(Addr);// Update address in shipto on salesforce.
			}
			else
				SaveAddressToSF(Addr);// Update address in shipto on salesforce.
		}
		else
			SaveAddressToSF(Addr);

		glAccountID =Addr.Account_Id;
		//pageReference page = new pageReference('/'+AccountId+'');
		//return page;
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

			if (string.isNotBlank( glAccountID))
				objShipTo.Account_Id__c=glAccountID;    

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
			objShipTo.External_UId__c=Addr.Integration_Key+'-'+Addr.ERP_Customer_Number+'-'+Addr.Ship_To_Code;
			//Database.Upsert(objShipTo,Ship_To__c.Fields.External_UId__c,true);
			upsert objShipTo; 
			
			//list<Ship_To__c> AddressList = [Select Id, isShipTo__c,Default_ShipTo__c, Ship_To_Code__c,IsPrimary__c,Integration_Key__c, 
			                             // Account_Id__c From Ship_To__c where Account_Id__c =:Addr.Account_Id and id !=:objShipTo.Id LIMIT 100];
			                          
            system.debug('AddressList3 '+json.serialize(AddressList));
			glAccountID =objShipTo.Account_Id__c;

			/*if(AddressList.size()>0)
			{
				Ship_To__c addressTobeupdated = new Ship_To__c();
				for(Address shipToUpdate : AddressList)
				{ 
					if(Addr.IsPrimary =='Yes' && Addr.Ship_To_Code != shipToUpdate.Ship_To_Code && shipToUpdate.IsPrimary =='Yes' )
					{     
						addressTobeupdated.Id = shipToUpdate.ShipToId;
						addressTobeupdated.IsPrimary__c='No';
						update addressTobeupdated;  
					}

					if(Addr.DefaultShipTo=='Yes' && Addr.Ship_To_Code != shipToUpdate.Ship_To_Code && shipToUpdate.DefaultShipTo=='Yes' && shipToUpdate.IsPrimary=='No'  )
					{
						addressTobeupdated = new Ship_To__c();
						addressTobeupdated.Id = shipToUpdate.ShipToId;
						addressTobeupdated.Default_ShipTo__c='No'; 
						update addressTobeupdated;                        
					}
					if(Addr.DefaultShipTo=='No' && Addr.Ship_To_Code != shipToUpdate.Ship_To_Code && shipToUpdate.isShipTo =='Yes' )  
					{
						addressTobeupdated = new Ship_To__c();
						addressTobeupdated.Id = shipToUpdate.ShipToId;
						addressTobeupdated.Default_ShipTo__c='No'; 
						update addressTobeupdated; 
					}                        
				}
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
			}*/
			
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
				if(status=='Failed')
				{

				}
				else
					status='Success';
				//status='Success';
						
		}
		catch(Exception ex)
		{
			status='Failed';
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Fatal, ex.getMessage()));
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Fatal, 'ClassName.SaveAddressToSF.LineNumber:'+ ex.getLineNumber()));
		}
	}
	//Promoting Addresses to sageERP 100
	public string PromoteAddressToERP_100(List<Address>AddrList,ERP_Config__c oIntegration)
	{
		 string response ='';
		try
		{  
		   
			string AccountID=Addr.Account_Id;
			map<String,String> PromotionFields = new map<String,String>();
			list<Account> CurrentAccount = [Select 
			                                a.Type, a.Website, a.ShippingStreet,a.ShippingState,a.ShippingPostalCode,a.ShippingLongitude,a.ShippingLatitude,a.ShippingCountry,a.ShippingCity,
			                                a.Phone,a.ParentId,a.Name,a.MasterRecordId,a.Id,a.Fax,a.ERP_Customer__c,a.Integration_Key__c,a.Description,a.ERP_Customer_Number__c ,a.AR_DivisonNo__c,
			                                a.ERP_Company_Code__c,a.BillingStreet,a.BillingState,a.BillingPostalCode,a.BillingLongitude,a.BillingLatitude,a.BillingCountry,a.BillingCity
			                                From Account a Where a.Id=:AccountID limit 1 ];

			list<Contact> Contacts = [Select 
			                          Id,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,
			                          MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Phone,Fax,MobilePhone,HomePhone,
			                          OtherPhone,Email,Title,Birthdate,Description,ERP_Contact_Code__c 
			                          From Contact Where AccountId =:AccountID limit 100];

			list<Ship_To__c> Addresses=new list<Ship_To__c>();
			//Addresses = [Select Id, isShipTo__c,Default_ShipTo__c, Warehouse_Code__c, Telephone_No__c, Telephone_Ext__c, Tax_Schedule__c, Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Name__c, 
			//              Ship_To_Country_Code__c, Ship_To_Code__c, Ship_To_City__c, Ship_To_Address3__c, Ship_To_Address2__c, Ship_To_Address1__c, Salesperson_No__c, IsPrimary__c, 
			//              Integration_Key__c, Fax_No__c, Email_Address__c, ERP_Customer_Number__c, ERP_Contact_Code__c, Account_Id__c ,Account_Id__r.Name,Account_Id__r.Type
			//              From Ship_To__c where Account_Id__c =:AccountID LIMIT 100];


			for(Address CustomAddress:AddrList)
			{

				Ship_To__c Address=new  Ship_To__c () ;

				Address.Ship_To_Code__c =CustomAddress.Ship_To_Code;
				Address.Ship_To_State__c=CustomAddress.Ship_To_State;
				Address.Ship_To_Zip_Code__c=CustomAddress.Ship_To_Zip_Code;
				Address.Ship_To_Country_Code__c=CustomAddress.Ship_To_Country_Code;
				Address.Ship_To_City__c=CustomAddress.Ship_To_City;

				//'<CODETERR>US</CODETERR>';
				Address.Ship_To_Address1__c=CustomAddress.Ship_To_Address1;
				Address.Ship_To_Address2__c=CustomAddress.Ship_To_Address2;
				Address.Ship_To_Address3__c=CustomAddress.Ship_To_Address3;
				Addresses.Add(Address);
			}

			string arDiv=String.valueOf(CurrentAccount[0].AR_DivisonNo__c);
			PromotionFields.put('AR_DivisonNo',arDiv);

			//list<ERP_Config__c> oIntegration = [SELECT Name, Synchronization__c,ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: CurrentAccount[0].Integration_Key__c];  
			Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);

			map<string,list<object>> AttribParams=new map<string,list<object>> ();
			list<object>  AttribParam= new list<object>();
			string IntegrationKey=CurrentAccount[0].Integration_Key__c;
			AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Address100', '' , Helper.MappingPurpose.POST); 
			AttribParam= new list<object>();
			AttribParam.add('SO_ShipToAddress');

			AttribParams.put('ERPFuncName',AttribParam);
			map<string,list<object>> SFObjectLists = new map<string,list<object>> ();

			SFObjectLists.put('Accounts',CurrentAccount);
			SFObjectLists.put('Contacts',Contacts);
			SFObjectLists.put('Addresses',Addresses);

			map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
			map<string,list<string>> parameter = new map<string,list<string>>();
			list<string> listParams=new list<string> ();

			Helper.Operator operator= Helper.Operator.EQUAL;

			listParams=new list<string> ();
			listParams.add(CurrentAccount[0].AR_DivisonNo__c);  
			parameter.put(string.valueOf(operator),listParams);
			WhereParams.put('ARDivisionNo',parameter);

			listParams=new list<string> ();
			parameter = new map<string,list<string>>();
			listParams.add((CurrentAccount[0].ERP_Customer_Number__c).toUpperCase());  
			parameter.put(string.valueOf(operator),listParams);                     
			WhereParams.put('CustomerNo',parameter);

			parameter = new map<string,list<string>>();
			listParams=new list<string> ();
			listParams.add(Addr.Ship_To_Code.toUpperCase()); 
			parameter.put(string.valueOf(operator),listParams);
			WhereParams.put('ShipToCode',parameter);

			baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
			Helper.GUMU_Response resGUMU_Response ; 
			resGUMU_Response =integrationFramework.getData(WhereParams,AttribParams);
			system.debug('getdata '+resGUMU_Response);

			if (resGUMU_Response.statusCode!='200' && resGUMU_Response.statusCode!='201' )
			{
				if (string.isNotBlank(resGUMU_Response.responseERPData))
				{
					Utility.parse(resGUMU_Response.responseERPData,'message');
				} 
			}   
			else
			{
				//insert record
				if (resGUMU_Response.totalRecord =='' || resGUMU_Response.totalRecord =='0')
				{
					AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Address100', '' , Helper.MappingPurpose.POST);
				}
				//update record
				else 
				{
					AttribParams=Utility.getAttribParameters('', '' , IntegrationKey, 'Address100', '' , Helper.MappingPurpose.MODIFY);
				} 

				AttribParam= new list<object>();
				AttribParam.add(setAccountAddressXML(AddressList,PromotionFields));
				system.debug('XML '+AttribParam);
				// AttribParam.add(setAccountAddressXML(AddressList,WhereParams));
				AttribParams.put('RequestXML',AttribParam);
				AttribParam= new list<object>();
				AttribParam.add('SO_ShipToAddress');
				AttribParams.put('ERPFuncName',AttribParam);
				list<string> KeyValue= new list<string>();
				KeyValue.Add(CurrentAccount[0].AR_DivisonNo__c);
				KeyValue.Add(CurrentAccount[0].ERP_Customer_Number__c);
				KeyValue.Add(Addr.Ship_To_Code);
				AttribParams.put('KeyValue',KeyValue);

				//Post the reocord 
				resGUMU_Response =integrationFramework.PostData(IntegrationKey,'Address', SFObjectLists,PromotionFields,AttribParams);

				system.debug('resGUMU_Response '+json.serialize(resGUMU_Response.ERPDataMap));
				if (resGUMU_Response.statusCode!='200' && resGUMU_Response.statusCode!='201' )
				{

					if (string.isNotBlank(resGUMU_Response.responseERPData))
					{
						Utility.parse(resGUMU_Response.responseERPData,'message');
					}  
					//return null;
					response='ErrorSystem';
					//return Response; 
				}
				else
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Address promoted successfully.'));
			}   
		}
		catch(Exception ex)
		{
			CustomException exc= new CustomException(className,'PromoteCustomer_100',ex,true);
		}
		return response;
	}

	private string setAccountAddressXML(list<Address> AddressList,map<String,String> PromotionFields) 
	{
		system.debug('AddressList '+AddressList);
		Integer count=Integer.valueOf(AddressList.size());

		string CustomerNo100 = PromotionFields.get('CustomerNo100');
		string Ar_DivisionNo=  PromotionFields.get('AR_DivisonNo');

		if (CustomerNo100 ==null ||CustomerNo100 =='null' ) 
			CustomerNo100 = Addr.ERP_Customer_Number;

		string strObjXML_1='';
		if (AddressList!=null)
		{
			string Ship_To_Address1 = string.isBlank(AddressList[count-1].Ship_To_Address1) ? ' ':AddressList[count-1].Ship_To_Address1;
			string Ship_To_Address2 = string.isBlank(AddressList[count-1].Ship_To_Address2) ? ' ':AddressList[count-1].Ship_To_Address2;
			string Ship_To_Address3 = string.isBlank(AddressList[count-1].Ship_To_Address3) ? ' ':AddressList[count-1].Ship_To_Address3;
			
			
			
			strObjXML_1 +='<entry xmlns:atom="http://www.w3.org/2005/Atom" ';
			strObjXML_1 +='xmlns:xs="http://www.w3.org/2001/XMLSchema" ';
			strObjXML_1 +='xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005" ';
			strObjXML_1 +='xmlns="http://www.w3.org/2005/Atom" ';
			strObjXML_1 +='xmlns:sdata="http://schemas.sage.com/sdata/2008/1" ';
			strObjXML_1 +='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
			strObjXML_1 +='xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1" ';
			strObjXML_1 +='xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1" ';
			strObjXML_1 +='xmlns:sme="http://schemas.sage.com/sdata/sme/2007" ';
			strObjXML_1 +='xmlns:http="http://schemas.sage.com/sdata/http/2008/1"> ';
			//strObjXML_1 +='<entry>';
			strObjXML_1 +='<sdata:payload>';
			strObjXML_1 +='<SO_ShipToAddress xmlns="">';
			strObjXML_1 +='<ARDivisionNo>'+ Ar_DivisionNo +'</ARDivisionNo>';
			strObjXML_1 +='<CustomerNo>'+ CustomerNo100 +'</CustomerNo>';
			strObjXML_1 +='<ShipToZipCode>'+AddressList[count-1].Ship_To_Zip_Code+'</ShipToZipCode>';
		    strObjXML_1 +='<ShipToCountryCode>'+AddressList[count-1].Ship_To_Country_Code+'</ShipToCountryCode>';
			strObjXML_1 +='<ShipToState>'+AddressList[count-1].Ship_To_State+'</ShipToState>';
			strObjXML_1 +='<ShipToCity>'+AddressList[count-1].Ship_To_City+'</ShipToCity>';
			strObjXML_1 += '<ShipToAddress1>'+Ship_To_Address1+'</ShipToAddress1>';
			strObjXML_1 +='<ShipToAddress2>'+Ship_To_Address2+'</ShipToAddress2>';
			strObjXML_1 +='<ShipToAddress3>'+Ship_To_Address3+'</ShipToAddress3> ';
			strObjXML_1 +='<TelephoneExt>'+AddressList[count-1].Telephone_Ext+'</TelephoneExt> ';
			strObjXML_1 +='<ShipToCode>'+AddressList[count-1].Ship_To_Code+'</ShipToCode>';
			strObjXML_1 +='<ShipToName>'+AddressList[count-1].Ship_To_Name+'</ShipToName>';
			strObjXML_1 +='<EmailAddress>'+AddressList[count-1].Email_Address+'</EmailAddress>';
			strObjXML_1 +='<TelephoneNo>'+AddressList[count-1].Telephone_No+'</TelephoneNo>';
			strObjXML_1 +='<FaxNo>'+AddressList[count-1].Fax_No+'</FaxNo>';
			//strObjXML_1 += '<TEXTSTRE4>'+Ship_To_Address4__c+'</TEXTSTRE2> ';
			strObjXML_1  +='<SWACTV>1</SWACTV>';
			//strObjXML_1 +='<FOB xsi:nil="false" />;
			//strObjXML_1+= <SHPVIADESC xsi:nil="false" />;
			strObjXML_1 +='</SO_ShipToAddress>';
			strObjXML_1 +='</sdata:payload>';
			strObjXML_1 +='</entry>';
		} 
		system.debug('strObjXML_1 '+strObjXML_1);
		return strObjXML_1;       
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