global class rm_EventDesignPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        EntityDefinition sampleEvent = [SELECT  QualifiedApiName, label
                                    FROM EntityDefinition 
                                    where keyprefix 
                                    like 'e%' and label = 'SampleEvent'
                                    order by QualifiedApiName limit 1];
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(sampleEvent.Label, sampleEvent.QualifiedApiName);
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  rows = new VisualEditor.DynamicPickListRows();        
                for( EntityDefinition e :  [SELECT  QualifiedApiName, label
                                    FROM EntityDefinition 
                                    where keyprefix 
                                    like 'e%' 
                                    order by QualifiedApiName] )
                {
                    VisualEditor.DataRow newRow = new VisualEditor.DataRow(e.label, e.QualifiedApiName);                    
                    rows.addRow(newRow);
                }
        return rows;
    }
}