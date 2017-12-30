require 'open4'

puts "SAC [65536 bytes, 32 byte/line, RAND replacement]:"
for i in 1...5
    power = 2 ** i

    for j in 1...7
        way = 
            Open4::popen4("./CacheSim -s") do |pid, stdin, stdout, stderr|
                stdin.puts "#{j} 2 #{power}"
                stdin.close
                puts "Ways: #{power}, Memgen #{j}: #{stdout.read.strip}"           
            end
    end
end
