require 'set'

module Fit

  class FixtureLoader
  
    def load name
      klass = find_fixture_class name
      klass.new
    end
    
    def find_fixture_class name
      camelizedName = (name.split(/[^a-zA-Z0-9.:$]/).collect { |word| first = word.slice!(0,1).upcase; first + word }).join.chomp('.')
      klasses = ([camelizedName, camelizedName + 'Fixture'].collect { |n| find_class(n) }).compact
      raise "Fixture #{name} not found." if klasses.length == 0
      klass = klasses.find { |k| k < Fixture }
      raise "#{name} is not a fixture." unless klass
      klass
    end
    
    # Try to load the named class. We first see if it's already loaded by looking
    # for the class name. If not, we convert the class name to a file name (by
    # changing '::' to '/', then try to require that file. We then look for the
    # constant again. This means that the class Example::Sqrt must be in the file
    # Example/sqrt.rb or the file example/sqrt.rb.
    def find_class name
      klass = find_constant name
      unless klass
        ([''] + @@fixture_packages.to_a).detect do |prefix|
          file_path = (prefix + name).gsub(/::/, '/').gsub(/\./, '/')
          classname = basename = File::basename(file_path)
          if basename.index('$')
            basename_parts = basename.split(/\$/)
            basename = basename_parts[0]
            classname = basename_parts.join('::')
          end
          file_basename = basename.split(/([A-Z][^A-Z]+)/).delete_if {|e| e.empty?}.collect {|e| e.downcase!}.join('_')
          file_dirname = File::dirname(file_path)
          file_name = (file_dirname == '.' ? '' : file_dirname + '/') + file_basename

          require_file file_name

          if file_dirname == '.'
            klass_name = classname
          else
            klass_name = File::dirname(file_path).split(%r{/}).collect { |e|
              e.index(/[A-Z]/).nil? ? e.capitalize : e
            }.join('::') + "::#{classname}"
          end
          klass = find_constant klass_name
        end
      end
      klass
    end
    
    def find_constant name
      class_name = name.gsub '.', '::'
      return class_name.split('::').inject(Object) { |par, const| par.const_get(const) }
    rescue NameError
      return nil
    end

    def require_file file_name
      begin
        require file_name.downcase
      rescue LoadError
        require file_name
      end
    rescue LoadError
      #raise "Couldn't load file #{file_name} or file #{file_name.downcase}"
    end
    
    @@fixture_packages = Set.new(['Fit::'])
    # This method adds the name of a module as a 'package' we should search for fixtures.
    # Supports import_fixture
    def FixtureLoader.add_fixture_package module_name
      @@fixture_packages << module_name + '::'
    end
    def FixtureLoader.fixture_packages
      @@fixture_packages
    end
    
  end
  
end
