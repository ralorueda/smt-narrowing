timeout 36000 maude ./smt-narrowing.maude ./brands-chaum.maude ./tests/time/regular-execution.maude > ./results/time/regular-execution.txt & disown
sleep 2
timeout 36000 maude ./smt-narrowing.maude ./brands-chaum.maude ./tests/time/mafia-no-const.maude > ./results/time/mafia-no-const.txt & disown
sleep 2
timeout 36000 maude ./smt-narrowing.maude ./brands-chaum.maude ./tests/time/mafia.maude > ./results/time/mafia.txt & disown
sleep 2
timeout 36000 maude ./smt-narrowing.maude ./brands-chaum.maude ./tests/time/hijacking.maude > ./results/time/hijacking.txt & disown