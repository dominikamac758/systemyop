3.0
nano chat_writer.sh
#!/bin/bash
# Skrypt piszący wiadomości do FIFO

FIFO=/tmp/mychat_fifo

# Tworzymy FIFO, jeśli nie istnieje
[ ! -p $FIFO ] && mkfifo $FIFO

echo "Chat Writer uruchomiony. Wpisuj wiadomości:"

while true; do
    read -p "Ty: " msg
    echo "$msg" > $FIFO
done

nano chat_reader.sh
#!/bin/bash
# Skrypt czytający wiadomości z FIFO

FIFO=/tmp/mychat_fifo

# Tworzymy FIFO, jeśli nie istnieje
[ ! -p $FIFO ] && mkfifo $FIFO

echo "Chat Reader uruchomiony, czekam na wiadomości:"

while true; do
    if read msg < $FIFO; then
        echo "On: $msg"
    fi
done


chmod +x chat_writer.sh chat_reader.sh
./chat_reader.sh   # w jednym terminalu
./chat_writer.sh   # w drugim terminalu



4.0 
nano writer.sh
#!/bin/bash
# Skrypt piszący dane do współdzielonego bufora (plik + blokada)

BUFFER=/tmp/shared_buffer.txt

for i in {1..10}; do
    # otwieramy deskryptor i blokujemy plik do zapisu
    exec 200>$BUFFER.lock
    flock -x 200          # blokada wyłączna
    echo "Dane $i" >> $BUFFER
    echo "Writer: zapisano Dane $i"
    flock -u 200
    sleep 1
done

nano reader.sh
#!/bin/bash
# Skrypt czytający dane ze współdzielonego bufora

BUFFER=/tmp/shared_buffer.txt

while true; do
    exec 200>$BUFFER.lock
    flock -s 200          # blokada współdzielona (odczyt)
    if [ -s $BUFFER ]; then
        line=$(head -n1 $BUFFER)
        echo "Reader: $line"
        sed -i '1d' $BUFFER
    fi
    flock -u 200
    sleep 1
done

chmod +x writer.sh reader.sh
./reader.sh &   # w jednym terminalu lub w tle
./writer.sh     # w drugim terminalu

5.0
nano receiver.sh
#!/bin/bash
# Skrypt odbiorcy sygnałów Morse'a

trap 'echo -n "."' USR1
trap 'echo -n "-"' USR2

echo "Receiver gotowy, PID=$$"

while true; do
    sleep 1
done

nano sender.sh
#!/bin/bash
# Skrypt nadawcy Morse'a
TARGET_PID=$1

if [ -z "$TARGET_PID" ]; then
    echo "Użycie: $0 <PID odbiorcy>"
    exit 1
fi

encode_char() {
    local char=$1
    case $char in
        A|a) kill -USR1 $TARGET_PID; sleep 1; kill -USR2 $TARGET_PID; sleep 2 ;;
        B|b) kill -USR2 $TARGET_PID; sleep 1; kill -USR1 $TARGET_PID; sleep 2 ;;
        *) kill -USR1 $TARGET_PID; sleep 1 ;;
    esac
}

read -p "Wpisz wiadomość: " msg
for (( i=0; i<${#msg}; i++ )); do
    encode_char "${msg:$i:1}"
done

terminal a, zapisac pid
chmod +x receiver.sh sender.sh
./receiver.sh

terminal b
./sender.sh <PID_odbiorcy>


Odbiorca – receiver_morse.sh
#!/bin/bash
# Odbiorca Morse'a – dekoduje kropki i kreski w czasie rzeczywistym

# Bufor do dekodowania
decoded_msg=""

# Funkcja dekodująca kropki i kreski na znaki (tylko A i B dla przykładu)
decode_signal() {
    local sig=$1
    case $sig in
        ".-") echo -n "A" ;;
        "-.") echo -n "B" ;;
        *) echo -n "?" ;;
    esac
}

# Obsługa sygnałów
trap 'echo -n "."; decoded_msg="${decoded_msg}."' USR1
trap 'echo -n "-"; decoded_msg="${decoded_msg}-"' USR2

echo "Receiver gotowy, PID=$$"
echo "Odbieranie sygnałów Morse'a..."

# Pętla nieskończona do odbierania sygnałów
while true; do
    sleep 1
done

️Nadawca – sender_morse.sh
#!/bin/bash
# Nadawca Morse'a – wysyła znaki jako sygnały
TARGET_PID=$1

if [ -z "$TARGET_PID" ]; then
    echo "Użycie: $0 <PID odbiorcy>"
    exit 1
fi

# Funkcja zamienia znak na kropki/kreski i wysyła sygnały
send_morse() {
    local char=$1
    case $char in
        A|a) kill -USR1 $TARGET_PID; sleep 1; kill -USR2 $TARGET_PID; sleep 2 ;;
        B|b) kill -USR2 $TARGET_PID; sleep 1; kill -USR1 $TARGET_PID; sleep 2 ;;
        *) kill -USR1 $TARGET_PID; sleep 1 ;;
    esac
}

# Wczytywanie wiadomości od użytkownika
read -p "Wpisz wiadomość (tylko A i B dla przykładu): " msg

# Wysyłanie znak po znaku
for (( i=0; i<${#msg}; i++ )); do
    send_morse "${msg:$i:1}"
done

echo "Wiadomość wysłana."

chmod +x receiver_morse.sh sender_morse.sh
./receiver_morse.sh
./sender_morse.sh <PID_odbiorcy>
