trigger accountTrigger on Account(before insert){
	
	for(Account acc : Trigger.new){
		if(String.isBlank(acc.Name)){
			acc.Name = 'Default Account';
		}
	}
}