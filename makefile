#help for make
#http://www.cnblogs.com/wang_yb/p/3990952.html
#https://segmentfault.com/a/1190000000349917
#http://blog.csdn.net/cuiyifang/article/details/7910268

#to use gprof to analyse efficience of the program:
#http://blog.chinaunix.net/uid-25194149-id-3215487.html

#to use gcov and lcov
#Notice that optimization should not be used here
#http://blog.163.com/bobile45@126/blog/static/96061992201382025729313/
#gcov -a main.cpp
#lcov --directory .   --capture --output-file dig.info 
#genhtml --output-directory . --frames --show-details dig.info 

#to use doxygen+graphviz+htmlhelp to generate document from source code:
#http://www.doxygen.nl/
#(also include good comments norm)
#http://blog.csdn.net/u010740725/article/details/51387810

#NOTICE: to speed up the make process, use make -j4
#use -j8 or higher may cause error
#http://blog.csdn.net/cscrazybing/article/details/50789482
#http://blog.163.com/liuhonggaono1@126/blog/static/10497901201210254622141/


#TODO:the dependences are not complete!

#TODO: parallel -pthread

#TODO: judge and decide using which program
#CC=$(shell which clang 2>/dev/null || which gcc)
#ccache, readline, gcov lcov
#http://blog.csdn.net/u012421852/article/details/52138960

#compile parameters

CC = ccache g++
#CC = g++

#the optimazition level of gcc/g++
#http://blog.csdn.net/hit_090420216/article/details/44900215
#NOTICE: -O2 is recommended, while -O3 is dangerous
#when developing, not use -O because it will disturb the normal 
#routine. use it for test and release.
CFLAGS = -c -Wall -g #-fprofile-arcs -ftest-coverage #-pg
EXEFLAG = -g #-fprofile-arcs -ftest-coverage #-pg
#-coverage
#CFLAGS = -c -Wall -O2
#EXEFLAG = -O2

#add -lreadline -ltermcap if using readline or objs contain readline
library = -ltermcap -lreadline -L./lib -lantlr -lgcov
def64IO = -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE

# paths

objdir = .objs/

exedir = bin/

lib_antlr = lib/libantlr.a

api_cpp = api/cpp/lib/libgstoreconnector.a

api_java = api/java/lib/GstoreJavaAPI.jar

# objects

#sstreeobj = $(objdir)Tree.o $(objdir)Storage.o $(objdir)Node.o $(objdir)IntlNode.o $(objdir)LeafNode.o $(objdir)Heap.o 
sitreeobj = $(objdir)SITree.o $(objdir)SIStorage.o $(objdir)SINode.o $(objdir)SIIntlNode.o $(objdir)SILeafNode.o $(objdir)SIHeap.o 
istreeobj = $(objdir)ISTree.o $(objdir)ISStorage.o $(objdir)ISNode.o $(objdir)ISIntlNode.o $(objdir)ISLeafNode.o $(objdir)ISHeap.o 

kvstoreobj = $(objdir)KVstore.o $(sitreeobj) $(istreeobj) #$(sstreeobj)

utilobj = $(objdir)Util.o $(objdir)Bstr.o $(objdir)Stream.o $(objdir)Triple.o $(objdir)BloomFilter.o

queryobj = $(objdir)SPARQLquery.o $(objdir)BasicQuery.o $(objdir)ResultSet.o  $(objdir)IDList.o \
		   $(objdir)Varset.o $(objdir)QueryTree.o $(objdir)ResultFilter.o $(objdir)GeneralEvaluation.o

signatureobj = $(objdir)SigEntry.o $(objdir)Signature.o

vstreeobj = $(objdir)VSTree.o $(objdir)EntryBuffer.o $(objdir)LRUCache.o $(objdir)VNode.o

stringindexobj = $(objdir)StringIndex.o

parserobj = $(objdir)RDFParser.o $(objdir)SparqlParser.o $(objdir)DBparser.o \
			$(objdir)SparqlLexer.o $(objdir)TurtleParser.o $(objdir)QueryParser.o

serverobj = $(objdir)Operation.o $(objdir)Server.o $(objdir)Client.o $(objdir)Socket.o 

databaseobj = $(objdir)Database.o $(objdir)Join.o $(objdir)Strategy.o


objfile = $(kvstoreobj) $(vstreeobj) $(stringindexobj) $(parserobj) $(serverobj) $(databaseobj) \
		  $(utilobj) $(signatureobj) $(queryobj)
	 
