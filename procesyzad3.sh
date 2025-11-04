#!/bin/bash
# Autor: Dominika Maciejewska
# Informatyka Medyczna, stopień I, semestr 3, 2025/2026 

nano another.c

#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Hello, I'm another program! My PID = %d\n", getpid());
    fflush(stdout); 
    getchar();      // czeka na ENTER
    return 0;
}

nano exec.c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm exec program! My PID = %d\n", getpid());
    fflush(stdout);
    execl("./another", "another", NULL);

    perror("exec error");
    printf("Hello, I'm again exec program! My PID = %d\n", getpid());
    fflush(stdout);
    return 0;
}

nano system.c

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm system program! My PID = %d\n", getpid());
    fflush(stdout);
    system("./another");

    printf("Hello, I'm again system program! My PID = %d\n", getpid());
    fflush(stdout);
    return 0;
}


kompilacja:
gcc -o another another.c
gcc -o exec exec.c
gcc -o system system.c

ls -l another exec system

./another
z innego terminala można sprawdzić
ps -p 12345 -o pid,ppid,cmd

./exec

to nie działa
ps -o pid,ppid,cmd --forest | grep -E "exec|another"
12345 ./exec
  └─(podmieniony na) another

./system

to tez nie działa
ps -o pid,ppid,cmd --forest | grep -E "system|another|sh -c"
12347 ./system
  └─12348 sh -c ./another
      └─12349 ./another

mv another another.tmp
./exec
./system
mv another.tmp another

w innym terminalu
ps -o pid,ppid,cmd --forest | grep -E "system|another|sh -c" -n
12360 ./system
  └─12361 sh -c ./another
      └─12362 ./another
ale to tez nie działa

#Czy program ‘exec’ ma potomka ? Jak to zaobserwować ?
Funkcja exec() nie tworzy nowego procesu — ona podmienia kod aktualnego procesu na inny program.
PID pozostaje ten sam, więc nie ma procesu-dziecka. 
Uruchom ./exec i w drugim terminalu wpisz:
pstree -p | grep exec
Zobaczysz tylko jeden proces (z jednym PID-em), bez żadnych dzieci.
Natomiast jego nazwa (CMD) zmieni się z exec na another.
#Czy program ‘another’ uruchomiony z ‘system’ i ‘exec’ otrzymuje nowy PID ? Jak to zaobserwować ?
W razie potrzeby dodaj getchar()/sleep() w odpowiednich miejscach.
exec() → ten sam proces, ten sam PID, tylko kod podmieniony
→ więc another ma ten sam PID co exec
system() → powłoka sh uruchamia nowy proces
→ więc another ma inny (nowy) PID
uruchomić exec i system
#Czy program ‘system’ tworzy powłokę pośrednią (/bin/bash) ? Jak to zaobserwować ?
tak,Uruchom ./system, a w drugim terminalu:
ps -o pid,ppid,cmd --forest | grep -E "system|sh|another"
Zobaczysz coś takiego:
42010 ./system
  └─42011 sh -c ./another
      └─42012 ./another

#W jakiej sytuacji pojawi się ‘Hello, I’m again exec program! My PID = xxx’ ?
To zdanie pojawi się tylko wtedy, gdy exec() się nie powiedzie.
Dlaczego:
Jeśli execl() działa poprawnie, kod programu exec zostaje zastąpiony → 
więc dalsze instrukcje (czyli ten printf) nigdy się nie wykonają.

#Czy w programie ‘exec’, po wywołaniu ‘another’ zmieni się PID i CMD ? Odpowiedź uzasadnij odpowiednim poleceniem.
PID: Nie zmieni się
CMD (nazwa programu): Tak, zmieni się
Wyjaśnienie:
exec() podmienia obraz procesu w pamięci — to ten sam PID, ale nowa komenda (CMD) i nowy kod programu.
Jak to zobaczyć:
Uruchom:
./exec &
ps -p $(pgrep -f exec) -o pid,ppid,cmd
Zaraz po podmianie zobaczysz, że PID jest ten sam, ale komenda zmieniła się na another.

#Czy w programie ‘system’, po wywołaniu ‘another’ zmieni się PID i CMD ? Odpowiedź uzasadnij odpowiednim poleceniem.
PID:  Tak, inny dla another
CMD: Oczywiście inny — to osobny proces
Wyjaśnienie:
system() tworzy nowy proces (sh), który tworzy następny (another), więc każdy z nich ma własny PID i CMD.
Jak to zobaczyć:
Uruchom:

./system &
ps -o pid,ppid,cmd --forest | grep -E "system|sh|another"


Zobaczysz np.:

42010 ./system
  └─42011 sh -c ./another
      └─42012 ./another


➡️ system (42010) → sh (42011) → another (42012)
Każdy ma inny PID i własny CMD.
