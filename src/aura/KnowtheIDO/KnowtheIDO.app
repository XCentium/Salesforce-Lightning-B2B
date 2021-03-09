<aura:application implements="lightning:isUrlAddressable" controller="FIDO" extends="force:slds">
    <aura:attribute name="recid" type="String" />
    <aura:attribute name="ScreenChoice" type="String" />
    <aura:attribute name="Settings" type="String[]" />
    <aura:attribute name="Industry" type="String" default='' />
    <aura:handler name="init" value="{!this}" action="{!c.init}"/>
    <c:FIDO_Wrapper2 ScreenChoice="{!v.ScreenChoice}" recid="{!v.recid}" Industry="{!v.Industry}" Settings="{!v.Settings}"/>
</aura:application>