inc = -I./tools/libantlr3c-3.4/ -I./tools/libantlr3c-3.4/include 


#auto generate dependencies
# http://blog.csdn.net/gmpy_tiger/article/details/51849474
# http://blog.csdn.net/jeffrey0000/article/details/12421317

#gtest
TARGET = $(exedir)gbuild $(exedir)gserver $(exedir)gclient $(exedir)gquery $(exedir)gconsole $(api_java) $(exedir)gadd $(exedir)gsub

all: $(TARGET)

test_index: test_index.cpp
	$(CC) $(EXEFLAG) -o test_index test_index.cpp $(objfile) $(library)

#BETTER: use for loop to reduce the lines
#NOTICE: g++ -MM will run error if linking failed, like Database.h/../SparlParser.h/../antlr3.h

#executables begin

#NOTICE:not include g*.o in objfile due to multiple definitions of main()
$(exedir)gbuild: $(lib_antlr) $(objdir)gbuild.o $(objfile) 
	$(CC) $(EXEFLAG) -o $(exedir)gbuild $(objdir)gbuild.o $(objfile) $(library)

$(exedir)gquery: $(lib_antlr) $(objdir)gquery.o $(objfile) 
	$(CC) $(EXEFLAG) -o $(exedir)gquery $(objdir)gquery.o $(objfile) $(library)

$(exedir)gserver: $(lib_antlr) $(objdir)gserver.o $(objfile) 
	$(CC) $(EXEFLAG) -o $(exedir)gserver $(objdir)gserver.o $(objfile) $(library)

$(exedir)gclient: $(lib_antlr) $(objdir)gclient.o $(objfile) 
	$(CC) $(EXEFLAG) -o $(exedir)gclient $(objdir)gclient.o $(objfile) $(library)

$(exedir)gconsole: $(lib_antlr) $(objdir)gconsole.o $(objfile) $(api_cpp)
	$(CC) $(EXEFLAG) -o $(exedir)gconsole $(objdir)gconsole.o $(objfile) $(library) -L./api/cpp/lib -lgstoreconnector

#executables end


#objects in Main/ begin

$(objdir)gbuild.o: Main/gbuild.cpp Database/Database.h Util/Util.h $(lib_antlr)
	$(CC) $(CFLAGS) Main/gbuild.cpp $(inc) -o $(objdir)gbuild.o 
	
$(objdir)gquery.o: Main/gquery.cpp Database/Database.h Util/Util.h $(lib_antlr)
	$(CC) $(CFLAGS) Main/gquery.cpp $(inc) -o $(objdir)gquery.o  #-DREADLINE_ON
	#add -DREADLINE_ON if using readline

$(objdir)gserver.o: Main/gserver.cpp Server/Server.h Util/Util.h $(lib_antlr)
	$(CC) $(CFLAGS) Main/gserver.cpp $(inc) -o $(objdir)gserver.o

$(objdir)gclient.o: Main/gclient.cpp Server/Client.h Util/Util.h $(lib_antlr)
	$(CC) $(CFLAGS) Main/gclient.cpp $(inc) -o $(objdir)gclient.o #-DREADLINE_ON

$(objdir)gconsole.o: Main/gconsole.cpp Database/Database.h Util/Util.h api/cpp/src/GstoreConnector.h $(lib_antlr)
	$(CC) $(CFLAGS) Main/gconsole.cpp $(inc) -o $(objdir)gconsole.o -I./api/cpp/src/ #-DREADLINE_ON

#objects in Main/ end


#objects in kvstore/ begin

#objects in sstree/ begin
#$(objdir)Tree.o: KVstore/SSTree/Tree.cpp KVstore/SSTree/Tree.h $(objdir)Stream.o
	#$(CC) $(CFLAGS) KVstore/SSTree/Tree.cpp -o $(objdir)Tree.o

#$(objdir)Storage.o: KVstore/SSTree/storage/Storage.cpp KVstore/SSTree/storage/Storage.h $(objdir)Util.o
	#$(CC) $(CFLAGS) KVstore/SSTree/storage/Storage.cpp -o $(objdir)Storage.o $(def64IO)

#$(objdir)Node.o: KVstore/SSTree/node/Node.cpp KVstore/SSTree/node/Node.h $(objdir)Util.o
	#$(CC) $(CFLAGS) KVstore/SSTree/node/Node.cpp -o $(objdir)Node.o

