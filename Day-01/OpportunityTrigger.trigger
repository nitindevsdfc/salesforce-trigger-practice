trigger OpportunityTrigger on Opportunity (before insert, before update) {
    OpportunityTriggerHandler.opportunityAmountUpdate(Trigger.new);
}
