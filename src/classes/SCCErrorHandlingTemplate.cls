/**
* Error handling class
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-06 
*/
public with sharing class SCCErrorHandlingTemplate {

    private String errorMessage         {get; set;}
    private String errorLine            {get; set;}
    private String status               {get; set;}
    private String typeOfError          {get; set;}
    
    
    /**
    * This is the constructor for errorhandlingtemplate class.
    * @param e: Exception
    * @return None.
    */
    public SCCErrorHandlingTemplate(Exception e) {
        this.errorMessage   = e.getMessage();
        this.errorLine      = String.valueOf(e.getLineNumber());
        this.status         = '500';
        this.typeOfError    = e.getTypeName();
    }
    
    /**
    * Constructor for String error messages.
    * @param errorMessage: String
    * @param statusCode: String
    * @return None.
    */
    public SCCErrorHandlingTemplate(String errorMessage, String statusCode, String typeOfError) {
        this.errorMessage   = errorMessage;
        this.errorLine      = '';
        this.status         = statusCode;
        this.typeOfError    = typeOfError;
    }

    /**
    * This method used for creating json text if there is error in process.
    * @param e: Exception
    * @return SCCErrorHandlingTemplate.
    */
    public static SCCErrorHandlingTemplate createError(Exception e) {
        return new SCCErrorHandlingTemplate(e);
    }
    
    /**
    * This method used for creating json text if there is error of missing default account in SC.
    * @param e: Exception
    * @return SCCErrorHandlingTemplate.
    */
    public static SCCErrorHandlingTemplate createError(String defaultAccMsg) {
        return new SCCErrorHandlingTemplate(defaultAccMsg, '500', 'Missing Default Account.');
    }

    /**
    * Overloaded createError to accept error-message & status code as arguments
    * This method used for creating json text if there is error of missing default account in SC.
    * @param errorMessage: String
    * @param statusCode: String
    * @return SCCErrorHandlingTemplate.
    */
    public static SCCErrorHandlingTemplate createError(String errorMessage, String statusCode, String typeOfError) {
        return new SCCErrorHandlingTemplate(errorMessage, statusCode, typeOfError);
    }

}