#$(objdir)IntlNode.o: KVstore/SSTree/node/IntlNode.cpp KVstore/SSTree/node/IntlNode.h
	#$(CC) $(CFLAGS) KVstore/SSTree/node/IntlNode.cpp -o $(objdir)IntlNode.o

#$(objdir)LeafNode.o: KVstore/SSTree/node/LeafNode.cpp KVstore/SSTree/node/LeafNode.h
	#$(CC) $(CFLAGS) KVstore/SSTree/node/LeafNode.cpp -o $(objdir)LeafNode.o

#$(objdir)Heap.o: KVstore/SSTree/heap/Heap.cpp KVstore/SSTree/heap/Heap.h $(objdir)Util.o
	#$(CC) $(CFLAGS) KVstore/SSTree/heap/Heap.cpp -o $(objdir)Heap.o
#objects in sstree/ end

#objects in sitree/ begin
$(objdir)SITree.o: KVstore/SITree/SITree.cpp KVstore/SITree/SITree.h $(objdir)Stream.o
	$(CC) $(CFLAGS) KVstore/SITree/SITree.cpp -o $(objdir)SITree.o

$(objdir)SIStorage.o: KVstore/SITree/storage/SIStorage.cpp KVstore/SITree/storage/SIStorage.h $(objdir)Util.o
	$(CC) $(CFLAGS) KVstore/SITree/storage/SIStorage.cpp -o $(objdir)SIStorage.o $(def64IO)

$(objdir)SINode.o: KVstore/SITree/node/SINode.cpp KVstore/SITree/node/SINode.h $(objdir)Util.o
	$(CC) $(CFLAGS) KVstore/SITree/node/SINode.cpp -o $(objdir)SINode.o

$(objdir)SIIntlNode.o: KVstore/SITree/node/SIIntlNode.cpp KVstore/SITree/node/SIIntlNode.h
	$(CC) $(CFLAGS) KVstore/SITree/node/SIIntlNode.cpp -o $(objdir)SIIntlNode.o

$(objdir)SILeafNode.o: KVstore/SITree/node/SILeafNode.cpp KVstore/SITree/node/SILeafNode.h
	$(CC) $(CFLAGS) KVstore/SITree/node/SILeafNode.cpp -o $(objdir)SILeafNode.o

$(objdir)SIHeap.o: KVstore/SITree/heap/SIHeap.cpp KVstore/SITree/heap/SIHeap.h $(objdir)Util.o
	$(CC) $(CFLAGS) KVstore/SITree/heap/SIHeap.cpp -o $(objdir)SIHeap.o
#objects in sitree/ end

#objects in istree/ begin
$(objdir)ISTree.o: KVstore/ISTree/ISTree.cpp KVstore/ISTree/ISTree.h $(objdir)Stream.o
	$(CC) $(CFLAGS) KVstore/ISTree/ISTree.cpp -o $(objdir)ISTree.o

$(objdir)ISStorage.o: KVstore/ISTree/storage/ISStorage.cpp KVstore/ISTree/storage/ISStorage.h $(objdir)Util.o
	$(CC) $(CFLAGS) KVstore/ISTree/storage/ISStorage.cpp -o $(objdir)ISStorage.o $(def64IO)

$(objdir)ISNode.o: KVstore/ISTree/node/ISNode.cpp KVstore/ISTree/node/ISNode.h $(objdir)Util.o
	$(CC) $(CFLAGS) KVstore/ISTree/node/ISNode.cpp -o $(objdir)ISNode.o

$(objdir)ISIntlNode.o: KVstore/ISTree/node/ISIntlNode.cpp KVstore/ISTree/node/ISIntlNode.h
	$(CC) $(CFLAGS) KVstore/ISTree/node/ISIntlNode.cpp -o $(objdir)ISIntlNode.o

$(objdir)ISLeafNode.o: KVstore/ISTree/node/ISLeafNode.cpp KVstore/ISTree/node/ISLeafNode.h
	$(CC) $(CFLAGS) KVstore/ISTree/node/ISLeafNode.cpp -o $(objdir)ISLeafNode.o

$(objdir)ISHeap.o: KVstore/ISTree/heap/ISHeap.cpp KVstore/ISTree/heap/ISHeap.h $(objdir)Util.o
	$(CC) $(CFLAGS) KVstore/ISTree/heap/ISHeap.cpp -o $(objdir)ISHeap.o
#objects in istree/ end

$(objdir)KVstore.o: KVstore/KVstore.cpp KVstore/KVstore.h KVstore/Tree.h 
	$(CC) $(CFLAGS) KVstore/KVstore.cpp $(inc) -o $(objdir)KVstore.o

