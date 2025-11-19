#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

int *array;          // globalna tablica
int n, k, t;         // parametry
long *partial_sums;  // suma z podtablic (k wyników)

void* worker(void* arg) {
    long tid = (long)arg;

    // każdy wątek liczy podtablice: tid, tid+t, tid+2t, ...
    for (int i = tid; i < k; i += t) {
        long sum = 0;
        int start = i * n;
        for (int j = 0; j < n; j++) {
            sum += array[start + j];
        }
        partial_sums[i] = sum;
    }

    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Użycie: ./psum <n> <k> <t>\n");
        return 1;
    }

    n = atoi(argv[1]);
    k = atoi(argv[2]);
    t = atoi(argv[3]);

    long total_elems = n * k;
    array = malloc(total_elems * sizeof(int));
    partial_sums = calloc(k, sizeof(long));

    srand(time(NULL));

    // wypełnianie tablicy losowo
    for (long i = 0; i < total_elems; i++)
        array[i] = rand() % 10;

    // pojedyncza suma sekwencyjna
    long seq_sum = 0;
    for (long i = 0; i < total_elems; i++)
        seq_sum += array[i];

    printf("Suma sekwencyjna  = %ld\n", seq_sum);

    // tworzenie wątków
    pthread_t *threads = malloc(t * sizeof(pthread_t));

    for (long i = 0; i < t; i++)
        pthread_create(&threads[i], NULL, worker, (void*)i);

    // join
    for (int i = 0; i < t; i++)
        pthread_join(threads[i], NULL);

    // suma wyników podtablic
    long parallel_sum = 0;
    for (int i = 0; i < k; i++)
        parallel_sum += partial_sums[i];

    printf("Suma równoległa   = %ld\n", parallel_sum);

    free(array);
    free(partial_sums);
    free(threads);

    return 0;
}

🛠️ Kompilacja w bashu

gcc -pthread psum.c -o psum

▶️ Przykładowe uruchomienia
1) Małe dane

./psum 10 4 2

    tablica 40 elementów

    4 podtablice po 10

    2 wątki

2) Więcej wątków niż podtablic

./psum 100 4 10

3) Duże dane

./psum 1000000 8 4

📌 Uwagi

    Wątki są przydzielane w systemie „przeskakiwania”:
    wątek 0 → podtablice 0, 0+t, 0+2t…
    wątek 1 → podtablice 1, 1+t, 1+2t…

    Dzięki temu działa dla dowolnej kombinacji t, k.

Jeśli chcesz, mogę też dodać:

    pomiar czasu,

    wersję z mutexem,

    wersję z OpenMP,

    testy porównawcze wydajności.

Powiedz tylko!
Powiedziałeś(-aś):
co ten program robi  w konteksie polecenia?
ChatGPT powiedział:

Poniżej masz jasne wyjaśnienie, jak program psum.c odpowiada dokładnie na treść zadania, krok po kroku.
✅ Co program robi w kontekście polecenia?

Polecenie wymaga:
1. Przyjęcie trzech parametrów:

./psum <n> <k> <t>

Program to robi:

n = atoi(argv[1]);
k = atoi(argv[2]);
t = atoi(argv[3]);

✔️ Zgodne z wymaganiem.
2. Utworzenie tablicy n * k elementów (dynamicznie)

Polecenie: "Program tworzy nk-elementową tablicę… (rezerwacja dynamiczna)"*

Program:

array = malloc(total_elems * sizeof(int));

✔️ Tablica tworzona dynamicznie.
✔️ Ma dokładnie n·k elementów.
3. Wypełnienie tablicy wartościami losowymi 0..9

array[i] = rand() % 10;

✔️ Zakres liczb 0–9, zgodny z poleceniem.
✔️ Każdy element jest pseudolosowy.
4. Policzenie sumy sekwencyjnej (jednowątkowo)

Polecenie:
„Program liczy sumę liczb z tablicy dodając po kolei wartości z komórek i podaje wynik na ekran.”

Program:

long seq_sum = 0;
for (long i = 0; i < total_elems; i++)
    seq_sum += array[i];
printf("Suma sekwencyjna  = %ld\n", seq_sum);

✔️ Suma element po elemencie.
✔️ Wynik wypisany.
5. Podział tablicy na k podtablic po n elementów

