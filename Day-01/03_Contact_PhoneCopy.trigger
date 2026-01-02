trigger contactTrigger on contact(before insert, before update){
	
	for(contact con : Trigger.new){
		if(con.Phone == null && con.MobilePhone != null){
			con.Phone = con.MobilePhone;
		}
	}

}