#objects in kvstore/ end


#objects in Database/ begin

$(objdir)Database.o: Database/Database.cpp Database/Database.h \
	$(objdir)IDList.o $(objdir)ResultSet.o $(objdir)SPARQLquery.o \
	$(objdir)BasicQuery.o $(objdir)Triple.o $(objdir)SigEntry.o \
	$(objdir)KVstore.o $(objdir)VSTree.o $(objdir)DBparser.o \
	$(objdir)Util.o $(objdir)RDFParser.o $(objdir)Join.o $(objdir)GeneralEvaluation.o $(objdir)StringIndex.o
	$(CC) $(CFLAGS) Database/Database.cpp $(inc) -o $(objdir)Database.o

$(objdir)Join.o: Database/Join.cpp Database/Join.h $(objdir)IDList.o $(objdir)BasicQuery.o $(objdir)Util.o\
	$(objdir)KVstore.o $(objdir)Util.o $(objdir)SPARQLquery.o
	$(CC) $(CFLAGS) Database/Join.cpp $(inc) -o $(objdir)Join.o

$(objdir)Strategy.o: Database/Strategy.cpp Database/Strategy.h $(objdir)SPARQLquery.o $(objdir)BasicQuery.o \
	$(objdir)Triple.o $(objdir)IDList.o $(objdir)KVstore.o $(objdir)VSTree.o $(objdir)Util.o $(objdir)Join.o $(objdir)ResultFilter.o
	$(CC) $(CFLAGS) Database/Strategy.cpp $(inc) -o $(objdir)Strategy.o

#objects in Database/ end


#objects in Query/ begin

$(objdir)IDList.o: Query/IDList.cpp Query/IDList.h
	$(CC) $(CFLAGS) Query/IDList.cpp $(inc) -o $(objdir)IDList.o

$(objdir)SPARQLquery.o: Query/SPARQLquery.cpp Query/SPARQLquery.h $(objdir)BasicQuery.o
	$(CC) $(CFLAGS) Query/SPARQLquery.cpp $(inc) -o $(objdir)SPARQLquery.o

$(objdir)BasicQuery.o: Query/BasicQuery.cpp Query/BasicQuery.h $(objdir)Signature.o
	$(CC) $(CFLAGS) Query/BasicQuery.cpp $(inc) -o $(objdir)BasicQuery.o

$(objdir)ResultSet.o: Query/ResultSet.cpp Query/ResultSet.h $(objdir)Stream.o
	$(CC) $(CFLAGS) Query/ResultSet.cpp $(inc) -o $(objdir)ResultSet.o

$(objdir)Varset.o: Query/Varset.cpp Query/Varset.h
	$(CC) $(CFLAGS) Query/Varset.cpp $(inc) -o $(objdir)Varset.o

$(objdir)QueryTree.o: Query/QueryTree.cpp Query/QueryTree.h $(objdir)Varset.o
	$(CC) $(CFLAGS) Query/QueryTree.cpp $(inc) -o $(objdir)QueryTree.o

$(objdir)ResultFilter.o: Query/ResultFilter.cpp Query/ResultFilter.h $(objdir)BasicQuery.o $(objdir)SPARQLquery.o $(objdir)Util.o
	$(CC) $(CFLAGS) Query/ResultFilter.cpp $(inc) -o $(objdir)ResultFilter.o

#no more using $(objdir)Database.o
$(objdir)GeneralEvaluation.o: Query/GeneralEvaluation.cpp Query/GeneralEvaluation.h $(objdir)QueryParser.o $(objdir)QueryTree.o \
	$(objdir)SPARQLquery.o $(objdir)Varset.o $(objdir)KVstore.o $(objdir)ResultFilter.o $(objdir)Strategy.o $(objdir)StringIndex.o 
	$(CC) $(CFLAGS) Query/GeneralEvaluation.cpp $(inc) -o $(objdir)GeneralEvaluation.o

#objects in Query/ end


#objects in Signature/ begin

$(objdir)SigEntry.o: Signature/SigEntry.cpp Signature/SigEntry.h $(objdir)Signature.o
	$(CC) $(CFLAGS) Signature/SigEntry.cpp $(inc) -o $(objdir)SigEntry.o

$(objdir)Signature.o: Signature/Signature.cpp Signature/Signature.h
	$(CC) $(CFLAGS) Signature/Signature.cpp $(inc) -o $(objdir)Signature.o

