trigger AccountTrigger on Account (before insert, before update) {

    AccountTriggerHandler.setPriorityAccount(Trigger.new, Trigger.oldMap);

}