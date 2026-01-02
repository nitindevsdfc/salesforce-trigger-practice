trigger contactTrigger on contact(before insert){

	for(contact con : Trigger.new){
		if(con.Email != null && !con.Email.contains('@')){
			con.Email = null;
		}
	}

}