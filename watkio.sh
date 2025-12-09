#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

typedef long long ll;

typedef struct {
    int *arr;
    long start;
    long end;
    ll *result;
} ThreadData;


void* sum_subarray(void *arg) {
    ThreadData *data = arg;
    ll sum = 0;
    for (long i = data->start; i < data->end; ++i)
        sum += data->arr[i];

    *(data->result) = sum;
    pthread_exit(NULL);
}

double get_time_in_microseconds() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec * 1000000 + (double)tv.tv_usec;
}

double measure_time(long n, long k, long t) {
    long total = n * k;
    int *arr = malloc(sizeof(int) * total);

    srand((unsigned)time(NULL));
    for (long i = 0; i < total; ++i) {
        arr[i] = rand() % 10;
    }

    ll *k_ele = malloc(sizeof(ll) * k);

    pthread_t threads[t];
    ThreadData thread_data[t];

    long subarrays_per_thread = k / t;
    long remaining_subarrays = k % t;
    long current_subarray = 0;

    double start = get_time_in_microseconds();

    for (long i = 0; i < t; i++) {
        long subarrays_to_sum = subarrays_per_thread + (i < remaining_subarrays ? 1 : 0);
        thread_data[i].arr = arr;
        thread_data[i].start = current_subarray * n;
        thread_data[i].end = thread_data[i].start + subarrays_to_sum * n;
        thread_data[i].result = &k_ele[current_subarray];
        current_subarray += subarrays_to_sum;

        pthread_create(&threads[i], NULL, sum_subarray, &thread_data[i]);
    }

    for (long i = 0; i < t; ++i) {
        pthread_join(threads[i], NULL);
    }

    double end = get_time_in_microseconds();

    free(arr);
    free(k_ele);
    return end - start;
}

void autotune(long m) {
    double min_time = INFINITY;
    long best_n = 1, best_k = m, best_t = 1;

    for (long n = 1; n <= m; n++) {
        if (m % n != 0) continue; // Liczba k musi być całkowita
        long k = m / n;

        for (long t = 1; t <= 10; t++) {
            double time = measure_time(n, k, t);
            if (time < min_time && time > 0) {
                min_time = time;
                best_n = n;
                best_k = k;
                best_t = t;
            }
        }
    }

    printf("Optymalne parametry: n=%ld, k=%ld, t=%ld\n", best_n, best_k, best_t);
    printf("Najkrótszy czas: %.2f mikrosekund\n", min_time);
}


int main(int argc, char *argv[]) {
    long m = strtol(argv[1], NULL, 10);

    autotune(m);

    return 0;
}

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

typedef long long ll;

// Struktura danych dla wątku
typedef struct {
    int *tablica;        // wskaźnik do całej tablicy liczb
    long indeks_start;   // indeks startowy fragmentu tablicy
    long indeks_koniec;  // indeks końcowy fragmentu tablicy
    ll *wynik;           // wskaźnik do miejsca, gdzie zapisujemy wynik
} DaneWatku;

// Funkcja wykonywana przez wątek – sumuje przydzielony fragment tablicy
void* sumuj_fragment(void *arg) {
    DaneWatku *dane = arg;
    ll suma = 0;
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

    // Tworzymy tablicę n*k elementów i wypełniamy losowymi wartościami
    int *tablica = malloc(sizeof(int) * rozmiar_calkowity);
    srand((unsigned)time(NULL));
    for (long i = 0; i < rozmiar_calkowity; ++i)
        tablica[i] = rand() % 10;

    // Tablica do przechowywania sum każdej podtablicy
    ll *wyniki_podtablic = malloc(sizeof(ll) * k);

    pthread_t watki[liczba_watkow];
    DaneWatku dane_watkow[liczba_watkow];

    // Obliczamy ile podtablic przypada na jeden wątek
    long podtablice_na_watek = k / liczba_watkow;
    long pozostale_podtablice = k % liczba_watkow; // pierwsze wątki dostają po jednej podtablicy więcej
    long aktualna_podtablica = 0;

    double czas_start = zmierz_czas_mikrosekundy();

    // Tworzenie wątków
    for (long i = 0; i < liczba_watkow; i++) {
        long ile_podtablic_dla_tego_watku = podtablice_na_watek + (i < pozostale_podtablice ? 1 : 0);

        dane_watkow[i].tablica = tablica;
        dane_watkow[i].indeks_start = aktualna_podtablica * n;
        dane_watkow[i].indeks_koniec = dane_watkow[i].indeks_start + ile_podtablic_dla_tego_watku * n;
        dane_watkow[i].wynik = &wyniki_podtablic[aktualna_podtablica];

        aktualna_podtablica += ile_podtablic_dla_tego_watku;

        pthread_create(&watki[i], NULL, sumuj_fragment, &dane_watkow[i]);
    }

    // Czekamy aż wszystkie wątki zakończą pracę
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
    long najlepsze_n = 1, najlepsze_k = m, najlepsza_liczba_watkow = 1;

    for (long n = 1; n <= m; n++) {
        if (m % n != 0) continue; // k musi być liczbą całkowitą
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

    printf("Optymalne parametry: n=%ld, k=%ld, liczba_watkow=%ld\n", najlepsze_n, najlepsze_k, najlepsza_liczba_watkow);
    printf("Najkrótszy czas: %.2f mikrosekund\n", min_czas);
}

int main(int argc, char *argv[]) {
    long m = strtol(argv[1], NULL, 10); // odczyt wartości m z argumentu programu
    autotune(m);                        // szukamy optymalnych parametrów
    return 0;
}

