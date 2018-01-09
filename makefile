OBJ=laml
subdirs:=sample
.PHONY: $(subdirs) install TEST clean

$(OBJ): app src
	stack build

install:
	stack build
	stack install

TEST:
	make -C sample

.PHONY: clean
clean:
	stack clean
	$(foreach subdir,$(subdirs),make -C $(subdir) clean)