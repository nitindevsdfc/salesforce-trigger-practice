trigger contactTrigger on contact(before upadte){
	
	for(contact newcontact : Trigger.new){
		
		Contact contactoldValue = Trigger.oldMap.get(con.Id);
		
		if(newcontact.Email != contactoldValue.Email && !newcontact.Email.contains('@') && newcontact.Email != null){
			
			newcontact.addError('Invalid Email Format');
		
		}
		
	
	}

}