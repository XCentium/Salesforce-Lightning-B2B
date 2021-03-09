<aura:application extends="force:slds">
    <aura:handler value="{!this}" name="init" action="{!c.init}"/>
        <c:Clienteling_Wrapper/> 
    <ltng:require styles="{!$Resource.SLDS221 + '/styles/salesforce-lightning-design-system.min.css'}" />
</aura:application>