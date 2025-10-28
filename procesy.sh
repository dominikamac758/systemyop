#!/bin/bash
# Autor: Dominika Maciejewska
# Informatyka Medyczna, stopień I, semestr 3, 2025/2026  

another.c
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Hello, I'm another program! My PID = %d\n", getpid());
    fflush(stdout); // aby natychmiast wypisało
    getchar(); // wstrzymanie programu, czeka na Enter
    return 0;
}

exec.c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm exec program! My PID = %d\n", getpid());
    fflush(stdout);

    // podmiana procesu na another
    execl("./another", "another", NULL);

    // jeżeli exec się nie powiedzie:
    perror("exec failed");
    printf("Hello, I'm again exec program! My PID = %d\n", getpid());
    fflush(stdout);

    return 0;
}
# execl() podmienia bieżący proces, nie tworzy nowego.
# Linia po execl() wykona się tylko jeśli exec nie znajdzie pliku lub nie uda się uruchomić.

system.c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm system program! My PID = %d\n", getpid());
    fflush(stdout);

    system("./another"); // wywołanie nowego procesu przez powłokę (sh)

    printf("Hello, I'm again system program! My PID = %d\n", getpid());
    fflush(stdout);

    return 0;
}
# system() tworzy nowy proces (potomka) i uruchamia polecenie w /bin/sh -c ....
# kompilacja w terminalu
gcc another.c -o another
gcc exec.c -o exec
gcc system.c -o system

# uruchamianie i obserwacja:
./exec
./system

# To powinien wyrzucić:
Hello, I'm exec program! My PID = 12345
Hello, I'm another program! My PID = 12345
➡️ PID się nie zmienia, bo exec() nie tworzy nowego procesu — tylko podmienia bieżący.
Hello, I'm system program! My PID = 12346
Hello, I'm another program! My PID = 12347
Hello, I'm again system program! My PID = 12346
➡️ system() tworzy nowy proces potomny, który ma inny PID.

#  W nowym terminalu:
ps -o pid,ppid,cmd --forest | grep -E "system|another|sh -c"

12346 ./system
  └─12347 /bin/sh -c ./another
      └─12348 ./another
To pokazuje:

system ma potomka /bin/sh

/bin/sh ma potomka another

zmiana nazwy programu:
mv another another.tmp
./exec

to wyrzuci
Hello, I'm exec program! My PID = 23456
exec failed: No such file or directory
Hello, I'm again exec program! My PID = 23456

./system

Hello, I'm system program! My PID = 23457
sh: 1: ./another: not found
Hello, I'm again system program! My PID = 23457

Bo system() uruchomił /bin/sh -c ./another, ale powłoka nie znalazła pliku.

przywrocenie nazwy
mv another.tmp another

Czy program exec ma potomka?

Nie.

👉 exec() nie tworzy nowego procesu, tylko podmienia bieżący proces na inny program (another).
To znaczy, że PID i cały kontekst procesu zostają takie same — zmienia się tylko kod programu.

🔍 Jak to zaobserwować:

Uruchom:

./exec


W tym czasie w innym terminalu wpisz:

ps -o pid,ppid,cmd --forest | grep exec


lub

pstree -p | grep exec


📌 Zobaczysz tylko jeden proces:

1234 ./another


➡️ Proces exec został zastąpiony przez another — nie ma potomka.

🔹 2️⃣ Czy program another uruchomiony z system i exec otrzymuje nowy PID?
🔸 Dla exec:

❌ Nie — PID się nie zmienia.
Po execl() proces exec staje się another, ale z tym samym numerem PID.

🔸 Dla system:

✅ Tak — system() tworzy nowy proces potomny, a w nim powłokę /bin/sh, która uruchamia another.
Każdy z nich ma nowy PID.

🔍 Jak to sprawdzić:

Dodaj sleep(10); w another.c (żeby mieć czas na obserwację):

sleep(10);


Uruchom oba programy w osobnych momentach i sprawdź:

Dla exec:
./exec &
ps -o pid,ppid,cmd | grep another


