module AWS
  module OpsWorks
    module System
      module Helper

        MIN_MEMORY = 2000 unless defined?(MIN_MEMORY)

        def self.swap_needed?(total_memory)
          (total_memory.to_i / 1024) < MIN_MEMORY
        end

        def self.swap_file_size(total_memory)
          MIN_MEMORY - (total_memory.to_i / 1024)
        end

      end
    end
  end
end
