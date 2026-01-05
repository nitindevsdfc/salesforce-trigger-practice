trigger accountTrigger on Account(before insert, before update){
	
	for(Account acc : Trigger.new){
		if(acc.Industry == 'Banking' && acc.AnnualRevenue == null){
			acc.addError('Annual Revenue is mandatory for Banking Accounts');
		}
	}

}