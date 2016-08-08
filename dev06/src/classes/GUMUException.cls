public with sharing class GUMUException extends Exception
{
    public final String Message; 
    public final String MessageDetail; 
    public ApexPages.severity severity;

    /*
     * Constructor to generate Exception message
     */
    public GUMUException(String className, String methodName, Exception ex)
    {
        /*if(ex.getMessage() == 'List has no rows for assignment to sobject')
        {
            message='No records found!';
            severity= ApexPages.severity.ERROR;
        }
        else if(ex.getTypeName() == 'System.NullPointerException')
        {
            message='No records found!'+'====class:'+className+'====method:'+methodName;
            severity= ApexPages.severity.INFO;
        }
        else if(ex.getTypeName() == 'System.DmlException')
        {
            message='Error while Insert or Update operation!';
            severity= ApexPages.severity.INFO;
        }
        else if(ex.getTypeName() == 'System.LimitException')
        {
            message='A governor limit has been exceeded!';
            severity= ApexPages.severity.INFO;
        }
        /*else if(ex.getTypeName() == 'System.ListException')
        {
            message='Error while accessing list data!';
            severity= ApexPages.severity.INFO;
        }
        else if(ex.getTypeName() == 'System.NoDataFoundException')
        {
            message='Error while accessing data that does not exist!';
            severity= ApexPages.severity.INFO;
        }
        else if(ex.getTypeName() == 'System.QueryException')
        {
            message='Error while retrieving data from system!';
            severity= ApexPages.severity.INFO;
        }
        else if(ex.getTypeName() == 'System.TypeException')
        {
            message='Problem while conversion of data!'+'====class:'+className+'====method:'+methodName+'====line:'+ex.getLineNumber();
            severity= ApexPages.severity.INFO;
        }*/
        if(ex.getTypeName() == 'System.XmlException')
        {
            message='Problem while reading XML data!';
            severity= ApexPages.severity.INFO;
        }
        else
        {
            message= ex.getTypeName();
            severity= ApexPages.severity.FATAL;
        }
        MessageDetail=ex.getStackTraceString();
        
    }
}