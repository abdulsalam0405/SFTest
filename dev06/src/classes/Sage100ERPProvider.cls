//This is used for returning provider of Sage100 ERP
public class Sage100ERPProvider extends BaseERPProvider
{    
	private string className='Sage100ERPProvider'; 
	/* public override boolean TestConnection(String URL, list<String> ConnectionParameters) 
    {
        return null; 
    }
	 */
	// Method to establish connection    
	public override boolean TestConnection(String URL, list<String> ConnectionParameters) 
	{ 
		string companyCode; 
		string username;  
		string password;

		//List of fields for the connection information 
		Map<string,string> Parameters =new Map<string,string>();
		try
		{       
			for(String ParamPair : ConnectionParameters)
			{
				string key;
				string value='';    
				String[] PairArray=ParamPair.split('=');
				key=PairArray[0]; 
				if(PairArray.size() > 1)
					value=PairArray[1]; 
				else
					value=''; 
				Parameters.put(key,value);
			}   

			if(Parameters.containsKey('Username'))
				username=Parameters.get('Username');

			if(Parameters.containsKey('Password'))
				password=Parameters.get('Password');

			if(Parameters.containsKey('CompanyCode'))
				companyCode= Parameters.get('CompanyCode');

			String EndPoint = URL+'/'+companyCode+'/SO_ShipToAddress/$schema';

			Helper.GUMU_Response oGUMU_Respons; 

			oGUMU_Respons= GetDataRequest(EndPoint,username,password);

			if(oGUMU_Respons.statusMessage == 'OK')
				return true;
			else
				return false;
		}
		catch(Exception ex)
		{
			CustomException exc= new CustomException(className,'TestConnection',Ex,false);
			throw ex;
		}
	}

