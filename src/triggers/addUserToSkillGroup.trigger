trigger addUserToSkillGroup on ProfileSkillUser (after insert) 
{
    Map<Id,String> profSkillId2Name = new Map<Id,String>();
    List<ProfileSkill> proSkills = [select id, name from ProfileSkill];
    
    Map<String, Id> GroupName2GroupId = new Map<String, Id>();
    List<Group> skillGroups = [select id, name from Group];
    
    List<GroupMember> newMembers = new List<GroupMember>();
    
    //setup mapping of profile skill to profile skill's name
    for(ProfileSkill p: proSkills)
         profSkillId2Name.put(p.Id, p.Name);
    //setup mapping group name to group id
    for(Group g : skillGroups)
        GroupName2GroupId.put(g.Name,g.Id);
     
    //add new members
    for(ProfileSkillUser profSkillUser : Trigger.New)
    {
        String skillName = profSkillId2Name.get(profSkillUser.ProfileSkillId);
        Id thisSkillGroup = GroupName2GroupId.get(skillName); //get group id associated with the skill
        //is there is such a group
        if(thisSkillGroup != null)
            newMembers.add( new GroupMember(GroupId=thisSkillGroup,UserOrGroupId=profSkillUser.UserId) ); //add groupMember
    } 
    List<Id> groupIds = new List<Id>();
    List<Id> userIds = new List<Id>();
    for(GroupMember gMemb : newMembers)
    {
        groupIds.add(gMemb.GroupId);
        userIds.add(gMemb.UserOrGroupId);
    }
    EditGroupMembers.add(groupIds,userIds);
    
}