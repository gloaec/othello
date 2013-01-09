# Makefile othello - Authors: Ghislain Loaec - Abdel Djalil Ramoul
# 
# Usage :
#
# Pour recompiler le système progressivement :
#     make
# Pour recalculer les dépendances entre les modules :
#     make depend
# Pour supprimer l'exécutable et les fichiers compilés :
#     make clean
# Pour compiler avec le compileur de code natif :
#     make opt

SRC_PATH = src/

SOURCES = othello.ml

EXEC = othello 

LIBS=$(WITHGRAPHICS)

# OCAML COMPILERS
CAMLC = ocamlc
CAMLOPT = ocamlopt
CAMLDEP = ocamldep
CAMLLEX = ocamllex
CAMLYACC = ocamlyacc


# OCAML INCLUDES
WITHGRAPHICS =graphics.cma -cclib -lgraphics -cclib -L/usr/X11R6/lib -cclib -lX11
WITHUNIX =unix.cma -cclib -lunix
WITHSTR =str.cma -cclib -lstr
WITHNUMS =nums.cma -cclib -lnums
WITHTHREADS =threads.cma -cclib -lthreads
WITHDBM =dbm.cma -cclib -lmldbm -cclib -lndbm

all:: .ocamlinit.input .ocamlinit $(EXEC)

opt : $(EXEC).opt

SRCS = $(addprefix $(SRC_PATH), $(SOURCES))
SMLIY = $(SRCS:.mly=.ml)
SMLIYL = $(SMLIY:.mll=.ml)
SMLYL = $(filter %.ml,$(SMLIYL))
OBJS = $(SMLYL:.ml=.cmo)
OPTOBJS = $(OBJS:.cmx=.cmx)

$(EXEC): $(OBJS) 
	$(CAMLC) $(CUSTOM) -o $(EXEC) $(LIBS) $(OBJS)

# $(EXEC)-opt: $(OPTOBJS)
#	$(CAMLOPT) -o $(EXEC) $(LIBS:.cma=.cmxa) $(OPTOBJS)

.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly 

.ml.cmo:
	$(CAMLC) -c $<

.mli.cmi:
	$(CAMLC) -c $<

.ml.cmx:
	$(CAMLOPT) -c $<

.mll.cmo:
	$(CAMLLEX) $<
	$(CAMLC) -c $*.ml

.mll.cmx:
	$(CAMLLEX) $<
	$(CAMLOPT) -c $*.ml

.mly.cmo:
	$(CAMLYACC) $<
	$(CAMLC) -c $*.mli
	$(CAMLC) -c $*.ml

.mly.cmx:
	$(CAMLYACC) $<
	$(CAMLOPT) -c $*.mli
	$(CAMLOPT) -c $*.ml

.mly.cmi:
	$(CAMLYACC) $<
	$(CAMLC) -c $*.mli

.mll.ml:
	$(CAMLLEX) $<

.mly.ml:
	$(CAMLYACC) $<

clean::
	rm -f $(addprefix $(SRC_PATH), *.cm[iox] *~ .*~ )
	rm -f $(EXEC)
	rm -f $(addprefix $(SRC_PATH), $(SOURCES)).opt

.ocamlinit.input: Makefile
	@echo -n '--Checking Ocaml input files: '
	@(ls $(SMLIY) $(SMLIY:.ml=.mli) 2>/dev/null || true) \
	     >  $(addprefix $(SRC_PATH),.ocamlinit.new)
	@diff $(addprefix $(SRC_PATH),.ocamlinit.new) $(addprefix $(SRC_PATH),.ocamlinit.input) 2>/dev/null 1>/dev/null && \
	    (echo 'unchanged'; rm -f $(addprefix $(SRC_PATH),.ocamlinit.new)) || \
	    (echo 'changed'; mv $(addprefix $(SRC_PATH),.ocamlinit.new) $(addprefix $(SRC_PATH),.ocamlinit.input))

ocamlinit: $(addprefix $(SRC_PATH),.ocamlinit)

.ocamlinit:: $(SMLIY) $(addprefix $(SRC_PATH),.ocamlinit.input)
	@echo '--Re-building ocamlinitencies'
	$(CAMLDEP) $(SMLIY) $(SMLIY:.ml=.mli) > $(addprefix $(SRC_PATH),.ocamlinit)

include $(addprefix $(SRC_PATH),.ocamlinit)