//This is used for returning provider of SageX3 ERP
public Class SageX3ERPProvider extends BaseERPProvider
{
    private string className='SageX3ERPProvider';
    // Method to establish connection
    public override boolean TestConnection(String URL, list<String> ConnectionParameters) 
    {      
        string companyCode; 
        string username;  
        string password;
        string language;
        string poolId;

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

            if(Parameters.containsKey('codeUser'))
                username= Parameters.get('codeUser');

            if(Parameters.containsKey('password'))
                password= Parameters.get('password');

            if(Parameters.containsKey('poolAlias'))
                companyCode= Parameters.get('poolAlias');
            
            if(Parameters.containsKey('codeLang'))
                language= Parameters.get('codeLang');
                
            if(Parameters.containsKey('poolId'))
                poolId= Parameters.get('poolId');
            
            string requestType='query';         
            Helper.GUMU_Response oGUMU_Respons; 
            
            map<string,map<string,list<string>>> whereParams = new map<string,map<string,list<string>>>();
            map<string,list<object>> AttribParams = new map<string,list<object>>();
            list<string> RequestType1 = new list<string>();
            RequestType1.add('query');
            AttribParams.put('RequestType',RequestType1);
            
            list<object>  AttribParam= new list<object>();
            AttribParam.add('1');
            AttribParams.put('startIndex',AttribParam);
    
            AttribParam= new list<object>();
            AttribParam.add('1');
            AttribParams.put('count',AttribParam);
            
            oGUMU_Respons= GetDataRequest(URL,username,password,companyCode,language,poolId,requestType,'YGTCUSTDTL',whereParams,AttribParams);


                        
            if(oGUMU_Respons.statusCode == '200')
                return true;
            else
                return false; 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'TestConnection',ex,false);
            throw ex;
            return false;
        }
    }


    //overridden Method to retrieve records from ERP
    public override Helper.GUMU_Response getRecords(map<string,map<string,list<string>>> whereParams, 
    map<string,list<object>> AttribParams)
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
            Attrib=AttribParams.get('DataFinder');
            DataFinder=(String)Attrib[0];
            Attrib=AttribParams.get('IntegrationId');
            integrationID=(String)Attrib[0];
            Attrib=AttribParams.get('RequestType');
            RequestType=(String)Attrib[0];
            //Assign custom setting to variables
            ParamMap = GetConnectionParams(integrationID);
            //Set web service url       
            EndPoint = ParamMap.get('WebServiceURL') ;
            return GetDataRequest(EndPoint,ParamMap.get('codeUser') ,ParamMap.get('password') ,ParamMap.get('CompanyCode') , ParamMap.get('codeLang'),ParamMap.get('poolAlias'),RequestType,DataFinder,
                whereParams,AttribParams);       
                   
        }  
        catch(Exception ex)
        {
        	if(system.isFuture() == false)
            	CustomException exc= new CustomException(ClassName,'getRecords',ex,false);
            throw ex;
        }        
    }
    
    
    // overridden Method to post records to ERP
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
            Attrib=AttribParams.get('DataFinder');
            DataFinder=(String)Attrib[0];
            Attrib=AttribParams.get('IntegrationId');
            integrationID=(String)Attrib[0];
            Attrib=AttribParams.get('RequestType');
            RequestType=(String)Attrib[0];
            //Assign custom setting to variables
           
            ParamMap = GetConnectionParams(integrationID);
            //Set web service url       
            EndPoint = ParamMap.get('WebServiceURL') ;
            return GetDataRequest(EndPoint,ParamMap.get('codeUser') ,ParamMap.get('password') ,ParamMap.get('CompanyCode') , ParamMap.get('codeLang'),ParamMap.get('poolAlias'),RequestType,DataFinder,
                new map<string,map<string,list<string>>>() ,AttribParams);       
                   
        }  
        catch(Exception ex)
        {
        	if(system.isFuture() == false)
            	CustomException exc= new CustomException (className,'PostRecords',ex,false);
            throw ex;
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
            CustomException exc= new CustomException(ClassName,'GetConnectionParams',ex,false);
            throw ex;
        }      
    }
    
    private string RequestObjectXML(map<string,map<string,list<string>>> whereParams,map<string,list<object>> AttribParams)
    {
       
        string objectXML='';
        try
        {
            list<object> Attrib=AttribParams.get('RequestType');
            string requestType=(string)Attrib[0];            
                        
            Attrib=AttribParams.get('startIndex');
            string startIndex=(string)Attrib[0];
            
            Attrib=AttribParams.get('count');
            string maxCount=(string)Attrib[0];
                
            
            if(requestType =='read')
            {
                objectXML +='<objectKeys xsi:type="wss:ArrayOfCAdxParamKeyValue" soapenc:arrayType="wss:CAdxParamKeyValue[1]">';
                objectXML +='<PARAM>';
                //Logic for adding filters
                if(whereParams.size()>0)
                {
                     if(whereParams.keySet()!=null)
                     {
                       for(string fieldKey : whereParams.keySet())
                         {
                            if(fieldKey == null)
                                continue;
                            map<string,list<string>> paramsAttrib= whereParams.get(fieldKey);
                            list<string> paramsValues;
                            if (paramsAttrib.get(string.valueOf(Helper.Operator.EQUAL))!=null)
                            {
                                
                                paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.EQUAL));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            }
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.RANGE))!=null)
                            {
                                paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.RANGE));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            }
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_OR_EQUAL))!=null)
                            {
                                 paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_OR_EQUAL));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                                
                            }
                            
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE))!=null)
                            {
                                 paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            }
                            
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE))!=null)
                            {
                                 paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            }  
                            /*///////////////////////////*/
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_THAN))!=null)
                            {
                                 paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_THAN));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            
                            }
                            
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL))!=null)
                            {
                                paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            }
                            
                           else if(paramsAttrib.get(string.valueOf(Helper.Operator.STARTS_WITH))!=null)
                           {
                                paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.STARTS_WITH));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                           }
                           
                            else if(paramsAttrib.get(string.valueOf(Helper.Operator.DOES_NOT_CONTAIN))!=null)
                            {
                                paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.DOES_NOT_CONTAIN));
                                objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                            }
                            
                           else if(paramsAttrib.get(string.valueOf(Helper.Operator.LESS_THAN))!=null)
                           {
                                 paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LESS_THAN));
                                 objectXML +='<key>'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'') + '</key>';
                                objectXML += '<value>' + paramsValues[0]  +'</value>';
                           
                           }
                               
                    }
                }
             }
                       
                objectXML +='</PARAM>';
                objectXML +='</objectKeys>';
                system.debug('XML Request '+objectXML);
            }
            else  if(requestType =='run')
            {
                objectXML +='<inputXml xsi:type="xsd:string"><![CDATA[';
                //objectXML +='<?xml version="1.0" encoding="UTF-8"?> <PARAM> <TAB ID="AX_PAR"> <LIN NUM="1"> <FLD NAME="AXPARCOD">$REC_MAX</FLD> <FLD NAME="AXPARVAL">10</FLD> </LIN> <LIN NUM="2"> <FLD NAME="AXPARCOD">$REC_STARTAT</FLD> <FLD NAME="AXPARVAL">1</FLD> </LIN> <LIN NUM="3"> <FLD NAME="AXPARCOD">$TOTAL_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="4"> <FLD NAME="AXPARCOD">$RET_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="5"> <FLD NAME="AXPARCOD">$HAS_NEXT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> </TAB><TAB ID="AX_WHR" ><LIN NUM="1" ><FLD NAME="AXWHRLFTBRK" >0</FLD><FLD NAME="AXWHRCOD" >BPCNUM</FLD><FLD NAME="AXWHROPE" >5</FLD><FLD NAME="AXWHRCODVAL" >NA002</FLD><FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN><LIN NUM="2" ><FLD NAME="AXWHRLFTBRK" >0</FLD><FLD NAME="AXWHRCOD" >BPCNUM</FLD><FLD NAME="AXWHROPE" >7</FLD><FLD NAME="AXWHRCODVAL" >NA002</FLD><FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB> </PARAM>';
                objectXML +='<?xml version="1.0" encoding="UTF-8"?> <PARAM> <TAB ID="AX_PAR"> <LIN NUM="1"> ';
                objectXML +='<FLD NAME="AXPARCOD">$REC_MAX</FLD> <FLD NAME="AXPARVAL">';
                objectXML += maxCount;
                objectXML +='</FLD> </LIN> <LIN NUM="2"> <FLD NAME="AXPARCOD">$REC_STARTAT</FLD> <FLD NAME="AXPARVAL">';
                objectXML +=startIndex;
                objectXML +='</FLD> </LIN> <LIN NUM="3"> <FLD NAME="AXPARCOD">$TOTAL_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="4"> <FLD NAME="AXPARCOD">$RET_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="5"> <FLD NAME="AXPARCOD">$HAS_NEXT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> </TAB>';
              
               if(whereParams.size()>0)
               {
                  
                    integer i=1;
                   
                    for(string fieldKey : whereParams.keySet()) 
                    {
                         map<string,list<string>> paramsAttrib= whereParams.get(fieldKey);
                         list<string> paramsValues;
                        objectXML +='<TAB ID="AX_WHR" >';
                        if (paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE))==null)
                        {
                            objectXML +='<LIN NUM="'+i+'" ><FLD NAME="AXWHRLFTBRK" >0</FLD>';
                        }
                        
                        if (paramsAttrib.get(string.valueOf(Helper.Operator.EQUAL))!=null)
                        {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.EQUAL));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >2</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                            
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.RANGE))!=null)
                        {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.RANGE));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >5</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN>';
                            objectXML += '<LIN NUM="2" ><FLD NAME="AXWHRLFTBRK" >0</FLD>';
                            objectXML += '<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+'</FLD>';
                            objectXML += '<FLD NAME="AXWHROPE" >7</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[1]  +'</FLD>';
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_OR_EQUAL))!=null)
                        {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_OR_EQUAL));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >5</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                        
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.LESSER_OR_EQUAL))!=null)
                        {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LESSER_OR_EQUAL));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >7</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                             if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                        
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL))!=null)
                        { 
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >3</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                             if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                        
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE))!=null)
                        {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >9</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                             if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.CONTAINS))!=null)
                        {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LIKE_CALUSE));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >9</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                             if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                        }
                        else if(paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE))!=null)
                        {
                            integer j =1;
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.IN_CLAUSE));
                           for(string param : paramsValues)
                            {
                                objectXML +='<LIN NUM="'+j+'" ><FLD NAME="AXWHRLFTBRK" >0</FLD>';
                                objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >2</FLD>';
                                objectXML += '<FLD NAME="AXWHRCODVAL" >' + param  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                                objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >2</FLD></LIN>';
                                j++;                         
                            }  
                            
                           objectXML +=  '</TAB>';
                        }
                        
                        
                        
                        /*///////////////////////////////////////////*/
                        
                        
                       else if(paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_THAN))!=null)
                       {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.GREATER_THAN));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >4</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                       }
                       else if(paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL))!=null)
                       {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.NOT_EQUAL));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >3</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                       }
                        /*not found */
                       else if(paramsAttrib.get(string.valueOf(Helper.Operator.STARTS_WITH))!=null)
                       {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.STARTS_WITH));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >8</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                       }
                       
                       /*not found */
                      else if(paramsAttrib.get(string.valueOf(Helper.Operator.DOES_NOT_CONTAIN))!=null)
                      {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.DOES_NOT_CONTAIN));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >10</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                      }
                      
                      else if(paramsAttrib.get(string.valueOf(Helper.Operator.LESS_THAN))!=null)
                      {
                            paramsValues = paramsAttrib.get(string.valueOf(Helper.Operator.LESS_THAN));
                            objectXML +='<FLD NAME="AXWHRCOD" >'+fieldKey.replace(BaseERPProvider.DuplicateFLDStr,'')+ '</FLD><FLD NAME="AXWHROPE" >6</FLD>';
                            objectXML += '<FLD NAME="AXWHRCODVAL" >' + paramsValues[0]  +'</FLD>';//'<value>' + paramsValues[0]  +'</value>';// paramsValues[0]  +  + paramsValues[1]   ;
                            objectXML += '<FLD NAME="AXWHRRGTBRK" >0</FLD>';
                            
                            if(i>2)
                            	objectXML += '<FLD NAME="AXWHRANDOR" >2</FLD></LIN></TAB>';
                            else
                            	objectXML += '<FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB>';
                      
                      }
                     
                        else
                        {
                            objectXML +='<inputXml xsi:type="xsd:string"><![CDATA[';                    
                            objectXML +='<?xml version="1.0" encoding="UTF-8"?> <PARAM> <TAB ID="AX_PAR"> <LIN NUM="1"> ';
                            objectXML +='<FLD NAME="AXPARCOD">$REC_MAX</FLD> <FLD NAME="AXPARVAL">';
                            objectXML += '200';
                            objectXML +='</FLD> </LIN> <LIN NUM="2"> <FLD NAME="AXPARCOD">$REC_STARTAT</FLD> <FLD NAME="AXPARVAL">';
                            objectXML +='1';
                            objectXML +='</FLD> </LIN> <LIN NUM="3"> <FLD NAME="AXPARCOD">$TOTAL_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="4"> <FLD NAME="AXPARCOD">$RET_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="5"> <FLD NAME="AXPARCOD">$HAS_NEXT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> </TAB>';
                            
                        } 
                        i++;              
                    }
                 }
                objectXML += '</PARAM>';
                objectXML +=']]></inputXml>';
              
            }
            else  if(requestType =='query')
            {
                objectXML +='<objectKeys xsi:type="wss:ArrayOfCAdxParamKeyValue" soapenc:arrayType="wss:CAdxParamKeyValue[]" />';
                objectXML +='<listSize xsi:type="xsd:int">10</listSize>';
            }
            else  if(requestType =='actionObject')
            {
                Attrib=AttribParams.get('ProductCode');
                string ProductCode=(string)Attrib[0];
                
                Attrib=AttribParams.get('AccountID');
                string AccountID=(string)Attrib[0];
                
                Attrib=AttribParams.get('Quantity');
                string Quantity=(string)Attrib[0];
                
                Attrib=AttribParams.get('discount');
                string discount=(string)Attrib[0];
                
                Attrib=AttribParams.get('UOM');
                string UOM=(string)Attrib[0];
                
                Attrib=AttribParams.get('salesite');
                string salesite=(string)Attrib[0];
                
                Attrib=AttribParams.get('shipSite');
                string shipSite=(string)Attrib[0];
                
                Attrib=AttribParams.get('grossPrice');
                string grossPrice=(string)Attrib[0];
                
                Attrib=AttribParams.get('taxRule');
                string taxRule=(string)Attrib[0];
                
                Attrib=AttribParams.get('Currency');
                string CurrencyName=(string)Attrib[0];
                
                objectXML +='<actionCode xsi:type="xsd:string">V</actionCode>';
                objectXML +='<objectXml xsi:type="xsd:string">';
                objectXML +='<![CDATA[';
                objectXML +='<PARAM>';
                objectXML +='<GRP ID="SOH0_1"><FLD NAME="SALFCY">'+salesite+'</FLD> <FLD NAME="BPCORD">'+AccountID+'</FLD><FLD NAME="CUR">'+CurrencyName+'</FLD></GRP>';
                objectXML +='<GRP ID="SOH1_4"><FLD NAME="CUR">'+CurrencyName+'</FLD></GRP>';
                objectXML +='<GRP ID="SOH2_1"><FLD NAME="STOFCY">'+shipSite+'</FLD><FLD MENULAB="Normal" MENULOCAL="410" NAME="DLVPIO">1</FLD></GRP>';
                objectXML +='<TAB DIM="200" ID="SOH4_1" SIZE="1">';
                objectXML +='<LIN NUM="1">';
                objectXML +='<FLD NAME="ITMREF">'+ProductCode+'</FLD>';
                objectXML +='<FLD NAME="DSTOFCY">'+shipSite+'</FLD>';
                objectXML +=' <FLD NAME="QTY">'+Quantity+'</FLD>';
                objectXML +='<FLD NAME="DISCRGVAL1" TYPE="Decimal">'+discount+'</FLD>';
                objectXML +='<FLD NAME="GROPRI">'+grossPrice+'</FLD>';
                objectXML +='<FLD NAME="VACITM1" TYPE="Char">'+taxRule+'</FLD>';
                objectXML +='</LIN></TAB></PARAM>]]></objectXml>';
                
            }
            else  if(requestType =='save')
            {
                Attrib=AttribParams.get('RequestXML');
                string RequestXML=(string)Attrib[0];
                
                objectXML +='<objectXml xsi:type="xsd:string">';
                objectXML +='<![CDATA[';
                objectXML +=RequestXML;            
                objectXML +=']]></objectXml>';              
            }
            else  if(requestType =='modify')
            {
                Attrib=AttribParams.get('RequestXML');
                string RequestXML=(string)Attrib[0];
                
                
                Attrib=AttribParams.get('include');
                string key = (string)Attrib[0];
                
                Attrib=AttribParams.get('CustomerNo');
                string value = (string)Attrib[0];
                objectXML +='<objectKeys xsi:type="wss:ArrayOfCAdxParamKeyValue" soapenc:arrayType="wss:CAdxParamKeyValue[1]">';
                objectXML +='<PARAM>';
                objectXML +='<key>'+key+'</key>';
                objectXML +='<value>'+value+'</value>';
                objectXML +='</PARAM></objectKeys>';             
                objectXML +='<objectXml xsi:type="xsd:string">';
                objectXML +='<![CDATA[';
                objectXML +=RequestXML;            
                objectXML +=']]></objectXml>';              
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RequestObjectXML',ex,false);
            throw ex;
        } 
      system.debug('objectXML123 '+objectXML); 
       return objectXML;
        
    }

    private Helper.GUMU_Response GetDataRequest(string EndPoint, string username,string password,string companyCode,string language,string poolId,string requestType,string dataFinder,
    map<string,map<string,list<string>>> whereParams,map<string,list<object>> AttribParams)
    {
        
        Helper.GUMU_Response oGUMU_Response = new Helper.GUMU_Response(); 
        try 
        {
            Utility.ProgramList sbr = new Utility.ProgramList();
            string PrepareRequest='';
            PrepareRequest +='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:wss="http://www.adonix.com/WSS" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            PrepareRequest +='<soapenv:Header /><soapenv:Body>';
            PrepareRequest +='<wss:'+requestType+' soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
            PrepareRequest +='<callContext xsi:type="wss:CAdxCallContext">';
            PrepareRequest +='<poolAlias xsi:type="xsd:string">'+companyCode+'</poolAlias>';
            PrepareRequest +='<codeUser xsi:type="xsd:string">'+username+'</codeUser>';
            PrepareRequest +='<password xsi:type="xsd:string">'+password+'</password>';
            PrepareRequest +='<poolId xsi:type="xsd:string">'+poolId+'</poolId>';
            PrepareRequest +='<codeLang xsi:type="xsd:string">'+language+'</codeLang>';
            PrepareRequest +='</callContext>';
            PrepareRequest +='<publicName xsi:type="xsd:string">' + dataFinder +'</publicName>';
            PrepareRequest +=RequestObjectXML(whereParams,AttribParams);
            PrepareRequest +='</wss:'+requestType+'></soapenv:Body></soapenv:Envelope>';
            
            system.debug('PrepareRequest '+PrepareRequest);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'PrepareRequest '+PrepareRequest)); 
            
           
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setHeader('SOAPAction','');
            
        
            req.setBody(PrepareRequest);
            req.setTimeOut(120000);
           
            Http http = new Http();
                        
            // code for test cases
            if (Test.isRunningTest())
            {
               string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
               if(dataFinder =='YGTCUSTDTL')
                     TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                     
                oGUMU_Response.responseERPData=TestResponseData;
                oGUMU_Response.statusMessage='Ok';
                oGUMU_Response.statusCode =string.valueof(200);
                
                
                return oGUMU_Response;
            }
            
            string getResponse='';
            HTTPResponse res;
            Dom.Document doc = new Dom.Document();
            
            try
            {
                res = http.send(req);              
                getResponse=res.getBody();  
                system.debug('getResponse '+getResponse);                   
                doc.load(getResponse);
            }
            catch (CalloutException Ex)
            {
                oGUMU_Response.statusCode ='101';
                oGUMU_Response.statusMessage=String.valueOf(Ex);
                return oGUMU_Response;
            }
            catch (Exception Ex)
            {
                oGUMU_Response.statusCode ='100';
                oGUMU_Response.statusMessage=String.valueOf(Ex);
                system.debug('oGUMU_Response455 '+oGUMU_Response);
                return oGUMU_Response;
            } 
            
            Dom.XMLNode Envelope = doc.getRootElement();       
            Dom.XMLNode respBody= Envelope.getChildElements()[0];
            
            oGUMU_Response.responseERPData=getResponse;
            
                        
            if(oGUMU_Response.responseERPData!='')
            {
            	if(system.isFuture() == false)
                	Utility.parse(oGUMU_Response.responseERPData,'message'); 
            }
            Integer status ;
            for(Dom.XMLNode resultxml : respBody.getChildElements()) 
            {
                string getattrId=resultxml.getAttribute('id',null);
                
                for(Dom.XMLNode subchild : resultxml.getChildElements()) 
                {
                    if(subchild.getName() == 'status')
                    {
                        status = Integer.valueof(subchild.getText());
                        if(status==1)
                        {
                            oGUMU_Response.statusMessage='Ok';
                            oGUMU_Response.statusCode ='200';//string.valueof(status);                            
                        }
                        else
                           oGUMU_Response.statusCode =string.valueof(status);                           
                        break;
                    }
                    if(subchild.getName() == 'message' && getattrId =='id1')
                    {
                        oGUMU_Response.statusMessage=subchild.getText();
                    }                   
                }
            }
            
            //get the response value for provided web service url
           system.debug('oGUMU_Response455 '+oGUMU_Response);
            return oGUMU_Response;
            
        }
        catch(Exception Ex)
        {
        	
        	if(system.isFuture() == false)
            	CustomException exc= new CustomException(ClassName,'GetDataRequest',ex,false);
            throw ex;            
        }
        
    }
}