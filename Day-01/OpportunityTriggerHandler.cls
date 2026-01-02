public class OpportunityTriggerHandler {

    public static void opportunityAmountUpdate(List<Opportunity> opplist){
        for(Opportunity opp : opplist){

            Decimal productAmt = opp.Product_Amount__c != null ? opp.Product_Amount__c : 0;
            Decimal serviceAmt = opp.Service_Amount__c != null ? opp.Service_Amount__c : 0;

            opp.Amount = productAmt + serviceAmt;

            if(opp.StageName == 'Closed Won' && opp.CloseDate > Date.today()){
                opp.addError('Opportunity CloseDate must be today or earlier');
            }
        }
    }
}
