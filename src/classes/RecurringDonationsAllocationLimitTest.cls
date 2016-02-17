@isTest
private class RecurringDonationsAllocationLimitTest {
    /**
     * Given Default Allocations are enabled
     * And Opportunity Forecast Months is set to 1
     * When I create 20 open ended recurring donations
     * And set the Opportunity Forecast Months to 12
     * Then there should be 240 Opportunity records related to the recurring donations
     * And there should be 240 Payment records related to the opportunities
     * And there should be 240 Allocation records related to the opportunities
     * And there should be 240 Allocation records related to the payments
     */
    @isTest
    private static void testAllocationsCreatedForManyOpenEndedRecurringDonations() {
        Contact c = new Contact(LastName = 'Test');
        insert c;

        General_Accounting_Unit__c defaultGau = new General_Accounting_Unit__c(
            Name = 'Test GAU'
        );
        insert defaultGau;

        npe03__Recurring_Donations_Settings__c rdSettings = UTIL_CustomSettingsFacade.getRecurringDonationsSettings();
        rdSettings.npe03__Opportunity_Forecast_Months__c = 1;

        Allocations_Settings__c allocationSettings = UTIL_CustomSettingsFacade.getAllocationsSettings();
        allocationSettings.Default_Allocations_Enabled__c = true;
        allocationSettings.Default__c = defaultGau.Id;

        List<npe03__Recurring_Donation__c> donations = new List<npe03__Recurring_Donation__c>();

        for (Integer i = 0; i < 20; i++) {
            donations.add(new npe03__Recurring_Donation__c(
                npe03__Contact__c = c.Id,
                npe03__Amount__c = 100.0,
                npe03__Installment_Period__c = 'Monthly',
                npe03__Open_Ended_Status__c = 'Open'
            ));
        }

        insert donations;

        Test.startTest();

        rdSettings.npe03__Opportunity_Forecast_Months__c = 12;
        STG_PanelRDBatch_CTRL rdBatch = new STG_PanelRDBatch_CTRL();
        rdBatch.runBatch();

        Test.stopTest();

        List<Opportunity> createdOpportunities = [
            SELECT Id
            FROM Opportunity
            WHERE npe03__Recurring_Donation__c IN :donations
        ];

        System.assertEquals(240, createdOpportunities.size());

        List<npe01__OppPayment__c> createdPayments = [
            SELECT Id
            FROM npe01__OppPayment__c
            WHERE npe01__Opportunity__c IN :createdOpportunities
        ];

        System.assertEquals(240, createdPayments.size());

        List<Allocation__c> createdOpportunityAllocations = [
            SELECT Id
            FROM Allocation__c
            WHERE Opportunity__c IN :createdOpportunities
        ];

        System.assertEquals(240, createdOpportunityAllocations.size());

        List<Allocation__c> createdRecurringDonationAllocations = [
            SELECT Id
            FROM Allocation__c
            WHERE Recurring_Donation__c IN :donations
        ];

        System.assertEquals(240, createdRecurringDonationAllocations.size());
    }
}