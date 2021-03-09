trigger SkillonBadgeProdCert on WorkBadge (after insert) {
for (WorkBadge badge : Trigger.new)
   {
     WorkBadge myBadge = [select id, definition.name from WorkBadge where id = :badge.id];

       // Is this the "Acme Product - Certification Level 1" badge being given?
       if (myBadge.definition.Name == '**Product Certified')


       {
           // Get the record for the Product Knowledge skill
           ProfileSkill ps = [SELECT Id, Name FROM ProfileSkill WHERE Name = 'Product Knowledge'];
           if (ps == null)
               continue;
           
           // Does the user already have this skill?
           List<ProfileSkillUser> psu_list = [SELECT Id, Name, ProfileSkillId, UserId FROM ProfileSkillUser WHERE ProfileSkillId = :ps.Id AND 
                                  UserId = :badge.RecipientId];
           
           if ((psu_list != null) && (psu_list.size() > 0))  // Already has the skill
               continue;

           // Otherwise, add the skill
           ProfileSkillUser psu = new ProfileSkillUser();
           psu.ProfileSkillId = ps.Id;
           psu.UserId = badge.RecipientId;
           
           insert psu;
       }
   }
}