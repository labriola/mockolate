package mockolate.ingredients.faux
{
    import asx.string.formatToString;
    
    import mockolate.ingredients.Invocation;
    import mockolate.ingredients.InvocationType;
    
    public class FauxInvocation implements Invocation
    {
        private var _options:Object;
        
        public function FauxInvocation(options:Object=null)
        {
            _options = options || {};
        }
        
        public function get target():Object
        {
            return _options.target;
        }
        
        public function get name():String
        {
            return _options.name;
        }
        
        public function get invocationType():InvocationType
        {
            return _options.invocationType || InvocationType.METHOD;
        }
        
        public function get isMethod():Boolean
        {
            return invocationType == InvocationType.METHOD;
        }
        
        public function get isGetter():Boolean
        {
            return invocationType == InvocationType.GETTER;
        }
        
        public function get isSetter():Boolean
        {
            return invocationType == InvocationType.SETTER;
        }
        
        public function get arguments():Array
        {
            return _options.arguments;
        }
        
        public function get returnValue():*
        {
            return _options.returnValue;
        }
        
        public function set returnValue(value:*):void
        {
            _options.returnValue = value;
        }
        
        public function proceed():void
        {
            if (target)
            {
                if (isMethod)
                {
                    target[name].apply(target, this.arguments || []);
                }
                else if (isGetter)
                {
                    returnValue = target[name];
                }
                else if (isSetter)
                {
                    target[name] = arguments ? arguments[0] : null;
                }
            }
        }
        
        public function toString():String 
        {
            return formatToString(this, "FauxInvocation", ["invocationType", "name", "arguments"]);
        }
    }
}
