trigger contactTrigger on contact(after insert){

	set<Id> accId = new set<Id>();
	
	for(contact con : Trigger.new){
		if(con.AccountId != null){
			accId.add(con.AccountId);
		}
	}
	
	if(accId.isEmpty()){
		return;
	}
	
	Map<Id, Account> accMap = new Map<Id, Account>([Select Id, Type From Account Where Id IN :accId]);
	
	List<contact> conlist = new List<contact>();
	
	for(contact con : Trigger.new){
		Account accRecord = accMap.get(con.AccountId);
		if(accRecord != null && accRecord.Type == 'Customer'){
			con.Description = 'Customer Contact';
			conlist.add(con);
		}
	}
	
	if(!con.isEmpty()){
		upadte conlist;
	}

}