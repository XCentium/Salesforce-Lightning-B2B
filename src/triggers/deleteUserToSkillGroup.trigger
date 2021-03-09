trigger deleteUserToSkillGroup on ProfileSkillUser (before delete) 

{
    Map<Id,String> profSkillId2Name = new Map<Id,String>();
    List<ProfileSkill> proSkills = [select id, name from ProfileSkill];

    
    Map<String, Id> GroupName2GroupId = new Map<String, Id>();
    List<Group> skillGroups = [select id, name from Group];
    
    
    //setup mapping of profile skill to profile skill's name

    for(ProfileSkill p: proSkills)
         profSkillId2Name.put(p.Id, p.Name);
    //setup mapping group name to group id
    for(Group g : skillGroups)
        GroupName2GroupId.put(g.Name,g.Id);
     

    //delete members
    List<Id> groupMemberIds = new List<Id>();
    for(ProfileSkillUser profSkillUser : Trigger.old)
    {
        String skillName = profSkillId2Name.get(profSkillUser.ProfileSkillId);
        Id thisSkillGroup = GroupName2GroupId.get(skillName); //get group id associated with the skill

        //is there is such a group
        if(thisSkillGroup != null)
        {    
            //delete group member
            GroupMember gmemb = [select id from GroupMember where GroupId = :thisSkillGroup AND UserOrGroupId = :profSkillUser.UserId Limit 1]; //this is BAD, make a map when you have time
            groupMemberIds.add(gmemb.Id);
        }
    }
    
    EditGroupMembers.del(groupMemberIds);
}