➡️ Zobaczysz:

1234 ./another


Ten sam PID, co wcześniej w komunikacie programu exec.

Dla system:
./system &
ps -o pid,ppid,cmd --forest | grep -E "system|another|sh"


➡️ Zobaczysz coś takiego:

1235 ./system
 └─1236 /bin/sh -c ./another
     └─1237 ./another


Tu widać: another ma nowy PID, inny niż system.

🔹 3️⃣ Czy program system tworzy powłokę pośrednią (/bin/bash lub /bin/sh)?

✅ Tak.

system() zawsze działa w taki sposób:

Tworzy nowy proces potomny, który uruchamia /bin/sh -c "<polecenie>".

To oznacza, że zanim zostanie uruchomiony another, powstaje proces powłoki (np. /bin/sh).

🔍 Jak to zaobserwować:

Uruchom:

./system &


Sprawdź:

ps -o pid,ppid,cmd --forest | grep -E "system|sh -c|another"


➡️ Wynik:

1235 ./system
  └─1236 /bin/sh -c ./another
      └─1237 ./another


Widać, że pomiędzy system a another znajduje się /bin/sh.

🔹 4️⃣ W jakiej sytuacji pojawi się:
Hello, I'm again exec program! My PID = xxx


➡️ Tylko wtedy, gdy execl() się nie powiedzie, czyli gdy nie znajdzie pliku wykonywalnego lub nie ma uprawnień do jego uruchomienia.

🔍 Przykład:

Zmień nazwę pliku another:

mv another another.tmp


Uruchom:

./exec


📌 Wynik:

Hello, I'm exec program! My PID = 1238
exec failed: No such file or directory
Hello, I'm again exec program! My PID = 1238


Przywróć plik:

mv another.tmp another

🔹 5️⃣ Czy w programie exec, po wywołaniu another zmieni się PID i CMD?

PID: ❌ Nie zmieni się.

CMD: ✅ Tak — zmieni się z ./exec na ./another.

Bo exec() podmienia obraz procesu — ten sam proces, ale z nowym programem.

🔍 Jak to zaobserwować:

Uruchom w tle:

./exec &


Sprawdź proces:

ps -o pid,cmd | grep another


➡️ Zobaczysz np.:

1239 ./another


To znaczy, że proces o PID 1239 teraz działa jako another, mimo że wcześniej był exec.

🔹 6️⃣ Czy w programie system, po wywołaniu another zmieni się PID i CMD?

PID: ❌ Nie zmienia się dla programu system.
(jego proces trwa dalej i ma ten sam PID)

CMD: ❌ Nie zmienia się — nadal jest ./system.

Ale: system() uruchamia osobny proces (/bin/sh) z innym PID i innym CMD (./another).

🔍 Jak to zaobserwować:

Uruchom:

./system &


Wpisz:

ps -o pid,ppid,cmd --forest | grep -E "system|another|sh -c"


📌 Wynik:

1240 ./system
  └─1241 /bin/sh -c ./another
      └─1242 ./another


➡️ system ma PID 1240 i CMD ./system — nie zmieniło się.
➡️ another ma nowy PID (1242) i osobny wpis w tabeli procesów.

🧠 Podsumowanie (tabela)
Pytanie	Odpowiedź	Jak zaobserwować
Czy exec ma potomka?	❌ Nie	ps -o pid,ppid,cmd --forest – tylko jeden proces
Czy another ma nowy PID przy exec?	❌ Nie (ten sam PID)	komunikat PID w programie
Czy another ma nowy PID przy system?	✅ Tak	ps -o pid,ppid,cmd --forest
Czy system tworzy powłokę /bin/sh?	✅ Tak	w drzewie procesów widać /bin/sh -c
Kiedy „I'm again exec program”?	gdy execl() się nie uda	po usunięciu lub zmianie nazwy another
Czy po exec zmienia się PID/CMD?	PID ❌, CMD ✅	ps -o pid,cmd
Czy po system zmienia się PID/CMD?	PID ❌, CMD ❌	ps -o pid,cmd --forest







