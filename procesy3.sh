1. Nie ma potomka:
ps -o pid,ppid,cmd --forest
zastępuje bieżący proces nowym programem — nie tworzy procesu potomnego.

2.exec() — NIE, PID pozostaje ten sam.
system() — TAK, nowy proces powłoki tworzy nowy PID dla another.
ps -o pid,ppid,cmd | grep -E "exec|another"
ps -o pid,ppid,cmd --forest | grep -E "system|sh -c|another"


3. Tak.
ps -o pid,ppid,cmd --forest
system
 └─ sh -c ./another
      └─ another

4. Tylko wtedy, gdy exec() się nie uda — np.:
brak pliku another,
brak uprawnień wykonania,
błędna ścieżka.

5. PID – nie, CMD – tak, zmieni się na another
ps -o pid,cmd | grep <PID>

6. Nie. Proces system zachowuje swój PID i CMD.
To powłoka i another dostają nowe PID-y.

ps -o pid,ppid,cmd --forest



