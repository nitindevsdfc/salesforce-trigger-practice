trigger contactTrigger on contact(after delete){
	
	ContactTriggerHandler.SetContactsPresence(Trigger.oldMap);

}