#objects in Signature/ end


#objects in Util/ begin

$(objdir)Util.o:  Util/Util.cpp Util/Util.h
	$(CC) $(CFLAGS) Util/Util.cpp -o $(objdir)Util.o

$(objdir)Stream.o:  Util/Stream.cpp Util/Stream.h $(objdir)Util.o $(objdir)Bstr.o
	$(CC) $(CFLAGS) Util/Stream.cpp -o $(objdir)Stream.o $(def64IO)

$(objdir)Bstr.o: Util/Bstr.cpp Util/Bstr.h $(objdir)Util.o
	$(CC) $(CFLAGS)  Util/Bstr.cpp -o $(objdir)Bstr.o

$(objdir)Triple.o: Util/Triple.cpp Util/Triple.h $(objdir)Util.o
	$(CC) $(CFLAGS) Util/Triple.cpp -o $(objdir)Triple.o

$(objdir)BloomFilter.o:  Util/BloomFilter.cpp Util/BloomFilter.h $(objdir)Util.o
	$(CC) $(CFLAGS) Util/BloomFilter.cpp -o $(objdir)BloomFilter.o 

#objects in util/ end


#objects in VSTree/ begin

$(objdir)VSTree.o: VSTree/VSTree.cpp VSTree/VSTree.h $(objdir)EntryBuffer.o $(objdir)LRUCache.o $(objdir)VNode.o
	$(CC) $(CFLAGS) VSTree/VSTree.cpp $(inc) -o $(objdir)VSTree.o $(def64IO)

$(objdir)EntryBuffer.o: VSTree/EntryBuffer.cpp VSTree/EntryBuffer.h Signature/SigEntry.h
	$(CC) $(CFLAGS) VSTree/EntryBuffer.cpp $(inc) -o $(objdir)EntryBuffer.o $(def64IO)

$(objdir)LRUCache.o: VSTree/LRUCache.cpp  VSTree/LRUCache.h VSTree/VNode.h
	$(CC) $(CFLAGS) VSTree/LRUCache.cpp $(inc) -o $(objdir)LRUCache.o $(def64IO)

$(objdir)VNode.o: VSTree/VNode.cpp VSTree/VNode.h
	$(CC) $(CFLAGS) VSTree/VNode.cpp $(inc) -o $(objdir)VNode.o $(def64IO)

#objects in VSTree/ end


#objects in StringIndex/ begin
$(objdir)StringIndex.o: StringIndex/StringIndex.cpp StringIndex/StringIndex.h $(objdir)KVstore.o $(objdir)Util.o

	$(CC) $(CFLAGS) StringIndex/StringIndex.cpp $(inc) -o $(objdir)StringIndex.o
#objects in StringIndex/ end


#objects in Parser/ begin

$(objdir)DBparser.o: Parser/DBparser.cpp Parser/DBparser.h $(objdir)SparqlParser.o $(objdir)SparqlLexer.o $(objdir)Triple.o
	$(CC) $(CFLAGS) Parser/DBparser.cpp $(inc) -o $(objdir)DBparser.o

$(objdir)SparqlParser.o: Parser/SparqlParser.c Parser/SparqlParser.h
	gcc  $(CFLAGS) Parser/SparqlParser.c $(inc) -o $(objdir)SparqlParser.o

$(objdir)SparqlLexer.o: Parser/SparqlLexer.c Parser/SparqlLexer.h
	gcc  $(CFLAGS) Parser/SparqlLexer.c $(inc) -o $(objdir)SparqlLexer.o

$(objdir)TurtleParser.o: Parser/TurtleParser.cpp Parser/TurtleParser.h Parser/Type.h
	gcc  $(CFLAGS) Parser/TurtleParser.cpp $(inc) -o $(objdir)TurtleParser.o

$(objdir)RDFParser.o: Parser/RDFParser.cpp Parser/RDFParser.h $(objdir)TurtleParser.o $(objdir)Triple.o
	gcc  $(CFLAGS) Parser/RDFParser.cpp $(inc) -o $(objdir)RDFParser.o

$(objdir)QueryParser.o: Parser/QueryParser.cpp Parser/QueryParser.h $(objdir)SparqlParser.o $(objdir)SparqlLexer.o $(objdir)QueryTree.o
	$(CC) $(CFLAGS) Parser/QueryParser.cpp $(inc) -o $(objdir)QueryParser.o

#objects in Parser/ end


#objects in Server/ begin