Polecenie:
„Program dzieli zadaną tablicę na k równych podtablic (po n elementów)”

Program tego nie robi jawnie, ale używa matematyki:

int start = i * n;   // początek podtablicy i

✔️ Podtablica nr i to zakres [i*n … i*n+n-1].
6. Utworzenie t wątków

Polecenie:
„Program tworzy t wątków, które sumują podtablice.”

Program:

pthread_create(&threads[i], NULL, worker, (void*)i);

✔️ Tworzy dokładnie t wątków.
Każdy z nich liczy sumy podtablic zgodnie z:

for (int i = tid; i < k; i += t)

✔️ Dzięki temu każdy wątek liczy jedną albo kilka podtablic — zależnie od t i k.
7. Wątki wypisują sumy podtablic w tablicy wyników

Polecenie:
„Wątek główny sumuje wyniki sumowania podtablic…”

Każdy wątek zapisuje wynik swojej podtablicy do:

partial_sums[i] = sum;

✔️ Mamy k wyników — po jednym na podtablicę.
8. Wątek główny sumuje wyniki

long parallel_sum = 0;
for (int i = 0; i < k; i++)
    parallel_sum += partial_sums[i];

✔️ Zgodnie z poleceniem — sumuje wyniki prac wątków.
✔️ Wynik wypisany na ekran.
9. Program wypisuje dwie sumy:

    sekwencyjną

    z równoległego sumowania

✔️ Można łatwo porównać poprawność i wydajność — tego również wymaga końcówka zadania, gdzie każesz robić testy na różnych parametrach.
📌 Podsumowanie: czy program spełnia polecenie? — TAK
Wymaganie z polecenia	Zrobione w kodzie	OK?
Argumenty n k t	tak	✔️
Alokacja n*k	tak	✔️
Losowe liczby 0–9	tak	✔️
Suma sekwencyjna	tak	✔️
Podział na k podtablic	tak	✔️
t wątków	tak	✔️
Każdy wątek sumuje podtablice	tak	✔️
Wątek główny sumuje wyniki	tak	✔️
Przykładowe uruchomienia	tak	✔️

Program jest w 100% zgodny z treścią zadania.

Jeśli chcesz, mogę:

    narysować schemat działania program → tablica → wątki,

    poprawić program tak, aby każdy wątek liczył tylko jedną podtablicę (inna interpretacja zadania),

    dodać pomiar czasu i analizę wydajności.

Powiedziałeś(-aś):
czy te suma zawsze beda takie same?
ChatGPT powiedział:

Tak — w poprawnie napisanym programie suma sekwencyjna i suma równoległa zawsze powinna być taka sama, ponieważ:
✅ Dlaczego wyniki muszą być identyczne?

Obie sumy (sekwencyjna i równoległa):

    liczą dokładnie te same elementy tablicy,

    każdy element jest dodany dokładnie jeden raz,

    nie dochodzi do modyfikacji tablicy przez żaden wątek,

    każdy wątek sumuje swoją część, a wynik główny je sumuje.

Obie operacje to matematyczna suma wszystkich elementów, więc wynik musi być identyczny.
⚠️ Kiedy sumy mogłyby się różnić?

W dwóch przypadkach — ale te NIE występują w tym programie:
1. Błędy synchronizacji lub współdzielona zmienna bez blokady

Np. gdyby wszystkie wątki sumowały do jednej globalnej zmiennej bez mutexa → mielibyśmy race condition.

W tym programie tego nie ma.

Każdy wątek zapisuje tylko do swojej komórki:

partial_sums[i] = sum;

2. Zmiana tablicy przez wątki w trakcie sumowania

Trudno zrobić przypadkiem, ale gdyby wątki modyfikowały array[], wyniki mogłyby się różnić.

Ten program tylko czyta tablicę — nie ma zapisu.
🟢 Wniosek

W tym programie:
✔️ suma sekwencyjna = suma równoległa
✔️ zawsze
✔️ niezależnie od wartości n, k, t
✔️ bo dane są nieruszone, a podsumowania wykluczają konflikty
🔍 Chcesz, mogę dodać do programu automatyczne sprawdzanie:

if (seq_sum == parallel_sum) printf("OK\n");
else printf("ERROR\n");

