public with sharing class LookupController 
{
        public List<sObject> results{get;set;} // search results
        public string searchString{get;set;} // search keyword
        public string ObjectName {get;set;}
        public string Fieldtosearch1 {get;set;}
        public string Fieldtosearch2 {get;set;}
        public string Fieldtoshow1{get;set;}
        public string Fieldtoshow2{get;set;}
        public string Fieldtoshow3{get;set;}
        public string SearchFieldLabel1 {get;set;}
        public string SearchFieldLabel2 {get;set;}
        public string SearchFieldLabel3 {get;set;}
        public string SearchFieldLabel4 {get;set;}
        public string SearchFieldLabel5 {get;set;}
        public string WhereField1 {get;set;}
        public string WhereFieldValue1 {get;set;}
        public string WhereCompareOp1 {get;set;}
        public string WhereField2 {get;set;}
        public string WhereFieldValue2 {get;set;}
        public string WhereCompareOp2 {get;set;}
        public string WhereField3 {get;set;}
        public string WhereFieldValue3 {get;set;}
        public string WhereCompareOp3 {get;set;}
        public String NameSpace {get;set;}

        /*
     *  get the current search string
     */
        public LookupController () 
        {
                try
                {
                        NameSpace=Utility.FetchNameSpace();
                        searchString = System.currentPageReference().getParameters().get('lksrch');
                        ObjectName = Utility.getSobjectName(System.currentPageReference().getParameters().get('obj'));
                        Fieldtosearch1 = System.currentPageReference().getParameters().get('fldsrch1');
                        Fieldtosearch2 = System.currentPageReference().getParameters().get('fldsrch2');
                        Fieldtoshow1= System.currentPageReference().getParameters().get('fldshow1');
                        Fieldtoshow2= System.currentPageReference().getParameters().get('fldshow2');
                        Fieldtoshow3= System.currentPageReference().getParameters().get('fldshow3');
                        WhereField1 = System.currentPageReference().getParameters().get('wherefield1');
                        WhereFieldValue1 =System.currentPageReference().getParameters().get('wherefieldvalue1');
                        WhereCompareOp1 = System.currentPageReference().getParameters().get('wherecompareop1');
                        WhereField2 = System.currentPageReference().getParameters().get('wherefield2');
                        WhereFieldValue2 =System.currentPageReference().getParameters().get('wherefieldvalue2');
                        WhereCompareOp2 = System.currentPageReference().getParameters().get('wherecompareop2');
                        WhereField3 = System.currentPageReference().getParameters().get('wherefield3');
                        WhereFieldValue3 =System.currentPageReference().getParameters().get('wherefieldvalue3');
                        WhereCompareOp3 = System.currentPageReference().getParameters().get('wherecompareop3');
                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

                        if(ObjectName!=null)
                        {
                                Schema.SObjectType sObjectSchema = schemaMap.get(ObjectName);
                                Map<String, Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap();

                                if(string.isnotblank(Fieldtosearch1)){
                                        SearchFieldLabel1 = fieldMap.get(Fieldtosearch1).getDescribe().getLabel();
                                }
                                
                                if(string.isnotblank(Fieldtosearch2)){
                                        SearchFieldLabel2 = fieldMap.get(Fieldtosearch2).getDescribe().getLabel();
                                }

                                if(string.isnotblank(Fieldtoshow1)){
                                        SearchFieldLabel3 = fieldMap.get(Fieldtoshow1).getDescribe().getLabel();
                                }

                                if(string.isnotblank(Fieldtoshow2)){
                                        SearchFieldLabel4 = fieldMap.get(Fieldtoshow2).getDescribe().getLabel();
                                }

                                if(string.isnotblank(Fieldtoshow3)){
                                        SearchFieldLabel5 = fieldMap.get(Fieldtoshow3).getDescribe().getLabel();
                                }
                        }
                        runSearch();  
                }
                  catch(Exception ex)
        {
                GUMUException exc= new GUMUException('GTLookup','GTLookup',ex);
                //ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
        }

        /*
     *  performs the keyword search
     */
        public PageReference search() 
        {
            try
            {
                runSearch();
            }
            catch(Exception ex)
            {
                GUMUException exc= new GUMUException('GTLookup','search',ex);
                ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
            }
            return null;
        }

        /*
     * prepare the query and issue the search command
     */
        public void runSearch() 
        {
            try
            {
                 // TODO prepare query string for complex serarches & prevent injections
                    
                    results = performSearch(String.valueOf(searchString));
                   
            }
            catch(Exception ex)
            {
                GUMUException exc= new GUMUException('GTLookup','runSearch',ex);                
                ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
            }         
        } 

        /*
     * Run the search and return the records found.  
     */
        public List<sObject> performSearch(string searchString) 
        {
                String soql ='';
                boolean bWhereClause = false;
                
                try
                {
                        if(ObjectName!=null)
                        {
                                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectName);
                                Map<String, Schema.SobjectField> fields = targetType.getDescribe().fields.getMap();

                                // Check if the user has read access on the ApexClass.NamespacePrefix
                                if (!fields.get('id').getDescribe().isAccessible()) {
                                        return null;
                                }

                                soql ='select id, ';
                                if(ObjectName == 'PricebookEntry')
                                {
                                        // Check if the user has read access on the ApexClass.NamespacePrefix
                                        if (!fields.get('Product2Id').getDescribe().isAccessible()) {
                                                return null;
                                        }
                                        soql = soql + 'Product2Id, '; 
                                }
                                if(string.isnotblank(Fieldtosearch1))
                                {    
                                        // Check if the user has read access on the ObjectName.id
                                        if (!fields.get(Fieldtosearch1).getDescribe().isAccessible()) {
                                                return null;
                                        }
                                        soql = soql + String.escapeSingleQuotes(Fieldtosearch1);
                                }

                                if(string.isnotblank(Fieldtosearch2))  
                                {
                                        // Check if the user has read access on the ObjectName.Fieldtosearch2
                                        if (!fields.get(Fieldtosearch2).getDescribe().isAccessible()) {
                                                return null;
                                        }  

                                        soql = soql + ','+ String.escapeSingleQuotes(Fieldtosearch2);
                                }
                                if(string.isnotblank(Fieldtoshow1))
                                {
                                        // Check if the user has read access on the ObjectName.Fieldtoshow1
                                        if (!fields.get(Fieldtoshow1).getDescribe().isAccessible()) {
                                                return null;
                                        }
                                        soql = soql + ','+ String.escapeSingleQuotes(Fieldtoshow1);
                                }
                                if(string.isnotblank(Fieldtoshow2))
                                {
                                        // Check if the user has read access on the ObjectName.Fieldtoshow2
                                        if (!fields.get(Fieldtoshow2).getDescribe().isAccessible()) {
                                                return null;
                                        }
                                        soql = soql + ','+ String.escapeSingleQuotes(Fieldtoshow2);
                                }
                                if(string.isnotblank(Fieldtoshow3))
                                {
                                        // Check if the user has read access on the ObjectName.Fieldtoshow3
                                        if (!fields.get(Fieldtoshow3).getDescribe().isAccessible()) {
                                                return null;
                                        }
                                        soql = soql + ','+ String.escapeSingleQuotes(Fieldtoshow3);
                                }

                                soql = soql + ' from ' + String.escapeSingleQuotes(ObjectName);  

                                if(string.isNotEmpty(searchString) && string.isNotBlank(Fieldtosearch1) && string.isBlank(Fieldtosearch2))
                                {
                                        soql = soql + ' where ('+ String.escapeSingleQuotes(Fieldtosearch1) + '  LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\')';
                                        
                                        bWhereClause = true;
                                }

                                if(string.isNotEmpty(searchString) && string.isNotBlank(Fieldtosearch1) && string.isNotBlank(Fieldtosearch2))
                                {
                                        if(bWhereClause == false)
                                                soql = soql + ' where ';

                                        soql = soql + ' ('+ String.escapeSingleQuotes(Fieldtosearch1) + '  LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\'';
                                        soql = soql+' OR ' + String.escapeSingleQuotes(Fieldtosearch2) + '  LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\')';
                                        bWhereClause = true;
                                }

                                if(string.isNotBlank(WhereField1) && string.isnotblank(WhereFieldValue1))
                                {
                                        if(bWhereClause == false)
                                                soql = soql + ' where ';
                                        else
                                                soql = soql + ' AND ';

                                        soql = soql + ' ' + String.escapeSingleQuotes(WhereField1) ;

                                        if(WhereCompareOp1 == 'notequal')
                                        {
                                                if(WhereFieldValue1.toLowerCase() == 'blank')
                                                        soql = soql + '!=\'\'';
                                                else 
                                                        soql = soql + '!=' + String.escapeSingleQuotes(WhereFieldValue1) + '';
                                        }
                                        else if(WhereCompareOp1 == 'equal')
                                        {
                                                if(WhereFieldValue1.toLowerCase() == 'blank')
                                                        soql = soql + '=\'\'';
                                                else 
                                                        soql = soql + '=\'' + String.escapeSingleQuotes(WhereFieldValue1) + '\'';
                                        }
                                        else if(WhereCompareOp1.toLowerCase() == 'in')
                                        {
                                                soql = soql + ' IN ( ';

                                                List<String> InParts = WhereFieldValue1.split('_');
                                                Boolean bFirst = true;
                                                for(String Part : InParts)
                                                {
                                                        if(!bFirst)
                                                                soql = soql + ',';
                                                        soql = soql +  '\'' + String.escapeSingleQuotes(Part) + '\'';
                                                        bFirst = false;
                                                }

                                                soql = soql + ' )'; 
                                        }                        
                                }
                                if(WhereField2 != 'undefined' && string.isNotBlank(WhereField2) && string.isnotblank(WhereFieldValue2))
                                {
                                        soql = soql + ' AND ';

                                        soql = soql + ' ' + String.escapeSingleQuotes(WhereField2) ;

                                        if(WhereCompareOp2 == 'notequal') 
                                        {
                                                if(WhereFieldValue2.toLowerCase() == 'blank')
                                                        soql = soql + '!=\'\'';
                                                else 
                                                        soql = soql + '!=' + String.escapeSingleQuotes(WhereFieldValue2) + '';
                                        }    

                                        else if(WhereCompareOp2 == 'equal')
                                        {
                                                if(WhereFieldValue2.toLowerCase() == 'blank')
                                                        soql = soql + '=\'\'';
                                                else 
                                                        soql = soql + '=\'' + String.escapeSingleQuotes(WhereFieldValue2) + '\'';
                                        }
                                        else if(WhereCompareOp2.toLowerCase() == 'in')
                                        {
                                                soql = soql + ' IN ( ';

                                                List<String> InParts = WhereFieldValue2.split('_');
                                                Boolean bFirst = true;
                                                for(String Part : InParts)
                                                {
                                                        if(!bFirst)
                                                                soql = soql + ',';
                                                        soql = soql +  '\'' + String.escapeSingleQuotes(Part) + '\'';
                                                        bFirst = false;
                                                }

                                                soql = soql + ' )'; 
                                        }                      
                                }
                                if(WhereField3 != 'undefined' && string.isNotBlank(WhereField3) && string.isnotblank(WhereFieldValue3))
                                {
                                        soql = soql + ' AND ';

                                        soql = soql + ' ' + String.escapeSingleQuotes(WhereField3) ;

                                        if(WhereCompareOp3 == 'notequal') 
                                        {
                                                if(WhereFieldValue3.toLowerCase() == 'blank')
                                                        soql = soql + '!=\'\'';
                                                else 
                                                        soql = soql + '!=' + String.escapeSingleQuotes(WhereFieldValue3) + '';
                                        }
                                        else if(WhereCompareOp3 == 'equal')
                                        {
                                                if(WhereFieldValue3.toLowerCase() == 'blank')
                                                        soql = soql + '=\'\'';
                                                else 
                                                        soql = soql + '=\'' + String.escapeSingleQuotes(WhereFieldValue3) + '\'';
                                        }
                                        else if(WhereCompareOp3.toLowerCase() == 'in')
                                        {
                                                soql = soql + ' IN ( ';

                                                List<String> InParts = WhereFieldValue3.split('_');
                                                Boolean bFirst = true;
                                                for(String Part : InParts)
                                                {
                                                        if(!bFirst)
                                                                soql = soql + ',';
                                                        soql = soql +  '\'' + String.escapeSingleQuotes(Part) + '\'';
                                                        bFirst = false;
                                                }

                                                soql = soql + ' )'; 
                                        }                                
                                }
                                soql = soql + ' limit 1000';
                               //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'soql :'+soql));
                                return database.query(soql); 
                        }
                }
                catch(Exception ex)
                {
                        GUMUException exc= new GUMUException('GTLookup','performSearch',ex);
                        ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
                }      
                return null;
        }

        /*
     * Used by the visualforce page to send the link to the right dom element
     */
        public string getFormTag() 
        {
            return System.currentPageReference().getParameters().get('frm');
        }

        public string getFieldsToShowTag() 
        {
            return System.currentPageReference().getParameters().get('fldshow');
        }

        /*
     * Used by the visualforce page to send the link to the right dom element for the text box
     */
        public string getTextBox() 
        {
            return System.currentPageReference().getParameters().get('txt');
        }

}