# SMT narrowing
This implementation is related to a paper: https://link.springer.com/chapter/10.1007/978-3-031-12441-9_3.

Nowadays, formal cryptographic protocol analysis relies on symbolic techniques such as narrowing and equational unification, e.g. Maude-NPA, Tamarin or AKISS crypto tools. In previous works, we developed a new narrowing strategy, called canonical narrowing, which manages to reduce the state explosion problem by introducing irreducibility constraints. In this paper, we extend canonical narrowing to handle conditional rules with SMT constraints. We demonstrate the viability of this method with the Brands and Chaum protocol using time and location information described as SMT constraints on the real numbers.


## Requisites
In order to run the files, Maude version 3.2.1 is required, which can be found in http://maude.cs.illinois.edu/w/index.php/The_Maude_System.

## Repository structure
###### root folder
At the root of the project are the specification and execution files for the examples used in the paper. In addition, there is the file that defines the standard narrowing and canonical narrowing algorithms with SMT constraints.

###### tests
This folder contains the execution calls of the examples used.

###### results
This folder contains the outputs of the experiments of this work after running them.

## Algorithm execution
The first step in running the algorithms is to run Maude. Once this is done, it is necessary to load the modules that are in the files in the root of the project. To do this, the "load [file]" command is used. Note that "native-narrowing.maude" is only neccesary if we want to compare with the original narrowing from Maude. It is also necessary to load the file containing the rewrite theory to be used. In our case, these files are located in "experimental-modules", but the user can specify any other. Finally, the call to the algorithm must be executed as follows:

```
reduce in NARROWING :
        narrowing(upModule(<module_name>, false),
              <initial_term>,
              =>*,
              <target_term>,
              <narrowing_type>, <variant_option_set>, <irreducibility_constrainst>, <smt_constrainst>
              <variable_qid>, <maximum_depth>, <maximum_solutions>) .
``` 

