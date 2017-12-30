require 'open4'

puts "FAC [32 bytes/line, RAND replacement]:"
for i in 10...17
    power = 2 ** i

    for j in 1...7
        size = 
            Open4::popen4("./CacheSim -s") do |pid, stdin, stdout, stderr|
                stdin.puts "#{j} 3 #{power} 4"
                stdin.close
                puts "Cache size: #{power}, Memgen #{j}: #{stdout.read.strip}"           
            end
    end
end

puts "FAC [4096 bytes, 32 bytes/line]:"
replacement = ["LFU", "LRU", "FIFO", "RAND"];
for i in 1...5
    for j in 1...7
        policy = 
            Open4::popen4("./CacheSim -s") do |pid, stdin, stdout, stderr|
                stdin.puts "#{j} 3 4096 #{i}"
                stdin.close
                puts "Line size: #{replacement[i - 1]}, Memgen #{j}: #{stdout.read.strip}"           
            end
    end
end