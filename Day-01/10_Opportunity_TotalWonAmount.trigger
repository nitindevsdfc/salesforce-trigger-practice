trigger opportunityTrigger on opportunity(after insert, after update){
	
	OpportunityTriggerHandler.opportunityTotalAmountCalculate(Trigger.newMap, Trigger.oldMap);

}