Where the parameters that are between "<" and ">" are at the user's choice. The options are as follows:
* module_name: Name of the module that defines the rewrite theory to use.
* initial_term: Initial term for narrowing.
* target_term: Target term for narrowing.
* narrowing_type: It can be "standard" or "canonical". In the second case, irreducibility constraints will be used to eliminate unnecessary narrowing steps. If we also add "smt" at the beginning of any of the two, we will indicate that a conditional module with SMT restrictions is used.
* variant_option_set: It can be "filter" or "none" (review Maude's original command). The first case only works correctly for standard narrowing.
* irreducibility_constrainst: Takes the value of the list of initial irreducibility constraints. It can be empty. In fact, if standard narrowing is used, it will be ignored even if it is given another value.
* smt_constrainst: 
* variable_qid: This parameter is important if an identifier is used for variables in the start and/or target terms that is '@, '#, or '%. It must be indicated in it which of them is used. In case none are used, choose any of them for this parameter.
* maximum_depth: Maximum depth that you want to deploy the search tree for narrowing.
* maximum_solutions: Maximum solutions that you want the narrowing algorithm to find.

### Running example
Now we give an example of use if, for example, we want to execute a reachability problem using the Brands and Chaum protocol (no space version, since that one uses Maude NRA). The first thing, after executing Maude, is to load the necessary modules for it. Let's imagine that we are at the root of this project:

```
load smt-narrowing.maude
load brands-chaum.maude
```

Now we can run a problem. For example, we will use the reachability problem modelling a hijacking attack:

```
mod TEST-PROTOCOL is
  protecting NARROWING .
  protecting BRANDS-CHAUM .
endm

reduce in TEST-PROTOCOL :
        narrowing(upModule('BRANDS-CHAUM, false),
              --- INITIAL TERM
              upTerm(
              {(
              --- Intruder
              [nilEe, 
                -((n(a, ra1) * n(b, rb1))                               @ b : t3:Real -> (a : t4:Real) # i : t4':Real), 
                        {t4':Real === t3:Real + dbi:Real and dbi:Real >= 0/1}, 
                -(n(a, ra1)                                             @ a : t2:Real -> (b : t3:Real) # i : t3':Real), 
                        {t3':Real === t2:Real + dai:Real and dai:Real >= 0/1}, 
                +(sign(i, (n(a, ra1) * n(b, rb1)) ; n(a, ra1))          @ i : t6:Real -> a : t7:Real) 
              | nileE]  
              & 
              --- Alice, verifier
              [nilEe, 
                -(CommitB:NTMsg                                         @ b : t1:Real -> (a : t2:Real) # i : t2':Real), 
                        {t2:Real === t1:Real + dab:Real and dab:Real > 0/1}, 
                +(n(a, ra1)                                             @ a : t2:Real -> (b : t3:Real) # i : t3':Real), 
                -((n(a, ra1) * NB:Nonce)                                @ b : t3:Real -> (a : t4:Real) # i : t4':Real), 
                        {t4:Real === t3:Real + dab:Real and dab:Real > 0/1}, 
                        {(t4:Real - t2:Real) <= (2/1 * d:Real) and d:Real > 0/1}, 
                -(SB:Secret                                             @ b : t3:Real -> (a : t5:Real) # i : t5':Real), 
                        {t5:Real === t3:Real + dab:Real and dab:Real > 0/1}, 
                -(sign(i, (n(a, ra1) * NB:Nonce) ; n(a, ra1))           @ i : t6:Real -> a : t7:Real), 
                        {t7:Real === t6:Real + dai:Real and dai:Real > 0/1} 
              | nileE]  
              & 
              --- Bob, prover
              [nilEe, 
                +(commit(n(b, rb1), s(b, rb2))                          @ b : t1:Real -> (a : t2:Real) # i : t2':Real), 
                -(NA:Nonce                                              @ a : t2:Real -> (b : t3:Real) # i : t3':Real), 
                        {t3:Real === t2:Real + dab:Real and dab:Real > 0/1}, 
                +((NA:Nonce * n(b, rb1))                                @ b : t3:Real -> (a : t4:Real) # i : t4':Real), 
                +(s(b, rb2)                                             @ b : t3:Real -> (a : t5:Real) # i : t5':Real) 
              | nileE]) 
              --- Intruder Knowledge
              { 
                inI(commit(n(b, rb1), s(b, rb2))                         @ b : t1:Real -> (a : t2:Real) # i : t2':Real),
                inI(n(a, ra1)                                            @ a : t2:Real -> (b : t3:Real) # i : t3':Real),
                inI((n(a, ra1) * n(b, rb1))                              @ b : t3:Real -> (a : t4:Real) # i : t4':Real),
                inI(s(b, rb2)                                            @ b : t3:Real -> (a : t5:Real) # i : t5':Real),
                inI(sign(i, (n(a, ra1) * n(b, rb1)) ; n(a, ra1))         @ i : t6:Real -> a : t7:Real) 
              } 
              }), 
              =>*,
              --- FINAL TERM
              upTerm(
              {(
              --- Intruder
              [nilEe | 
                -((n(a, ra1) * n(b, rb1))                               @ b : t3:Real -> (a : t4:Real) # i : t4':Real), 
                        {t4':Real === t3:Real + dbi:Real and dbi:Real >= 0/1}, 
                -(n(a, ra1)                                             @ a : t2:Real -> (b : t3:Real) # i : t3':Real), 
                        {t3':Real === t2:Real + dai:Real and dai:Real >= 0/1}, 
                +(sign(i, (n(a, ra1) * n(b, rb1)) ; n(a, ra1))          @ i : t6:Real -> a : t7:Real), 
              nileE]  
              & 
              --- Alice, verifier
              [nilEe | 
                -(CommitB:NTMsg                                         @ b : t1:Real -> (a : t2:Real) # i : t2':Real), 
                        {t2:Real === t1:Real + dab:Real and dab:Real > 0/1}, 
                +(n(a, ra1)                                             @ a : t2:Real -> (b : t3:Real) # i : t3':Real), 
                -((n(a, ra1) * NB:Nonce)                                @ b : t3:Real -> (a : t4:Real) # i : t4':Real), 
                        {t4:Real === t3:Real + dab:Real and dab:Real > 0/1}, 
                        {(t4:Real - t2:Real) <= (2/1 * d:Real) and d:Real > 0/1}, 
                -(SB:Secret                                             @ b : t3:Real -> (a : t5:Real) # i : t5':Real), 
                        {t5:Real === t3:Real + dab:Real and dab:Real > 0/1}, 
                -(sign(i, (n(a, ra1) * NB:Nonce) ; n(a, ra1))          @ i : t6:Real -> a : t7:Real), 
                        {t7:Real === t6:Real + dai:Real and dai:Real > 0/1}, 
              nileE]  
              & 
              --- Bob, prover
              [nilEe | 
                +(commit(n(b, rb1), s(b, rb2))                          @ b : t1:Real -> (a : t2:Real) # i : t2':Real), 
                -(NA:Nonce                                              @ a : t2:Real -> (b : t3:Real) # i : t3':Real), 
                        {t3:Real === t2:Real + dab:Real and dab:Real > 0/1}, 
                +((NA:Nonce * n(b, rb1))                                @ b : t3:Real -> (a : t4:Real) # i : t4':Real), 
                +(s(b, rb2)                                             @ b : t3:Real -> (a : t5:Real) # i : t5':Real), 
              nileE]) 
              --- Intruder Knowledge
              { 
                nI(commit(n(b, rb1), s(b, rb2))                         @ b : t1:Real -> (a : t2:Real) # i : t2':Real),
                nI(n(a, ra1)                                            @ a : t2:Real -> (b : t3:Real) # i : t3':Real),
                nI((n(a, ra1) * n(b, rb1))                              @ b : t3:Real -> (a : t4:Real) # i : t4':Real),
                nI(s(b, rb2)                                            @ b : t3:Real -> (a : t5:Real) # i : t5':Real),
                nI(sign(i, (n(a, ra1) * n(b, rb1)) ; n(a, ra1))         @ i : t6:Real -> a : t7:Real) 
              } 
              }), 
              smt standard, none, empty, 'true.Boolean, '@, unbounded, unbounded) .            
```

That would be the call for the narrowing standard. In case we wanted to use canonical, we would only have to replace the word "standard" with "canonical" in the corresponding parameter.
