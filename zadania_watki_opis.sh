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
