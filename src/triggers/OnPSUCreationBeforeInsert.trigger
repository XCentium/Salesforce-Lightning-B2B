trigger OnPSUCreationBeforeInsert on ProfileSkillUser (after insert) 
{
   for (ProfileSkillUser psu : Trigger.new)
   {
      ProfileSkill skill = [SELECT Id, Restricted_skill__c FROM ProfileSkill WHERE Id = :psu.ProfileSkillId];
      if (skill == null)
      {
         continue;
      }

      // Can the user add this particular skill?
      if ((skill.Restricted_skill__c == true) && (psu.CreatedById == psu.UserId))
      {
         Trigger.new[0].addError('This is a restricted skill and cannot be added directly.  Please complete the required Certification first.');
         continue;
      }            
   }
}