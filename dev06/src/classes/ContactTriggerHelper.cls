global class ContactTriggerHelper {

	private static final string ClassName='ContactTriggerHelper';
	public static integer ContactSequence;  
	public static String GlContactCode='';
	//public list<map<string,string>> Contact_Code;

	public static void BeforeInsert(list<Contact> NewContacts,list<Contact> OldContacts)
	{
		try
		{
			for(Contact Cont : NewContacts)
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

	public static void AfterInsert(list<Contact> NewContacts,list<Contact> OldContacts)
	{
		try
		{
			List<String> lstAccountId = new List<String>();
			List<String> lstContactId = new List<String>();
			for(Contact cnt : NewContacts)
			{
				lstAccountId.add(cnt.AccountId);
				lstContactId.add(cnt.Id);
			}

			Map<ID, Account> lstAct = new Map<ID, Account>([Select Id,Integration_Key__c From Account Where Id IN:lstAccountId ]);

			Map<ID, ERP_Config__c> lstIntegration = new Map<ID, ERP_Config__c>([SELECT Id, Synchronization__c FROM ERP_Config__c LIMIT 100 ]);

			Map<ID, Contact> lstContact = new Map<ID, Contact>([Select Id,Sync_To_ERP__c From Contact Where Id IN:lstContactId ]);

			List<Contact> LstUpsertContact = new List<Contact>();

			string synchronization ='';
			string IntegrationId='';

			for(Contact cnt : NewContacts)
			{
				if(cnt.AccountId !=null)
				{
					if(Utility.bRunTrigger && lstAct.size() > 0)
					{
						Account Act = lstAct.get(cnt.AccountId);

						if(Act != null)
						{
							IntegrationId = Act.Integration_Key__c;

							if(String.isNotBlank(IntegrationId))
							{   
								ERP_Config__c oIntegration = lstIntegration.get(Act.Integration_Key__c);

								if(oIntegration == null)
									continue;

								synchronization = oIntegration.Synchronization__c;

								if(synchronization =='both' || synchronization=='Salesforce to ERP')
								{ 
									if(cnt.Sync_To_ERP__c)
									{
										UpsertERPContact(cnt.Id,IntegrationId);
									}
									else
									{
										Contact upCnt = lstContact.get(cnt.id);
										upCnt.Sync_To_ERP__c=true;

										LstUpsertContact.add(upCnt);
									}
								}
							}
						}
					}
				}
			} 

			update LstUpsertContact;
		}
		catch(Exception ex)
		{
			CustomException exc= new CustomException(ClassName,'AfterInsert',ex,false);
		} 
	}

	public static void BeforeUpdate(list<Contact> NewContacts,list<Contact> OldContacts)
	{
		system.debug('NewContacts '+NewContacts);
		try
		{
			List<String> lstAccountId = new List<String>();
			for(Contact cnt : NewContacts)
				lstAccountId.add(cnt.AccountId);

			Map<ID, Account> lstAct = new Map<ID, Account>([Select Id,Integration_Key__c From Account Where Id IN :lstAccountId]);
			Map<ID, ERP_Config__c> lstIntegration = new Map<ID, ERP_Config__c>([SELECT Id, Synchronization__c FROM ERP_Config__c LIMIT 10 ]);
			system.debug('lstIntegration '+lstIntegration);
			
			for(Contact cnt : NewContacts)
			{
				if(Utility.bRunTrigger && lstAct.size() > 0)
				{
					Account Act = lstAct.get(cnt.AccountId);

					if(String.isNotBlank(Act.Integration_Key__c))
					{

						ERP_Config__c oIntegration = lstIntegration.get(Act.Integration_Key__c);
						//system.debug('synchronization '+synchronization);
						string synchronization = oIntegration.Synchronization__c;
						
						system.debug('synchronization '+synchronization);
						
						if(synchronization =='both' || synchronization=='Salesforce to ERP')
						{
							Decimal decTime =Decimal.valueOf(Datetime.now().getTime() - cnt.LastModifiedDate.getTime());
							if(decTime > 500)
							{
								if(cnt.Sync_To_ERP__c)
								{
									system.debug('SyncToERP'+cnt.Sync_To_ERP__c);
									UpsertERPContact(cnt.Id,Act.Integration_Key__c);
								}
								else
									cnt.Sync_To_ERP__c=true;
							}
						}
					}
				}
			}
		}
		catch(Exception ex)
		{
			CustomException exc= new CustomException(ClassName,'BeforeUpdate',ex,false);
		} 
	}

	public static void AfterUpdate(list<Contact> NewContacts,list<Contact> OldContacts)
	{
		try
		{
			for(Contact Cont : NewContacts)
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

	@future (callout=true)
	public static void UpsertERPContact(String CntId,String IntegrationKey)
	{
		Contact cnt=         [Select 
				             ERP_Contact_Code__c,Phone,Department, OtherPhone,Name, MailingStreet, MailingState, MailingPostalCode, Title,Languages__c,
				             MailingCountry, MailingCity, LastName, Id,Salutation,HomePhone,FirstName,MobilePhone,AssistantName,AssistantPhone,
				             Integration_Key__c,Fax, Email,AccountId,Last_Sync_Message__c,Contact_Sequence__c,account.ERP_Customer_Number__c,account.AR_DivisonNo__c
				             From Contact
				             Where Id=:CntId limit 1];
		
		system.debug('cnt '+cnt);
		string MAXCOUNT='';
		string STARTAT='';
		string TOTALCOUNT='';
		string RETCOUNT='';
		string HASNEXT='';
		string HASPREV='';
		string CompanyCode='';

		/************ Create Header part*************/
		ERP_Config__c oIntegration = [SELECT ERP_System__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c,Inactive__c FROM ERP_Config__c WHERE ID =: IntegrationKey Limit 1];
		
		system.debug('oIntegration '+oIntegration);
		String EndPoint= oIntegration.Web_Service_URL__c;

		String ERPSystemName= oIntegration.ERP_System__c;


		String ImageURL='';
		String ResourceName='';
		String SyncMessage='';
		Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);

		String strResponse ='';
		if(ERPSystemName == 'SageERPX3')
		{
			strResponse= UpsertERPContact_X3(cnt, oIntegration, ParamMap);
		}

		if(ERPSystemName =='Sage100ERP')
		{
			strResponse= UpsertERPContact_100(cnt, oIntegration, ParamMap);
		}

		if(strResponse.startsWith('Error'))
			ResourceName=strResponse;
		else
			ResourceName='Success';
				
		system.debug('ResourceName2 '+ResourceName);

		List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :ResourceName];
		// Getting namespace
		String namespace ='';
		string gettime='';
		if (Test.isRunningTest())
			return;
		else
		{
			if(resourceList.size()>0)
			{
				if(resourceList[0].NamespacePrefix != null)
					namespace= resourceList[0].NamespacePrefix;
				gettime= string.valueOf(resourceList[0].SystemModStamp.getTime());
			}
		}

		ImageURL= '/resource/' +gettime + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + ResourceName;
		cnt.Last_Sync_Message__c = '<img alt="success" width="12" height="12" src="'+ImageURL+'"> ' + ResourceName + ' : ' + String.valueOf(Datetime.now()) + SyncMessage;
					
		if(String.isBlank(cnt.ERP_Contact_Code__c))
		{
			cnt.ERP_Contact_Code__c=GlContactCode;
			cnt.External_UId__c= IntegrationKey+'-'+cnt.Account.ERP_Customer_Number__c+'-'+GlContactCode; 
			cnt.Contact_Sequence__c=ContactSequence;
			cnt.Sync_To_ERP__c=false;
			update cnt;
		}
		else
			update cnt;
		
		
	}

	//updating customer contact to SageX3
	public static string UpsertERPContact_X3(Contact cnt,ERP_Config__c oIntegration,Map<String,String> ParamMap)
	{       
		string strResponse = objectXML_X3(cnt,oIntegration,ParamMap);
		return strResponse;
	}
	
	public static string UpsertERPContact_100(Contact cont, ERP_Config__c oIntegration,Map<String,String> ParamMap)
	{
		string sCustomerNumber = '';
		Dom.Document doc;
		ReadAndWriteXML.XmlNode objXmlNode ;        

		string AccountType= '';
		string PublicationName = '';
		String EndPoint= oIntegration.Web_Service_URL__c;
		String ERPSystemName= oIntegration.ERP_System__c;

		// Map<String,String> ParamMap =Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
		Account act=[select AR_DivisonNo__c,ERP_Customer_Number__c from Account where Id=:cont.AccountId];


		map<String,String> PromotionFields = new map<String,String>();
		map<string,list<object>> AttribParams=new map<string,list<object>> ();
		map<string,object> AttribPara=new map<string,object> ();

		list<object>  Attrib= new list<object>();
		list<object>  AttribParam= new list<object>();
		Contact cn=[select ERP_Contact_Code__c from Contact where Id=:cont.Id];

		
		Helper.MappingPurpose mappingType;
		if(String.isNotBlank(cn.ERP_Contact_Code__c))
		{
			mappingType=Helper.MappingPurpose.MODIFY;
		}
		else
			mappingType=Helper.MappingPurpose.POST;


		//AttribParams=Utility.getAttribParameters('', '' , cont.Integration_Key__c, 'Contacts', '' , Helper.MappingPurpose.MODIFY); 
		AttribParams=Utility.getAttribParameters('', '' , cont.Integration_Key__c, 'Contacts', '' ,mappingType); 
		PublicationName='AR_CustomerContact';       
		AttribParam= new list<object>();
		AttribParam.add(PublicationName);
		AttribParams.put('ERPFuncName',AttribParam);

		AttribPara.put('Ar_DivNo',act.AR_DivisonNo__c);

		AttribPara.put('ERP_CustNo',act.ERP_Customer_Number__c);


		//set the attributes
		map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
		list<Contact>contacts = new list<Contact> ();
		contacts.Add(cont);

		AttribParam= new list<object>();
		AttribParam.add(setAccountContactXML(contacts,AttribPara));
		 
		AttribParams.put('RequestXML',AttribParam);

		//SFObjectLists.put('Accounts',contacts);
		//SFObjectLists.put('Contacts',cont);

		map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
		baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(cont.Integration_Key__c);

		if(Test.isRunningTest())
		{
			return '';  
		}

		string ar_no =act.AR_DivisonNo__c;
		string custNo=act.ERP_Customer_Number__c;
		string conCode=cn.ERP_Contact_Code__c;
		
		list<string> KeyValue= new list<string>();
		KeyValue.Add(ar_no);
		KeyValue.Add(custNo.toUpperCase());

		KeyValue.Add(conCode);
		AttribParams.put('KeyValue',KeyValue);
		Helper.GUMU_Response resGUMU_Response =integrationFramework.PostData( cont.Integration_Key__c,'Contacts', SFObjectLists,PromotionFields,AttribParams);

		  Contact test1=          [Select 
						             ERP_Contact_Code__c,Phone, OtherPhone,Name, MailingStreet, MailingState, MailingPostalCode, Title,Languages__c,
						             MailingCountry, MailingCity, LastName, Id,
						             Integration_Key__c,Fax, Email,AccountId,Last_Sync_Message__c,Contact_Sequence__c,account.ERP_Customer_Number__c,account.AR_DivisonNo__c
						             From Contact
						             Where Id=:cont.Id limit 1];


		string strResponse='';

		if (string.isNotBlank(resGUMU_Response.statusCode))
		{
			if (resGUMU_Response.statusCode =='200'  || resGUMU_Response.statusCode =='201')
			{
				// TODO:For success
				GlContactCode=resGUMU_Response.ERPDataMap[0].get('ContactCode');
			}
			else
			{
				strResponse = 'Error'+resGUMU_Response.statusCode + ':' + resGUMU_Response.statusMessage + '\n'+resGUMU_Response.responseERPData;
				//update Act; 
			}
		}		
		return strResponse;
	}

	private static string  setAccountContactXML(list <Contact> Contacts, map<string,object> Attrib) 
	{
		system.debug('Contactsfvgdf '+Contacts);
		string CustomerNo =String.ValueOf(Attrib.get('ERP_CustNo'));
		string Ar_DivisionNo=String.ValueOf(Attrib.get('Ar_DivNo'));
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
			string Address1='';
            string Address2='';
            string Address3='';
			if(Cont.MailingStreet != null)
            {
                String[] MailingAddress = Cont.MailingStreet.split('\n');
                
                if (MailingAddress.size() > 2)
                { 
                    Address1 = MailingAddress[0]==null? '' : MailingAddress[0];
                    Address2 = MailingAddress[1]==null? '' : MailingAddress[1];
                    Address3 = MailingAddress[2]==null? '' : MailingAddress[2];
                }
                else if (MailingAddress.size() > 1)
                { 
                    Address1 = MailingAddress[0]==null? '' : MailingAddress[0];
                    Address2 = MailingAddress[1]==null? '' : MailingAddress[1];
                }
                else if (MailingAddress.size() > 0)
                { 
                    Address1 = MailingAddress[0]==null? '' : MailingAddress[0];
                }
            }
			
			string emailAdd = Cont.Email==null? ' ' : Cont.Email;
			
			system.debug('Cont.Salutation '+Cont.Salutation);
			String contactCode=getRandom();
			//Cont.ERP_Contact_Code__c= CnCode ;
			//string contactCode = string.isblank(Cont.ERP_Contact_Code__c) ? '':Cont.ERP_Contact_Code__c;
			//string contactCode =CnCode;

			string Salutation = string.isblank(Cont.Salutation) ? '':Cont.Salutation;
			strObjXML_CONT += '<ARDivisionNo>'+Ar_DivisionNo+'</ARDivisionNo>';
			strObjXML_CONT += '<CustomerNo>'+CustomerNo+'</CustomerNo>';
			strObjXML_CONT += '<ContactCode>'+contactCode+'</ContactCode>';
			strObjXML_CONT += '<ContactName>'+Cont.Name+'</ContactName>';
	
			strObjXML_CONT += '<ZipCode>'+Cont.MailingPostalCode+'</ZipCode>';
			strObjXML_CONT +='<CountryCode>'+Cont.MailingCountry+'</CountryCode>';
			strObjXML_CONT += '<State>'+Cont.MailingState+'</State>';
			strObjXML_CONT +='<City>'+Cont.MailingCity+'</City>';
			strObjXML_CONT += '<AddressLine1>'+Address1+'</AddressLine1>';
			strObjXML_CONT += '<AddressLine2>'+Address2+'</AddressLine2>';
			strObjXML_CONT += '<AddressLine3>'+Address3+'</AddressLine3>';
			strObjXML_CONT += '<Salutation>'+Salutation+'</Salutation> ';
			strObjXML_CONT += '<TelephoneNo1>'+Cont.Phone+'</TelephoneNo1> ';
			strObjXML_CONT += '<TelephoneNo2>'+Cont.HomePhone+'</TelephoneNo2> ';
			strObjXML_CONT += '<FaxNo>'+Cont.Fax+'</FaxNo> ';
			strObjXML_CONT += '<EmailAddress>'+emailAdd+'</EmailAddress> ';
			strObjXML_CONT += '<ContactTitle>'+Cont.Title+'</ContactTitle> ';
			//strObjXML_CONT += '<ContactNotes>'+Cont.Description+'</ContactNotes> ';
			//strObjXML_1 += '<TelephoneExt1>'+Cont.MobilePhone+'</TelephoneExt1> ';
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

	public Static String getRandom() 
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

	public static string objectXML_X3(Contact cnt,ERP_Config__c oIntegration,Map<String,String> ParamMap)
	{
		string sCustomerNumber = '';     
		string AccountType= '';
		string PublicationName = '';
		String IntegrationKey;
		string RequestXml = '';

		Account Act = [select Id,ERP_Customer_Number__c,Name,Type,Integration_Key__c,Website from Account where Id=: cnt.AccountId];

		if(Act != null)
		{
			AccountType = Act.Type;
			if(AccountType == 'Prospect')
				PublicationName = 'YGTPROSDTL';
			else
				PublicationName = 'YGTCUSTDTL';
		}
		string Version = ParamMap.get('version');
		list<Contact> Contacts = [Select 
		                          Id,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,
		                          MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Phone,Fax,MobilePhone,HomePhone,
		                          OtherPhone,Email,Title,Birthdate,Description,ERP_Contact_Code__c 
		                          From Contact Where AccountId =:Act.Id limit 100];

		RequestXml += '<PARAM><GRP ID="BPC0_1" >';
		RequestXml += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCSTA" TYPE="Integer" >2</FLD>';
		RequestXml += '<FLD NAME="BPCNUM" TYPE="Char" >'+Act.ERP_Customer_Number__c+'</FLD>';
		RequestXml += '<FLD NAME="BPCNAM" TYPE="Char" >'+Act.Name+'</FLD>';
		RequestXml += '</GRP>';

	string ContactCode = string.isBlank(cnt.ERP_Contact_Code__c) ? '': cnt.ERP_Contact_Code__c;
		integer i=1;
		if(ContactCode =='' || ContactCode == null)
		{
			RequestXml += '<TAB DIM="50" ID="CNTC_1" >';
			i = Contacts.size();
			ContactSequence = Contacts.size();                
		}
		else
		{
			RequestXml += '<TAB DIM="50" ID="CNTC_1" NBLIG="'+ integer.valueOf(Contacts.size()) +'" >';
			i = integer.valueOf(cnt.Contact_Sequence__c);
			ContactSequence = i ;
			GlContactCode = ContactCode;
		}

		//Contact uptCntCode = new Contact();
		//for(Contact cnt :NewContactList)
		//{               
		string Language = string.isBlank(cnt.Languages__c) ? '': cnt.Languages__c;

		if(ContactCode =='' || ContactCode == null)
		{
			ContactCode=string.valueOf(Math.abs(Crypto.getRandomInteger()));
			GlContactCode = ContactCode;
		}
		string LastName = string.isBlank(cnt.LastName) ? '': cnt.LastName;
		string FirstName = string.isBlank(cnt.FirstName) ? '': cnt.FirstName;
		//string Title = string.isBlank(cnt.Title) ? '': cnt.Title;
		string ContactName = string.isBlank(cnt.Name) ? '': cnt.Name;
		string strCntPhone=string.isBlank(cnt.Phone) ?'' : cnt.Phone;
		string strCntFax =string.isBlank(cnt.Fax) ?'' : cnt.Fax;
		string ContactMobileNo =string.isBlank(cnt.MobilePhone) ?'' : cnt.MobilePhone;
		string strCntEmail =string.isBlank(cnt.Email) ? ' ' : cnt.Email;
		string Department =string.isBlank(cnt.Department) ? '' : cnt.Department;
                    

		string FullName = LastName +'\\'+FirstName;
		
		if(string.isNotBlank(strCntPhone))
        	strCntPhone = Utility.phoneformat(strCntPhone);
        	
        if(string.isNotBlank(strCntFax))
        	strCntFax = Utility.phoneformat(strCntFax);
        
        if(string.isNotBlank(ContactMobileNo))
        	ContactMobileNo = Utility.phoneformat(ContactMobileNo);
        	
     	string Title = string.isBlank(cnt.Salutation) ? '': cnt.Salutation;
        list<Menu_Setting__c> menus = [select Sequence_Number__c,Code__c from Menu_Setting__c where Code__c=:Title LIMIT 1];

        string seqNo='';
        if(menus.size()>0)
        	seqNo = string.valueOf(menus[0].Sequence_Number__c);

		RequestXml += '<LIN NUM="'+i+'" >';
		RequestXml += '<FLD NAME="CCNCRM" TYPE="Char" >'+ContactCode+'</FLD>';
		RequestXml += '<FLD NAME="CNTLNA" TYPE="Char" >'+LastName+'</FLD>';
		RequestXml += '<FLD NAME="CNTFNA" TYPE="Char" >'+FirstName+'</FLD>';
		//RequestXml += '<FLD NAME="CNTCRY" TYPE="Char" >DE</FLD>';
		RequestXml += '<FLD MENULAB="No" MENULOCAL="1" NAME="CNTFLG" TYPE="Integer" >1</FLD>';
		
		if(menus.size()>0)
        	RequestXml += '<FLD MENULAB="'+Title+'" MENULOCAL="941" NAME="CNTTTL" TYPE="Integer" >'+seqNo+'</FLD>';
		
		RequestXml += '<FLD MENULAB="Buyer" MENULOCAL="233" NAME="CNTFNC" TYPE="Integer" >6</FLD>';
		RequestXml += '<FLD NAME="CNTSRV" TYPE="Char">'+Department+'</FLD>';
		RequestXml += '<FLD NAME="CNTTEL" TYPE="Char" >'+strCntPhone+'</FLD>';
		RequestXml += '<FLD NAME="CNTFAX" TYPE="Char" >'+strCntFax+'</FLD>';
		RequestXml += '<FLD NAME="CNTMOB" TYPE="Char" >'+ContactMobileNo+'</FLD>';		
		RequestXml += '<FLD NAME="CNTFULNAM" TYPE="Char" >'+ContactName+'</FLD>';

		RequestXml += '<FLD NAME="CNTWEB" TYPE="Char" >'+strCntEmail+'</FLD>';
		RequestXml += '<FLD MENULAB="No" MENULOCAL="1" NAME="CNTFBDMAG" TYPE="Integer" >1</FLD>';
		RequestXml += '<FLD NAME="CNTLAN" TYPE="Char" >'+Language+'</FLD>';
		RequestXml += '<FLD NAME="CNTCSP" TYPE="Char" ></FLD>';
		//RequestXml += '<FLD NAME="CNTFULNAM" TYPE="Char" >'+LastName+'\''+FirstName+'</FLD>';
		RequestXml += '<FLD NAME="CNTFULNAM" TYPE="Char" >'+FullName+'</FLD>';
		RequestXml += '<FLD NAME="FLMOD" TYPE="Integer" >0</FLD>';
		RequestXml += '<FLD NAME="FLMODFONC" TYPE="Integer" >0</FLD>';
		RequestXml += '<FLD NAME="FLNEW" TYPE="Integer" >1</FLD>';      
		RequestXml += '</LIN>';
		// i++;
		//}
		RequestXml += '</TAB></PARAM>';

		
		system.debug('RequestXml12 '+RequestXml);
		/*Prepare parameters*/
		map<string,list<object>> AttribParams=new map<string,list<object>> ();
		list<object>  AttribParam= new list<object>();

		AttribParam= new list<object>();
		AttribParam.add(RequestXml);
		AttribParams.put('RequestXML',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add(Act.ERP_Customer_Number__c);
		AttribParams.put('CustomerNo',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add(PublicationName);
		AttribParams.put('ERPFuncName',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add(Version);
		AttribParams.put('Version',AttribParam);

		AttribParam= new list<object>();
		Helper.MappingPurpose mappingType =Helper.MappingPurpose.MODIFY;
		AttribParam.add(mappingType);
		AttribParams.put('MappingPurpose',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add(oIntegration.Id);
		AttribParams.put('IntegrationId',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add('Customer');
		AttribParams.put('SourceEntity',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add('0');
		AttribParams.put('startIndex',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add('0');
		AttribParams.put('count',AttribParam);

		AttribParam= new list<object>();
		AttribParam.add('BPCNUM');
		AttribParams.put('include',AttribParam);

		map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
		baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(oIntegration.Id);
		if (Test.isRunningTest())
		{
			return   '';    
		}
		Helper.GUMU_Response resGUMU_Response =integrationFramework.getData(WhereParams, AttribParams);
		
		system.debug('resGUMU_Response  '+resGUMU_Response);
		
		map<String,String> mapProData =resGUMU_Response.SFDataMap;
		string strResponse='';
		if(mapProData != null)
			strResponse = mapProData.get('CustNo');
		else
			strResponse = 'Error -'+resGUMU_Response.statusMessage;
			
		system.debug('strResponse '+strResponse);
		return strResponse;
	}
}