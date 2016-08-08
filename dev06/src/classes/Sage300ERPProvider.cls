//This is used for returning provider of Sage300 ERP
public class Sage300ERPProvider extends BaseERPProvider
{ 
    private string className='Sage300ERPProvider';
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
                username= Parameters.get('Username');

            if(Parameters.containsKey('Password'))
                password= Parameters.get('Password');


            if(Parameters.containsKey('CompanyCode'))
                companyCode= Parameters.get('CompanyCode');
                
                          
            String EndPoint = URL+'/'+companyCode+'/arCustomersFinder';
            
            Helper.GUMU_Response oGUMU_Respons;
            oGUMU_Respons= GetDataRequest(EndPoint,username,password,null);
			
            if(oGUMU_Respons.statusMessage == 'OK')
                return true;
            else
                return false;
        }
        catch(Exception ex)
        {
            //GUMUException exc= new GUMUException(className,'TestConnection',ex);
             CustomException exc= new CustomException (className,'TestConnection',ex,false);
            return false;
        }
    }
   
    public string ReplaceSpacialChar(string Value)
    {
    	Value = Value.replace( ' ','%20');
    	Value = Value.replace('\'','%27%27');
        Value = Value.replace('#','%23');
        Value = Value.replace('+','%2B');
        Value = Value.replace('&','%26');
    	 
    	return Value;
    }
    

    //Retrive data from Sage 300
    public override Helper.GUMU_Response getRecords(map<string,map<string,list<string>>> whereParams, 
            map<string,list<object>> AttribParams)
    {
    	system.debug('whereParams'+whereParams);
    	
        String EndPoint ='';
        String UserID ='';
        String Password =''; 
        string sDataFinder;
        string integrationID;
        string RequestType=''; 
        list<object> Attrib;
        try
        { 
        	
            //This below should be some constant
            Attrib=AttribParams.get('DataFinder');
            sDataFinder=(String)Attrib[0];
             
            Attrib=AttribParams.get('IntegrationId');
            integrationID=(String)Attrib[0];
            Attrib=AttribParams.get('RequestType');        //RequestType
            
            if (Attrib != null )
            {
                RequestType=(String)Attrib[0];
                //RequestType=(String)Attrib[1];
            }
          
              
            //Assign custom setting to variables
            Map<String,String> ParamMap = GetConnectionParams(integrationID);
            UserID = ParamMap.get('Username');  
            Password = Utility.Decrypt(ParamMap.get('Password')); 
            
       	 	EndPoint = ParamMap.get('WebServiceURL') + '/' + ParamMap.get('CompanyCode') + '/' + sDataFinder;
        
            //Set web service url     
            
            if(string.isNotBlank(RequestType) && RequestType=='getDescription' )
                EndPoint = EndPoint + '/$Schema';
            else
            {
                
                EndPoint = EndPoint + '?';
                Boolean isAttribExist = false;
                 
                //set the attributes 
                for(string fieldKey : AttribParams.keySet()) 
                {
    	            //TODO:remove from the list 
                    if (fieldKey== 'RequestXML' ||   fieldKey== 'RequestType' || fieldKey == 'DataFinder' || fieldKey == 'ERPFuncName'  || fieldKey == 'IntegrationID' || fieldKey == 'SourceEntity' || fieldKey == 'MappingPurpose' )
                    {
                        continue;
                    }
    
                    Attrib = AttribParams.get(fieldKey);
    
                    if(Attrib.size() > 0)
                    {
                        for(object Att : Attrib)
                        {
                            EndPoint += fieldKey.replace(' ','%20') + '='+  string.valueOf(Att).replace(' ','%20') + '&';
                            isAttribExist=true;
                        }                       
                    } 
                }
    
                if (isAttribExist=true){
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
                        //EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20eq%20' + '\'' + paramsValues[0].replace(' ','%20') + '\'';
                        
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20eq%20' + '\'' + ReplaceSpacialChar(paramsValues[0]) + '\'';
                        
                        
                    }
                    else if(paramsAttrib.get(string.valueOf(Helper.Operator.RANGE))!=null) //RANGE
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.RANGE));//RANGE
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20between%20' + '\'' + ReplaceSpacialChar(paramsValues[0]) + '%\'' + '%20and%20' + '\'' + ReplaceSpacialChar(paramsValues[1])  + '%\'' ;
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
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20like%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }
                     else if(paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20ne%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }
                     else if(paramsAttrib.get(string.valueOf(Helper.Operator.LESS_THAN))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LESS_THAN));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20lt%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }
                   /*  else if(paramsAttrib.get(string.valueOf(Helper.Operator.DOES_NOT_CONTAIN))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.DOES_NOT_CONTAIN));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20notlike%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }*/
                     else if(paramsAttrib.get(string.valueOf(Helper.Operator.STARTS_WITH))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.STARTS_WITH));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20left%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }
                     else if(paramsAttrib.get(string.valueOf(Helper.Operator.CONTAINS))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.CONTAINS));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20like%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }
                     else if(paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_THAN))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_THAN));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20gt%20' + '\'%25' + paramsValues[0] + '%25\'';
                    }
                     else if(paramsAttrib.get(string.valueOf(Helper.Operator.LESSER_OR_EQUAL))!=null)
                    {
                        paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LESSER_OR_EQUAL));
                        if(EndPoint.contains('&where')==false)
                            EndPoint = EndPoint + '&where=' ;
                        else
                            EndPoint = EndPoint + '%20and%20' ;
                        EndPoint = EndPoint + fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '%20le%20' + '\'%25' + paramsValues[0] + '%25\'';
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
                                EndPoint += '\'' + ReplaceSpacialChar(param) + '\''; //param.replace(' ','%20').replace('\'','%27%27')
                                if(i != paramsValues.size())
                                    EndPoint += ',';
                                i++;                            
                            }                       
                            EndPoint += ')';
                        }
                    }               
                }
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'EndPoint :'+EndPoint));
            } 
          	           
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getRecords',ex,false);
        }
        system.debug('EndPoint: '+EndPoint); 

            system.debug('UserID: '+UserID );
            system.debug('Password: '+Password );	
            Password = 'ADMIN';
        return GetDataRequest(EndPoint,UserID,Password, AttribParams);
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
            system.debug('ParamMap: '+ParamMap); 
            return ParamMap;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'GetConnectionParams',ex,false);
            return ParamMap;
        }      
    }

    private Helper.GUMU_Response GetDataRequest(string EndPoint, string UserID, string Password ,map<string,list<object>> AttribParams)
    {
    	
        Helper.GUMU_Response oGUMU_Response = new Helper.GUMU_Response(); 
        list<object> Attrib;
        try 
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPoint);
            req.setMethod('GET');
             
            Blob headerValue = Blob.valueOf(UserID + ':' + Password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction','');
            req.setTimeOut(120000);
            
           //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'EndPoint '+EndPoint));
			 
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
            	//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'req '+req));
            	res = http.send(req);
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
            oGUMU_Response.statusMessage= res.getStatus();
            oGUMU_Response.responseERPData=getResponse;
            system.debug('oGUMU_Response'+oGUMU_Response);
            return oGUMU_Response;
        }
        catch(Exception Ex)
        {
            CustomException exc= new CustomException (className,'GetDataRequest',ex,false);
            return oGUMU_Response;
        }
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
            Attrib=AttribParams.get('IntegrationId');
            integrationID=(String)Attrib[0];
            ParamMap = GetConnectionParams(integrationID);
            
            EndPoint = ParamMap.get('WebServiceURL') ;
            
        }  
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'PostRecords',ex,true);
            throw ex;
        }
        return PostDataRequest(EndPoint,ParamMap.get('Username'),ParamMap.get('Password'),ParamMap.get('CompanyCode'),AttribParams);
            
    }
    
    private Helper.GUMU_Response PostDataRequest(string EndPoint, string UserID, string Password,string cmpnycode, map<string,list<object>> AttribParams)
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
            Attrib=AttribParams.get('MappingPurpose');
            mp=(Helper.MappingPurpose)Attrib[0];
            HttpRequest req = new HttpRequest();
             req.setMethod('POST');   
           
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
                        KeyValue+=(string)attr;
                    else
                        KeyValue+=(string)attr +'%3B';
                }

                EndPoint+=KeyValue  +'\')';  
                  
                req.setMethod('PUT');
            }
            
            if (mp == Helper.MappingPurpose.ACTION)
            {
            	
            	req.setMethod('POST');
            	EndPoint = 'https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/oepricefinders/$service/oepricPrimePricingFinder';	
            }
           
            req.setEndpoint(EndPoint);
            Blob headerValue = Blob.valueOf(UserID + ':' + Utility.Decrypt(Password));
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'UserID'+UserID+'Utility.Decrypt(Password)'+Utility.Decrypt(Password)));
           // Blob headerValue = Blob.valueOf('ADMIN' + ':' + 'ADMIN');
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction','');
            string PrepareRequest='';
            list<string>objectXMLList=new list<string>(); 
            
            for(object obj:AttribParams.get('RequestXML'))
            {
                objectXMLList.add((string)obj);
            }
            
            PrepareRequest= objectXMLList[0];
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'PrepareRequest :'+PrepareRequest));
            req.setBody(PrepareRequest);
            req.setTimeOut(120000);
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
            	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'req :'+req));
              	res = http.send(req);
  				
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
            oGUMU_Response.statusMessage= res.getStatus();
            oGUMU_Response.responseERPData=getResponse;
            
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'getResponse: '+getResponse));
            //avction if then call get metohd else 
            EndPoint='https://www.magentosageerp.com:8080/SDataServlet/sdata/sageERP/accpac/SAMINC/oepricefinders?includeSchema=true&startIndex=1&count=20';
            string User_ID =UserID; // string.valueOf('ADMIN')
            string Pass_word =Utility.Decrypt(Password); // string.valueOf('ADMIN')
            
            if (mp == Helper.MappingPurpose.ACTION)
            {
              if (oGUMU_Response.statusCode!='200')
              		return oGUMU_Response;  
              if (getResponse.contains('<RETURNCODE>0</RETURNCODE>')) 	
              	oGUMU_Response = GetDataRequest(EndPoint,User_ID,Pass_word,null);
              
              return oGUMU_Response;          
            }
            else
            {
             return oGUMU_Response;
            }
            
            return null;
            
        }
        catch(Exception Ex)
        {
            CustomException exc= new CustomException(className,'PostDataRequest',Ex,true);
            return oGUMU_Response;
        }
    } 
    
   
    
}