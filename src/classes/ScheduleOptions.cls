global class ScheduleOptions implements Comparable {

    public string policyLabel;
    public Integer slotCount;
    public Integer candidateCount;
    public Integer mainSlotCount;
    public Integer mainCandidateCount;

    // Constructor
    public ScheduleOptions(String pl, Integer sc, Integer mc, Integer cc, Integer mcc)
    {
        policyLabel = pl;
        slotCount = sc;
        mainSlotCount = mc;
        candidateCount = cc;
        mainCandidateCount = mcc;
    }

    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        ScheduleOptions compareToSlot = (ScheduleOptions)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (slotCount > compareToSlot.slotCount) {
            // Set return value to a positive value.
            returnValue = -1;
        } else if (slotCount < compareToSlot.slotCount) {
            // Set return value to a negative value.
            returnValue = 1;
        }
        return returnValue;
    }

    public string GetOutputString(string iconCheck, string iconCross)
    {
        string strResponse = '';
        strResponse = '<tr style="vertical-align:middle;"><td>' + (slotCount > mainSlotCount ? iconCheck : iconCross) + '</td><td style="padding-top:8px;padding-bottom:8px;"><strong>' + policyLabel
            + '</strong>: With the \'' + policyLabel + '\' policy, there are ' +
            (slotCount > mainSlotCount ?  '<strong>' + (slotCount - mainSlotCount) + '</strong>' + (mainSlotCount > 0 ? ' additional' : '') + ' scheduling options across <strong>' + (candidateCount == mainCandidateCount ? 'the same ' + candidateCount + '</strong>' : (candidateCount - mainCandidateCount) + '</strong> ' + (mainSlotCount > 0 ? 'additional' : '')) + ' candidate(s).'
             : '<strong>NO</strong> additional scheduling options available.') +
            '</td></tr>';
        return strResponse;
    }
}