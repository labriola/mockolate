package mockolate
{
    import asx.object.isA;
    
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.utils.describeType;
    
    import mockolate.errors.ExpectationError;
    import mockolate.ingredients.Mockolate;
    import mockolate.sample.DarkChocolate;
    import mockolate.sample.Flavour;
    
    import org.flexunit.assertThat;
    import org.flexunit.async.Async;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.core.not;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.object.strictlyEqualTo;
    
    public class VerifyingMockolates
    {
        // shorthands
        public function proceedWhen(target:IEventDispatcher, eventName:String, timeout:Number=30000, timeoutHandler:Function=null):void
        {
            Async.proceedOnEvent(this, target, eventName, timeout, timeoutHandler);
        }
        
        [Before(async, timeout=30000)]
        public function prepareMockolates():void
        {
            proceedWhen(
                prepare(Flavour, DarkChocolate),
                Event.COMPLETE);
        }
        
        /*
           Verifying
         */
        
        [Test]
        public function verifyingMockBehaviourAsPassing():void
        {
            var instance:Flavour = strict(Flavour);
            
            mock(instance).method("combine").args(nullValue());
            
            instance.combine(null);
            
            verify(instance);
        }
        
        [Test(expected="mockolate.errors.ExpectationError")]
        public function verifyingMockBehaviourAsFailingAsNotCalled():void
        {
            var instance:Flavour = strict(Flavour);
            
            mock(instance).method("combine").args(nullValue());
            
            verify(instance);
        }
        
        [Test]
        public function verifyingShouldReturnAllUnmetExpectations():void 
        {
            var instance:Flavour = strict(Flavour);
            
            mock(instance).property("name").returns("blueberry");
            mock(instance).property("ingredients").returns([]);
            mock(instance).method("toString").returns("blueberry");
            
            try 
            {
                verify(instance); 
            }
            catch (error:ExpectationError)
            {
                trace(error.message);
                assertThat(error.expectations, arrayWithSize(3));
            }
        }
        
        /*
           Verifying nice mock as Test Spy
        
           // verify api
           // verify: test spy
           verify(instance:*, propertyOrMethod:String, ...matchers):Verifier
           // verify: argument matchers
           .args(...matchers)
           // verify: receive count
           .times(n:int)
           .never()
           .once()
           .twice()
           .thrice()
           .atLeast(n:int)
           .atMost(n:int)
           // verify: expectation ordering
           .ordered(group:String="global")
         */
        
        [Test]
        public function verifyingAsTestSpyAsPassing():void
        {
            var instance:Flavour = nice(Flavour);
            
            instance.combine(null);
            
            verify(instance).method("combine").args(nullValue()).once();
        }
        
        [Test(expected="mockolate.errors.VerificationError")]
        public function verifyingAsTestSpyAsFailing():void
        {
            var instance:Flavour = nice(Flavour);
            
            verify(instance).method("combine").args(nullValue()).once();
        }
        
        [Test(expected="mockolate.errors.VerificationError")]
        public function verifyingAsTestSpyAsFailingInvokedCount():void
        {
            var instance:Flavour = nice(Flavour);
            
            instance.combine(null);
            
            verify(instance)
                .method("combine")
                .args(nullValue())
                .twice();
        }
		
		[Test(expected="mockolate.errors.VerificationError")]
		public function verifyAsTestSpyFailingInvokedCountNever():void 
		{
			var instance:Flavour = nice(Flavour);
			
			instance.combine(null);
			
			verify(instance).method("combine").args(nullValue()).times(0);
		}
		
    }
}