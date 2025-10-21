#!/bin/bash
# Autor: Dominika Maciejewska
# Informatyka Medyczna, stopień I, semestr 3, 2025/2026

liczba=101

losowa=$((RANDOM%100 + 1))

echo Gra polega na odgadnieciu liczby od 0 do 100

for i in {1..7}; do
  read -p "Zgadnij liczbe: " liczba

  if [ "$liczba" -eq "$losowa" ]; then
    echo "Brawo!"
    break
  elif [ "$liczba" -gt "$losowa" ]; then
    echo "Szukana liczba mniejsza"
  elif [ "$liczba" -lt "$losowa" ]; then
    echo "Szukana liczba wieksza"
  fi

  if [ $i -eq 7 ]; then
    echo Nie udalo ci sie odgadnac liczby 7 probach
  fi
done
