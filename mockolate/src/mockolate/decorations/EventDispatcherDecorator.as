package mockolate.decorations
{
	import asx.array.contains;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mockolate.errors.MockolateError;
	import mockolate.ingredients.Invocation;
	import mockolate.ingredients.InvocationType;
	import mockolate.ingredients.Mockolate;
	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.ingredients.mockolate_ingredient;
	
	use namespace mockolate_ingredient;

	/**
	 * Decorates the MockingCouverture with expectations specific to IEventDispatcher.
	 * 
	 * @see mockolate.ingredients.MockingCouverture#asHTTPService() 
	 */
	public class EventDispatcherDecorator extends Decorator implements InvocationDecorator
	{
		private var _eventDispatcher:IEventDispatcher;
		private var _eventDispatcherMethods:Array = [
			'addEventListener', 
			'dispatchEvent', 
			'hasEventListener', 
			'removeEventListener', 
			'willTrigger'
			];
		
		/**
		 * Constructor.
		 * 
		 * @param mockolate Mockolate instance 
		 */
		public function EventDispatcherDecorator(mockolate:Mockolate)
		{
			super(mockolate);
			
			initialize();
		}
		
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		protected function initialize():void 
		{
			if (this.mockolate.target is DisplayObject)
				initializeForDisplayObject();
			else if (this.mockolate.target is IEventDispatcher)
				initializeForEventDispatcher();
			else
				throw new MockolateError(["Mockolate target is not an IEventDispatcher, target: {}", [mockolate.target]], mockolate, mockolate.target);
		}
		
		protected function initializeForEventDispatcher():void 
		{
			_eventDispatcher = new EventDispatcher(this.mockolate.target);
			
			for each (var methodName:String in _eventDispatcherMethods)
			{
				mocker.method(methodName).answers(new MethodInvokingAnswer(_eventDispatcher, methodName));    
			}
		}
		
		protected function initializeForDisplayObject():void 
		{
			_eventDispatcher = this.mockolate.target as IEventDispatcher;
			
			for each (var methodName:String in _eventDispatcherMethods)
			{
				mocker.method(methodName).pass();    
			}
		}
		
		override mockolate_ingredient function invoked(invocation:Invocation):void 
		{
			// when the invocation is for an IEventDispatcher method
			// then call that method on the _eventDispatcher
			// 
			// IEventDispatcher methods must to be forwarded to a separate
			// EventDispatcher instance than the proxied instance in order to
			// actually dispatch events and avoid recursive stack overflows. 
			//
			if (invocation.invocationType == InvocationType.METHOD
				&& this.mockolate.target is IEventDispatcher
				&& !(this.mockolate.target is DisplayObject)
				&& contains(_eventDispatcherMethods, invocation.name))
			{
				_eventDispatcher[invocation.name].apply(null, invocation.arguments);	
			}
		}
	}
}