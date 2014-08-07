/**
 * @author      Josep Vall-llobera <valnavjo_at_gmail.com>
 * @version     1.2.0
 * @since       24/09/2012
 */
public abstract class TriggerTemplate {
    
    /**STATIC ATTRIBUTES*/
    private static final Map<String, Handler> handlerInstances = new Map<String, Handler>();
    
    /**PUBLIC STATIC METHODS*/
    public static Handler getHandler() {
        return getHandler(getDefaultClassName());
    }
    
    public static Handler getHandler(String className) {
        //-- Prevalidations
        if (className == null || className.trim().length() == 0) {
            throw new TriggerTemplateException('"className" is mandatory.');
        }

        //-- toLowerCase & remove "__c" (custom objects)
        className = className.toLowerCase().replace('__c', '');
        
        //-- Reach Handler
        Handler handlerAux = handlerInstances.get(className);
        if (handlerAux == null) {
            try {
                handlerAux = (Handler)Type.forName(className).newInstance();
                handlerInstances.put(className, handlerAux);
            } catch (System.NullPointerException npe) {
                throw new TriggerTemplateException('"' + className + '" does not exist.');
            }
        }
        return handlerAux;
    }
    
    /**PRIVATE STATIC METHODS*/
    private static String getDefaultClassName() {
        String sObjectType = Trigger.new != null ? String.valueOf(Trigger.new.getSObjectType()) :
												   String.valueOf(Trigger.old.getSObjectType());
		sObjectType = sObjectType.replace('__c', '').replace('_', '');
		
        return 'Trigger' + sObjectType + 'Handler';
    }

    /**NESTED CLASSES*/
    public abstract class Handler {
        /**ATTRIBUTES*/
        private final Map<String, List<TriggerAction>> triggerActionsByEvent;
    
        /**CONSTRUCTOR*/
        protected Handler() {
            this.triggerActionsByEvent = new Map<String, List<TriggerAction>>();
        }
        
        /**BUILDER PATTERN*/
        public Handler add(final TriggerAction triggerAction) {
            //-- Get event
            TriggerEvent triggerEvt;
            if (triggerAction instanceof BeforeInsert) this.groupTriggerAction(triggerAction, TriggerEvent.BEFORE_INSERT);
            if (triggerAction instanceof BeforeUpdate) this.groupTriggerAction(triggerAction, TriggerEvent.BEFORE_UPDATE);
            if (triggerAction instanceof BeforeDelete) this.groupTriggerAction(triggerAction, TriggerEvent.BEFORE_DELETE);
            if (triggerAction instanceof AfterInsert) this.groupTriggerAction(triggerAction, TriggerEvent.AFTER_INSERT);
            if (triggerAction instanceof AfterUpdate) this.groupTriggerAction(triggerAction, TriggerEvent.AFTER_UPDATE);
            if (triggerAction instanceof AfterDelete) this.groupTriggerAction(triggerAction, TriggerEvent.AFTER_DELETE);
            if (triggerAction instanceof AfterUnDelete) this.groupTriggerAction(triggerAction, TriggerEvent.AFTER_UNDELETE);
            
            //-- Return this
            return this;
        }
        
