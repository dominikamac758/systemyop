W moim programie porównuję dwa sposoby sumowania dużej tablicy liczb: sposób sekwencyjny i sposób wielowątkowy.
Najpierw program tworzy dużą tablicę liczb całkowitych i wypełnia ją losowymi wartościami od 0 do 9.

W części sekwencyjnej tablica jest sumowana zwykłą pętlą, jednym wątkiem. Mierzę czas tego obliczenia.

Następnie wykonuję to samo zadanie w sposób równoległy. Dzielę całą tablicę na fragmenty i każdy fragment przekazuję do osobnego wątku. Każdy wątek dostaje informację, od którego do którego indeksu ma sumować i zapisuje wynik swojej części do własnej struktury.
Wątki działają równolegle, dzięki czemu obliczenia mogą być szybsze na procesorach wielordzeniowych.

Po zakończeniu pracy wszystkich wątków program zbiera ich wyniki, sumuje je i porównuje z sumą obliczoną sekwencyjnie.
Na końcu wypisuję dwie rzeczy: sumę otrzymaną w sposób wielowątkowy oraz czas działania wątków. Dzięki temu mogę porównać, czy równoległe przetwarzanie daje przyspieszenie.

Najważniejsze elementy tego zadania to:

poprawny podział danych między wątki,

uruchomienie każdego wątku z jego zakresem,

pthread_join, który gwarantuje, że czekamy na wszystkie wątki,

oraz zebranie wyników z poszczególnych wątków.

Całość pokazuje, jak można przyspieszyć obliczenia dzięki równoległości.



W tym programie sprawdzam, jak zmienia się czas wykonywania sumowania dużej tablicy liczb w zależności od trzech parametrów:
n – ile elementów ma jedna podtablica,
k – ile takich podtablic tworzymy,
t – ile używamy wątków.

Dla każdej kombinacji tych wartości program generuje tablicę liczb o rozmiarze n razy k. Następnie dzieli tę tablicę na fragmenty i rozdziela je między wątki. Każdy wątek sumuje swój własny fragment, czyli działa równolegle z innymi.

Najważniejszym elementem tego programu jest pomiar czasu wykonania operacji wielowątkowego sumowania.
Do pomiaru używam funkcji gettimeofday(), która zwraca czas w mikrosekundach, czyli milionowych częściach sekundy. Dzięki temu mogę bardzo dokładnie zmierzyć, ile trwa wykonanie danego zestawu obliczeń.

Czas startowy zapisuję tuż przed uruchomieniem wszystkich wątków, a czas końcowy tuż po zakończeniu pracy ostatniego wątku. Różnica między tymi dwoma wartościami to rzeczywisty czas wykonania wielowątkowego sumowania.

Program powtarza ten pomiar dla różnych wartości n, k i t, a wyniki zapisuje do pliku CSV, dzięki czemu można później narysować wykres lub przeanalizować, jak liczba wątków wpływa na szybkość działania programu.

Dzięki temu program pozwala ocenić, kiedy wielowątkowość przyspiesza obliczenia, a kiedy liczba wątków jest już zbyt duża i nie daje zysku.”