Chcesz?
Powiedziałeś(-aś):
Obuduj program z zadania (1) przy pomocy funkcji liczących czas wykonania. Pomierz czas realizacji obliczeń dla różnych, odpowiednio dużych n, k i t. Narysuj wykres przyspieszenia, tzn. czasu obliczeń od zadanej liczby wątków dla stałej wartości n i k.

Wskazówki
Liczenie czasu wykonania przy pomocy polecenia ‘time’ w Linux:
./time ./program
Liczenie czasu przy pomocy funkcji time() w programie:
#include <time.h>
time_t czas_start, czas_stop;
time(&czas_start)
… kod programu, którego czas wykonania będziemy liczyć
time(&czas_stop)
Kod wykonywał się przez czas_stop - czas_start sekund.
Liczenie czasu precyzyjniej, w mili/mikrosekundach:
	#include <sys/time.h>
	Funkcja: gettimeofday()
ChatGPT powiedział:

Poniżej dostajesz:

✔️ pełną wersję programu z pomiarem czasu
✔️ instrukcję wykonania pomiarów
✔️ jak stworzyć wykres przyspieszenia
✔️ gotowy skrypt Bash do automatycznego pomiaru

To jest kompletny zestaw odpowiedzi na nowe polecenie.
✅ 1. Program psum_time.c z pomiarem czasu (mikrosekundy – gettimeofday)

Pomiar obejmuje tylko część równoległą (tworzenie wątków + sumowanie), bo to właśnie ma być zmierzone.

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>

int *array;
int n, k, t;
long *partial_sums;

void* worker(void* arg) {
    long tid = (long)arg;

    for (int i = tid; i < k; i += t) {
        long sum = 0;
        int start = i * n;
        for (int j = 0; j < n; j++)
            sum += array[start + j];
        partial_sums[i] = sum;
    }

    return NULL;
}

long long time_us() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (long long)tv.tv_sec * 1000000LL + tv.tv_usec;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Użycie: ./psum <n> <k> <t>\n");
        return 1;
    }

    n = atoi(argv[1]);
    k = atoi(argv[2]);
    t = atoi(argv[3]);

    long total_elems = n * k;
    array = malloc(total_elems * sizeof(int));
    partial_sums = calloc(k, sizeof(long));

    srand(time(NULL));
    for (long i = 0; i < total_elems; i++)
        array[i] = rand() % 10;

    // --- Pomiary czasu ---
    long long start = time_us();

    pthread_t *threads = malloc(t * sizeof(pthread_t));

    for (long i = 0; i < t; i++)
        pthread_create(&threads[i], NULL, worker, (void*)i);

    for (int i = 0; i < t; i++)
        pthread_join(threads[i], NULL);

    long long end = time_us();
    long long elapsed = end - start;
    printf("%lld\n", elapsed);     // <- wynik: czas w mikrosekundach

    // sumowanie wyników
    long parallel_sum = 0;
    for (int i = 0; i < k; i++)
        parallel_sum += partial_sums[i];

    free(array);
    free(partial_sums);
    free(threads);
    return 0;
}

✅ 2. Kompilacja

gcc -pthread psum_time.c -o psum_time

✅ 3. Jak wykonać pomiary?

Wybierasz stałe n i k, np.:

n = 200000
k = 100

i mierzysz dla różnych t:

./psum_time 200000 100 1
./psum_time 200000 100 2
./psum_time 200000 100 4
./psum_time 200000 100 8
./psum_time 200000 100 16

Każde wywołanie wypisuje sam czas w mikrosekundach.
✔️ 4. Wykres przyspieszenia (speedup)

Speedup definiujesz tak:

S(t) = T(1) / T(t)

gdzie:

    T(1) = czas dla 1 wątku

    T(t) = czas dla t wątków

Przykład (liczby przykładowe):
t	czas [us]	speedup
1	2000000	1.00
2	1100000	1.81
4	600000	3.33
8	400000	5.00
16	380000	5.26
🧪 5. Automatyczne mierzenie w Bash: run_tests.sh

#!/bin/bash

n=200000
k=100

echo "t,czas_us" > wyniki.csv

for t in 1 2 4 8 16 32; do
    time_us=$(./psum_time $n $k $t)
    echo "$t,$time_us" >> wyniki.csv
done

Uruchom:

bash run_tests.sh

