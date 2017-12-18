OBJ=laml
EXE=laml-exe
subdirs:=sample
.PHONY: $(subdirs)

$(OBJ): app src
	stack build

.PHONY: TEST
TEST:
	make -C sample

.PHONY: clean
clean:
	stack clean
	$(foreach subdir,$(subdirs),make -C $(subdir) clean)