$(objdir)Operation.o: Server/Operation.cpp Server/Operation.h
	$(CC) $(CFLAGS) Server/Operation.cpp $(inc) -o $(objdir)Operation.o

$(objdir)Socket.o: Server/Socket.cpp Server/Socket.h
	$(CC) $(CFLAGS) Server/Socket.cpp $(inc) -o $(objdir)Socket.o

$(objdir)Server.o: Server/Server.cpp Server/Server.h $(objdir)Socket.o $(objdir)Database.o $(objdir)Operation.o
	$(CC) $(CFLAGS) Server/Server.cpp $(inc) -o $(objdir)Server.o

$(objdir)Client.o: Server/Client.cpp Server/Client.h $(objdir)Socket.o $(objdir)Util.o
	$(CC) $(CFLAGS) Server/Client.cpp $(inc) -o $(objdir)Client.o

#objects in Server/ end


$(lib_antlr):
	rm -rf tools/libantlr3c-3.4/
	cd tools; tar -xzvf libantlr3c-3.4.tar.gz;
	cd tools; cd libantlr3c-3.4/; ./configure -enable-64bit; make;
	rm -rf lib/libantlr.a
	ar -crv lib/libantlr.a tools/libantlr3c-3.4/*.o 
	#NOTICE: update the sparql.tar.gz if Sparql* in Parser are changed manually
	rm -rf Parser/Sparql*
	cd tools; tar -xzvf sparql.tar.gz; mv Sparql* ../Parser/;

$(api_cpp): $(objdir)Socket.o
	$(MAKE) -C api/cpp/src 

$(api_java):
	$(MAKE) -C api/java/src

.PHONY: clean dist tarball api_example gtest sumlines

clean:
	rm -rf lib/libantlr.a
	$(MAKE) -C api/cpp/src clean
	$(MAKE) -C api/cpp/example clean
	$(MAKE) -C api/java/src clean
	$(MAKE) -C api/java/example clean
	#$(MAKE) -C KVstore clean
	rm -rf $(exedir)g* $(objdir)*.o $(exedir).gserver*
	#rm -rf .project .cproject .settings   just for eclipse
	#rm -rf cscope* just for vim
	rm -rf logs/*.log

dist: clean
	rm -rf *.nt *.n3 .debug/*.log .tmp/*.dat *.txt *.db
	rm -rf tools/libantlr3c-3.4 lib/libantlr.a Parser/Sparql*
	#rm -rf Parser/SparqlLexer* Parser/SparlParser.cpp
	rm -rf cscope* .cproject .settings tags
	rm -rf *.info

tarball:
	tar -czvf devGstore.tar.gz api bin lib tools .debug .tmp .objs test docs data makefile \
		Main Database KVstore Util Query Signature VSTree Parser Server README.md init.conf NOTES.md StringIndex Coverage

APIexample: $(api_cpp) $(api_java)
	$(MAKE) -C api/cpp/example
	$(MAKE) -C api/java/example

gtest: $(objdir)gtest.o $(objfile)
	$(CC) $(EXEFLAG) -o $(exedir)gtest $(objdir)gtest.o $(objfile) lib/libantlr.a $(library)

$(objdir)gtest.o: test/gtest.cpp
	$(CC) $(CFLAGS) test/gtest.cpp $(inc) -o $(objdir)gtest.o
	
$(exedir)gadd: $(objdir)gadd.o $(objfile)
	$(CC) $(EXEFLAG) -o $(exedir)gadd $(objdir)gadd.o $(objfile) lib/libantlr.a $(library)

$(objdir)gadd.o: Main/gadd.cpp
	$(CC) $(CFLAGS) Main/gadd.cpp $(inc) -o $(objdir)gadd.o

$(exedir)gsub: $(objdir)gsub.o $(objfile)
	$(CC) $(EXEFLAG) -o $(exedir)gsub $(objdir)gsub.o $(objfile) lib/libantlr.a $(library)

$(objdir)gsub.o: Main/gsub.cpp
	$(CC) $(CFLAGS) Main/gsub.cpp $(inc) -o $(objdir)gsub.o

sumlines:
	bash test/sumline.sh

tag:
	ctags -R

idx:
	find `realpath .` -name "*.h" -o -name "*.c" -o -name "*.cpp" > cscope.files
	cscope -bkq #-i cscope.files

cover:
	bash test/cover.sh

fulltest:
	#NOTICE:compile gstore with -O2 only
	#setup new virtuoso and configure it
	cp test/full_test.sh ~
	cd ~
	bash full_test.sh

