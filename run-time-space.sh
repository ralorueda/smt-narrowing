timeout 36000 maude-nra -no-prelude /pub/maude-a136/prelude.maude ./smt-narrowing.maude ./brands-chaum-space.maude ./tests/time-space/regular-execution.maude > ./results/time-space/regular-execution.txt & disown
sleep 2
timeout 36000 maude-nra -no-prelude /pub/maude-a136/prelude.maude ./smt-narrowing.maude ./brands-chaum-space.maude ./tests/time-space/mafia-no-const.maude > ./results/time-space/mafia-no-const.txt & disown
sleep 2
timeout 36000 maude-nra -no-prelude /pub/maude-a136/prelude.maude ./smt-narrowing.maude ./brands-chaum-space.maude ./tests/time-space/mafia.maude > ./results/time-space/mafia.txt & disown
sleep 2
timeout 36000 maude-nra -no-prelude /pub/maude-a136/prelude.maude ./smt-narrowing.maude ./brands-chaum-space.maude ./tests/time-space/hijacking.maude > ./results/time-space/hijacking.txt & disown
