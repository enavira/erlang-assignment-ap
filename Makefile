compile:
	erlc -pa . -o bin/ src/*.erl 

node1:
	erl -pa bin/ -sname foo -setcookie cake -eval 'dc:start().'

node2:
	erl -pa bin/ -sname bar -setcookie cake -eval 'ab:start(goteborg, newyork).'

clean: 
	(cd bin && rm -rf *.beam)