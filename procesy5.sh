kod w c:
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/prctl.h>
#include <string.h>
#include <sys/wait.h>

void read_comm(char *buf, size_t s) {
    FILE *f = fopen("/proc/self/comm", "r");
    fgets(buf, s, f);
    buf[strcspn(buf, "\n")] = 0;
    fclose(f);
}

void read_cmdline(char *buf, size_t s) {
    FILE *f = fopen("/proc/self/cmdline", "r");
    size_t n = fread(buf, 1, s - 1, f);
    buf[n] = 0;
    for (size_t i = 0; i < n; i++)
        if (buf[i] == 0) buf[i] = ' ';
    fclose(f);
}

void print_info(const char *tag) {
    char comm[64], cmdline[256];
    read_comm(comm, sizeof(comm));
    read_cmdline(cmdline, sizeof(cmdline));

    printf("%s: PID=%d PPID=%d NAME=%s CMD=%s\n",
           tag, getpid(), getppid(), comm, cmdline);
    printf("Naciśnij ENTER aby kontynuować...\n");
    getchar();
}

int main() {
    prctl(PR_SET_NAME, "Main");
    print_info("Start");

    pid_t child = fork();

    if (child > 0) {
        // Rodzic --------------+
        prctl(PR_SET_NAME, "Rodzic");
        print_info("Rodzic");

        // Wujek (brat Rodzica)
        pid_t w = fork();
        if (w == 0) {
            prctl(PR_SET_NAME, "Wujek");
            print_info("Wujek");
            exit(0);
        }

        // Dziadek (po powstaniu Wujka)
        prctl(PR_SET_NAME, "Dziadek");
        print_info("Dziadek");
        wait(NULL); // na Wujka
        wait(NULL); // na Rodzica
    }

    else if (child == 0) {
        // Dziecko -------------+
        prctl(PR_SET_NAME, "Dziecko");
        print_info("Dziecko");

        // Wnuk
        pid_t wnuk = fork();
        if (wnuk == 0) {
            prctl(PR_SET_NAME, "Dziecko");
            print_info("Wnuk (Dziecko)");
            exit(0);
        }

        // Rodzic (po powstaniu Wnuka)
        prctl(PR_SET_NAME, "Rodzic");
        print_info("Rodzic");

        // Brat (brat Dziecka)
        pid_t brat = fork();
        if (brat == 0) {
            prctl(PR_SET_NAME, "Brat");
            print_info("Brat");
            exit(0);
        }

        wait(NULL); // Wnuk
        wait(NULL); // Brat
    }

    return 0;
}

Instrukcja krok-po-kroku w bash / dwóch konsolach

Załóżmy, że masz dwa terminale: Terminal A (tam skompilujesz i uruchomisz program) i Terminal B (tam będziesz obserwował drzewo procesów / ps / pstree / htop).

1) Kompilacja w Terminal A
gcc -Wall -o pokolenia pokolenia.c

2) Uruchom program w Terminal A
./pokolenia


Po uruchomieniu program wypisze informacje pierwszego wywołania print_info_and_wait(...) i poprosi: (Główny - przed forkiem) Naciśnij ENTER, aby kontynuować.... Na razie NIE naciskaj ENTER — przejdź do Terminal B, aby obserwować proces.

3) W Terminal B — sprawdź proces (tu jeszcze będzie tylko proces pokolenia)

Najpierw znajdź PID procesu:

pgrep -l pokolenia


To wypisze np.:

12345 pokolenia


Zamiast 12345 użyj faktycznego PID.

Pokaż PID, PPID i nazwę:

ps -o pid,ppid,comm -p 12345


Pokaż pełne polecenie dla tego PID:

ps -o pid,ppid,args -p 12345


Pokaż całe drzewo procesów zaczynając od tego procesu:

pstree -p 12345
# lub
ps axjf | grep -A5 12345
# albo (bardziej uniwersalne)
ps -ef --forest | grep pokolenia -n


Możesz też użyć watch aby obserwować zmiany co 1s:

watch -n 1 'ps -o pid,ppid,comm --forest -C pokolenia'


(jeśli -C pokolenia nie działa idealnie dla Twojej dystrybucji, użyj pgrep w kombinacji).

Możesz też uruchomić htop:

htop


W htop wciśnij F5 (Tree) aby zobaczyć strukturę drzewa. Możesz wyszukać pokolenia (klawisz / aby filtrować).

4) Wróć do Terminal A i naciśnij ENTER

Program wykona pierwszy fork i utworzy potomka. Po forku:

w procesie rodzicu program nazwał się najpierw Rodzic i wypisze swoje info, potem zatrzyma się — zobaczysz komunikat Proces (rodzic) po pierwszym fork ... Naciśnij ENTER....

w procesie dziecka program nazwał się Dziecko i również wypisze swoje info i zatrzyma się (jednak aby dziecko wypisało info, najpierw musi dojść do odpowiedniego miejsca — wg programu wypisze swoje info niezależnie i też zatrzyma się).

W Terminal B teraz zobaczysz kilka procesów pokolenia. Użyj ponownie:

pgrep -l pokolenia
ps -o pid,ppid,comm -p <pid1>,<pid2>,<pid3>
pstree -p <pid_of_root_process>


Przykładowe polecenia:

pgrep -l pokolenia
# powiedzmy wypisze: 12345, 12346
ps -o pid,ppid,comm,args -p $(pgrep -d, -f pokolenia)
pstree -p $(pgrep -n pokolenia)   # -n (pierwszy/ostatni) w zależności co chcesz

5) Naciśnij ENTER w Terminal A (rodzic) — kontynuacja

Po naciśnięciu ENTER proces rodzic wykona następujące kroki (fork na Wujek, potem przemianowanie do Dziadek i kolejne print_info_and_wait). Każdy z tych kroków zatrzymuje procesy — po każdym print_info_and_wait w Terminal A zobaczysz prośbę o ENTER. W tym czasie możesz w Terminal B obserwować:

pojawienie się procesu Wujek

zmiany w comm (nazwa procesu pokazana przez ps), która powinna być zgodna z prctl(PR_SET_NAME, ...).

Polecenia, które użyjesz w Terminal B są te same jak poprzednio:

pgrep -l pokolenia
ps -o pid,ppid,comm,args -p $(pgrep -d, -f pokolenia)
pstree -p $(pgrep -n pokolenia)

6) W terminalu gdzie jest Dziecko: naciśnij ENTER, żeby kontynuować utworzenie wnuka

W Terminal A (tam gdzie uruchomiłeś program) najpierw naciskasz ENTER aby wznowić Dziecko, ono utworzy wnuka. Po tej akcji zobaczysz w Terminal B nowy proces (wnuk), oraz przemianowanie nazw, tak aby finalna linia trzech pokoleń miała kolejno nazwy: Dziadek (oryginalny główny), Rodzic (środkowy), Dziecko (wnuk).

Sprawdzaj:

ps -eo pid,ppid,comm,args | grep pokolenia
pstree -p $(pgrep -n pokolenia)

7) Obserwacja w top / htop

top — uruchom top i wciśnij V aby zobaczyć widok drzewa (zależnie od wersji top).

htop — uruchom htop, naciśnij F5 aby zobaczyć widok drzewa. Możesz wyszukać pokolenia (klawisz /).

8) Zakończenie

Po obejrzeniu każdego etapu naciśnij ENTER w Terminal A aby dany proces kontynuował do następnego kroku. Program sam kończy procesy (jest tam waitpid dla dzieci), więc po przejściu wszystkich etapów procesy znikną z listy.


