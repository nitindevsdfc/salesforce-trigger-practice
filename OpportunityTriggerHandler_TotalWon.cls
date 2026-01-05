public class OpportunityTriggerHandler{

	public static void opportunityTotalAmountCalculate(Map<Id, opportunity> newMap, Map<Id, opportunity> oldMap){
		
		set<Id> accId = new set<Id>();
		
		for(opportunity newopp : newMap.values()){
			
			opportunity oldopp = oldMap.containsKey(newopp.Id) ? oldMap.get(newopp.Id) ? null;

			if(newopp.Stage == 'Closed Won' && (oldopp == null || oldopp.Stage != newopp.Stage)){
				
				accId.add(newopp.AccountId);
				
			}
		}
		
		if(accId.isEmpty()){
			return;
		}
		
		Map<Id, Decimal> accMap = new Map<Id, Decimal>();
		
		for(AggregateResult ar : [Select AccountId accId, SUM(Amount) total from opportunity Where AccountId IN :accId GROUP BY AccountId]){
			accMap.put((Id)ar.get('accId'), (Decimal)ar.get('total'));
		}
		
		List<Account> acclist = new List<Account>();
		
		for(Id acId : accMap.keySet()){
			
			acclist.add(new Account(Id = acId, Total_Won_Amount__c = accMap.containsKey(acId) ? accMap.get(acId) : 0))
			
		}
		
		if(!acclist.isEmpty())
		{
			Database.update(acclist, false);
		}
	}

}