	//Retrive data from Sage 100
	public override Helper.GUMU_Response getRecords(map<string,map<string,list<string>>> whereParams, 
			map<string,list<object>> AttribParams)
	{
		//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, '23 '+json.serialize(AttribParams)));
		system.debug('whereParams '+json.serialize(whereParams));
		system.debug('AttribParams '+json.serialize(AttribParams));
		String EndPoint ='';
		String UserID ='';
		String Password ='';
		string sDataFinder;
		string integrationID;
		string RequestType=''; 
		list<object> Attrib;
		try
		{   
			//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'AttribParams '+AttribParams));    
			//This below should be some constant
			/*Attrib=AttribParams.get('DataFinder');
			sDataFinder=(String)Attrib[0];
			system.debug('sDataFinder '+sDataFinder);*/		
			Attrib=AttribParams.get('ERPFuncName');
			sDataFinder=(String)Attrib[0];
			
		    //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'sDataFinder '+sDataFinder));
			Attrib=AttribParams.get('IntegrationId');
			system.debug('IntegrationId '+Attrib);
		   //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'sDataFinder '+sDataFinder));
			
			integrationID=(String)Attrib[0];
			Attrib=AttribParams.get('RequestType');
			
			if (Attrib != null )
			{
				RequestType=(String)Attrib[0];				
			}
			
			//Assign custom setting to variables
			Map<String,String> ParamMap = GetConnectionParams(integrationID);

			system.debug('ParamMap '+ParamMap);
			UserID = ParamMap.get('Username');  
			Password =Utility.Decrypt(ParamMap.get('Password')); 

			//Set web service url     
			EndPoint = ParamMap.get('WebServiceURL') + '/' + ParamMap.get('CompanyCode') + '/' + sDataFinder;
			
			
			//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'EndPoint  '+EndPoint));
			if(string.isNotBlank(RequestType) && RequestType=='getDescription' )
			{
				EndPoint = EndPoint + '/$Schema';
			}
			else
			{
				EndPoint = EndPoint + '?';
				Boolean isAttribExist = false;  
				//set the attributes 
				for(string fieldKey : AttribParams.keySet())
				{
					//TODO:remove from the list 
					if (fieldKey == 'ERPFuncName' || fieldKey == 'KeyValue' || fieldKey == 'DataFinder' || fieldKey == 'IntegrationID' || fieldKey == 'SourceEntity' || fieldKey == 'MappingPurpose' )
					{
						continue;
					}
					Attrib = AttribParams.get(fieldKey);
				//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Attrib '+Attrib));

					if(Attrib.size() > 0)
					{
						for(object Att : Attrib)
						{
							EndPoint += fieldKey.replace(' ','%20') + '='+  string.valueOf(Att).replace(' ','%20') + '&';
							isAttribExist=true;
							system.debug('EndPoint03 '+EndPoint);
							 //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'EndPoint03 '+EndPoint));
						}                       
					} 
				}

				if (isAttribExist=true)
				{
					EndPoint = EndPoint.subString(0, EndPoint.length() - 1);
				}

				//Logic for adding filters
				for(string fieldKey : whereParams.keySet())
				{

					map<string,list<string>> paramsAttrib= whereParams.get(fieldKey);
					list<string> paramsValues;

					if (paramsAttrib.get(string.valueOf(Helper.Operator.EQUAL))!=null)
					{
						paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.EQUAL));
						if(EndPoint.contains('&where')==false)
							EndPoint = EndPoint + '&where=' ;
						else
							EndPoint = EndPoint + '%20and%20' ;
						EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20eq%20' + '\'' + paramsValues[0].replace(' ','%20') + '\'';
						system.debug('URL'+EndPoint);
					}
					else if(paramsAttrib.get(string.valueOf(Helper.Operator.RANGE))!=null)
					{
						paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.RANGE));
						if(EndPoint.contains('&where')==false)
							EndPoint = EndPoint + '&where=' ;
						else
							EndPoint = EndPoint + '%20and%20' ;
						EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20between%20' + '\'' + paramsValues[0].replace(' ','%20')  + '%\'' + '%20and%20' + '\'' + paramsValues[1].replace(' ','%20')   + '%\'' ;
					}
					else if(paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_OR_EQUAL))!=null)
					{
						paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_OR_EQUAL));
						if(EndPoint.contains('&where')==false)
							EndPoint = EndPoint + '&where=' ;
						else
							EndPoint = EndPoint + '%20and%20' ;
						EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20ge%20' + '\'' + paramsValues[0] + '\'';
					}
					else if(paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE))!=null)
					{
						paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE));
						string paramValue = paramsValues[0];
						paramValue = paramValue.replace('\'','%25');
						
						if(EndPoint.contains('&where')==false)
							EndPoint = EndPoint + '&where=' ;
						else
							EndPoint = EndPoint + '%20and%20' ;
							
						EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20like%20' + '\'%25' + paramValue.replace(' ','%20') + '%25\'';
					}
					else if(paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE))!=null)
					{
						paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE));

						if(paramsValues.size() > 0)
						{
							if(EndPoint.contains('&where')==false)
								EndPoint = EndPoint + '&where=' ;
							else
								EndPoint = EndPoint + '%20and%20' ;
							EndPoint +=  fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20in%20';
							EndPoint += '(';

							Integer i = 1;

							for(string param : paramsValues)
							{
								EndPoint += '\'' + param.replace(' ','%20').replace('\'','%27') + '\'';
								if(i != paramsValues.size())
									EndPoint += ',';
								i++;                            
							}                       
							EndPoint += ')';
						}
					} 
				}
			}                
		}
		catch(Exception ex)
		{
			system.debug('ex2');
			CustomException exc= new CustomException(className,'getRecords',Ex,false);
		}
		//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:EndPoint:'+EndPoint));
		return GetDataRequest(EndPoint,UserID,Password);
		
	}

	public override Helper.GUMU_Response PostRecords( map<string,list<object>> AttribParams)
	{
		String EndPoint ='';
		string DataFinder;
		string RequestType;
		string integrationID; 
		list<object> Attrib;
		Map<String,String> ParamMap ;
		try
		{ 
			//This below should be some constant
			Attrib=AttribParams.get('ERPFuncName');

			// DataFinder='SO_ShipToAddress';//(String)Attrib[0];
			Attrib=AttribParams.get('IntegrationId');
			integrationID=(String)Attrib[0];

			Attrib=AttribParams.get('RequestType');
			RequestType=(String)Attrib[0];

			//RequestType= 'Helper.MappingPurpose.POST';//Attrib[0];
			//Assign custom setting to variables
			ParamMap = GetConnectionParams(integrationID);
			//Set web service url       
			EndPoint = ParamMap.get('WebServiceURL') ;
			return PostDataRequest(EndPoint,ParamMap.get('Username'),ParamMap.get('Password'),ParamMap.get('CompanyCode'),AttribParams);
		}  
		catch(Exception ex)
		{
			CustomException exc= new CustomException (className,'PostRecords',ex,false);
			throw ex;
		}
		
	}

	private Helper.GUMU_Response PostDataRequest(string EndPoint, string UserID, string Password,string cmpnycode, map<string,list<object>> AttribParams )
	{
		Helper.GUMU_Response oGUMU_Response = new Helper.GUMU_Response(); 
		try 
		{
			Helper.MappingPurpose mp;
			string DataFinder;
			list<object> Attrib;
			Attrib=AttribParams.get('ERPFuncName');
			DataFinder=(String)Attrib[0]; 
			EndPoint+='/'+cmpnycode+'/'+DataFinder;

			HttpRequest req = new HttpRequest();

			req.setMethod('POST');

			Attrib=AttribParams.get('MappingPurpose');
			mp=(Helper.MappingPurpose)Attrib[0];

			if (mp == Helper.MappingPurpose.MODIFY)
			{
				EndPoint+='(\'';
				Attrib=AttribParams.get('KeyValue');
				string KeyValue='';
				integer Counterkey=0;
				for(object attr  :Attrib)
				{
					Counterkey++;
					if (Counterkey==Attrib.size())
					{
						KeyValue+=(string)attr;
					}
					else
					{
						KeyValue+=(string)attr +'%3B';
					}
				}

				EndPoint+=KeyValue  +'\')';     
				//EndPoint+='01%3BKL' +'\')';  
				req.setMethod('PUT');
			}

			req.setEndpoint(EndPoint); 

			Blob headerValue = Blob.valueOf(UserID + ':' + Utility.Decrypt(Password));
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			req.setHeader('Authorization', authorizationHeader);
			req.setHeader('Content-Type', 'application/atom+xml;type=entry');
			req.setHeader('SOAPAction','');

			string PrepareRequest='';

			list<string>objectXMLList=new list<string>(); 

			for(object obj:AttribParams.get('RequestXML'))
			{
				objectXMLList.add((string)obj);
			}
			PrepareRequest=objectXMLList[0];
			//PrepareRequest='<entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005" xmlns="http://www.w3.org/2005/Atom" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1" xmlns:sme="http://schemas.sage.com/sdata/sme/2007" xmlns:http="http://schemas.sage.com/sdata/http/2008/1"> <sdata:payload><SO_SalesOrderHeaderSPECIAL xmlns="" ><ARDivisionNo>01</ARDivisionNo><CustomerNo>ASD</CustomerNo><FOB></FOB><CheckNoForDeposit></CheckNoForDeposit><FreightAmt>0</FreightAmt><DiscountAmt>0</DiscountAmt><PrintPickingSheets>N</PrintPickingSheets><PrintSalesOrders>N</PrintSalesOrders><TermsCode>00</TermsCode><TaxSchedule>CA</TaxSchedule><WarehouseCode>000</WarehouseCode><ShipVia>UPS BLUE</ShipVia><ShipToCountryCode>USA</ShipToCountryCode><ShipToZipCode>400606</ShipToZipCode><ShipToState>TX</ShipToState><ShipToCity>VAR</ShipToCity><ShipToAddress3></ShipToAddress3><ShipToAddress2></ShipToAddress2><ShipToAddress1>Billing Street 123</ShipToAddress1><ShipToName>SHP01</ShipToName><BillToCountryCode>USA</BillToCountryCode><BillToZipCode>400606</BillToZipCode><BillToState>TX</BillToState><BillToCity>MUM</BillToCity><BillToAddress3></BillToAddress3><BillToAddress2></BillToAddress2><BillToAddress1>301,GURUKRIPA</BillToAddress1><BatchFax>N</BatchFax><SalespersonNo>0200</SalespersonNo><SO_SalesOrderHeaderSPECIALSECOND><ItemCode>D1500</ItemCode><Valuation>3</Valuation><Commissionable>N</Commissionable><WarehouseCode></WarehouseCode><UnitOfMeasure>BOX</UnitOfMeasure><TaxClass></TaxClass><CommentText></CommentText><QuantityOrdered>2.00</QuantityOrdered><UnitPrice>1700.00</UnitPrice><UnitOfMeasureConvFactor>100.0000</UnitOfMeasureConvFactor><LineDiscountPercent>0</LineDiscountPercent></SO_SalesOrderHeaderSPECIALSECOND></SO_SalesOrderHeaderSPECIAL></sdata:payload></entry>';
			system.debug('PrepareRequest  '+PrepareRequest);
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'PrepareRequest :'+PrepareRequest));	
			req.setBody(PrepareRequest);
			req.setTimeOut(120000);
			system.debug('URL  '+req);

			//get the response value for provided web service url
			Http http = new Http();
			HTTPResponse res ; 

			if (Test.isRunningTest())
			{
				string TestResponseData='';
				TestResponseData='<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:http="http://schemas.sage.com/sdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-12-29T17:17:39Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq \'1100\'&amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq \'1100\'&amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq \'1100\'&amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 1100</title><author><name>Generated</name></author><updated>2015-12-29T17:17:39Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')</id><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="1100" sdata:url="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')"><IDCUST>1100</IDCUST><NAMECUST>Bargain Mart - San Diego Test</NAMECUST><TEXTSNAM>BMT-SD</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT>BARMART</IDNATACCT><CODECURN>USD</CODECURN><NAMECITY>Anytown</NAMECITY><CODESTTE>CA</CODESTTE><CODECTRY>USA</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Bargain Mart Plaza</TEXTSTRE1><TEXTSTRE2>Corner 182nd and 34th Street</TEXTSTRE2><TEXTSTRE3 xsi:nil="false"/><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>45112</CODEPSTL><TEXTPHON1>4084518981</TEXTPHON1><TEXTPHON2>4084518711</TEXTPHON2><NAMECTAC>Mr. Jose Grange</NAMECTAC><PRICLIST>WHS</PRICLIST><DATEINAC xsi:nil="true"/><DATELASTMN>2015-05-22</DATELASTMN><CODETERR>CA</CODETERR><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>4081212124514</CTACPHONE><PAYMCODE>CHECK</PAYMCODE><AMTCRLIMT>10000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>CALIF</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2015052206264041ADMIN___SAMINC</http:etag></entry></feed>';

				oGUMU_Response.responseERPData=TestResponseData;
				oGUMU_Response.statusMessage='Ok';
				oGUMU_Response.statusCode =string.valueof(200);
				return oGUMU_Response;
			}
			try
			{
				res = http.send(req);
			}
			catch (CalloutException Ex)
			{
				system.debug('101');
				oGUMU_Response.statusCode ='101';
				oGUMU_Response.statusMessage='Error:'+Ex;
				return oGUMU_Response;
			}
			catch (Exception Ex)
			{
				system.debug('100');
				oGUMU_Response.statusCode ='100';
				oGUMU_Response.statusMessage='Error:'+Ex;
				return oGUMU_Response;
			} 

			string getResponse=res.getBody();
			oGUMU_Response.statusCode =string.valueof(res.getStatusCode());
			oGUMU_Response.statusMessage= res.getStatus();
			oGUMU_Response.responseERPData=getResponse;
			system.debug('oGUMU_Response4556  '+oGUMU_Response);
			return oGUMU_Response;
		}
		catch(Exception Ex)
		{
			throw ex; 
			return oGUMU_Response;
		}
	}

	private map<String,String> GetConnectionParams(string integrationID)
	{
		Map<String,String> ParamMap=new Map<String,String>();
		try
		{
			//Get the connection information from custom setting 
			ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: integrationID];

			String EndPoint= oIntegration.Web_Service_URL__c;
			String ERPSystemName= oIntegration.ERP_System__c;
			String CompanyCode=oIntegration.ERP_Company_Code__c;
			ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
			ParamMap.put('WebServiceURL',EndPoint);
			ParamMap.put('CompanyCode',CompanyCode);
			return ParamMap;
		}
		catch(Exception ex)
		{
			//GUMUException exc= new GUMUException(className,'GetConnectionParams',ex);
			CustomException exc= new CustomException(className,'GetConnectionParams',Ex,false);
			return ParamMap;
		}      
	}

	private Helper.GUMU_Response GetDataRequest(string EndPoint, string UserID, string Password )
	{
		Helper.GUMU_Response oGUMU_Response = new Helper.GUMU_Response(); 
		try 
		{
			HttpRequest req = new HttpRequest();
			req.setEndpoint(EndPoint);
			req.setMethod('GET');
			Blob headerValue = Blob.valueOf(UserID + ':' + Password);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			req.setHeader('Authorization', authorizationHeader);
			req.setHeader('Content-Type', 'application/atom+xml;type=entry');
			req.setHeader('SOAPAction','');
			req.setTimeOut(120000);
			//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'req:  '+req));
			system.debug('req34 '+req);

			//get the response value for provided web service url
			Http http = new Http();
			HTTPResponse res ; 

			if (Test.isRunningTest())
			{
				string TestResponseData='';
				TestResponseData='<?xml version="1.0" encoding="UTF-8"?><fAttribParamdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-12-29T17:17:39Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq \'1100\'&amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq \'1100\'&amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq \'1100\'&amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 1100</title><author><name>Generated</name></author><updated>2015-12-29T17:17:39Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')</id><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="1100" sdata:url="https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(\'1100\')"><IDCUST>1100</IDCUST><NAMECUST>Bargain Mart - San Diego Test</NAMECUST><TEXTSNAM>BMT-SD</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT>BARMART</IDNATACCT><CODECURN>USD</CODECURN><NAMECITY>Anytown</NAMECITY><CODESTTE>CA</CODESTTE><CODECTRY>USA</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Bargain Mart Plaza</TEXTSTRE1><TEXTSTRE2>Corner 182nd and 34th Street</TEXTSTRE2><TEXTSTRE3 xsi:nil="false"/><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>45112</CODEPSTL><TEXTPHON1>4084518981</TEXTPHON1><TEXTPHON2>4084518711</TEXTPHON2><NAMECTAC>Mr. Jose Grange</NAMECTAC><PRICLIST>WHS</PRICLIST><DATEINAC xsi:nil="true"/><DATELASTMN>2015-05-22</DATELASTMN><CODETERR>CA</CODETERR><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>4081212124514</CTACPHONE><PAYMCODE>CHECK</PAYMCODE><AMTCRLIMT>10000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>CALIF</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2015052206264041ADMIN___SAMINC</http:etag></entry></feed>';
				oGUMU_Response.responseERPData=TestResponseData;
				oGUMU_Response.statusMessage='Ok';
				oGUMU_Response.statusCode =string.valueof(200);
				return oGUMU_Response;
			}

			try
			{
				res = http.send(req);
				//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'res Provider:  '+res));
			}
			catch (CalloutException Ex)
			{
				oGUMU_Response.statusCode ='101';
				oGUMU_Response.statusMessage='Error:'+Ex;
				return oGUMU_Response;
			}
			catch (Exception Ex)
			{
				oGUMU_Response.statusCode ='100';
				oGUMU_Response.statusMessage='Error:'+Ex;
				return oGUMU_Response;
			} 

			string getResponse=res.getBody();
			oGUMU_Response.statusCode =string.valueof(res.getStatusCode());
			oGUMU_Response.statusMessage= string.valueof(res.getStatus());
			oGUMU_Response.responseERPData=getResponse;
			//	ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'oGUMU_Response Provider:  '+oGUMU_Response));
			return oGUMU_Response;
		}
		catch(Exception Ex)
		{
			CustomException exc= new CustomException (className,'GetDataRequest',ex,false);
			return oGUMU_Response;
		}
	}
}