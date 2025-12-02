
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

typedef long long ll;

typedef struct {
    int *tab;
    long start;
    long end;
    ll result;
} Watek;

void *liczyby_sume_dla_jednego_watku(void *arg){
    Watek *watek = arg;
    ll suma=0;

    for (int i=watek->start; i<watek->end; i++) {
        suma += watek->tab[i];
    }

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

    watek->result = suma;
    pthread_exit(NULL);
}

// Funkcja do liczenia czasu wykonania operacji
double czas() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec * 1000000 + (double)tv.tv_usec; //microsekundy
}


int main(int argc, char *argv[]) {
    long n = strtol(argv[1], NULL, 10); // Ilość na jedną talice
    long k = strtol(argv[2], NULL, 10); // Liczba podtablic
    long t = strtol(argv[3], NULL, 10); // Liczba wątków

    ll total=n*k;
    int *tab=malloc(sizeof(int)*total);  //tablica wszystkich liczb

    srand(time(NULL));
    for(int i=0; i<total; i++){
        tab[i] = rand()%10;
    }

    double start1 = czas();
    ll suma=0;
    for(int i=0; i<total; i++){
        suma+=tab[i];
    }
    double end1 = czas();
    printf("Suma: %lld ", suma);
    printf("\nCzas sekwencyjny: %f", end1-start1);


    long ilosc_podtablic_na_watek = k/t;
    long pozostale_podtablice = k%t;
    long index_obecnej_podtablicy = 0;

    pthread_t watki[t];  // tworzymy tablice wątków
    Watek *watki_data[t]; // dane watkow

    double start2=czas();
    for (int i = 0; i < t; i++) {
        watki_data[i] = malloc(sizeof(Watek));
        long nowa_ilosc_podtablic_na_watek = ilosc_podtablic_na_watek + ((pozostale_podtablice > 0) ? 1 : 0);
        watki_data[i]->tab = tab;
        watki_data[i]->start = index_obecnej_podtablicy * n;
        watki_data[i]->end = watki_data[i]->start + nowa_ilosc_podtablic_na_watek * n;
        index_obecnej_podtablicy += nowa_ilosc_podtablic_na_watek;

        pthread_create(&watki[i], NULL, liczyby_sume_dla_jednego_watku, watki_data[i]);
        pozostale_podtablice--;
    }

    // Wątek glowny czeka na zakonczenie wszystkich watkow
    for (int i=0; i<t; i++) {
        pthread_join(watki[i], NULL);
    }
    double end2=czas();

    // Liczymy sume watkow
    ll suma_watkow = 0;
    for (int i = 0; i < t; i++) {
        suma_watkow += watki_data[i]->result;
        free(watki_data[i]);
    }

    printf("\nSuma: %lld", suma_watkow);
    printf("\nCzas watkowy: %f ", end2-start2);

    free(tab);
    return 0;
}

include <stdio.h>
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
    for (long i = 0; i < total; ++i)
        arr[i] = rand() % 10;


    ll *k_ele = malloc(sizeof(ll) * k);

    pthread_t threads[t];
    ThreadData thread_data[t];

    long subarrays_per_thread = k / t;
    long remaining_subarrays = k % t;
    long current_subarray = 0;

    double start = get_time_in_microseconds();

    for (long i = 0; i < t; ++i) {
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

int main(int argc, char *argv[]) {
    long n_values[] = {1000, 5000, 10000, 20000, 50000};
    long k_values[] = {10, 50, 100, 200, 500};
    long t_values[] = {1, 2, 4, 8, 16};

    FILE *fp = fopen("wyniki_nkt.csv", "w");

    for (size_t i = 0; i < sizeof(n_values) / sizeof(n_values[0]); ++i) {
        for (size_t j = 0; j < sizeof(k_values) / sizeof(k_values[0]); ++j) {
            for (size_t l = 0; l < sizeof(t_values) / sizeof(t_values[0]); ++l) {
                long n = n_values[i];
                long k = k_values[j];
                long t = t_values[l];

                double time = measure_time(n, k, t);
                if (time >= 0) {
                    printf("n=%ld, k=%ld, t=%ld: %.2f mikrosekund\n", n, k, t, time);
                    fprintf(fp, "%ld,%ld,%ld,%.2f\n", n, k, t, time);
                }
            }
        }
    }

    fclose(fp);

    return 0;
}

