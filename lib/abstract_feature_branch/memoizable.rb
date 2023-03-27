module AbstractFeatureBranch
  module Memoizable
    private
    
    # memoizes a variable thread-safe
    # expects a MUTEX constant on the class including this moddule, which pre-initializes
    # mutexes at class definition time
    # Example:
    # MUTEX = { '@varname' => Mutex.new }
    def memoize_thread_safe(variable, variable_build_method_name = nil, &variable_builder)
      variable_builder ||= method(variable_build_method_name)
      if instance_variable_get(variable).nil?
        mutex_hash = self.is_a?(Module) ? self::MUTEX : self.class::MUTEX
        mutex_hash[variable].synchronize do
          if instance_variable_get(variable).nil?
            instance_variable_set(variable, variable_builder.call)
          end
        end
      end
      instance_variable_get(variable)
    end
  end
end
