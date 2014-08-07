/**
 * @author      Josep Vall-llobera <valnavjo_at_gmail.com>
 * @version     1.1.0
 * @since       24/09/2012
 */
public class TriggerTemplateSample extends TriggerTemplate.Handler {

	/*CONSTRUCTOR*/
	private TriggerTemplateSample() {
		this.add(new BeforeInsertLogic())
			.add(new AfterInsertLogic())
			.add(new BeforeUpdateLogicOnce())
			.add(new BeforeUpdateLogicAlways())
			.add(new AfterUpdateLogicOnce())
			.add(new AfterUpdateLogicAlways())
			.add(new BeforeDeleteLogic())
			.add(new AfterDeleteLogic())
			.add(new AfterUnDeleteLogic());
	}
	
	/*LOGIC UNITS*/
	//INSERT
	private class BeforeInsertLogic extends LogicUnit implements BeforeInsert {
		public void execute(final List<Account> newSObjects) {
			System.debug('Executing "BeforeInsertLogic"...');
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
		}
	}
	
	private class AfterInsertLogic extends LogicUnit implements AfterInsert {
		public void execute(final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap) {
			System.debug('Executing "AfterInsertLogic"...');
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
			System.debug('newSObjectsMap --> ' + newSObjectsMap);
		}
	}
	
	//UPDATE
	private class BeforeUpdateLogicOnce extends LogicUnit implements BeforeUpdate {
		public BeforeUpdateLogicOnce() {
			super(TriggerTemplate.ExecuteTimes.ONCE);
		}
		
		public void execute(final List<Account> oldSObjects, final Map<Id, SObject> oldSObjectsMap,
							final List<Account> newSObjects, final Map<Id, SObject> newSObjectsMap) {
			System.debug('Executing "BeforeUpdateLogicOnce"...');
			System.debug('newSObjects.size --> ' + oldSObjects.size());
			System.debug('newSObjects --> ' + oldSObjects);
			System.debug('newSObjectsMap --> ' + oldSObjectsMap);
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
			System.debug('newSObjectsMap --> ' + newSObjectsMap);
		}
	}
	
	private class BeforeUpdateLogicAlways extends LogicUnit implements BeforeUpdate {
		public void execute(final List<Account> oldSObjects, final Map<Id, SObject> oldSObjectsMap,
							final List<Account> newSObjects, final Map<Id, SObject> newSObjectsMap) {
			System.debug('Executing "BeforeUpdateLogicAlways"...');
			System.debug('newSObjects.size --> ' + oldSObjects.size());
			System.debug('newSObjects --> ' + oldSObjects);
			System.debug('newSObjectsMap --> ' + oldSObjectsMap);
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
			System.debug('newSObjectsMap --> ' + newSObjectsMap);
		}
	}
	
	private class AfterUpdateLogicOnce extends LogicUnit implements AfterUpdate {
		public AfterUpdateLogicOnce() {
			super(TriggerTemplate.ExecuteTimes.ONCE);
		}

		public void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap,
							final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap) {
			
			System.debug('Executing "AfterUpdateLogicOnce"...');
			System.debug('newSObjects.size --> ' + oldSObjects.size());
			System.debug('newSObjects --> ' + oldSObjects);
			System.debug('newSObjectsMap --> ' + oldSObjectsMap);
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
			System.debug('newSObjectsMap --> ' + newSObjectsMap);
		}
	}
	
	private class AfterUpdateLogicAlways extends LogicUnit implements AfterUpdate {		
		public void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap,
							final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap) {					
			System.debug('Executing "AfterUpdateLogicAlways"...');
			System.debug('newSObjects.size --> ' + oldSObjects.size());
			System.debug('newSObjects --> ' + oldSObjects);
			System.debug('newSObjectsMap --> ' + oldSObjectsMap);
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
			System.debug('newSObjectsMap --> ' + newSObjectsMap);
		}
	}
	
	//DELETE
	private class BeforeDeleteLogic extends LogicUnit implements BeforeDelete {
		public void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap) {
			System.debug('Executing "BeforeDeleteLogic"...');
			System.debug('oldSObjects.size --> ' + oldSObjects.size());
			System.debug('oldSObjects --> ' + oldSObjects);
		}
	}
	
	private class AfterDeleteLogic extends LogicUnit implements AfterDelete {
		public void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap) {
			System.debug('Executing "AfterDeleteLogic"...');
			System.debug('oldSObjects.size --> ' + oldSObjects.size());
			System.debug('oldSObjects --> ' + oldSObjects);
			System.debug('oldSObjectsMap --> ' + oldSObjectsMap);
		}
	}
	
	//UNDELETE
	private class AfterUnDeleteLogic extends LogicUnit implements AfterUnDelete {
		public void execute(final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap) {
			System.debug('Executing "AfterUnDeleteLogic"...');
			System.debug('newSObjects.size --> ' + newSObjects.size());
			System.debug('newSObjects --> ' + newSObjects);
			System.debug('newSObjectsMap --> ' + newSObjectsMap);
		}
	}
}