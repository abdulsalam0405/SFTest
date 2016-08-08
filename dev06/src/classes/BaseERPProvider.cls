//This is used for returning provider of Base ERP
public abstract  Class BaseERPProvider
{
    // Method to establish connection
    public virtual boolean TestConnection(String URL, list<String> ConnectionParameters)
    {
        return null;
    } 
    
    public static final string DuplicateFLDStr='***DUP***';
     
     
    
    //(overridden)Method to retrieve records from ERP
    //public abstract Helper.GUMU_Response getRecords( map<string,map<string,list<string>>> whereParams, map<string,list<object>> AttribParams);
    //{
    //  return null;
    //}
    public virtual Helper.GUMU_Response getRecords( map<string,map<string,list<string>>> whereParams, map<string,list<object>> AttribParams)
    {
        return null;
    }
    //(overridden)Method to post records to ERP
    public virtual Helper.GUMU_Response PostRecords( map<string,list<object>> AttribParams)
    {
        return null;
    }
    
    
 
}