require 'open4'

puts "DMC [65536 bytes]:"
for i in 2...8
    power = 2 ** i

    for j in 1...7
        line = 
            Open4::popen4("./CacheSim -s") do |pid, stdin, stdout, stderr|
                stdin.puts "#{j} 1 65536 #{power}"
                stdin.close
                puts "Line size: #{power}, Memgen #{j}: #{stdout.read.strip}"           
            end
    end
end

puts "DMC [16 bytes/line]:"
for i in 10...17
    power = 2 ** i

    for j in 1...7
        size = 
            Open4::popen4("./CacheSim -s") do |pid, stdin, stdout, stderr|
                stdin.puts "#{j} 1 #{power} 16"
                stdin.close
                puts "Cache size: #{power}, Memgen #{j}: #{stdout.read.strip}"           
            end
    end
end
    