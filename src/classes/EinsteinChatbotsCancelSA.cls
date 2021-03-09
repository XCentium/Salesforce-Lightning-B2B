global class EinsteinChatbotsCancelSA 
{
    @InvocableMethod(label='Einstein Chatbots - Cancel Service Appointment' description='Cancels the selected Service Appointment')
    global static List<ServiceAppointment> cancelSA(List<ServiceAppointment> requests) 
    {
        List<ServiceAppointment> results = new List<ServiceAppointment>();
        For (ServiceAppointment objSA : requests)
        {
            if (objSA != null && String.IsNotBlank(objSA.Id))
            {
                objSA.Status = 'Canceled';
                objSA.ArrivalWindowStartTime = null;
                objSA.ArrivalWindowEndTime = null;
                update objSA;
                results.add(objSA);
                return results; 
            }
            break;
        }
        
        return new List<ServiceAppointment>{new ServiceAppointment()};
    } 
}