require 'fit/fixture'

module Fit
  
  class FitProtocol
    
    def FitProtocol.read_size(input)
      str_value = read(10, input)
      return str_value.to_i
    end
    
    def FitProtocol.read(bytes, input)
      value = input.read(bytes)
      return value
    end
    
    def FitProtocol.read_document(input)
      byte_count = read_size(input)
      return read(byte_count, input)
    end
    
    def FitProtocol.read_counts(input)
      counts = Counts.new
      counts.right = FitProtocol.read_size(input)
      counts.wrong = FitProtocol.read_size(input)
      counts.ignores = FitProtocol.read_size(input)
      counts.exceptions = FitProtocol.read_size(input)
      return counts
    end  
    
    def FitProtocol.write_size(size, output)
      formatted_size = FitProtocol.format_number(size)
      output.write(formatted_size) 
      output.flush
    end
    
    def FitProtocol.write_document(document, output)
      FitProtocol.write_size(document.size, output)
      output.write(document)
      output.flush
    end
    
    def FitProtocol.write_counts(counts, output)
      FitProtocol.write_size(0, output)
      FitProtocol.write_size(counts.right, output)
      FitProtocol.write_size(counts.wrong, output)
      FitProtocol.write_size(counts.ignores, output)
      FitProtocol.write_size(counts.exceptions, output)
    end
    
    def FitProtocol.format_number(size)
      number_of_zeros = 10 - size.to_s.size
      formatted_value = ""
      number_of_zeros.times do
        formatted_value << '0'
      end
      formatted_value << size.to_s
      return formatted_value
    end
  end
  
end