Otrzymasz plik wyniki.csv.
📈 6. Tworzenie wykresu (Python + matplotlib)

Zawartość plot.py:

import matplotlib.pyplot as plt
import csv

t = []
times = []

with open("wyniki.csv") as f:
    r = csv.reader(f)
    next(r)
    for row in r:
        t.append(int(row[0]))
        times.append(int(row[1]))

T1 = times[0]
speedup = [T1 / x for x in times]

plt.plot(t, speedup, marker='o')
plt.xlabel("Liczba wątków t")
plt.ylabel("Przyspieszenie S(t)")
plt.title("Speedup równoległego sumowania")
plt.grid(True)
plt.show()

Uruchom:

python3 plot.py

Otrzymasz wykres przyspieszenia zgodny z wymaganiami.
🎉 Gotowe!

Dostajesz:

✔️ program z pomiarem czasu
✔️ instrukcje pomiaru
✔️ algorytm obliczania przyspieszenia
✔️ skrypt bash do automatycznych testów
✔️ skrypt Python do generowania wykresu

Chcesz, żebym przygotował gotowy PDF z wykresem i opisem?
Powiedziałeś(-aś):
co mam pokolei wpisac w terminalu zeby zovaczyc czy program działa?
ChatGPT powiedział:

Poniżej dostajesz dokładną, krok-po-kroku instrukcję, co wpisać w terminalu, żeby:

1️⃣ skompilować program
2️⃣ uruchomić go
3️⃣ sprawdzić, czy działa poprawnie
4️⃣ zmierzyć czasy

To najprostsza możliwa ścieżka.
✅ KROK 1 — Utwórz plik z programem

W terminalu:

nano psum_time.c

Wklej cały kod programu (który ci dałem wcześniej), a potem:

    CTRL + O → Enter (zapis)

    CTRL + X (wyjście)

✅ KROK 2 — Kompilacja

Wpisz:

gcc -pthread psum_time.c -o psum_time

Jeśli nie ma błędów — program jest gotowy.
✅ KROK 3 — Pierwsze testowe uruchomienie

Ustaw testowe parametry, np.:

./psum_time 10000 10 1

Powinno wypisać coś w stylu:

12345

(liczba = czas w mikrosekundach)

Jeśli cokolwiek się wyświetla → program działa.
✅ KROK 4 — Sprawdź działanie dla kilku wartości t

Najpierw uruchom 1 wątek:

./psum_time 100000 50 1

Potem więcej:

./psum_time 100000 50 2
./psum_time 100000 50 4
./psum_time 100000 50 8

Za każdym razem powinna pokazywać się liczba — czas wykonania.
✅ KROK 5 — Automatyczne pomiary (opcjonalnie, ale zalecane)

Utwórz plik:

nano run_tests.sh

Wklej:

#!/bin/bash

n=200000
k=100

echo "t,czas_us" > wyniki.csv

for t in 1 2 4 8 16; do
    time_us=$(./psum_time $n $k $t)
    echo "$t,$time_us" >> wyniki.csv
done

Zapisz i wyjdź.

Nadaj prawa do uruchamiania:

chmod +x run_tests.sh

Uruchom:

./run_tests.sh

Powstanie plik:

wyniki.csv

🎉 GOTOWE — teraz wiesz, że program działa

Jeżeli powyższe komendy:

    kompilują się,

    uruchamiają się,

    wypisują czasy,

to program działa prawidłowo.
📌 Jeśli chcesz, mogę:

    sprawdzić twój kod,

    poprawić błędy kompilacji,

    przygotować gotowy raport z wykresem.

Powiedz tylko!
Powiedziałeś(-aś):
a co z wykresem?
ChatGPT powiedział:

OK — teraz pokażę Ci dokładnie, jak zrobić wykres od początku do końca, krok po kroku w terminalu.

Wykres powstanie na podstawie danych z programu, czyli czasu wykonania dla różnych t (liczby wątków).

Nic nie zakładam — prowadzę Cię za rękę.
✅ KROK 1 — Zrób pomiary i zapisz je do pliku CSV

Jeśli użyłeś skryptu run_tests.sh, to masz już plik:

wyniki.csv

Jeżeli nie masz, zrób go teraz:
1.1. Utwórz plik run_tests.sh

W terminalu:

nano run_tests.sh

Wklej to:

