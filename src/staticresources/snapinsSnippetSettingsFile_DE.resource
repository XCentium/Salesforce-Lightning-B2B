window._snapinsSnippetSettingsFile = (function() 
  {
  var userId = $A.get("$SObjectType.CurrentUser.Id");

  embedded_svc.snippetSettingsFile.avatarImgURL = '/consumer/resource/snapinsAssets/snapinsAgentAvatar_40x40px.png';
  embedded_svc.snippetSettingsFile.smallCompanyLogoImgURL = '/consumer/resource/snapinsAssets/snapinsMinimizedLogo_30x30px.png';
  embedded_svc.snippetSettingsFile.waitingStateBackgroundImgURL = '/consumer/resource/snapinsAssets/snapinsWaitingState_200x60px.png';
  embedded_svc.snippetSettingsFile.headerBackgroundURL = '/consumer/resource/snapinsAssets/snapinsHeaderBackgroundImage_320x225px.png';
  embedded_svc.snippetSettingsFile.chatbotAvatarImgURL = '/consumer/resource/snapinsAssets/snapinsBotAvatar_40x40px.png';
  
  embedded_svc.snippetSettingsFile.extraPrechatFormDetails = [
  {"label":"ChatEndUserId__c","value":userId,"displayToAgent":true,"transcriptFields": ["ChatEndUserId__c"]},
  {"label":"StartURL","value":window.location.href,"transcriptFields":[ "ChatStartURL__c" ],"displayToAgent":true}
  ];

  }
)();