        /**PUBLIC METHODS*/
        public void execute() {
            //-- Get actions by event
            final TriggerEvent triggerEvt = this.getTriggerEvent();
            final List<TriggerAction> triggerActions = this.triggerActionsByEvent.get(triggerEvt.name());
            
            //-- No actions, no party
            if (triggerActions == null || triggerActions.isEmpty()) return;
            
            //-- Execute proper actions
            for (TriggerAction triggerAction : triggerActions) {            
                if (triggerEvt == TriggerEvent.BEFORE_INSERT) {
                    ((BeforeInsert)triggerAction).execute(Trigger.new);
                } else
    
                if (triggerEvt == TriggerEvent.BEFORE_UPDATE) {
                    if (((LogicUnit)triggerAction).mustBeExecuted(Trigger.newMap.keySet(), triggerEvt))
                        ((BeforeUpdate)triggerAction).execute(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                } else
    
                if (triggerEvt == TriggerEvent.BEFORE_DELETE) {
                    ((BeforeDelete)triggerAction).execute(Trigger.old, Trigger.oldMap);
                } else
    
                if (triggerEvt == TriggerEvent.AFTER_INSERT) {
                    ((AfterInsert)triggerAction).execute(Trigger.new, Trigger.newMap);
                } else
    
                if (triggerEvt == TriggerEvent.AFTER_UPDATE) {
                    if (((LogicUnit)triggerAction).mustBeExecuted(Trigger.newMap.keySet(), triggerEvt))
                        ((AfterUpdate)triggerAction).execute(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                } else
    
                if (triggerEvt == TriggerEvent.AFTER_DELETE) {
                    ((AfterDelete)triggerAction).execute(Trigger.old, Trigger.oldMap);
                } else
    
                if (triggerEvt == TriggerEvent.AFTER_UNDELETE) {
                    ((AfterUnDelete)triggerAction).execute(Trigger.new, Trigger.newMap);
                }
            }
        }
    
        /**PRIVATE METHODS*/    
        private TriggerEvent getTriggerEvent() {
            if (Trigger.isBefore && Trigger.isInsert) return TriggerEvent.BEFORE_INSERT;
            if (Trigger.isBefore && Trigger.isUpdate) return TriggerEvent.BEFORE_UPDATE;
            if (Trigger.isBefore && Trigger.isDelete) return TriggerEvent.BEFORE_DELETE;
            if (Trigger.isAfter && Trigger.isInsert) return TriggerEvent.AFTER_INSERT;
            if (Trigger.isAfter && Trigger.isUpdate) return TriggerEvent.AFTER_UPDATE;
            if (Trigger.isAfter && Trigger.isDelete) return TriggerEvent.AFTER_DELETE;
            if (Trigger.isAfter && Trigger.isUndelete) return TriggerEvent.AFTER_UNDELETE;
            return null;
        }
    
        private void groupTriggerAction(final TriggerAction triggerAction, final TriggerEvent triggerEvt) {
            //-- Add action to grouped Map
            List<TriggerAction> triggerActions = this.triggerActionsByEvent.get(triggerEvt.name());
            if (triggerActions == null) {
                triggerActions = new List<TriggerAction>();
                this.triggerActionsByEvent.put(triggerEvt.name(), triggerActions);
            }
            triggerActions.add(triggerAction);
        }   
    }

    public abstract class LogicUnit {

        /**ATTRIBUTES*/
        private ExecuteTimes executeTimes;
        private Map<String, Set<Id>> updatedSObjectIdsByEvt;
        
        /**CONSTRUCTORS*/
        protected LogicUnit() {
            //-- By default, a logic unit will always be executed
            this(TriggerTemplate.ExecuteTimes.ALWAYS);
        }
        
        protected LogicUnit(final ExecuteTimes executeTimes) {
            if (executeTimes == null)
                throw new TriggerTemplateException('You must define "executeTimes".');
            
            this.updatedSObjectIdsByEvt = new Map<String, Set<Id>>();
            this.executeTimes = executeTimes;
        }
        
        /**PRIVATE METHODS*/
        private Boolean mustBeExecuted(final Set<Id> sObjectIds, final TriggerEvent triggerEvt) {
            //-- Logic unit must be executed only once
            if (this.executeTimes == TriggerTemplate.ExecuteTimes.ONCE) {
                //-- Get the already executed Ids, depending on the event
                Set<Id> updatedSObjectIds = this.updatedSObjectIdsByEvt.get(triggerEvt.name());
                if (updatedSObjectIds == null) {
                    updatedSObjectIds = new Set<Id>();
                    this.updatedSObjectIdsByEvt.put(triggerEvt.name(), updatedSObjectIds);
                }
                
                //-- Check if the Ids have already been executed
                if (!updatedSObjectIds.containsAll(sObjectIds)) {
                    updatedSObjectIds.addAll(sObjectIds);
                    return true;
                } else {
                    return false;
                }
            
            //-- Logic unit must be executed always
            } else {
                return true;
            }
        }
    }

    /**NESTED ENUMS*/
    public enum ExecuteTimes { ALWAYS, ONCE }
    private enum TriggerEvent { BEFORE_INSERT, AFTER_INSERT, BEFORE_UPDATE, AFTER_UPDATE,
                                BEFORE_DELETE, AFTER_DELETE, AFTER_UNDELETE }
    
    /**NESTED INTERFACES*/
    public virtual interface TriggerAction { }
    public interface BeforeInsert extends TriggerAction { void execute(final List<SObject> newSObjects); }
    public interface AfterInsert extends TriggerAction { void execute(final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap); }
    public interface BeforeUpdate extends TriggerAction { void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap,
                                                                       final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap); }
    public interface AfterUpdate extends TriggerAction { void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap,
                                                                      final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap); }
    public interface BeforeDelete extends TriggerAction { void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap); }
    public interface AfterDelete extends TriggerAction { void execute(final List<SObject> oldSObjects, final Map<Id, SObject> oldSObjectsMap); }
    public interface AfterUndelete extends TriggerAction { void execute(final List<SObject> newSObjects, final Map<Id, SObject> newSObjectsMap); }
    
    /**NESTED EXCEPTIONS*/
    public class TriggerTemplateException extends Exception { }
}