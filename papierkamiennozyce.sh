#!/bin/bash
# Autor: Dominika Maciejewska
# Informatyka Medyczna, stopień I, semestr 3, 2025/2026

list=("kamien", "papier", "nozyce")

wyn_gracz=0
wyn_komp=0
wyn_rem=0

for i in {1..10}; do
  echo "Wybierz
    k-kamien
    p-pamier
    n-nozyce
  "
  read wybor

  komp=${list[$((RANDOM % 3))]:0:1}
  if [ "${wybor}" == "${komp}" ]; then
    echo "Remis"
    wyn_rem=$((wyn_rem+1))
  elif [[ ( "$wybor" == "k" && "$komp" == "n" ) || \
        ( "$wybor" == "n" && "$komp" == "p" ) || \
        ( "$wybor" == "p" && "$komp" == "k" ) ]]; then
    echo "Gracz wygrywa!"
    wyn_gracz=$((wyn_gracz+1))
  else
    echo "Komputer wygrywa"
    wyn_komp=$((wyn_komp+1))
  fi
done

echo "Punktacja:"
echo "Wynik gracza: ${wyn_gracz}"
echo "Wynik komputera: ${wyn_komp}"
echo "Wynik remisow: ${wyn_rem}"

if [ "${wyn_gracz}" -gt "${wyn_komp}" ]; then
  echo "Wygrywa gracza"
else
  echo "Wygrywa komputer"
fi
