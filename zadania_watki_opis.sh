Struktura DaneWatku przechowuje wszystkie informacje potrzebne do pracy wątku.
tablica – wskaźnik do głównej tablicy, z której wątek sumuje fragment.
indeks_start i indeks_koniec – określają zakres fragmentu tablicy przypisany do wątku.
wynik – wskaźnik do miejsca, w którym wątek zapisuje wynik sumowania.
Dzięki temu każdy wątek zna tylko swój fragment i wie, gdzie zapisać wynik

Funkcja przyjmuje wskaźnik void*, który rzutujemy na typ DaneWatku.
Tworzymy zmienną lokalną suma, aby sumować fragment tablicy wątku.
Pętla sumuje wszystkie elementy od indeks_start do indeks_koniec-1.
Wynik zapisujemy w pamięci wskazanej przez wynik.
pthread_exit(NULL) kończy wątek.
Dlaczego tak: Każdy wątek sumuje niezależnie swój fragment tablicy.

Pobiera aktualny czas systemowy w mikrosekundach.
tv_sec – liczba sekund od epoki Unix, tv_usec – mikrosekundy.
Przeliczamy sekundy na mikrosekundy, dodając tv_usec.
Dlaczego: do pomiaru przyspieszenia wielowątkowego potrzebujemy dokładnych jednostek czasu, 
a mikrosekundy są wystarczająco precyzyjne dla tej skali.

double zmierz_czas_watki(long n, long k, long liczba_watkow)
Parametry:
n – liczba elementów w jednej podtablicy
k – liczba podtablic
liczba_watkow – liczba wątków do wykonania sumowania
long rozmiar_calkowity = n * k;
int *tablica = malloc(sizeof(int) * rozmiar_calkowity);
srand((unsigned)time(NULL));
for (long i = 0; i < rozmiar_calkowity; ++i)
    tablica[i] = rand() % 10;
Tworzymy tablicę dynamicznie, bo może być bardzo duża.
Wypełniamy ją losowymi liczbami 0–9.
ll *wyniki_podtablic = malloc(sizeof(ll) * k);
pthread_t watki[liczba_watkow];
DaneWatku dane_watkow[liczba_watkow];
wyniki_podtablic – przechowuje sumy podtablic.
watki – identyfikatory wątków, dane_watkow – struktury z danymi dla wątków.
long podtablice_na_watek = k / liczba_watkow;
long pozostale_podtablice = k % liczba_watkow;
long aktualna_podtablica = 0;
Obliczamy, ile podtablic przypada na wątek.
Pierwsze pozostale_podtablice wątki dostają jedną podtablicę więcej, aby równomiernie rozłożyć pracę.
double czas_start = zmierz_czas_mikrosekundy();
Pobieramy czas startu przed uruchomieniem wątków.

Dla każdego wątku:
Obliczamy ile podtablic będzie sumował wątek.
Wypełniamy strukturę z informacjami o tablicy i indeksach fragmentu.
Przesuwamy wskaźnik aktualna_podtablica.
Tworzymy wątek (pthread_create), który wykonuje sumuj_fragment.
Dlaczego tak: równomierny podział pracy minimalizuje czas oczekiwania.

pthread_join – synchronizacja, program czeka, aż wszystkie wątki zakończą.
To konieczne, żeby nie pobrać czasu końcowego zanim wątki się nie zakończą.

Pobieramy czas po zakończeniu wszystkich wątków.
Zwalniamy pamięć dynamiczną.
Zwracamy czas wykonania sumowania w mikrosekundach.

Funkcja autotune ma za zadanie znaleźć optymalne parametry dla sumowania wielowątkowego.
Parametr m to całkowity rozmiar tablicy, którą będziemy sumować.
min_czas = INFINITY – inicjalizujemy minimalny czas bardzo dużą wartością, 
aby każda rzeczywista zmierzona wartość była mniejsza.
najlepsze_n, najlepsze_k, najlepsza_liczba_watkow – zmienne przechowujące aktualnie najlepszą konfigurację.
Na początku ustawione domyślnie: jedna podtablica (n=1), liczba podtablic k=m i jeden wątek (t=1).
chcemy mieć punkt startowy i gwarancję, że każda mierzona wartość czasu będzie mniejsza niż początkowy min_czas.

Pętla po n – sprawdzamy wszystkie możliwe długości podtablic od 1 do m.
if (m % n != 0) continue; – upewniamy się, że tablica może zostać podzielona na całkowitą liczbę podtablic 
(k musi być liczbą całkowitą).
k = m / n – liczba podtablic w zależności od długości podtablicy.
chcemy tylko konfiguracji, w których tablica dzieli się równomiernie, 
bez reszty, żeby wątki miały pełne podtablice.

Pętla po liczbie wątków – testujemy od 1 do 10 wątków.
Wywołujemy funkcję zmierz_czas_watki, która:
Tworzy tablicę o rozmiarze n*k.
Dzieli ją na k podtablic.
Przydziela podtablice do liczba_watkow wątków.
Sumuje wątki i mierzy czas wykonania w mikrosekundach.
chcemy zmierzyć rzeczywisty czas wykonania dla różnych konfiguracji podtablic i liczby wątków,
aby znaleźć najkrótszy czas.
Jeśli czas dla tej konfiguracji jest mniejszy niż dotychczasowy minimalny (min_czas), 
zapisujemy go jako nowy najlepszy czas.
Jednocześnie zapisujemy parametry, które dały ten czas (n, k, liczba wątków).
czas > 0 – dodatkowe zabezpieczenie, aby ignorować ewentualne błędy w pomiarze czasu.




Dlaczego używamy wątków: aby przyspieszyć sumowanie dużej tablicy przez równoległe sumowanie podtablic.
Podział tablicy: tablica dzielona na k podtablic po n elementów, przy czym wątki dostają równą liczbę podtablic.
Synchronizacja: używamy pthread_join, aby upewnić się, że wszystkie wątki skończyły sumowanie przed odczytem czasu.
Pomiar czasu: gettimeofday pozwala na precyzyjny pomiar w mikrosekundach.
Autotuning: sprawdzamy różne wartości n, k i liczby wątków, aby znaleźć najkrótszy czas wykonania.
Dynamiczna pamięć: wszystkie tablice tworzymy dynamicznie, bo liczba elementów może być bardzo duża.
