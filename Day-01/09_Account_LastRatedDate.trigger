trigger AccountTrigger on Account (before update) {
    AccountTriggerHandler.LastRatedDateUpdate(Trigger.newMap, Trigger.oldMap);
}