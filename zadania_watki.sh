Zadanie 3.0
nano psum.c

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

typedef long long ll;

// Struktura danych przekazywana do wątku
typedef struct {
    int *tablica;        // wskaźnik do całej tablicy liczb
    long indeks_start;   // indeks początkowy fragmentu
    long indeks_koniec;  // indeks końcowy fragmentu
    ll wynik;            // miejsce na sumę obliczoną przez wątek
} DaneWatku;

// Funkcja wykonywana przez każdy wątek – sumuje fragment tablicy
void *sumuj_fragment(void *arg){
    DaneWatku *dane = arg;
    ll lokalna_suma = 0;

    // Sumowanie fragmentu tablicy od indeksu start do end-1
    for (long i = dane->indeks_start; i < dane->indeks_koniec; i++) {
        lokalna_suma += dane->tablica[i];
    }

    // Zapisanie wyniku w strukturze
    dane->wynik = lokalna_suma;

    pthread_exit(NULL);
}

// Funkcja mierząca czas w mikrosekundach
double zmierz_czas() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec * 1000000 + (double)tv.tv_usec;
}


int main(int argc, char *argv[]) {

    // Pobranie n, k, t z argumentów programu
    long n = strtol(argv[1], NULL, 10); // liczba elementów w jednej podtablicy
    long k = strtol(argv[2], NULL, 10); // liczba podtablic
    long t = strtol(argv[3], NULL, 10); // liczba wątków

    ll rozmiar_calkowity = n * k;
    int *tablica = malloc(sizeof(int) * rozmiar_calkowity);

    // Losowe wypełnienie tablicy wartościami 0–9
    srand(time(NULL));
    for (long i = 0; i < rozmiar_calkowity; i++) {
        tablica[i] = rand() % 10;
    }

    // -----------------------------
    // SUMOWANIE SEKWENCYJNE
    // -----------------------------
    double czas_start_sekw = zmierz_czas();

    ll suma_sekwencyjna = 0;
    for (long i = 0; i < rozmiar_calkowity; i++) {
        suma_sekwencyjna += tablica[i];
    }

    double czas_koniec_sekw = zmierz_czas();

    printf("Suma sekwencyjna: %lld", suma_sekwencyjna);
    printf("\nCzas sekwencyjny: %.2f mikrosekund", czas_koniec_sekw - czas_start_sekw);


    // -------------------------------------
    // SUMOWANIE WIELOWĄTKOWE
    // -------------------------------------

    long podtablice_na_watek = k / t;   // ile pełnych podtablic dostaje każdy wątek
    long nadmiarowe = k % t;            // jeśli nie dzieli się równo, część wątków dostaje 1 więcej
    long aktualna_podtablica = 0;       // numer aktualnie przydzielanej podtablicy

    pthread_t watki[t];
    DaneWatku *dane_watkow[t];

    double czas_start_watki = zmierz_czas();

    for (int i = 0; i < t; i++) {

        dane_watkow[i] = malloc(sizeof(DaneWatku));

        // Każdy pierwszy "nadmiarowy" wątek dostanie jedną podtablicę więcej
        long ile_dla_tego_watku = podtablice_na_watek + (nadmiarowe > 0 ? 1 : 0);

        dane_watkow[i]->tablica = tablica;
        dane_watkow[i]->indeks_start = aktualna_podtablica * n;
        dane_watkow[i]->indeks_koniec = dane_watkow[i]->indeks_start + ile_dla_tego_watku * n;

        // Przesuwamy licznik podtablic o liczbę przydzielonych
        aktualna_podtablica += ile_dla_tego_watku;

        // Tworzymy wątek
        pthread_create(&watki[i], NULL, sumuj_fragment, dane_watkow[i]);

        nadmiarowe--; // zmniejszamy liczbę pozostałych "nadmiarowych"
    }

    // Czekamy na wszystkie wątki
    for (int i = 0; i < t; i++) {
        pthread_join(watki[i], NULL);
    }

    double czas_koniec_watki = zmierz_czas();

    // Sumujemy wyniki zwrócone przez wątki
    ll suma_watkow = 0;
    for (int i = 0; i < t; i++) {
        suma_watkow += dane_watkow[i]->wynik;
        free(dane_watkow[i]);
    }

    printf("\nSuma wielowątkowa: %lld", suma_watkow);
    printf("\nCzas wielowątkowy: %.2f mikrosekund\n", czas_koniec_watki - czas_start_watki);

    free(tablica);
    return 0;
}

gcc -pthread psum.c -o psum
./psum 1000000 10 4


Zadanie 4.0
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

typedef long long ll;

// Struktura danych dla wątku
typedef struct {
    int *tablica;        // wskaźnik do całej tablicy
    long indeks_start;   // indeks startowy fragmentu
    long indeks_koniec;  // indeks końcowy fragmentu
    ll *wynik;           // miejsce na zapis wyniku obliczonego przez wątek
} DaneWatku;

// Funkcja wykonywana przez wątek – sumuje fragment tablicy
void* sumuj_fragment(void *arg) {
    DaneWatku *dane = arg;
    ll suma = 0;

    for (long i = dane->indeks_start; i < dane->indeks_koniec; ++i)
        suma += dane->tablica[i];

    *(dane->wynik) = suma; // zapisujemy wynik w strukturze
    pthread_exit(NULL);
}