#!/bin/bash

n=200000
k=100

echo "t,czas_us" > wyniki.csv

for t in 1 2 4 8 16; do
    time_us=$(./psum_time $n $k $t)
    echo "$t,$time_us" >> wyniki.csv
done

Zapisz (Ctrl+O Enter) i wyjdź (Ctrl+X).
1.2. Nadaj prawa do uruchamiania:

chmod +x run_tests.sh

1.3. Uruchom:

./run_tests.sh

Powstanie plik:

wyniki.csv

Przykład zawartości:

t,czas_us
1,2050000
2,1200000
4,700000
8,450000
16,430000

✅ KROK 2 — Stwórz skrypt do generowania wykresu

W terminalu:

nano plot.py

Wklej:

import matplotlib.pyplot as plt
import csv

t = []
times = []

with open("wyniki.csv") as f:
    r = csv.reader(f)
    next(r)  # pomiń nagłówek
    for row in r:
        t.append(int(row[0]))
        times.append(int(row[1]))

T1 = times[0]
speedup = [T1 / x for x in times]

plt.figure(figsize=(8,5))
plt.plot(t, speedup, marker='o')
plt.xlabel("Liczba wątków t")
plt.ylabel("Przyspieszenie S(t)")
plt.title("Speedup równoległego sumowania")
plt.grid(True)
plt.savefig("wykres_speedup.png")
plt.show()

Zapisz i wyjdź.
✅ KROK 3 — Uruchom skrypt i wygeneruj wykres

W terminalu:

python3 plot.py

Jeśli Python i matplotlib są zainstalowane, otrzymasz:

    okienko z wykresem

    plik PNG zapisany jako:

wykres_speedup.png

Nazwijmy program psum_autotune.c.

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>

int *array;
int n, k, t;
long *partial_sums;

void* worker(void* arg) {
    long tid = (long)arg;

    for (int i = tid; i < k; i += t) {
        long sum = 0;
        int start = i * n;
        for (int j = 0; j < n; j++)
            sum += array[start + j];
        partial_sums[i] = sum;
    }
    return NULL;
}

long long time_us() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (long long)tv.tv_sec * 1000000LL + tv.tv_usec;
}

long long run_once(int n_val, int k_val, int t_val) {

    long total = n_val * k_val;

    // alokacja
    array = malloc(total * sizeof(int));
    partial_sums = calloc(k_val, sizeof(long));

    // losowanie danych
    for (long i = 0; i < total; i++)
        array[i] = rand() % 10;

    n = n_val;
    k = k_val;
    t = t_val;

    // pomiar czasu
    long long start = time_us();

    pthread_t *threads = malloc(t * sizeof(pthread_t));
    for (long i = 0; i < t; i++)
        pthread_create(&threads[i], NULL, worker, (void*)i);

    for (int i = 0; i < t; i++)
        pthread_join(threads[i], NULL);

    long long end = time_us();
    long long elapsed = end - start;

    free(array);
    free(partial_sums);
    free(threads);

    return elapsed;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Użycie: ./psum_autotune <m>\n");
        return 1;
    }

    long m = atol(argv[1]);

    long long best_time = 1e18;
    int best_n = 0, best_k = 0, best_t = 0;

    printf("Autotuning dla m = %ld...\n", m);

    // testujemy parametry
    for (int n_val = 1000; n_val <= m; n_val *= 2) {
        if (m % n_val != 0) continue;
        int k_val = m / n_val;

        for (int t_val = 1; t_val <= 32; t_val *= 2) {
            long long time = run_once(n_val, k_val, t_val);
            printf("n=%d k=%d t=%d  -> %lld us\n",
                   n_val, k_val, t_val, time);

            if (time < best_time) {
                best_time = time;
                best_n = n_val;
                best_k = k_val;
                best_t = t_val;
            }
        }
    }

    printf("\n=== NAJLEPSZA KONFIGURACJA ===\n");
    printf("n = %d\n", best_n);
    printf("k = %d\n", best_k);
    printf("t = %d\n", best_t);
    printf("czas = %lld us\n", best_time);

    return 0;
}
gcc -pthread psum_autotune.c -o psum_autotune

✅ 4. Uruchom AUTOTUNE

Na przykład dla:

m = 80000000

Wpisz:

./psum_autotune 80000000
