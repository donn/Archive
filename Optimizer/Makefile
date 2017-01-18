Sources := $(wildcard Sources/*.cpp)
Objects := $(addprefix Build/,$(notdir $(Sources:.cpp=.o)))
Name = Optimizer

all: RemoveMain
all: __maketemp

test: Flags = -DTest
test: Name = OptimizerTest
test: RemoveMain
test: __maketemp

#Building
Build/%.o: Sources/%.cpp
	@mkdir -p Build/
	@clang++ -c $(Flags) -std=c++11 $^ -o  $@

__maketemp: $(Objects)
	@clang++ $^ -o $@
	@cp __maketemp $(Name)
	@chmod +x $(Name)
	@rm -rf __maketemp
	@echo "Build successful."

RemoveMain:
	@rm -f Build/main.o

clean:
	@rm -rf Build/
	@rm -f Optimizer
	@rm -f OptimizerTest