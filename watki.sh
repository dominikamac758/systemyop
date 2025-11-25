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
#Kompilacja
gcc -pthread psum.c -o psum

#Uruchomienie
./psum 10 4 2

    tablica 40 elementów

    4 podtablice po 10

    2 wątki


# na 4.0
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
# Kompilacja

gcc -pthread psum_time.c -o psum_time

# nastepnie:

Wybierasz stałe n i k, np.:

n = 200000
k = 100

i mierzysz dla różnych t:

./psum_time 200000 100 1
./psum_time 200000 100 2
./psum_time 200000 100 4
./psum_time 200000 100 8
./psum_time 200000 100 16


#Kompilacja

gcc -pthread psum_time.c -o psum_time


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



chmod +x run_tests.sh

Uruchom:

./run_tests.sh

Powstanie plik:

wyniki.csv

nano plot.py

#kod:

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


python3 plot.py

 program psum_autotune.c.

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


./psum_autotune 80000000
