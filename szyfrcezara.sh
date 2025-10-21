#!/bin/bash
# Autor: Dominika Maciejewska
# Informatyka Medyczna, stopień I, semestr 3, 2025/2026  

echo "Podaj przesuniecie (liczba calkowita): "
read p
echo  "Podaj napis do zaszyfrowania/odszyfrowania (małe litery, bez spacji): "
read napis

tab="abcdefghijklmnopqrstuvwxyz"
d=${#tab}
d2=${#napis}

echo -n "Chcesz zaszyfrować(1) czy odszyfrować(2) napis? "
read wybor
if [ $wybor -eq 1 ]; then
    p=$p
else
    p=-$p
fi
for ((i=0; i<d2; i++)); do
    for ((j=0; j<d; j++)); do
        if [ "${napis:i:1}" == "${tab:j:1}" ]; then
            echo -n ${tab:((j+p)%d):1}
        fi
    done
done
echo
