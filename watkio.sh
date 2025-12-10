#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

// Struktura danych dla wątku
typedef struct {
    int *tablica;            // wskaźnik do całej tablicy liczb
    long indeks_start;       // indeks startowy fragmentu tablicy
    long indeks_koniec;      // indeks końcowy fragmentu tablicy
    long long *wynik;        // wskaźnik do miejsca, gdzie zapisujemy wynik
} DaneWatku;

// Funkcja wykonywana przez wątek – sumuje przydzielony fragment tablicy
void* sumuj_fragment(void *arg) {
    DaneWatku *dane = arg;
    long long suma = 0;

    for (long i = dane->indeks_start; i < dane->indeks_koniec; ++i)
        suma += dane->tablica[i];

    *(dane->wynik) = suma;
    pthread_exit(NULL);
}

// Funkcja zwracająca aktualny czas w mikrosekundach
double zmierz_czas_mikrosekundy() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec * 1000000 + (double)tv.tv_usec;
}

// Funkcja mierząca czas wykonania sumowania wielowątkowego
double zmierz_czas_watki(long n, long k, long liczba_watkow) {
    long rozmiar_calkowity = n * k;

    int *tablica = malloc(sizeof(int) * rozmiar_calkowity);
    srand((unsigned)time(NULL));

    for (long i = 0; i < rozmiar_calkowity; ++i)
        tablica[i] = rand() % 10;

    long long *wyniki_podtablic = malloc(sizeof(long long) * k);

    pthread_t watki[liczba_watkow];
    DaneWatku dane_watkow[liczba_watkow];

    long podtablice_na_watek = k / liczba_watkow;
    long pozostale_podtablice = k % liczba_watkow;
    long aktualna_podtablica = 0;

    double czas_start = zmierz_czas_mikrosekundy();

    for (long i = 0; i < liczba_watkow; i++) {

        long ile_podtablic_dla_tego_watku =
            podtablice_na_watek + (i < pozostale_podtablice ? 1 : 0);

        dane_watkow[i].tablica = tablica;
        dane_watkow[i].indeks_start = aktualna_podtablica * n;
        dane_watkow[i].indeks_koniec =
            dane_watkow[i].indeks_start + ile_podtablic_dla_tego_watku * n;
        dane_watkow[i].wynik = &wyniki_podtablic[aktualna_podtablica];

        aktualna_podtablica += ile_podtablic_dla_tego_watku;

        pthread_create(&watki[i], NULL, sumuj_fragment, &dane_watkow[i]);
    }

    for (long i = 0; i < liczba_watkow; ++i)
        pthread_join(watki[i], NULL);

    double czas_koniec = zmierz_czas_mikrosekundy();

    free(tablica);
    free(wyniki_podtablic);

    return czas_koniec - czas_start;
}

// Funkcja autotuningu – szuka optymalnych wartości n, k i liczby wątków
void autotune(long m) {
    double min_czas = INFINITY;
    long najlepsze_n = 1;
    long najlepsze_k = m;
    long najlepsza_liczba_watkow = 1;

    for (long n = 1; n <= m; n++) {
        if (m % n != 0) continue;

        long k = m / n;

        for (long liczba_watkow = 1; liczba_watkow <= 10; liczba_watkow++) {
            double czas = zmierz_czas_watki(n, k, liczba_watkow);

            if (czas < min_czas && czas > 0) {
                min_czas = czas;
                najlepsze_n = n;
                najlepsze_k = k;
                najlepsza_liczba_watkow = liczba_watkow;
            }
        }
    }

    printf("Optymalne parametry: n=%ld, k=%ld, liczba_watkow=%ld\n",
           najlepsze_n, najlepsze_k, najlepsza_liczba_watkow);
    printf("Najkrótszy czas: %.2f mikrosekund\n", min_czas);
}

int main(int argc, char *argv[]) {
    long m = strtol(argv[1], NULL, 10);
    autotune(m);
    return 0;
}
