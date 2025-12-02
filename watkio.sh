
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
