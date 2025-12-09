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