// Funkcja zwracająca czas w mikrosekundach
double zmierz_czas_mikrosekundy() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec * 1000000 + (double)tv.tv_usec;
}

// Funkcja mierząca czas wykonania sumowania wielowątkowego
double zmierz_czas_watki(long n, long k, long t) {
    long rozmiar_calkowity = n * k;

    // Tworzymy tablicę n*k elementów i wypełniamy losowymi wartościami
    int *tablica = malloc(sizeof(int) * rozmiar_calkowity);
    srand((unsigned)time(NULL));
    for (long i = 0; i < rozmiar_calkowity; ++i)
        tablica[i] = rand() % 10;

    // Tablica do przechowywania sum podtablic
    ll *wyniki_podtablic = malloc(sizeof(ll) * k);

    pthread_t watki[t];
    DaneWatku dane_watkow[t];

    // Ile podtablic przypada na jeden wątek
    long podtablice_na_watek = k / t;
    long nadmiarowe = k % t; // pierwsze wątki dostaną po 1 podtablicy więcej
    long aktualna_podtablica = 0;

    double czas_start = zmierz_czas_mikrosekundy();

    // Tworzenie wątków
    for (long i = 0; i < t; ++i) {
        long ile_dla_tego_watku = podtablice_na_watek + (i < nadmiarowe ? 1 : 0);

        dane_watkow[i].tablica = tablica;
        dane_watkow[i].indeks_start = aktualna_podtablica * n;
        dane_watkow[i].indeks_koniec = dane_watkow[i].indeks_start + ile_dla_tego_watku * n;
        dane_watkow[i].wynik = &wyniki_podtablic[aktualna_podtablica];

        aktualna_podtablica += ile_dla_tego_watku;

        pthread_create(&watki[i], NULL, sumuj_fragment, &dane_watkow[i]);
    }

    // Czekanie na zakończenie wszystkich wątków
    for (long i = 0; i < t; ++i)
        pthread_join(watki[i], NULL);

    double czas_koniec = zmierz_czas_mikrosekundy();

    // Zwolnienie pamięci
    free(tablica);
    free(wyniki_podtablic);

    return czas_koniec - czas_start;
}

int main(int argc, char *argv[]) {
    // Tablice testowych wartości n, k i t
    long n_values[] = {1000, 5000, 10000, 20000, 50000};
    long k_values[] = {10, 50, 100, 200, 500};
    long t_values[] = {1, 2, 4, 8, 16};

    // Plik CSV do zapisu wyników
    FILE *fp = fopen("wyniki_nkt.csv", "w");

    // Pętla po wszystkich kombinacjach n, k i t
    for (size_t i = 0; i < sizeof(n_values) / sizeof(n_values[0]); ++i) {
        for (size_t j = 0; j < sizeof(k_values) / sizeof(k_values[0]); ++j) {
            for (size_t l = 0; l < sizeof(t_values) / sizeof(t_values[0]); ++l) {
                long n = n_values[i];
                long k = k_values[j];
                long t = t_values[l];

                // Mierzymy czas wykonania sumowania wielowątkowego
                double czas = zmierz_czas_watki(n, k, t);

                if (czas >= 0) {
                    printf("n=%ld, k=%ld, t=%ld: %.2f mikrosekund\n", n, k, t, czas);
                    fprintf(fp, "%ld,%ld,%ld,%.2f\n", n, k, t, czas);
                }
            }
        }
    }

    fclose(fp);

    return 0;
}

gcc -O2 -pthread -o psum_speedup psum_speedup.c
ls -l psum_speedup
./psum_speedup

wykresy:

nano wykres.py
import pandas as pd
import matplotlib.pyplot as plt

# Wczytanie danych z CSV
dane = pd.read_csv("wyniki_nkt.csv")

# Wybieramy jedną wartość n i k do wykresu speedupu
n_val = 1000
k_val = 10

# Filtrowanie danych dla stałego n i k
df = dane[(dane['n'] == n_val) & (dane['k'] == k_val)]

# Sortowanie po liczbie wątków
df = df.sort_values(by='t')

# Wyliczenie speedupu względem najmniejszej liczby wątków (t=1)
czas_t1 = df[df['t'] == 1]['czas'].values[0]
df['speedup'] = czas_t1 / df['czas']

# Wykres czasu
plt.figure(figsize=(10,5))
plt.plot(df['t'], df['czas'], marker='o', label='Czas [mikrosekundy]')
plt.xlabel("Liczba wątków")
plt.ylabel("Czas [µs]")
plt.title(f"Czas wykonania vs liczba wątków (n={n_val}, k={k_val})")
plt.grid(True)
plt.legend()
plt.show()

# Wykres speedupu
plt.figure(figsize=(10,5))
plt.plot(df['t'], df['speedup'], marker='o', color='green', label='Speedup')
plt.xlabel("Liczba wątków")
plt.ylabel("Speedup")
plt.title(f"Speedup vs liczba wątków (n={n_val}, k={k_val})")
plt.grid(True)
plt.legend()
plt.show()

python3 wykres_speedup.py



