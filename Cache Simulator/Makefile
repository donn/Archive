Sources := $(wildcard Sources/*.cpp)
Objects := $(addprefix Build/,$(notdir $(Sources:.cpp=.o)))
Compiler := clang++

#Building
Build/%.o: Sources/%.cpp
	@mkdir -p Build/
	@$(Compiler) -c $(Flags) -std=c++11 $^ -o  $@

CacheSim: $(Objects)
	@$(Compiler) $^ -o $@
	@echo "Build successful."

clean:
	@rm -rf Build/